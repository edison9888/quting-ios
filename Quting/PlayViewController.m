//
//  PlayViewController.m
//  Quting
//
//  Created by Johnil on 13-5-30.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "PlayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "BluetoothViewController.h"
#import "RequestHelper.h"
#import "AppUtil.h"
@interface PlayViewController ()

@end

@implementation PlayViewController {
    UISlider *slider;
    UIButton *pre;
    UIButton *play;
    UIButton *next;
    UILabel *currentTime;
    UILabel *totalTime;
    
    UIView *coverView;
    ListViewController *listView;
    UIButton *listBtn;
    
    NSArray *datas;
    NSDictionary *dict;
    UIImage *coverImage;
    UILabel *detailTitle;
    NSMutableArray *tempDatas;
}

- (id)initWithDatas:(NSArray *)datas_ andParentData:(NSDictionary *)dict_ andCover:(UIImage *)img{
    self = [super init];
    if (self) {
        datas = datas_;
        dict = dict_;
        coverImage = img;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlay) name:AudioPlayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPause) name:AudioPauseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioNext) name:AudioNextNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPre) name:AudioPreNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioProgress:) name:AudioProgressNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
//    NSString *audioPath = @"http://tome-file.b0.upaiyun.com/Inmysong.mp3";
//    [[AudioManager defaultManager] playWithURL:audioPath];
    int height = self.view.frame.size.height-200;
    
    listView = [[ListViewController alloc] initWithModel:ListModel_play];
    listView.view.alpha = 0;
    listView.view.frame = CGRectMake(0, 0, 320, height+50);
    [self.view addSubview:listView.view];
    tempDatas = [[NSMutableArray alloc] init];
    NSMutableArray *mp3List = [NSMutableArray array];
    for (NSDictionary *temp in datas) {
        [tempDatas addObject:@{@"title":[dict valueForKey:@"name"], @"detailTitle": [temp valueForKey:@"name"], @"isFav":@(NO), @"duration":[temp valueForKey:@"time"]}];
        [mp3List addObject:[NSString stringWithFormat:@"%@/%@", @"http://t.pamakids.com/", [[temp valueForKey:@"url"] stringByReplacingOccurrencesOfString:@"public" withString:@""]]];
    }
    BOOL temp = NO;
    float progress = 0;
    float currentPlayTime = 0;
    if ([[AudioManager defaultManager] needURL]) {
        [[AudioManager defaultManager] clearAudioList];
        if (mp3List.count>0) {
            [[AudioManager defaultManager] addAudioListToList:mp3List];
            NSDictionary *history = [[NSUserDefaults standardUserDefaults] dictionaryForKey:[NSString stringWithFormat:@"history%@", [dict valueForKey:@"id"]]];
            if (history!=nil) {
                progress = [[history valueForKey:@"progress"] floatValue];
                currentPlayTime = [[history valueForKey:@"time"] floatValue];
                [[AudioManager defaultManager] playIndex:[[history valueForKey:@"currentIndex"] intValue] withTime:[[history valueForKey:@"time"] floatValue]];
            } else {
                [[AudioManager defaultManager] playListAtFirst];
            }
        }
        temp = YES;
    }

    if (tempDatas.count<=0) {
        [AppUtil warning:@"未找到数据" withType:m_error];
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:.5];
        return;
    }
    [listView loadDatas:tempDatas];
    
    if (coverImage==nil) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[dict valueForKey:@"mtype"]]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        UIImageView *cover = [[UIImageView alloc] init];
        [cover setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            coverImage = image;
            [self addCover:[[tempDatas objectAtIndex:0] valueForKey:@"detailTitle"]];
        } failure:nil];

    } else {
        [self addCover:[[tempDatas objectAtIndex:0] valueForKey:@"detailTitle"]];
    }
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(15, height+10, 290, 24)];
    [slider setMaximumValue:1];
    [slider setMinimumValue:0];
    slider.backgroundColor = [UIColor clearColor];
    [slider setMinimumTrackImage:imageNamed(@"slider-min.png") forState:UIControlStateNormal];
    [slider setMaximumTrackImage:imageNamed(@"slider-max.png") forState:UIControlStateNormal];
    [slider setThumbImage:imageNamed(@"slider-btn.png") forState:UIControlStateNormal];
    [slider setThumbImage:imageNamed(@"slider-btn.png") forState:UIControlStateHighlighted];
    [slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    //滑块拖动时的事件
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    //滑动拖动后的事件
    [slider addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    slider.enabled = ![[AudioManager defaultManager] needURL];
    slider.value = progress;
    [self.view addSubview:slider];
    
    currentTime = [[UILabel alloc] initWithFrame:CGRectMake(20, height+40, 150, 15)];
    currentTime.font = [UIFont systemFontOfSize:12];
    currentTime.text = @"00:00";
    currentTime.backgroundColor = [UIColor clearColor];
    currentTime.textColor = [UIColor colorWithRed:83/255.0 green:83/255.0 blue:83/255.0 alpha:1];
    [self.view addSubview:currentTime];
    
    totalTime = [[UILabel alloc] initWithFrame:CGRectMake(160, height+40, 145, 15)];
    totalTime.font = [UIFont systemFontOfSize:12];
    totalTime.backgroundColor = [UIColor clearColor];
    totalTime.text = @"00:00";
    totalTime.textAlignment = NSTextAlignmentRight;
    totalTime.textColor = [UIColor colorWithRed:83/255.0 green:83/255.0 blue:83/255.0 alpha:1];
    [self.view addSubview:totalTime];
    
    int duration = [[AudioManager defaultManager] duration];
    totalTime.text = [NSString stringWithFormat:@"%02d:%02d", duration/60, duration%60];
    int currentPlaybackTime = currentPlayTime;
    currentTime.text = [NSString stringWithFormat:@"%02d:%02d", currentPlaybackTime/60, currentPlaybackTime%60];
    slider.value = [[AudioManager defaultManager] progress];
    
    pre = [UIButton buttonWithType:UIButtonTypeCustom];
    play = [UIButton buttonWithType:UIButtonTypeCustom];
    next = [UIButton buttonWithType:UIButtonTypeCustom];
    [pre setImage:imageNamed(@"pre.png") forState:UIControlStateNormal];
    [play setImage:imageNamed(@"play.png") forState:UIControlStateNormal];
    [play setImage:imageNamed(@"pause.png") forState:UIControlStateSelected];
    [next setImage:imageNamed(@"next.png") forState:UIControlStateNormal];
    next.enabled = [[AudioManager defaultManager] hasNext];
    pre.enabled = [[AudioManager defaultManager] hasPre];
    [pre addTarget:self action:@selector(preAudio) forControlEvents:UIControlEventTouchUpInside];
    [play addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
    [next addTarget:self action:@selector(nextAudio) forControlEvents:UIControlEventTouchUpInside];
    pre.frame = CGRectMake(0, 0, 56, 56);
    next.frame = CGRectMake(0, 0, 56, 56);
    play.frame = CGRectMake(0, 0, 76, 76);
    NSLog(@"height:%f", self.view.frame.size.height);
    pre.center = CGPointMake(64, self.view.frame.size.height-100);
    play.center = CGPointMake(165, self.view.frame.size.height-100);
    next.center = CGPointMake(260, self.view.frame.size.height-100);
    play.selected = temp?temp:[[AudioManager defaultManager] playing];
    [self.view addSubview:pre];
    [self.view addSubview:play];
    [self.view addSubview:next];
    
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    rightView.backgroundColor = [UIColor clearColor];
    
    listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    listBtn.frame = CGRectMake(44, 0, 44, 44);
    [listBtn setImage:imageNamed(@"listItem.png") forState:UIControlStateNormal];
    [listBtn addTarget:self action:@selector(covertMode) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *blueTooth = [UIButton buttonWithType:UIButtonTypeCustom];
    [blueTooth setImage:imageNamed(@"bluetooth.png") forState:UIControlStateNormal];
    [blueTooth addTarget:self action:@selector(showTutorails) forControlEvents:UIControlEventTouchUpInside];
    blueTooth.frame = CGRectMake(0, 0, 44, 44);
    [rightView addSubview:blueTooth];
    [rightView addSubview:listBtn];
    
    UIBarButtonItem *listItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = listItem;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:imageNamed(@"backItem.png") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = [dict valueForKey:@"name"];
}

- (void)addCover:(NSString *)name{
    int size = isiPhone5?270:230;
    coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    coverView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:coverView atIndex:0];
    
    UIView *coverBG = [[UIView alloc] initWithFrame:CGRectMake(15-5, (isiPhone5?30:15)-5, size+10, size+10)];
    coverBG.backgroundColor = [UIColor whiteColor];
    coverBG.center = CGPointMake(self.view.center.x, coverBG.center.y);
    coverBG.layer.cornerRadius = (size+10)/2;
    
    UIView *smallCoverBG = [[UIView alloc] initWithFrame:CGRectMake(coverBG.frame.origin.x+coverBG.frame.size.width-70, coverBG.frame.origin.y+coverBG.frame.size.height-70, 60, 60)];
    smallCoverBG.backgroundColor = [UIColor whiteColor];
    smallCoverBG.layer.cornerRadius = 30;
    [coverView addSubview:smallCoverBG];
    
    [coverView addSubview:coverBG];
    
    UIImageView *cover = [[UIImageView alloc] initWithImage:coverImage];
    cover.frame = CGRectMake(5, 5, size, size);
    //    cover.center = coverBG.center;
    cover.contentMode = UIViewContentModeScaleAspectFill;
    cover.clipsToBounds = YES;
    cover.layer.cornerRadius = size/2;
    [coverBG addSubview:cover];
    
    UIView *smallCover1 = [[UIView alloc] initWithFrame:CGRectMake(smallCoverBG.frame.origin.x+4, smallCoverBG.frame.origin.y+4, smallCoverBG.frame.size.width-8, smallCoverBG.frame.size.height-8)];
    smallCover1.backgroundColor = [UIColor whiteColor];
    smallCover1.layer.cornerRadius = (smallCoverBG.frame.size.height-10)/2;
    smallCover1.clipsToBounds = YES;
    [coverView addSubview:smallCover1];
    
    UIView *smallCover = [[UIView alloc] initWithFrame:CGRectMake(smallCoverBG.frame.origin.x+5, smallCoverBG.frame.origin.y+5, smallCoverBG.frame.size.width-10, smallCoverBG.frame.size.height-10)];
    smallCover.backgroundColor = [UIColor whiteColor];
    smallCover.layer.cornerRadius = (smallCoverBG.frame.size.height-10)/2;
    smallCover.clipsToBounds = YES;
    [coverView addSubview:smallCover];
    
    UIImageView *cover2 = [[UIImageView alloc] initWithImage:coverImage];
    cover2.frame = CGRectMake(coverBG.frame.origin.x-smallCover.frame.origin.x+5, coverBG.frame.origin.y-smallCover.frame.origin.y+5, size, size);
    cover2.contentMode = UIViewContentModeScaleAspectFill;
    cover2.alpha = .8;
    [smallCover addSubview:cover2];
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, coverBG.frame.origin.y+coverBG.frame.size.height-16, 110, 16)];
    title.backgroundColor = [UIColor clearColor];
    title.text = [dict valueForKey:@"name"];
    title.font = [UIFont boldSystemFontOfSize:14];
    title.textColor = [UIColor colorWithRed:49/255.0 green:49/255.0 blue:49/255.0 alpha:1];
    [coverView addSubview:title];
    
    detailTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, coverBG.frame.origin.y+coverBG.frame.size.height+3, 150, 9)];
    detailTitle.backgroundColor = [UIColor clearColor];
    detailTitle.text = name;
    detailTitle.font = [UIFont boldSystemFontOfSize:9];
    detailTitle.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1];
    [coverView addSubview:detailTitle];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(addFav:) forControlEvents:UIControlEventTouchUpInside];
    if ([[dict valueForKey:@"is_like"] intValue]==1) {
        btn.tag = 1;
        [btn setImage:imageNamed(@"fav_play.png") forState:UIControlStateNormal];
    } else {
        btn.tag = -1;
        [btn setImage:imageNamed(@"unFav_play.png") forState:UIControlStateNormal];
    }
    btn.frame = CGRectMake(coverBG.frame.origin.x+coverBG.frame.size.width-28, coverBG.frame.origin.y+coverBG.frame.size.height-26, 28, 26);
    btn.center = smallCoverBG.center;
    [coverView addSubview:btn];
