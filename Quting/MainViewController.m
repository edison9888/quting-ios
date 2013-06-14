//
//  MainViewController.m
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "MainViewController.h"
#import "AlbumsView.h"
#import "RequestHelper.h"
#import "ListViewController.h"
#import "ShopViewController.h"
#import "AppUtil.h"
@interface MainViewController ()

@end

@implementation MainViewController {
    UITapGestureRecognizer *tap;
    ListViewController *listView;
    UIButton *searchBtn;
    UIButton *shopBtn;
    int maxCount;
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

- (void)viewWillAppear:(BOOL)animated{
    _scrollView.contentOffset = CGPointMake(0, offsetY);
}

- (void)viewDidDisappear:(BOOL)animated{
    offsetY = _scrollView.contentOffset.y;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    maxCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxCount"];
//    int temp = maxCount/6;
//    maxPage = maxCount%6==0?temp:(temp+1);
    self.navigationItem.title = @"趣 听";
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    
    shopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shopBtn addTarget:self action:@selector(shop) forControlEvents:UIControlEventTouchUpInside];
    shopBtn.frame = CGRectMake(0, 0, 44, 88);
    [shopBtn setImage:imageNamed(@"shopItem.png") forState:UIControlStateNormal];
    UIBarButtonItem *shop = [[UIBarButtonItem alloc] initWithCustomView:shopBtn];
    self.navigationItem.leftBarButtonItem = shop;
    
    searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn addTarget:self action:@selector(convertMode) forControlEvents:UIControlEventTouchUpInside];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:imageNamed(@"searchItem.png") forState:UIControlStateNormal];

    UIButton *configBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [configBtn addTarget:self action:@selector(showConfig) forControlEvents:UIControlEventTouchUpInside];
    configBtn.frame = CGRectMake(44, 0, 44, 44);
    [configBtn setImage:imageNamed(@"configItem.png") forState:UIControlStateNormal];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    rightView.backgroundColor = [UIColor clearColor];
    [rightView addSubview:searchBtn];
    [rightView addSubview:configBtn];
    
    UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = config;
    
    listView = [[ListViewController alloc] initWithModel:ListModel_search];
    listView.view.alpha = 0;
    listView.view.frame = CGRectMake(0, -480, 320, 480);
    [self.view addSubview:listView.view];
    [listView.tableView reloadData];
//    [listView loadDatas:@[@{@"title":@"我的歌声里", @"detailTitle":@"原声带第一首", @"isFav":@(NO), @"duration":@"05:20", @"isCurrent":@(NO)},
//     @{@"title":@"我的歌声里", @"detailTitle":@"原声带第二首", @"isFav":@(YES), @"duration":@"05:50", @"isCurrent":@(NO)},
//     @{@"title":@"我的歌声里", @"detailTitle":@"原声带第三首", @"isFav":@(NO), @"duration":@"04:25", @"isCurrent":@(YES)},
//     @{@"title":@"我的歌声里", @"detailTitle":@"原声带第四首", @"isFav":@(YES), @"duration":@"02:27", @"isCurrent":@(NO)},
//     @{@"title":@"我的歌声里", @"detailTitle":@"原声带第五首", @"isFav":@(NO), @"duration":@"06:32", @"isCurrent":@(NO)},]];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    _scrollView.delegate = self;

    NSString *key = @"api/buys";
    [[RequestHelper defaultHelper] requestGETAPI:key postData:@{@"guest_id": [[NSUserDefaults standardUserDefaults] valueForKey:@"guest"]} success:^(id result) {
        if (result) {
            NSMutableArray *datas = [NSMutableArray array];
            for (NSDictionary *dict in [result valueForKey:@"buys"]) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                for (NSString *key in [tempDict allKeys]) {
                    if ([[tempDict valueForKey:key] isKindOfClass:[NSNull class]]) {
                        [tempDict setValue:@"" forKey:key];
                    }
                }
                [datas addObject:tempDict];
            }
            [datas insertObject:@{@"mtype": @"", @"name": @"我的最爱", @"id": @"-1"} atIndex:0];
            [self loadAlbumsWithDatas:datas];
        }
        
    } failed:nil];

    [self.view addSubview:_scrollView];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"_UIApplicationSystemGestureStateChangedNotification"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [_scrollView setContentOffset:CGPointZero animated:YES];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:PAYMEIDA
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      float size = 115;
                                                      float gap = (320.0-size*2.0)/3.0;
                                                      int i = 0;
                                                      for (AlbumsView *albums in _scrollView.subviews) {
                                                          if ([albums isKindOfClass:[AlbumsView class]]) {
                                                              i++;
                                                          }
                                                      }
                                                      NSDictionary *data = note.object;
                                                        AlbumsView *albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap)+gap/2, size, size) andInfo:data isShop:NO];
                                                        albums.tag = [[data valueForKey:@"id"] intValue];
                                                        [_scrollView addSubview:albums];
                                                      i++;
                                                        int height = i%2==0?((i/2*(size+gap))+gap):((i/2+1)*(size+gap))+gap;
                                                        height = height<=_scrollView.frame.size.height?(_scrollView.frame.size.height+1):height;
