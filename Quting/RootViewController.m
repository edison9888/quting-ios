//
//  RootViewController.m
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "RootViewController.h"
#import "ConfigViewController.h"
#import "AppUtil.h"
#import "JASidePanelController.h"

@interface RootViewController ()

@end

@implementation RootViewController {
    JASidePanelController *sideView;
    UINavigationController *navigationController;
    ConfigViewController *config;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    _main = [[MainViewController alloc] init];
    _main.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    config = [[ConfigViewController alloc] initWithStyle:UITableViewStylePlain];
    config.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:_main];
    navigationController.delegate = self;
    navigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [navigationController.navigationBar setBackgroundImage:imageNamed(@"navi_background.png") forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.clipsToBounds = YES;
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                UITextAttributeTextColor: [UIColor whiteColor],
                          UITextAttributeTextShadowColor: [UIColor colorWithRed:70.0/255.0 green:153.0/255.0 blue:121.0/255.0 alpha:1.0],
                         UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]
     }];

    sideView = [[JASidePanelController alloc] init];
    sideView.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    sideView.shouldDelegateAutorotateToVisiblePanel = NO;
    sideView.centerPanel = navigationController;
    sideView.rightPanel = config;
    [self.view addSubview:sideView.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConfigView:) name:SHOWCONFIG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMainView:) name:BACKTOMAIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canRight) name:ENABLERIGHT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cantRight) name:DISABLERIGHT object:nil];
}

- (void)canRight{
    sideView.rightPanel = config;
}

- (void)cantRight{
    sideView.rightPanel = nil;
}

- (void)navigationController:(UINavigationController *)navigationController_ didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:NSClassFromString(@"MainViewController")]) {
        [sideView setRightPanel:config];
    } else {
        [sideView setRightPanel:nil];
    }
}

- (void)showConfigView:(NSNotification *)notifi{
    BOOL isAnimation = NO;
    if (notifi.object) {
        isAnimation = [notifi.object boolValue];
    }
    [sideView showRightPanelAnimated:isAnimation];
}

- (void)showMainView:(NSNotification *)notifi{
    BOOL isAnimation = NO;
    if (notifi.object) {
        isAnimation = [notifi.object boolValue];
    }
    [sideView showCenterPanelAnimated:isAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