//    UIImageView *heart = [[UIImageView alloc] initWithImage:imageNamed(@"noFav.png")];
//    heart.frame = CGRectMake(18, 20, 14, 13);
//    [smallCover addSubview:heart];
}

- (void)addFav:(UIButton *)btn{
    if (btn.tag==-1) {
        [[RequestHelper defaultHelper] requestPOSTAPI:@"/api/likes" postData:@{@"like[guest_id]": [[NSUserDefaults standardUserDefaults] valueForKey:@"guest"], @"like[medium_id]": [[dict valueForKey:@"id"] stringValue]} success:^(id result) {
            NSLog(@"result:%@", result);
            [AppUtil warning:@"收藏成功!" withType:m_success];
            [btn setImage:imageNamed(@"fav_play.png") forState:UIControlStateNormal];
            btn.tag = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEFAV object:[dict valueForKey:@"id"] userInfo:@{@"is_like": @(1)}];
        } failed:nil];
    } else {
        [[RequestHelper defaultHelper] requestGETAPI:@"api/likes/cancel" postData:@{@"medium_id": [[dict valueForKey:@"id"] stringValue], @"guest_id": [[NSUserDefaults standardUserDefaults] valueForKey:@"guest"]} success:^(id result) {
            [AppUtil warning:@"取消收藏成功!" withType:m_success];
            [btn setImage:imageNamed(@"unFav_play.png") forState:UIControlStateNormal];
            btn.tag = -1;
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGEFAV object:[dict valueForKey:@"id"] userInfo:@{@"is_like": @(-1)}];
        } failed:nil];
    }
}

