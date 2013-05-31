//
//  RootViewController.m
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "RootViewController.h"
#import "MainViewController.h"
#import "ConfigViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController {
    PaperFoldView *paperFoldView;
    UINavigationController *navigationController;
    
    MainViewController *main;
    ConfigViewController *config;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    main = [[MainViewController alloc] init];
    main.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    config = [[ConfigViewController alloc] initWithStyle:UITableViewStylePlain];
    config.view.frame = CGRectMake(0, 0, 280, self.view.frame.size.height);
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:main];
    navigationController.delegate = self;
    navigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [navigationController.navigationBar setBackgroundImage:imageNamed(@"navi_background.png") forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.clipsToBounds = YES;
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                UITextAttributeTextColor: [UIColor whiteColor],
                          UITextAttributeTextShadowColor: [UIColor colorWithRed:70.0/255.0 green:153.0/255.0 blue:121.0/255.0 alpha:1.0],
                         UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]
     }];

    paperFoldView = [[PaperFoldView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width,[self.view bounds].size.height)];
    paperFoldView.delegate = self;
    [self.view addSubview:paperFoldView];
    
    [paperFoldView setCenterContentView:navigationController.view];
    
    [paperFoldView setRightFoldContentView:config.view foldCount:2 pullFactor:.9];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConfigView:) name:SHOWCONFIG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMainView:) name:BACKTOMAIN object:nil];
}

- (void)navigationController:(UINavigationController *)navigationController_ didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:NSClassFromString(@"MainViewController")]) {
        for (UIGestureRecognizer *temp in paperFoldView.contentView.gestureRecognizers) {
            temp.enabled = YES;
        }
    } else {
        for (UIGestureRecognizer *temp in paperFoldView.contentView.gestureRecognizers) {
            temp.enabled = NO;
        }
    }
}

- (void)showConfigView:(NSNotification *)notifi{
    BOOL isAnimation = NO;
    if (notifi.object) {
        isAnimation = [notifi.object boolValue];
    }
    [paperFoldView setPaperFoldState:PaperFoldStateRightUnfolded animated:isAnimation];
}

- (void)showMainView:(NSNotification *)notifi{
    BOOL isAnimation = NO;
    if (notifi.object) {
        isAnimation = [notifi.object boolValue];
    }
    [paperFoldView setPaperFoldState:PaperFoldStateDefault animated:isAnimation];
}

- (void)paperFoldView:(id)paperFoldView didFoldAutomatically:(BOOL)automated toState:(PaperFoldState)paperFoldState{
    if (paperFoldState == PaperFoldStateDefault) {
        [main removeBackGesture];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
