//
//  CategoryListView.m
//  Quting
//
//  Created by Johnil on 13-6-24.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "CategoryListView.h"
#import "AlbumsView.h"
#import "RequestHelper.h"

@implementation CategoryListView {
    NSString *category;
    NSMutableDictionary *loadHistory;
}

- (id)initWithFrame:(CGRect)frame andCategory:(NSString *)cate{
    self = [super initWithFrame:frame];
    if (self) {
        category = cate;
        loadHistory = [[NSMutableDictionary alloc] init];
        self.delegate = self;
        [self loadAlbumsWithIndex:1];
        [self loadAlbumsWithIndex:2];
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_{
    CGFloat pageHeight = self.frame.size.height;
    int page = floor((self.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    if (page<0) {
        return;
    }
    if (scrollView_.contentOffset.y+scrollView_.frame.size.height > scrollView_.contentSize.height-100) {
        //        return;
        [self loadAlbumsWithIndex:page+2];
    }
}

- (void)loadAlbumsWithIndex:(int)index{
    NSString *key = [NSString stringWithFormat:@"api/media?page=%d&term=%@", index, category];
    if ([loadHistory valueForKey:key]!=nil) {
        return;
    }
    [loadHistory setValue:@"loaded" forKey:key];

    [[RequestHelper defaultHelper] requestGETAPI:@"api/media" postData:@{@"page":@(index), @"term":category} success:^(id result) {
        if (result) {
            NSMutableArray *datas = [NSMutableArray array];
            for (NSDictionary *dict in [result valueForKey:@"media"]) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                for (NSString *key in [tempDict allKeys]) {
                    if ([[tempDict valueForKey:key] isKindOfClass:[NSNull class]]) {
                        [tempDict setValue:@"" forKey:key];
                    }
                }
                [datas addObject:tempDict];
            }
            
            if (datas.count>0) {
                [self loadAlbumsWithDatas:datas];
            }
        }
        
    } failed:nil];
}

- (void)loadAlbumsWithDatas:(NSMutableArray *)datas{
    float size = 115;
    float gap = (320.0-size*2.0)/3.0;
    int tempCount = self.subviews.count;
    for (UIView *temp in self.subviews) {
        if (![temp isKindOfClass:[AlbumsView class]]) {
            tempCount--;
        }
    }
    int count = datas.count+tempCount;
    int start = count-datas.count;
    int index = 0;
    for (int i=start; i<count; i++) {
        AlbumsView *albums = [[AlbumsView alloc] initWithFrame:CGRectMake(+gap+(size+gap)*(i%2), i/2*(size+gap)+gap/2, size, size) andInfo:[datas objectAtIndex:index] isShop:YES];
        albums.tag = [[[datas objectAtIndex:index] valueForKey:@"id"] intValue];
        [self addSubview:albums];
        index ++;
    }
    int height = count%2==0?((count/2*(size+gap))+gap):((count/2+1)*(size+gap))+gap;
    height = height<=self.frame.size.height?(self.frame.size.height+1):height;
    //    height = height>maxPage*scrollView.frame.size.height?(maxPage*scrollView.frame.size.height):height;
    self.contentSize = CGSizeMake(0, height);
}


@end
