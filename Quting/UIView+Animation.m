//
//  UIView+Animation.m
//  TiantianCab
//
//  Created by Johnil on 13-5-17.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

- (void)fadeIn{
    self.alpha = 0;
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)fadeOut{
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
