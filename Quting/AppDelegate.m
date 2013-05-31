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
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[AudioManager defaultManager] addAudioListToList:@[@"http://tome-file.b0.upaiyun.com/1.mp3",
     @"http://tome-file.b0.upaiyun.com/2.mp3",
     @"http://tome-file.b0.upaiyun.com/3.mp3",
     @"http://tome-file.b0.upaiyun.com/4.mp3",
     @"http://tome-file.b0.upaiyun.com/5.mp3"]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _rootViewController = [[RootViewController alloc] init];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = _rootViewController;
    [self.window makeKeyAndVisible];
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
