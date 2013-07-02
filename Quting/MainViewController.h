//
//  MainViewController.h
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;

- (void)removeBackGesture;

@end
