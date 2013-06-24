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
#import "CategoryListView.h"
@interface ShopViewController ()

@end

@implementation ShopViewController {
    UIScrollView *scrollView;
    float offsetY;
    NSMutableDictionary *loadHistory;
    CategoryView *cate;
    NSMutableArray *categories;
    int currentCate;
    NSMutableArray *cateViewArr;
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
    cateViewArr = [[NSMutableArray alloc] init];
    loadHistory = [[NSMutableDictionary alloc] init];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:imageNamed(@"backItem.png") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.hidesBackButton = YES;

    self.navigationItem.title = @"商 店";
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:imageNamed(@"category.png")];
    [self.view addSubview:bg];

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 48, self.view.frame.size.width, self.view.frame.size.height-44-48)];
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    [[RequestHelper defaultHelper] requestGETAPI:@"/api/categories" postData:nil success:^(id result) {
        categories = [[NSMutableArray alloc] init];
        for (NSDictionary *temp in [result valueForKey:@"categories"]) {
            [categories addObject:[temp valueForKey:@"name"]];
            [cateViewArr addObject:[NSNull null]];
        }
        cate = [[CategoryView alloc] initWithNames:categories];
        cate.loadDelegate = self;
        [self.view addSubview:cate];
        [self loadDataWithPage:0];
        [self loadDataWithPage:1];
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*categories.count, 0);
    } failed:^(id result, NSError *error) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page<0) {
        return;
    }
    [cate changeToIndex:page+1];
    [self loadDataWithPage:page];
    [self loadDataWithPage:page+1];
}

- (void)loadDataWithPage:(int)page{
    if (page<0||page>cateViewArr.count-1) {
        return;
    }
    if ([cateViewArr objectAtIndex:page]==[NSNull null]) {
        CategoryListView *cateView = [[CategoryListView alloc] initWithFrame:CGRectMake(page*scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height) andCategory:[categories objectAtIndex:page]];
        [cateViewArr replaceObjectAtIndex:page withObject:cateView];
        [scrollView addSubview:cateView];
    }
}

- (void)loadListWithIndex:(int)index{
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*(index-1), 0) animated:YES];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
