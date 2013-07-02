//
//  AlbumsView.m
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AlbumsView.h"
#import <QuartzCore/QuartzCore.h>
#import "PlayViewController.h"
#import "MainViewController.h"
#import "ListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RequestHelper.h"
#import "PayView.h"
#import "UIView+Animation.h"
#import "AppUtil.h"
#define DOWNLOADTAG 123

@implementation AlbumsView {
    UIImageView *cover;
    UIButton *control;
    NSDictionary *dict;
    NSMutableArray *listInfos;
    CircularProgressView *circularProgressView;
    BOOL isShop;
    UIImageView *fav;
    int fixHeight;
    UIButton *download;
}

@synthesize coverImage;

- (UIImage*)imageFromView:(UIView*)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (id)initWithFrame:(CGRect)frame andInfo:(NSDictionary *)info isShop:(BOOL)isShop_
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFav:) name:CHANGEFAV object:nil];
        isShop = isShop_;
        self.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
        self.clipsToBounds = NO;
        if (isShop_) {
            fixHeight = 0;
        } else {
            fixHeight = 50;
        }
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-fixHeight)];
        bg.backgroundColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1];
        bg.layer.cornerRadius = frame.size.width/2;
        bg.clipsToBounds = YES;
        UIImage *temp = [self imageFromView:bg];
        [self addSubview:[[UIImageView alloc] initWithImage:temp]];
        dict = info;
        [self loadView];
    }
    return self;
}

- (void)loadView{
    //set backcolor & progresscolor
    UIColor *backColor = [UIColor whiteColor];
    
    int width = self.frame.size.width-10;
    //alloc CircularProgressView instance
    circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(5, 5, width, width)
                                                                  backColor:backColor
                                                              progressColor:[UIColor grayColor]
                                                                  lineWidth:5];
    //add CircularProgressView
    [self addSubview:circularProgressView];
    NSDictionary *history = [[NSUserDefaults standardUserDefaults] dictionaryForKey:[NSString stringWithFormat:@"history%@%d", [dict valueForKey:@"id"], isShop]];
    if (history!=nil && !isShop) {
        circularProgressView.progress = [[history valueForKey:@"albumsProgress"] floatValue];
    }
    
    cover = [[UIImageView alloc] init];
    cover.image = [UIImage imageNamed:@"thumb"];
    
    __block AlbumsView *blocksafeSelf = self;
    __block UIImageView *blockCover = cover;
//    __block UIImage *blockCoverImage = coverImage;
    if (![@"" isEqualToString:[dict valueForKey:@"mtype"]]) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[dict valueForKey:@"mtype"]]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [cover setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//            blockCoverImage = [image copy];
            blocksafeSelf.coverImage = image;
            blockCover.image = image;
            [blocksafeSelf customCoverView];
        } failure:nil];
    } else {
        [self customCoverView];
    }
    
    if (!isShop) {
        control = [UIButton buttonWithType:UIButtonTypeCustom];
        [control setImage:imageNamed(@"playing.png") forState:UIControlStateNormal];
        [control setImage:imageNamed(@"btn_pause.png") forState:UIControlStateSelected];
        [control addTarget:self action:@selector(manageAudio) forControlEvents:UIControlEventTouchUpInside];
        control.frame = CGRectMake(self.frame.size.width-28, self.frame.size.height-fixHeight-28, 26, 26);
        [self addSubview:control];
    }
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-fixHeight+5, self.frame.size.width, 15)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont boldSystemFontOfSize:15];
    _label.text = [dict valueForKey:@"name"];
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1];
    [self addSubview:_label];
    
    if ([[dict valueForKey:@"id"] intValue]!=-1 && !isShop) {
        download = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height-25, 65, 19)];
        if ([[AudioManager defaultManager] hasLocal:[[dict valueForKey:@"id"] intValue]]) {
            [download setImage:[UIImage imageNamed:@"local.png"] forState:UIControlStateNormal];
            download.userInteractionEnabled = NO;
            listInfos = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"ListInfo%@", [[dict valueForKey:@"id"] stringValue]]];
        } else {
            NSString *cacheRoot = [NSTemporaryDirectory() stringByAppendingPathComponent:[[dict valueForKey:@"id"] stringValue]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:cacheRoot]) {
                [download setImage:[UIImage imageNamed:@"resume_btn.png"] forState:UIControlStateNormal];
            } else {
                [download setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            }
            [download addTarget:self action:@selector(downloadToLocal) forControlEvents:UIControlEventTouchUpInside];
        }
        download.center = CGPointMake(_label.center.x, download.center.y);
        [self addSubview:download];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showDelete:)];
        [self addGestureRecognizer:longPress];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDeleteBtn:) name:@"deleteMode" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeleteBtn:) name:@"normalMode" object:nil];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self addGestureRecognizer:tap];
}

