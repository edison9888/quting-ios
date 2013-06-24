//
//  CategoryView.h
//  Quting
//
//  Created by Johnil on 13-6-20.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryView : UIScrollView <UIScrollViewDelegate>

- (id)initWithNames:(NSArray *)names;
@property (nonatomic, weak) id loadDelegate;
- (void)changeToIndex:(int)index;

@end

@protocol CategoryDelegate <NSObject>

- (void)loadListWithIndex:(int)index;

@end