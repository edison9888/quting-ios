//
//  RootViewController.h
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperFoldView.h"
#import "MainViewController.h"

@interface RootViewController : UIViewController <PaperFoldViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) MainViewController *main;

@end
