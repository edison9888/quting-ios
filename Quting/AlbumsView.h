//
//  AlbumsView.h
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularProgressView.h"

@interface AlbumsView : UIView

- (id)initWithFrame:(CGRect)frame andInfo:(NSDictionary *)info;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImage *coverImage;
- (void)stop;

- (void)audioProgress:(float)temp;
- (void)audioPlay;
- (void)audioPause;


@end
