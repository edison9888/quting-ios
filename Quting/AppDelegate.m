//
//  AppDelegate.m
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "RootViewController.h"
#import "AudioManager.h"
#import "OpenUDID.h"
#import "RequestHelper.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 1;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"guest"]==nil) {
        [[RequestHelper defaultHelper] requestPOSTAPI:@"/api/guests" postData:@{@"guest[device_token]": [OpenUDID value]} success:^(id result) {
            NSLog(@"%@", result);
            [[NSUserDefaults standardUserDefaults] setValue:[[result valueForKey:@"guest"] valueForKey:@"id"] forKey:@"guest"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _rootViewController = [[RootViewController alloc] init];
            self.window.backgroundColor = [UIColor blackColor];
            self.window.rootViewController = _rootViewController;
            [self.window makeKeyAndVisible];

        } failed:^(id result, NSError *error) {
            _rootViewController = [[RootViewController alloc] init];
            self.window.backgroundColor = [UIColor blackColor];
            self.window.rootViewController = _rootViewController;
            [self.window makeKeyAndVisible];
        }];
    } else {
        _rootViewController = [[RootViewController alloc] init];
        self.window.backgroundColor = [UIColor blackColor];
        self.window.rootViewController = _rootViewController;
        [self.window makeKeyAndVisible];
    }
    
    NSString *load = [NSString stringWithFormat:@"Default%@.png", isRetina?(isiPhone5?@"-568h@2x":@"@2x"):@""];
    UIImageView *temp = [[UIImageView alloc] initWithImage:imageNamed(load)];
    temp.frame = CGRectMake(0, 0, temp.frame.size.width, temp.frame.size.height);
    [_window addSubview:temp];
    
    [UIView animateWithDuration:.5 delay:2 options:UIViewAnimationOptionCurveLinear animations:^{
//        temp.transform = CGAffineTransformMakeScale(1.5, 1.5);
        temp.alpha = 0;
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
    }];


    return YES;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [[AudioManager defaultManager] changeStat];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[AudioManager defaultManager] next];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[AudioManager defaultManager] pre];
                break;
            default:
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
