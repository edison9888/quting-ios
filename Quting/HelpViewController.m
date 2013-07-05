//
//  HelpViewController.m
//  Quting
//
//  Created by Johnil on 13-6-25.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController {
    NSString *url;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSString *)url1{
    self = [super init];
    if (self) {
        url = url1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44)];
    if (url) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://quting.fm/help/help.php"]]];
    }
    [self.view addSubview:webView];
    if (!url) {
        self.navigationItem.title = @"帮助";
    } else {
        self.navigationItem.title = @"官方网站";
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:imageNamed(@"backItem.png") forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.navigationItem.leftBarButtonItem = back;
        self.navigationItem.hidesBackButton = YES;
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:imageNamed(@"close_btn.png") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = back;
}

- (void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