- (void)setTag:(NSInteger)tag{
    if (tag==-1) {
        control.alpha = 0;
    }
    [super setTag:tag];
}

- (void)showDelete:(UILongPressGestureRecognizer *)gesture{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteMode" object:nil];
}

- (void)showDeleteBtn:(NSNotification *)notifi{
    if ([self viewWithTag:100]!=nil) {
        return;
    }
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.values = @[@(.01), @(-.01)];
    rotation.autoreverses = YES;
    rotation.repeatCount = NSIntegerMax;
    rotation.duration = .1;
    [self.layer addAnimation:rotation forKey:@"shake"];
    UIButton *clearView = [UIButton buttonWithType:UIButtonTypeCustom];
    clearView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    clearView.tag = 100;
    [self addSubview:clearView];
    if (!control.hidden) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 40, 40);
        btn.tag = 101;
        [btn setImage:[UIImage imageNamed:@"del_btn.png"] forState:UIControlStateNormal];
        btn.center = CGPointMake(self.frame.size.width-15, 15);
        [btn addTarget:self action:@selector(unPay:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn fadeIn];
    }
}

- (void)removeDeleteBtn:(NSNotification *)notifi{
    [self.layer removeAllAnimations];
    [UIView animateWithDuration:.3 animations:^{
        [self viewWithTag:101].alpha = 0;
    } completion:^(BOOL finished) {
        [[self viewWithTag:100] performSelector:@selector(removeFromSuperview)];
        [[self viewWithTag:101] performSelector:@selector(removeFromSuperview)];
    }];
}

- (void)unPay:(UIButton *)btn{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"取消订阅" message:@"确认取消订阅吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.cancelButtonIndex != buttonIndex) {
        [[RequestHelper defaultHelper] requestDELETEAPI:[NSString stringWithFormat:@"/api/buys/%@", [[dict valueForKey:@"id"] stringValue]] postData:@{@"guest_id": [[NSUserDefaults standardUserDefaults] valueForKey:@"guest"], @"medium_id": [[dict valueForKey:@"id"] stringValue]} success:^(id result) {
            [AppUtil warning:@"取消订阅成功!" withType:m_success];
            [[NSNotificationCenter defaultCenter] postNotificationName:UNPAYMEIDA object:@(self.tag)];
        } failed:nil];
    }
}

- (void)stopDownload{
    control.hidden = NO;
    [[self viewWithTag:DOWNLOADTAG] removeFromSuperview];
    [download setImage:[UIImage imageNamed:@"resume_btn.png"] forState:UIControlStateNormal];
    [ApplicationDelegate.queue cancelAllOperations];
}

