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

@interface MainViewController ()

@end

@implementation MainViewController {
    UITapGestureRecognizer *tap;
    ListViewController *listView;
    UIButton *searchBtn;
    UIScrollView *scrollView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [listView loadDatas:@[@{@"title":@"我的歌声里", @"detailTitle":@"原声带第一首", @"isFav":@(NO), @"duration":@"05:20", @"isCurrent":@(NO)},
     @{@"title":@"我的歌声里", @"detailTitle":@"原声带第二首", @"isFav":@(YES), @"duration":@"05:50", @"isCurrent":@(NO)},
     @{@"title":@"我的歌声里", @"detailTitle":@"原声带第三首", @"isFav":@(NO), @"duration":@"04:25", @"isCurrent":@(YES)},
     @{@"title":@"我的歌声里", @"detailTitle":@"原声带第四首", @"isFav":@(YES), @"duration":@"02:27", @"isCurrent":@(NO)},
     @{@"title":@"我的歌声里", @"detailTitle":@"原声带第五首", @"isFav":@(NO), @"duration":@"06:32", @"isCurrent":@(NO)},]];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    float size = 115;
    float gap = (320.0-size*2.0)/3.0;
    int count = 7;
    for (int i=0; i<count; i++) {
        AlbumsView *albums = [[AlbumsView alloc] initWithFrame:CGRectMake(gap+(size+gap)*(i%2), i/2*(size+gap)+gap/2, size, size)];
        albums.tag = i;
        if (i>0) {
            albums.label.text = @"曲婉婷";
        }
        [scrollView addSubview:albums];
    }
    size = 120;
    int height = count%2==0?((count/2*(size+gap))+gap):((count/2+1)*(size+gap))+gap;
    height = height<=scrollView.frame.size.height?(scrollView.frame.size.height+1):height;
    scrollView.contentSize = CGSizeMake(0, height);
    [self.view addSubview:scrollView];
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
