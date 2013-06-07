//
//  MainViewController.m
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "MainViewController.h"
#import "AlbumsView.h"
#import "ListViewController.h"
#import "RequestHelper.h"
@interface MainViewController ()

@end

@implementation MainViewController {
    UITapGestureRecognizer *tap;
    ListViewController *listView;
    UIButton *searchBtn;
    UIScrollView *scrollView;
    int loadPage;
    int maxCount;
    int maxPage;
    dispatch_queue_t loadAlbums_queue;
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
    scrollView.contentOffset = CGPointMake(0, offsetY);
}

- (void)viewDidDisappear:(BOOL)animated{
    offsetY = scrollView.contentOffset.y;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    maxCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxCount"];
    int temp = maxCount/6;
    maxPage = maxCount%6==0?temp:(temp+1);
    loadAlbums_queue = dispatch_queue_create("loadAlbums", nil);
    self.navigationItem.title = @"趣 听";
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];

    searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn addTarget:self action:@selector(convertMode) forControlEvents:UIControlEventTouchUpInside];
    searchBtn.frame = CGRectMake(0, 0, 44, 88);
    [searchBtn setImage:imageNamed(@"searchItem.png") forState:UIControlStateNormal];
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.leftBarButtonItem = search;
    
    UIButton *configBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [configBtn addTarget:self action:@selector(showConfig) forControlEvents:UIControlEventTouchUpInside];
    configBtn.frame = CGRectMake(0, 0, 44, 88);
    [configBtn setImage:imageNamed(@"configItem.png") forState:UIControlStateNormal];
    UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithCustomView:configBtn];
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
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    scrollView.delegate = self;
    
    loadPage = -1;
    [self loadAlbumsWithIndex:1];

    [self.view addSubview:scrollView];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"_UIApplicationSystemGestureStateChangedNotification"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [scrollView setContentOffset:CGPointZero animated:YES];
                                                  }];
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
    if (scrollView_.contentOffset.y+scrollView_.frame.size.height > scrollView_.contentSize.height-scrollView_.frame.size.height*2 && (loadPage<=maxPage-1 || maxPage==0)) {
//        NSLog(@"%d", page);
//        return;
        loadPage++;
        loadPage *= -1;
        [self loadAlbumsWithIndex:loadPage*-1];
    }
}

- (void)loadAlbumsWithIndex:(int)index{
    NSString *key = [NSString stringWithFormat:@"api/media?page=%d", index];
//    NSMutableArray *temp = [[NSUserDefaults standardUserDefaults] valueForKey:key];
//    if (temp!=nil) {
//        [self loadAlbumsWithDatas:temp];
//    }
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
            NSMutableArray *datas = [NSMutableArray arrayWithArray:[result valueForKey:@"media"]];
            if (index==1) {
                [datas insertObject:@{@"mtype": @"", @"name": @"我的最爱", @"id": @"-1"} atIndex:0];
            }
            [self loadAlbumsWithDatas:datas];
        }
        
    } failed:nil];
}

- (void)loadAlbumsWithDatas:(NSMutableArray *)datas{
    float size = 115;
    float gap = (320.0-size*2.0)/3.0;
    int count = datas.count+(loadPage-1)*6+1;
    int start = (loadPage-1)*6+1;
    if (scrollView.subviews.count==0) {
        count--;
        start--;
    }
    int index = 0;
    for (int i=start; i<count; i++) {
        AlbumsView *albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap)+gap/2, size, size) andInfo:@{@"mtype": [[datas objectAtIndex:index] valueForKey:@"mtype"], @"name": [[datas objectAtIndex:index] valueForKey:@"name"]}];
        albums.tag = [[[datas objectAtIndex:index] valueForKey:@"id"] intValue];
        [scrollView addSubview:albums];
        index ++;
    }
    int height = count%2==0?((count/2*(size+gap))+gap):((count/2+1)*(size+gap))+gap;
    height = height<=scrollView.frame.size.height?(scrollView.frame.size.height+1):height;
    height = height>maxPage*scrollView.frame.size.height?(maxPage*scrollView.frame.size.height):height;
    scrollView.contentSize = CGSizeMake(0, height);
}

- (void)convertMode{
    if (listView.view.alpha==0) {
        [searchBtn setImage:imageNamed(@"backItem.png") forState:UIControlStateNormal];
        __block CGRect frame = listView.view.frame;
        frame.origin.y = 0;
        [UIView animateWithDuration:.3 animations:^{
            listView.view.alpha = 1;
            listView.view.frame = frame;
            frame = scrollView.frame;
            frame.origin.y = self.view.frame.size.height;
            scrollView.frame = frame;
            scrollView.alpha = 0;
        }];
    } else {
        [searchBtn setImage:imageNamed(@"searchItem.png") forState:UIControlStateNormal];
        __block CGRect frame = listView.view.frame;
        frame.origin.y = -listView.view.frame.size.height;
        [UIView animateWithDuration:.3 animations:^{
            listView.view.alpha = 0;
            listView.view.frame = frame;
            frame = scrollView.frame;
            frame.origin.y = 0;
            scrollView.frame = frame;
            scrollView.alpha = 1;
        }];
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
