//
//  CircularProgressView.m
//  CircularProgressView
//
//  Created by nijino saki on 13-3-2.
//  Copyright (c) 2013年 nijino. All rights reserved.
//  QQ:20118368
//  http://nijino_saki.blog.163.com

#import "CircularProgressView.h"

@interface CircularProgressView ()

@property (assign, nonatomic) CGFloat lineWidth;

@end

@implementation CircularProgressView {
}

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        _backColor = backColor;
        _progressColor = progressColor;
        _lineWidth = lineWidth;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //draw background circle
    UIBezierPath *backCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2)
                                                              radius:self.bounds.size.width / 2 - self.lineWidth / 2
                                                          startAngle:(CGFloat) - M_PI_2
                                                            endAngle:(CGFloat)(1.5 * M_PI)
                                                           clockwise:YES];
    [self.backColor setStroke];
    backCircle.lineWidth = self.lineWidth;
    [backCircle stroke];
    
    if (self.progress != 0) {
        //draw progress circle
        UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2)
                                                                      radius:self.bounds.size.width / 2 - self.lineWidth / 2
                                                                  startAngle:(CGFloat) - M_PI_2
                                                                    endAngle:(CGFloat)(- M_PI_2 + self.progress * 2 * M_PI)
                                                                   clockwise:YES];
        [progressCircle setLineCapStyle:kCGLineCapRound];
        [self.progressColor setStroke];
        progressCircle.lineWidth = self.lineWidth;
        [progressCircle stroke];
    }
}

- (void)audioProgress:(float)progress{
    self.progress = progress;
    //redraw back & progress circles
    [self setNeedsDisplay];
    
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressDelegate)]) {
        [self.delegate didUpdateProgressView];
    }
}

- (void)updateProgressCircle{
    //update progress value
}

- (void)setProgressColor:(UIColor *)progressColor{
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)play{
    if ([[AudioManager defaultManager] stat] != MPMoviePlaybackStatePlaying) {
        if ([[AudioManager defaultManager] needURL]) {
            [[AudioManager defaultManager] playListAtFirst];
            [[AudioManager defaultManager] addListener:self];
        } else {
            [[AudioManager defaultManager] resume];
        }
    } else {
        [[AudioManager defaultManager] pause];
    }
}

- (void)pause{
    if ([[AudioManager defaultManager] stat] == MPMoviePlaybackStatePlaying) {
        [[AudioManager defaultManager] pause];
    }
}

- (BOOL)playing{
    return [[AudioManager defaultManager] stat] == MPMoviePlaybackStatePlaying;
}

@end