- (void)downloadToLocal{
    if (control.hidden) {
        [self stopDownload];
        return;
    }
    control.hidden = YES;
    [download setImage:imageNamed(@"downloading.png") forState:UIControlStateNormal];
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-fixHeight)];
    bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    bg.layer.cornerRadius = self.frame.size.width/2;
    bg.clipsToBounds = YES;
    UIImage *temp = [self imageFromView:bg];
    UIImageView *downloading = [[UIImageView alloc] initWithImage:temp];
    downloading.tag = DOWNLOADTAG;
    [self addSubview:downloading];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-50, 10)];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 3;
    
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-50, 10)];
    blueView.layer.cornerRadius = 3;
    blueView.backgroundColor = [UIColor colorWithRed:76/255.0 green:136/255.0 blue:211/255.0 alpha:1];
    
    whiteView.center = downloading.center;
    blueView.center = downloading.center;
    [downloading addSubview:whiteView];
    [downloading addSubview:blueView];
    CGRect frame = blueView.frame;
    frame.size.width = 0;
    blueView.frame = frame;
        
    [[RequestHelper defaultHelper] requestGETAPI:@"/api/mfiles" postData:@{@"medium_id": [NSString stringWithFormat:@"%d", self.tag]} success:^(id result) {
        NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *rootPath = [documentdir stringByAppendingPathComponent:[[dict valueForKey:@"id"] stringValue]];
        NSString *cacheRoot = [NSTemporaryDirectory() stringByAppendingPathComponent:[[dict valueForKey:@"id"] stringValue]];
        NSArray *datas = [result valueForKey:@"mfiles"];
        [[NSUserDefaults standardUserDefaults] setValue:datas forKey:[NSString stringWithFormat:@"ListInfo%@", [[dict valueForKey:@"id"] stringValue]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        float count = datas.count;
        float realCount = datas.count;
        float partProgress = 100.0/datas.count/100.0;
        int index = 0;
        for (NSDictionary *temp in datas) {
            NSString *url = [NSString stringWithFormat:@"%@/%@", @"http://t.pamakids.com/", [[temp valueForKey:@"url"] stringByReplacingOccurrencesOfString:@"public/" withString:@""]];
            NSString *name = [[url componentsSeparatedByString:@"/"] lastObject];
            NSString *path = [rootPath stringByAppendingPathComponent:name];
            NSString *cachePath = [cacheRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"cache%@", name]];
            NSString *cacheRealPath = [cacheRoot stringByAppendingPathComponent:name];
            BOOL isDir;
            if (!([[NSFileManager defaultManager] fileExistsAtPath:cacheRoot isDirectory:&isDir] && isDir)) {
                [[NSFileManager defaultManager] createDirectoryAtPath:cacheRoot withIntermediateDirectories:NO attributes:nil error:nil];
            }
            NSLog(@"download url:%@", url);
            if ([[NSFileManager defaultManager] fileExistsAtPath:cacheRealPath]) {
                index++;
                count--;
                continue;
            }
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation1.outputStream = [NSOutputStream outputStreamToFileAtPath:cachePath append:NO];
            [operation1 setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                float progress = (totalBytesRead*1.0)/(totalBytesExpectedToRead*1.0);
                float needProgress = partProgress*index+partProgress*progress;
                CGRect frame = blueView.frame;
                frame.size.width = whiteView.frame.size.width*needProgress;
                blueView.frame = frame;
//                NSLog(@"url%@ progress:%f", url, progress);
            }];
            [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"download complet %d count:%f", index+1, count);
                [[NSFileManager defaultManager] moveItemAtPath:cachePath toPath:cacheRealPath error:nil];
                if (index+1==realCount) {
                    NSLog(@"albums download done", nil);
//                    BOOL isDir;
//                    if (!([[NSFileManager defaultManager] fileExistsAtPath:rootPath isDirectory:&isDir] && isDir)) {
//                        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:NO attributes:nil error:nil];
//                    }
//                    [[NSFileManager defaultManager] moveItemAtPath:cacheRoot toPath:rootPath error:nil];
                    if ([[NSFileManager defaultManager] copyItemAtPath:cacheRoot toPath:rootPath error:nil]) {
                        if ([[NSFileManager defaultManager] removeItemAtPath:cacheRoot error:nil]) {
                            control.hidden = NO;
                            [downloading removeFromSuperview];
                            [download setImage:[UIImage imageNamed:@"local.png"] forState:UIControlStateNormal];
                            download.userInteractionEnabled = NO;
                            listInfos = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"ListInfo%@", [[dict valueForKey:@"id"] stringValue]]];
                            if (self.layer.animationKeys.count>0) {
                                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                                btn.frame = CGRectMake(0, 0, 40, 40);
                                btn.tag = 101;
                                [btn setImage:[UIImage imageNamed:@"del_btn.png"] forState:UIControlStateNormal];
                                btn.center = CGPointMake(self.frame.size.width-15, 15);
                                [btn addTarget:self action:@selector(unPay:) forControlEvents:UIControlEventTouchUpInside];
                                [self addSubview:btn];
                                [btn fadeIn];
                            }
                        }
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"download failed", nil);
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }];
            [ApplicationDelegate.queue addOperation:operation1];
            index++;
        }
    } failed:nil];
}

