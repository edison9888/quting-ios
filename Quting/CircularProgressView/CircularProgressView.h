//
//  CircularProgressView.h
//  CircularProgressView
//
//  Created by nijino saki on 13-3-2.
//  Copyright (c) 2013年 nijino. All rights reserved.
//  QQ:20118368
//  http://nijino_saki.blog.163.com

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioManager.h"
@protocol CircularProgressDelegate;

@interface CircularProgressView : UIView <AudioManagerDelegate>

@property (assign, nonatomic) id <CircularProgressDelegate> delegate;
@property (assign, nonatomic) float progress;
@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) UIColor *progressColor;


- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth;
- (void)play;
- (void)pause;
- (BOOL)playing;

@end

@protocol CircularProgressDelegate <NSObject>

- (void)didUpdateProgressView;

@end