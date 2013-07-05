//
//  CategoryView.m
//  Quting
//
//  Created by Johnil on 13-6-20.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "CategoryView.h"
#import "RequestHelper.h"

@implementation CategoryView {
    NSMutableArray *categoriesArr;
}

- (id)initWithNames:(NSArray *)names{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 59)];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        categoriesArr = [[NSMutableArray alloc] initWithArray:names];
        int i = 0;
        int index=1;
        for (NSString *name in categoriesArr) {
            float widht = [name sizeWithFont:[UIFont systemFontOfSize:19] forWidth:320 lineBreakMode:NSLineBreakByCharWrapping].width;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i, 8, widht, 30);
            [btn setTitle:name forState:UIControlStateNormal];
//            btn.titleLabel.font = [UIFont systemFontOfSize:18];
            [btn setTitleColor:[UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1] forState:UIControlStateHighlighted];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            btn.tag = index;
            [btn addTarget:self action:@selector(changeTo:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            i+=(widht+10);
            if (index==1) {
                [self changeTo:btn];
            }
            index++;
        }
        self.contentSize = CGSizeMake(i, 0);

    }
    return self;
}

- (void)changeToIndex:(int)index{
    UIButton *btn_ = (UIButton *)[self viewWithTag:index];
    for (UIButton *btn in self.subviews) {
        if (btn==btn_) {
            continue;
        }
        if (btn.selected) {
            btn.selected = NO;
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
        }
    }
    btn_.selected = YES;
    btn_.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    NSLog(@"%f", btn_.center.x-btn_.frame.size.width);
    [self setContentOffset:CGPointMake(btn_.center.x-btn_.frame.size.width-(160-btn_.frame.size.width), 0) animated:NO];
}

- (void)changeTo:(UIButton *)btn_{
    [self changeToIndex:btn_.tag];
    [_loadDelegate loadListWithIndex:btn_.tag];
}

- (void)dealloc{
    [categoriesArr removeAllObjects];
    categoriesArr = nil;
}

@end