//                                                        height = height>maxPage*scrollView.frame.size.height?(maxPage*scrollView.frame.size.height):height;
                                                        _scrollView.contentSize = CGSizeMake(0, height);
                                                  }];
}

- (void)loadAlbumsWithDatas:(NSMutableArray *)datas{
    float size = 115;
    float gap = (320.0-size*2.0)/3.0;
    for (int i=0; i<datas.count; i++) {
        AlbumsView *albums;
        if ([[[datas objectAtIndex:i] valueForKey:@"id"] intValue]==-1) {
            albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap)+gap/2, size, size) andInfo:[datas objectAtIndex:i] isShop:NO];
        } else {
            albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap)+gap/2, size, size) andInfo:[datas objectAtIndex:i] isShop:NO];
        }
        albums.tag = [[[datas objectAtIndex:i] valueForKey:@"id"] intValue];
        [_scrollView addSubview:albums];
    }
    int height = datas.count%2==0?((datas.count/2*(size+gap))+gap):((datas.count/2+1)*(size+gap))+gap;
    height = height<=_scrollView.frame.size.height?(_scrollView.frame.size.height+1):height;
//    height = height>maxPage*scrollView.frame.size.height?(maxPage*scrollView.frame.size.height):height;
    _scrollView.contentSize = CGSizeMake(0, height);
}

- (void)shop{
    if (listView.view.alpha==1) {
        searchBtn.hidden = NO;
        [shopBtn setImage:imageNamed(@"shopItem.png") forState:UIControlStateNormal];
        __block CGRect frame = listView.view.frame;
        frame.origin.y = -listView.view.frame.size.height;
        [UIView animateWithDuration:.3 animations:^{
            listView.view.alpha = 0;
            listView.view.frame = frame;
            frame = _scrollView.frame;
            frame.origin.y = 0;
            _scrollView.frame = frame;
            _scrollView.alpha = 1;
        }];
    } else {
        ShopViewController *shop = [[ShopViewController alloc] init];
        [self.navigationController pushViewController:shop animated:YES];
    }
}

- (void)convertMode{
    if (listView.view.alpha==0) {
        [shopBtn setImage:imageNamed(@"backItem.png") forState:UIControlStateNormal];
        __block CGRect frame = listView.view.frame;
        frame.origin.y = 0;
        [UIView animateWithDuration:.3 animations:^{
            listView.view.alpha = 1;
            listView.view.frame = frame;
            frame = _scrollView.frame;
            frame.origin.y = self.view.frame.size.height;
            _scrollView.frame = frame;
            _scrollView.alpha = 0;
        }];
        searchBtn.hidden = YES;
    } 
}

- (void)showConfig{
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToReturn)];
        [self.view addGestureRecognizer:tap];
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWCONFIG object:@(YES)];
    } else {
        [self tapToReturn];
    }
}

- (void)tapToReturn{
    [[NSNotificationCenter defaultCenter] postNotificationName:BACKTOMAIN object:@(YES)];
    [self removeBackGesture];
}

- (void)removeBackGesture{
    if (tap) {
        [self.view removeGestureRecognizer:tap];
        tap = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
