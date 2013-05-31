//
//  AlbumsView.m
//  Quting
//
//  Created by Johnil on 13-5-29.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AlbumsView.h"
#import <QuartzCore/QuartzCore.h>
#import "PlayViewController.h"
#import "MainViewController.h"
#import "ListViewController.h"

@implementation AlbumsView {
    CircularProgressView *circularProgressView;
    UIImageView *cover;
    UIButton *control;
}

- (UIImage*)imageFromView:(UIView*)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, view.layer.contentsScale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
        self.clipsToBounds = NO;
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        bg.backgroundColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1];
        bg.layer.cornerRadius = frame.size.width/2;
        bg.clipsToBounds = YES;
        UIImage *temp = [self imageFromView:bg];
        [self addSubview:[[UIImageView alloc] initWithImage:temp]];
        [self loadView];
    }
    return self;
}

- (void)loadView{
    //set backcolor & progresscolor
    UIColor *backColor = [UIColor whiteColor];
    UIColor *progressColor = [UIColor colorWithRed:238.0/255.0 green:55.0/255.0 blue:137.0/255.0 alpha:1.0];
    
    int width = self.frame.size.width-10;
    //alloc CircularProgressView instance
    circularProgressView = [[CircularProgressView alloc] initWithFrame:CGRectMake(5, 5, width, width)
                                                                  backColor:backColor
                                                              progressColor:progressColor
                                                                  lineWidth:5];
    
    //set CircularProgressView delegate
    circularProgressView.delegate = self;
    
    //add CircularProgressView
    [self addSubview:circularProgressView];
    
    cover = [[UIImageView alloc] initWithImage:imageNamed(@"thumb.jpg")];
    cover.frame = CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.width-20);
    cover.contentMode = UIViewContentModeScaleAspectFit;
    cover.layer.cornerRadius = (self.frame.size.width-20)/2;
    cover.clipsToBounds = YES;
    
    UIView *blackCover = [[UIView alloc] initWithFrame:CGRectMake(-10, self.frame.size.height-40, self.frame.size.width, self.frame.size.height)];
    blackCover.backgroundColor = [UIColor blackColor];
    blackCover.layer.cornerRadius = self.frame.size.width/2;
    blackCover.alpha = .5;
    [cover addSubview:blackCover];
    
    UIImage *temp = [self imageFromView:cover];
    cover.image = temp;
    cover.layer.cornerRadius = 0;
    cover.alpha = .85;
    [self addSubview:cover];
    [blackCover removeFromSuperview];
    
    if (arc4random()%2==0) {
        UIImageView *fav = [[UIImageView alloc] initWithImage:imageNamed(@"fav.png")];
        fav.frame = CGRectMake(blackCover.center.x-7, self.frame.size.height-35, 14, 13);
        [cover addSubview:fav];
    } else {
        UIImageView *fav = [[UIImageView alloc] initWithImage:imageNamed(@"noFav.png")];
        fav.frame = CGRectMake(blackCover.center.x-7, self.frame.size.height-35, 14, 13);
        [cover addSubview:fav];
    }
    
    control = [UIButton buttonWithType:UIButtonTypeCustom];
    [control setImage:imageNamed(@"playing.png") forState:UIControlStateNormal];
    [control setImage:imageNamed(@"btn_pause.png") forState:UIControlStateSelected];
    [control addTarget:self action:@selector(manageAudio) forControlEvents:UIControlEventTouchUpInside];
    control.frame = CGRectMake(self.frame.size.width-28, self.frame.size.height-28, 26, 26);
    [self addSubview:control];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height+5, self.frame.size.width, 15)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont boldSystemFontOfSize:15];
    _label.text = @"我的最爱";
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1];
    [self addSubview:_label];
}

- (void)manageAudio{
    if ([circularProgressView playing]) {
        [circularProgressView pause];
        circularProgressView.progressColor = [UIColor grayColor];
        cover.alpha = .85;
        control.selected = NO;
    } else {
        [circularProgressView play];
        circularProgressView.progressColor =  [UIColor colorWithRed:238.0/255.0 green:55.0/255.0 blue:137.0/255.0 alpha:1.0];
        cover.alpha = 1;
        control.selected = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    cover.alpha = .5;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    cover.alpha = 1;
    if (self.tag==0) {
        ListViewController *list = [[ListViewController alloc] initWithModel:ListModel_fav];
        [list loadDatas:@[
         @[@{@"title":@"我的歌声里", @"detailTitle":@"原声带第一首", @"isFav":@(NO), @"duration":@"05:20", @"isCurrent":@(NO)},
         @{@"title":@"我的歌声里", @"detailTitle":@"原声带第二首", @"isFav":@(YES), @"duration":@"05:50", @"isCurrent":@(NO)},
         @{@"title":@"我的歌声里", @"detailTitle":@"原声带第五首", @"isFav":@(NO), @"duration":@"06:32", @"isCurrent":@(NO)}],
         
         @[@{@"title":@"我的歌声里", @"detailTitle":@"原声带第一首", @"isFav":@(NO), @"duration":@"05:20", @"isCurrent":@(NO)},
         @{@"title":@"我的歌声里", @"detailTitle":@"原声带第二首", @"isFav":@(YES), @"duration":@"05:50", @"isCurrent":@(NO)},
         @{@"title":@"我的歌声里", @"detailTitle":@"原声带第三首", @"isFav":@(NO), @"duration":@"04:25", @"isCurrent":@(YES)},
         @{@"title":@"我的歌声里", @"detailTitle":@"原声带第四首", @"isFav":@(YES), @"duration":@"02:27", @"isCurrent":@(NO)},
         @{@"title":@"我的歌声里", @"detailTitle":@"原声带第五首", @"isFav":@(NO), @"duration":@"06:32", @"isCurrent":@(NO)}]
         ]];
         
         
        [((MainViewController *)self.superview.superview.nextResponder).navigationController pushViewController:list animated:YES];
    } else {
        PlayViewController *play = [[PlayViewController alloc] init];
        [((MainViewController *)self.superview.superview.nextResponder).navigationController pushViewController:play animated:YES];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    cover.alpha = 1;
}

#pragma mark Circular Progress View Delegate method
- (void)didUpdateProgressView{
//    NSLog(@"progress:%f", circularProgressView.progress);
}

@end