- (void)customCoverView{
    cover.frame = CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.width-20);
    cover.contentMode = UIViewContentModeScaleAspectFill;
    cover.layer.cornerRadius = (self.frame.size.width-20)/2;
    cover.clipsToBounds = YES;

    UIView *blackCover;
    if (!isShop) {
        blackCover = [[UIView alloc] initWithFrame:CGRectMake(-10, self.frame.size.height-fixHeight-40, self.frame.size.width, self.frame.size.height-fixHeight)];
        blackCover.backgroundColor = [UIColor blackColor];
        blackCover.layer.cornerRadius = self.frame.size.width/2;
        blackCover.alpha = .5;
        [cover addSubview:blackCover];
    }
    
    UIImage *temp = [self imageFromView:cover];
    cover.image = temp;
    cover.layer.cornerRadius = 0;
    cover.alpha = .85;
    [self addSubview:cover];
    
    if (!isShop) {
        [blackCover removeFromSuperview];
        if ([[dict valueForKey:@"is_like"] intValue]==1) {
            fav = [[UIImageView alloc] initWithImage:imageNamed(@"fav.png")];
            fav.frame = CGRectMake(blackCover.center.x-7, self.frame.size.height-fixHeight-35, 14, 13);
            [cover addSubview:fav];
        } else {
            fav = [[UIImageView alloc] initWithImage:imageNamed(@"noFav.png")];
            fav.frame = CGRectMake(blackCover.center.x-7, self.frame.size.height-fixHeight-35, 14, 13);
            [cover addSubview:fav];
        }
    }
}

- (void)changeFav:(NSNotification *)notifi{
    if ([notifi.object intValue]!=self.tag) {
        return;
    }
    [dict setValue:[notifi.userInfo valueForKey:@"is_like"] forKey:@"is_like"];
    if ([[notifi.userInfo valueForKey:@"is_like"] intValue]==1) {
        [fav setImage:imageNamed(@"fav.png")];
    } else {
        [fav setImage:imageNamed(@"noFav.png")];
    }
}

- (void)stop{
    cover.alpha = .85;
    control.selected = NO;
}

- (void)manageAudio{
    [[AudioManager defaultManager] clearOtherAlbumsStat:self];
    if ([[AudioManager defaultManager] playing]) {
        [[AudioManager defaultManager] pause];
        [self audioPause];
    } else {
        if ([[AudioManager defaultManager] needURL]) {
            if (listInfos==nil) {
                [[RequestHelper defaultHelper] requestGETAPI:@"/api/mfiles" postData:@{@"medium_id": [NSString stringWithFormat:@"%d", self.tag]} success:^(id result) {
                    listInfos = [result valueForKey:@"mfiles"];
                    NSMutableArray *mp3files = [NSMutableArray array];
                    for (NSDictionary *temp in listInfos) {
                        [mp3files addObject:[NSString stringWithFormat:@"%@/%@", @"http://t.pamakids.com/", [[temp valueForKey:@"url"] stringByReplacingOccurrencesOfString:@"public" withString:@""]]];
                    }
                    [[AudioManager defaultManager] clearAudioList];
                    [[AudioManager defaultManager] addAudioListToList:mp3files];
                    NSDictionary *history = [[NSUserDefaults standardUserDefaults] dictionaryForKey:[NSString stringWithFormat:@"history%@%d", [dict valueForKey:@"id"], isShop]];
                    if (history!=nil) {
                        [[AudioManager defaultManager] playIndex:[[history valueForKey:@"currentIndex"] intValue] withTime:[[history valueForKey:@"time"] floatValue]];
                    } else {
                        [[AudioManager defaultManager] playListAtFirst];
                    }
                    [[AudioManager defaultManager] setCurrentAlbums:self];
                } failed:nil];
            } else {
                NSMutableArray *mp3files = [NSMutableArray array];
                for (NSDictionary *temp in listInfos) {
                    [mp3files addObject:[NSString stringWithFormat:@"%@/%@", @"http://t.pamakids.com/", [[temp valueForKey:@"url"] stringByReplacingOccurrencesOfString:@"public" withString:@""]]];
                }
                [[AudioManager defaultManager] clearAudioList];
                [[AudioManager defaultManager] addAudioListToList:mp3files];
                NSDictionary *history = [[NSUserDefaults standardUserDefaults] dictionaryForKey:[NSString stringWithFormat:@"history%@%d", [dict valueForKey:@"id"], isShop]];
                if (history!=nil) {
                    [[AudioManager defaultManager] playIndex:[[history valueForKey:@"currentIndex"] intValue] withTime:[[history valueForKey:@"time"] floatValue]];
                } else {
                    [[AudioManager defaultManager] playListAtFirst];
                }
            }
        } else {
            [[AudioManager defaultManager] resume];
        }
        [self audioPlay];
    }
}

