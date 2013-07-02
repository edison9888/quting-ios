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
    UIButton *searchBtn;
    UIButton *shopBtn;
    UIButton *configBtn;
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
    [searchBtn addTarget:self action:@selector(openSearch) forControlEvents:UIControlEventTouchUpInside];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:imageNamed(@"searchItem.png") forState:UIControlStateNormal];

    configBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [configBtn addTarget:self action:@selector(showConfig) forControlEvents:UIControlEventTouchUpInside];
    configBtn.frame = CGRectMake(44, 0, 44, 44);
    [configBtn setImage:imageNamed(@"configItem.png") forState:UIControlStateNormal];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    rightView.backgroundColor = [UIColor clearColor];
    [rightView addSubview:searchBtn];
    [rightView addSubview:configBtn];
    
    UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = config;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    _scrollView.delegate = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollView)];
    [self.view addGestureRecognizer:tapGesture];

    NSString *key = @"api/buys";
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:@"guest"];
    userID = userID==nil?@"":userID;
    [[RequestHelper defaultHelper] requestGETAPI:key postData:@{@"guest_id": userID} success:^(id result) {
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
            [[NSUserDefaults standardUserDefaults] setValue:datas forKey:@"buysData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self loadAlbumsWithDatas:datas];
        }
        
    } failed:^(id result, NSError *error) {
        [AppUtil warning:@"请检查网络连接" withType:m_error];
        NSMutableArray *datas = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"buysData"]];
        if (datas.count==0) {
            [datas insertObject:@{@"mtype": @"", @"name": @"我的最爱", @"id": @"-1"} atIndex:0];
        }
        [self loadAlbumsWithDatas:datas];
    }];

    [self.view addSubview:_scrollView];
//    [[NSNotificationCenter defaultCenter] addObserverForName:@"_UIApplicationSystemGestureStateChangedNotification"
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification *note) {
//                                                      [_scrollView setContentOffset:CGPointZero animated:YES];
//                                                  }];
    
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
                                                      NSArray *local = [[NSUserDefaults standardUserDefaults] valueForKey:@"buysData"];
                                                      NSMutableArray *datas = [NSMutableArray arrayWithArray:local];
                                                      [datas addObject:data];
                                                      [[NSUserDefaults standardUserDefaults] setValue:datas forKey:@"buysData"];
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                        AlbumsView *albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap+40)+gap/2, size, size+50) andInfo:data isShop:NO];
                                                        albums.tag = [[data valueForKey:@"id"] intValue];
                                                        [_scrollView addSubview:albums];
                                                      i++;
                                                      int height = i%2==0?((i/2*(size+gap+40))+gap):((i/2+1)*(size+gap+40))+gap;
                                                      height = height<=_scrollView.frame.size.height?(_scrollView.frame.size.height+1):height;
                                                      _scrollView.contentSize = CGSizeMake(0, height);
                                                      [datas removeAllObjects];
                                                      datas = nil;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UNPAYMEIDA
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [UIView animateWithDuration:.3 animations:^{
                                                          int tag = [note.object intValue];
                                                          BOOL beginMove = NO;
                                                          int index = 0;
                                                          float size = 115;
                                                          float gap = (320.0-size*2.0)/3.0;
                                                          for (AlbumsView *albums in _scrollView.subviews) {
                                                              if (![albums isKindOfClass:[AlbumsView class]]) {
                                                                  continue;
                                                              }
                                                              if (albums.tag==tag) {
                                                                  [albums removeFromSuperview];
                                                                  beginMove = YES;
                                                                  index++;
                                                                  continue;
                                                              }
                                                              if (beginMove) {
                                                                  CGRect frame = albums.frame;
                                                                  frame.origin.x = gap+(size+gap)*((index-1)%2);
                                                                  frame.origin.y = (index-1)/2*(size+gap+40)+gap/2;
                                                                  albums.frame = frame;
                                                              }
                                                              index ++;
                                                          }
                                                          index -= 1;
                                                          int height = index%2==0?((index/2*(size+gap+40))+gap):((index/2+1)*(size+gap+40))+gap;
                                                          height = height<=_scrollView.frame.size.height?(_scrollView.frame.size.height+1):height;
                                                          _scrollView.contentSize = CGSizeMake(0, height);
                                                      }];
                                                  }];

}

- (void)tapScrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"normalMode" object:nil];
}

- (void)loadAlbumsWithDatas:(NSMutableArray *)datas{
    float size = 115;
    float gap = (320.0-size*2.0)/3.0;
    for (int i=0; i<datas.count; i++) {
        AlbumsView *albums;
        if ([[[datas objectAtIndex:i] valueForKey:@"id"] intValue]==-1) {
            albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap+40)+gap/2, size, size+50) andInfo:[datas objectAtIndex:i] isShop:NO];
        } else {
            albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap+40)+gap/2, size, size+50) andInfo:[datas objectAtIndex:i] isShop:NO];
        }
        albums.tag = [[[datas objectAtIndex:i] valueForKey:@"id"] intValue];
        [_scrollView addSubview:albums];
    }
    int height = datas.count%2==0?((datas.count/2*(size+gap+40))+gap):((datas.count/2+1)*(size+gap+40))+gap;
    height = height<=_scrollView.frame.size.height?(_scrollView.frame.size.height+1):height;
    _scrollView.contentSize = CGSizeMake(0, height);
}

- (void)shop{
    ShopViewController *shop = [[ShopViewController alloc] init];
    [self.navigationController pushViewController:shop animated:YES];
}

- (void)openSearch{
    ListViewController *listView = [[ListViewController alloc] initWithModel:ListModel_search];
    [self.navigationController pushViewController:listView animated:YES];
}

- (void)showConfig{
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOWCONFIG object:@(YES)];
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
