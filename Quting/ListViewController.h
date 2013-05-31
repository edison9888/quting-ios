//
//  ListViewController.h
//  Quting
//
//  Created by Johnil on 13-5-31.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ListModel_play = 1,
    ListModel_search,
    ListModel_fav
} ListModel;

@interface ListViewController : UITableViewController

- (id)initWithModel:(ListModel)model;
- (void)loadDatas:(NSArray *)datas;

@end