- (void)recordPlayProgress:(NSNotification *)notifi{
    if (!isShop) {
        NSLog(@"record to %d, with info %@", [[dict valueForKey:@"id"] intValue], [notifi userInfo]);
        [[NSUserDefaults standardUserDefaults] setValue:[notifi userInfo] forKey:[NSString stringWithFormat:@"history%@%d", [dict valueForKey:@"id"], isShop]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)tapView:(UIGestureRecognizer *)gesture{
    cover.alpha = 1;
    if (isShop) {
        PayView *pay = [[PayView alloc] initWithImage:self.coverImage andInfo:dict];
        [self.window addSubview:pay];
        [pay fadeIn];
        return;
    } else {
        if (self.tag == -1) {
            [[AudioManager defaultManager] clearOtherAlbumsStat:nil];
            [[AudioManager defaultManager] setCurrentAlbums:nil];
        } else {
            [[AudioManager defaultManager] clearOtherAlbumsStat:self];
            [[AudioManager defaultManager] setCurrentAlbums:self];
        }
    }
    if (self.tag==-1) {
        [[RequestHelper defaultHelper] requestGETAPI:@"/api/likes" postData:@{@"guest_id": [[NSUserDefaults standardUserDefaults] valueForKey:@"guest"]} success:^(id result) {
            //            if ([[result valueForKey:@"likes"] count]>0) {
            NSMutableArray *tempDatas = [NSMutableArray array];
            for (NSDictionary *temp in [result valueForKey:@"likes"]) {
                [tempDatas addObject:temp];
            }
            ListViewController *list = [[ListViewController alloc] initWithModel:ListModel_fav];
            NSArray *temp = [[NSUserDefaults standardUserDefaults] valueForKey:@"historys"];
            if (temp == nil) {
                temp = @[];
            }
            [list loadDatas:@[tempDatas, temp]];
            [((MainViewController *)self.superview.superview.nextResponder).navigationController pushViewController:list animated:YES];
            //            }
        } failed:nil];
        
    } else {
        NSMutableArray *historys;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"historys"]==nil) {
            historys = [NSMutableArray array];
        } else {
            historys = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"historys"]];
        }
        BOOL has = NO;
        for (NSDictionary *temp in historys) {
            if ([[temp valueForKey:@"id"] intValue] == [[dict valueForKey:@"id"] intValue]) {
                has = YES;
                break;
            }
        }
        if (!has) {
            [historys addObject:dict];
            [[NSUserDefaults standardUserDefaults] setValue:historys forKey:@"historys"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if (listInfos==nil) {
            [[RequestHelper defaultHelper] requestGETAPI:@"/api/mfiles" postData:@{@"medium_id": [NSString stringWithFormat:@"%d", self.tag]} success:^(id result) {
                listInfos = [result valueForKey:@"mfiles"];
                PlayViewController *playViewController = [[PlayViewController alloc] initWithDatas:listInfos andParentData:dict andCover:self.coverImage];
                [((MainViewController *)self.superview.superview.nextResponder).navigationController pushViewController:playViewController animated:YES];
            } failed:nil];
        } else {
            PlayViewController *playViewController = [[PlayViewController alloc] initWithDatas:listInfos andParentData:dict andCover:self.coverImage];
            [((MainViewController *)self.superview.superview.nextResponder).navigationController pushViewController:playViewController animated:YES];
        }
    }
}

- (void)audioProgress:(float)temp{
    circularProgressView.progress = temp;
}

- (void)audioPlay{
    circularProgressView.progressColor =  [UIColor colorWithRed:238.0/255.0 green:55.0/255.0 blue:137.0/255.0 alpha:1.0];
    cover.alpha = 1;
    control.selected = YES;
}

- (void)audioPause{
    circularProgressView.progressColor = [UIColor grayColor];
    cover.alpha = .85;
    control.selected = NO;
}

- (NSString *)localRoot{
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *rootPath = [documentdir stringByAppendingPathComponent:[[dict valueForKey:@"id"] stringValue]];
    return rootPath;
}

-(void)dealloc{
    if ([[AudioManager defaultManager] imCurrentAlbums:self]) {
        [[AudioManager defaultManager] clearAudioList];
        [[AudioManager defaultManager] setCurrentAlbums:nil];
    }
    NSLog(@"dealloc %@", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