- (void)showTutorails{
    BluetoothViewController *bluetooth = [[BluetoothViewController alloc] init];
    [self.navigationController pushViewController:bluetooth animated:YES];
}

- (void)covertMode{
    [UIView animateWithDuration:.3 animations:^{
        if (listView.view.alpha==0) {
            [listBtn setImage:imageNamed(@"coverModeItem.png") forState:UIControlStateNormal];
            listView.view.alpha = 1;
            coverView.alpha = 0;
        } else {
            [listBtn setImage:imageNamed(@"listItem.png") forState:UIControlStateNormal];
            listView.view.alpha = 0;
            coverView.alpha = 1;
        }
    }];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)preAudio{
    slider.enabled = NO;
    NSLog(@"pre");
    [[AudioManager defaultManager] pre];
}

- (void)playAudio{
    if ([[AudioManager defaultManager] needURL]) {
        [[AudioManager defaultManager] playListAtFirst];
        NSLog(@"init audio");
    }
    play.selected = [[AudioManager defaultManager] changeStat];
}

- (void)nextAudio{
    slider.enabled = NO;
    NSLog(@"next");
    [[AudioManager defaultManager] next];
}

- (void)checkSlider{
    if (slider.value>=1) {
        slider.enabled = NO;
        slider.value = 0;
        [self audioProgress:0];
        play.selected = NO;
    }
}

