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

- (id)init{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 59)];
    if (self) {
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        categoriesArr = [[NSMutableArray alloc] init];
        [[RequestHelper defaultHelper] requestGETAPI:@"/api/categories" postData:nil success:^(id result) {
            [categoriesArr removeAllObjects];
            NSArray *temp = [result valueForKey:@"categories"];
            [categoriesArr addObjectsFromArray:temp];
            int i = 0;
            int index=0;
            for (NSDictionary *info in categoriesArr) {
                float widht = [[info valueForKey:@"name"] sizeWithFont:[UIFont systemFontOfSize:19] forWidth:320 lineBreakMode:NSLineBreakByCharWrapping].width;
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(i, 8, widht, 30);
                [btn setTitle:[info valueForKey:@"name"] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:17];
                [btn setTitleColor:[UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                btn.tag = index;
                [btn addTarget:self action:@selector(changeTo:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
                i+=(widht+10);
                if (index==0) {
                    [self changeTo:btn];
                }
                index++;
            }
            self.contentSize = CGSizeMake(i, 0);
        } failed:nil];
    }
    return self;
}

- (void)changeTo:(UIButton *)btn_{
    for (UIButton *btn in self.subviews) {
        if (btn==btn_) {
            continue;
        }
        if (btn.selected) {
            btn.selected = NO;
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
        }
    }
    btn_.selected = YES;
    btn_.titleLabel.font = [UIFont systemFontOfSize:19];
    [_loadDelegate loadListWithCategory:[[categoriesArr objectAtIndex:btn_.tag] valueForKey:@"name"]];
}

- (void)dealloc{
    [categoriesArr removeAllObjects];
    categoriesArr = nil;
}

@end
