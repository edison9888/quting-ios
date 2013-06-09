//
//  BluetoothViewController.m
//  Quting
//
//  Created by Johnil on 13-6-10.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "BluetoothViewController.h"

@interface BluetoothViewController ()

@end

@implementation BluetoothViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:imageNamed(@"backItem.png") forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.navigationItem.leftBarButtonItem = back;
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.title = @"在汽车中使用";
    }
    return self;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    UIScrollView *scrolview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 369)];
    scrolview.backgroundColor = [UIColor colorWithRed:83/255.0 green:83/255.0 blue:83/255.0 alpha:1];
    scrolview.contentSize = CGSizeMake(320*4, 0);
    scrolview.showsVerticalScrollIndicator = NO;
    scrolview.showsHorizontalScrollIndicator = NO;
    scrolview.pagingEnabled = YES;
    for (int i=0; i<4; i++) {
        UIImageView *page = [[UIImageView alloc] initWithImage:imageNamed(([NSString stringWithFormat:@"page%d.png", i+1]))];
        CGRect frame = page.frame;
        frame.origin.x = i*320;
        page.frame = frame;
        [scrolview addSubview:page];
    }
    [self.view addSubview:scrolview];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:imageNamed(@"backBtn.png") forState:UIControlStateNormal];
    back.frame = CGRectMake(0, 369, 250, 41);
    back.center = CGPointMake(320/2, 369+(self.view.frame.size.height-44-369)/2);
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
