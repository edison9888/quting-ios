//
//  PayView.m
//  Quting
//
//  Created by Johnil on 13-6-9.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "PayView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppUtil.h"
#import "UIView+Animation.h"

@implementation PayView {
}

- (id)initWithImage:(UIImage *)coverImage andInfo:(NSDictionary *)info
{
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        int size = isiPhone5?270:230;
        
        UIView *infoPanel = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT/2, size-50, HEIGHT/2-50)];
        infoPanel.center = CGPointMake(WIDTH/2, HEIGHT/2+(HEIGHT/2-50)/2);
        infoPanel.backgroundColor = [UIColor whiteColor];
        infoPanel.layer.cornerRadius = 5;
        [self addSubview:infoPanel];
        
        UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, self.frame.size.width, self.frame.size.height)];
        coverView.backgroundColor = [UIColor clearColor];
        [self addSubview:coverView];
        
        UIView *coverBG = [[UIView alloc] initWithFrame:CGRectMake(15-5, (isiPhone5?30:15)-5, size+10, size+10)];
        coverBG.backgroundColor = [UIColor whiteColor];
        coverBG.center = CGPointMake(self.center.x, coverBG.center.y);
        coverBG.layer.cornerRadius = (size+10)/2;
        
        UIView *smallCoverBG = [[UIView alloc] initWithFrame:CGRectMake(coverBG.frame.origin.x+coverBG.frame.size.width-70, coverBG.frame.origin.y+coverBG.frame.size.height-70, 60, 60)];
        smallCoverBG.backgroundColor = [UIColor whiteColor];
        smallCoverBG.layer.cornerRadius = 30;
        [coverView addSubview:smallCoverBG];
        
        [coverView addSubview:coverBG];
        
        UIImageView *cover = [[UIImageView alloc] initWithImage:coverImage];
        cover.frame = CGRectMake(5, 5, size, size);
        //    cover.center = coverBG.center;
        cover.contentMode = UIViewContentModeScaleAspectFill;
        cover.clipsToBounds = YES;
        cover.layer.cornerRadius = size/2;
        [coverBG addSubview:cover];
        
        UIView *smallCover1 = [[UIView alloc] initWithFrame:CGRectMake(smallCoverBG.frame.origin.x+4, smallCoverBG.frame.origin.y+4, smallCoverBG.frame.size.width-8, smallCoverBG.frame.size.height-8)];
        smallCover1.backgroundColor = [UIColor whiteColor];
        smallCover1.layer.cornerRadius = (smallCoverBG.frame.size.height-10)/2;
        smallCover1.clipsToBounds = YES;
        [coverView addSubview:smallCover1];
        
        UIView *smallCover = [[UIView alloc] initWithFrame:CGRectMake(smallCoverBG.frame.origin.x+5, smallCoverBG.frame.origin.y+5, smallCoverBG.frame.size.width-10, smallCoverBG.frame.size.height-10)];
        smallCover.backgroundColor = [UIColor whiteColor];
        smallCover.layer.cornerRadius = (smallCoverBG.frame.size.height-10)/2;
        smallCover.clipsToBounds = YES;
        [coverView addSubview:smallCover];
        
        UIImageView *cover2 = [[UIImageView alloc] initWithImage:coverImage];
        cover2.frame = CGRectMake(coverBG.frame.origin.x-smallCover.frame.origin.x+5, coverBG.frame.origin.y-smallCover.frame.origin.y+5, size, size);
        cover2.contentMode = UIViewContentModeScaleAspectFill;
        cover2.alpha = .9;
        [smallCover addSubview:cover2];
        
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, smallCover.frame.size.width, smallCover.frame.size.height)];
        price.backgroundColor = [UIColor clearColor];
        price.text = @"免费";
        price.textColor = [UIColor whiteColor];
        price.font = [UIFont boldSystemFontOfSize:18];
        price.textAlignment = NSTextAlignmentCenter;
        [smallCover addSubview:price];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(isiPhone5?60:80, coverBG.frame.origin.y+coverBG.frame.size.height, size-70, 20)];
        title.backgroundColor = [UIColor clearColor];
        title.text = [NSString stringWithFormat:@" %@", [info valueForKey:@"name"]];
        title.font = [UIFont boldSystemFontOfSize:14];
        title.textColor = [UIColor colorWithRed:49/255.0 green:49/255.0 blue:49/255.0 alpha:1];
        [coverView addSubview:title];
        
        UITextView *detailTitle = [[UITextView alloc] initWithFrame:CGRectMake(isiPhone5?60:80, coverBG.frame.origin.y+coverBG.frame.size.height+20, size-70, isiPhone5?60:50)];
        detailTitle.backgroundColor = [UIColor clearColor];
        detailTitle.text = [info valueForKey:@"description"];
        detailTitle.font = [UIFont boldSystemFontOfSize:9];
        detailTitle.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1];
        detailTitle.editable = NO;
        [coverView addSubview:detailTitle];
        
        UIButton *subscription = [UIButton buttonWithType:UIButtonTypeCustom];
        float scale = 251.0/(size-70);
        subscription.frame = CGRectMake(isiPhone5?60:80, detailTitle.frame.origin.y+(isiPhone5?80:55), size-70, 42/scale);
        [subscription setImage:imageNamed(@"subscriptionBtn.png") forState:UIControlStateNormal];
        [subscription addTarget:self action:@selector(addSubScription) forControlEvents:UIControlEventTouchUpInside];
        [coverView addSubview:subscription];
    }
    return self;
}

- (void)addSubScription{
    [AppUtil warning:@"订阅成功!" withType:m_success];
    [self fadeOut];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self fadeOut];
}

@end
