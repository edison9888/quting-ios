//
//  CategoryView.h
//  Quting
//
//  Created by Johnil on 13-6-20.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, weak) id loadDelegate;

@end

@protocol CategoryDelegate <NSObject>

- (void)loadListWithCategory:(NSString *)name;

@end