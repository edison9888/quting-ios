	//
//  ShopViewController.m
//  Quting
//
//  Created by Johnil on 13-6-9.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "ShopViewController.h"
#import "AlbumsView.h"
#import "RequestHelper.h"
#import "AudioManager.h"
@interface ShopViewController ()

@end

@implementation ShopViewController {
    UIScrollView *scrollView;
    int loadPage;
    int maxCount;
    int maxPage;
    float offsetY;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated{
    [[AudioManager defaultManager] clearAudioList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:imageNamed(@"backItem.png") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.hidesBackButton = YES;

    maxCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxCount"];
    int temp = maxCount/6;
    maxPage = maxCount%6==0?temp:(temp+1);
    self.navigationItem.title = @"商 店";
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    scrollView.delegate = self;
    
    loadPage = -1;
    [self loadAlbumsWithIndex:1];
    
    [self.view addSubview:scrollView];
//    [[NSNotificationCenter defaultCenter] addObserverForName:@"_UIApplicationSystemGestureStateChangedNotification"
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification *note) {
//                                                      [scrollView setContentOffset:CGPointZero animated:YES];
//                                                  }];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_{
    if (loadPage<0) {
        return;
    }
    CGFloat pageHeight = scrollView.frame.size.height;
    int page = floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    if (page<0) {
        return;
    }
    if (scrollView_.contentOffset.y+scrollView_.frame.size.height > scrollView_.contentSize.height-scrollView_.frame.size.height && (loadPage<=maxPage-1 || maxPage==0)) {
        //        NSLog(@"%d", page);
        //        return;
        loadPage++;
        loadPage *= -1;
        [self loadAlbumsWithIndex:loadPage*-1];
    }
}

- (void)loadAlbumsWithIndex:(int)index{
    NSString *key = [NSString stringWithFormat:@"api/media?page=%d", index];
    NSMutableArray *temp = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:key]];
    if (temp!=nil && temp.count>0) {
        loadPage *= -1;
        [self loadAlbumsWithDatas:temp];
        return;
    }
    [[RequestHelper defaultHelper] requestGETAPI:key postData:nil success:^(id result) {
        if (result) {
            int tempMax = [[result valueForKey:@"count"] intValue];
            if (maxCount==0) {
                if (tempMax!=maxCount) {
                    maxCount = tempMax;
                    [[NSUserDefaults standardUserDefaults] setInteger:maxCount forKey:@"maxCount"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    int temp = maxCount/6;
                    maxPage = maxCount%6==0?temp:(temp+1);
                }
            }
            loadPage *= -1;
            NSMutableArray *datas = [NSMutableArray array];
            for (NSDictionary *dict in [result valueForKey:@"media"]) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                for (NSString *key in [tempDict allKeys]) {
                    if ([[tempDict valueForKey:key] isKindOfClass:[NSNull class]]) {
                        [tempDict setValue:@"" forKey:key];
                    }
                }
                [datas addObject:tempDict];
            }
            [[NSUserDefaults standardUserDefaults] setValue:datas forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self loadAlbumsWithDatas:datas];
        }
        
    } failed:nil];
}

- (void)loadAlbumsWithDatas:(NSMutableArray *)datas{
    float size = 115;
    float gap = (320.0-size*2.0)/3.0;
    int count = datas.count+(loadPage-1)*6;
    int start = (loadPage-1)*6;
    int index = 0;
    for (int i=start; i<count; i++) {
        AlbumsView *albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap)+gap/2, size, size) andInfo:[datas objectAtIndex:index] isShop:YES];
        albums.tag = [[[datas objectAtIndex:index] valueForKey:@"id"] intValue];
        [scrollView addSubview:albums];
        index ++;
    }
    int height = count%2==0?((count/2*(size+gap))+gap):((count/2+1)*(size+gap))+gap;
    height = height<=scrollView.frame.size.height?(scrollView.frame.size.height+1):height;
    height = height>maxPage*scrollView.frame.size.height?(maxPage*scrollView.frame.size.height):height;
    scrollView.contentSize = CGSizeMake(0, height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