#pragma mark - audio notification

- (void)audioProgress:(NSNotification *)notifi{
    float progress = [notifi.object floatValue];
    [self progress:progress];
}

- (void)progress:(float)progress{
    if (!slider.enabled) {
        slider.enabled = YES;
    }
    if ([totalTime.text isEqualToString:@"00:00"]) {
        int duration = [[AudioManager defaultManager] duration];
        totalTime.text = [NSString stringWithFormat:@"%02d:%02d", duration/60, duration%60];
    }
    int currentPlaybackTime = progress*[[AudioManager defaultManager] duration];
    if (currentPlaybackTime>0) {
        currentTime.text = [NSString stringWithFormat:@"%02d:%02d", currentPlaybackTime/60, currentPlaybackTime%60];
    }
    if (progress!=0) {
        slider.value = progress;
    }
    [self checkSlider];
}

- (void)audioPlay{
    play.selected = YES;
}

- (void)audioPause{
    play.selected = NO;
}

- (void)audioPre{
    pre.enabled = [[AudioManager defaultManager] hasPre];
    next.enabled = [[AudioManager defaultManager] hasNext];
    detailTitle.text = [[tempDatas objectAtIndex:[[AudioManager defaultManager] currentIndex]] valueForKey:@"detailTitle"];
}

- (void)audioNext{
    pre.enabled = [[AudioManager defaultManager] hasPre];
    next.enabled = [[AudioManager defaultManager] hasNext];
    detailTitle.text = [[tempDatas objectAtIndex:[[AudioManager defaultManager] currentIndex]] valueForKey:@"detailTitle"];
}

- (void)sliderValueChanged:(UISlider *)slider1{
//    NSLog(@"slider change:%f", slider.value);
    [[AudioManager defaultManager] skipTo:slider.value];
    [self checkSlider];
}

- (void)sliderDragUp:(UISlider *)slider1{
    NSLog(@"slider up:%f", slider.value);
    if (![[AudioManager defaultManager] playing]) {
        [[AudioManager defaultManager] resume];
    }
    [self progress:slider1.value];
    [self performSelector:@selector(resume) withObject:nil afterDelay:.8];
}

- (void)resume{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlay) name:AudioPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPause) name:AudioPauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioNext) name:AudioNextNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPre) name:AudioPreNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioProgress:) name:AudioProgressNotification object:nil];
}

- (void)sliderTouchDown:(UISlider *)slider1{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *temp in self.navigationController.viewControllers) {
        if ([temp isKindOfClass:NSClassFromString(@"ListViewController")]) {
            [arr removeObject:temp];
        }
    }
    self.navigationController.viewControllers = arr;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlay) name:AudioPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPause) name:AudioPauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioNext) name:AudioNextNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPre) name:AudioPreNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioProgress:) name:AudioProgressNotification object:nil];
}

- (void)dealloc{
    NSLog(@"playview dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
