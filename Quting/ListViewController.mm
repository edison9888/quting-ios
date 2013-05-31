//
//  ListViewController.m
//  Quting
//
//  Created by Johnil on 13-5-31.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "ListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "VoiceTextField.h"
@interface ListViewController ()

@end

@implementation ListViewController {
    ListModel model;
    NSArray *datas;
    
    UIButton *myFavBtn;
    UIButton *historyBtn;
}

- (id)initWithModel:(ListModel)model_{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        model = model_;
        if (model==ListModel_fav) {
            self.navigationItem.title = @"我的最爱";
            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = CGRectMake(0, 0, 44, 44);
            [backBtn setImage:imageNamed(@"backItem.png") forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
            self.navigationItem.leftBarButtonItem = back;
            self.navigationItem.hidesBackButton = YES;
        }
    }
    return self;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    self.tableView.backgroundView = bgView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (datas) {
        if (model==ListModel_fav) {
            if (myFavBtn.selected) {
                return [[datas objectAtIndex:0] count]+1;
            } else {
                return [[datas objectAtIndex:1] count]+1;
            }
        }
        if (model==ListModel_search) {
            return datas.count+1;
        }
        return datas.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
//        if (isSearch) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        }
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (![cell viewWithTag:9]) {
        UIImageView *line = [[UIImageView alloc] initWithImage:imageNamed(@"separator.png")];
        line.frame = CGRectMake(0, 49, 320, 2);
        line.tag = 9;
        [cell addSubview:line];
    }
    if (model==ListModel_search) {
        if (indexPath.row==0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[UIImageView alloc] initWithImage:imageNamed(@"cell_bg.png")];
            
            if (![cell viewWithTag:1]) {
                VoiceTextField *textField = [[VoiceTextField alloc] initWithFrame:CGRectMake(45, 9, 235, 33)];
                //            textField.center = CGPointMake(self.view.frame.size.width/2, 50);
                textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [textField setReturnKeyType:UIReturnKeyDone];
                textField.placeholder = @"请输入搜索内容";
                textField.textColor = [UIColor blackColor];
                textField.tag = 1;
                [cell addSubview:textField];
                
                UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [recordBtn setImage:imageNamed(@"record.png") forState:UIControlStateNormal];
                recordBtn.frame = CGRectMake(275, 9, 35, 35);
                [recordBtn addTarget:textField action:@selector(voiceMode) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:recordBtn];
            }
        } else {
            NSDictionary *dict = [datas objectAtIndex:indexPath.row-1];
            cell.textLabel.text = [dict valueForKey:@"title"];
            
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            if (!label) {
                UILabel *duration = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 50)];
                duration.font = [UIFont systemFontOfSize:12];
                duration.textAlignment = NSTextAlignmentCenter;
                duration.text = [dict valueForKey:@"duration"];
                duration.backgroundColor = [UIColor clearColor];
                duration.textColor = [UIColor colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:1];
                duration.tag = 1;
                [cell addSubview:duration];
            } else {
                label.text = [dict valueForKey:@"duration"];
            }
        }
    } else if (model==ListModel_play) {
        NSDictionary *dict = [datas objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict valueForKey:@"title"];
        cell.detailTextLabel.text = [dict valueForKey:@"detailTitle"];
        
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        if (!label) {
            UILabel *duration = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 50)];
            duration.font = [UIFont systemFontOfSize:12];
            duration.textAlignment = NSTextAlignmentCenter;
            duration.text = [dict valueForKey:@"duration"];
            duration.backgroundColor = [UIColor clearColor];
            duration.textColor = [UIColor colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:1];
            duration.tag = 1;
            [cell addSubview:duration];
        } else {
            label.text = [dict valueForKey:@"duration"];
        }
        
        BOOL isFav = [[dict valueForKey:@"isFav"] boolValue];
        if (isFav && ![cell viewWithTag:2]) {
            UIImageView *fav = [[UIImageView alloc] initWithImage:imageNamed(@"fav.png")];
            fav.tag = 2;
            fav.center = CGPointMake(240, 50/2);
            [cell addSubview:fav];
        }
        
        BOOL isCurrent = [[dict valueForKey:@"isCurrent"] boolValue];
        if (isCurrent && ![cell viewWithTag:3]) {
            UIView *current = [[UIView alloc] initWithFrame:CGRectMake(0, 50/2-16, 7, 32)];
            current.tag = 3;
            current.backgroundColor = [UIColor colorWithRed:242/255.0 green:100/255.0 blue:163/255.0 alpha:1];
            [cell addSubview:current];
        }
    } else if (model==ListModel_fav) {
        if (indexPath.row==0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundView = [[UIImageView alloc] initWithImage:imageNamed(@"myFavBG.png")];
            
            if (!myFavBtn) {
                myFavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [myFavBtn setImage:imageNamed(@"myFavUnselect.png") forState:UIControlStateNormal];
                [myFavBtn setImage:imageNamed(@"myFavUnselect.png") forState:UIControlStateHighlighted];
                [myFavBtn setImage:imageNamed(@"myFavSelect.png") forState:UIControlStateSelected];
                [myFavBtn addTarget:self action:@selector(favMode) forControlEvents:UIControlEventTouchDown];
                myFavBtn.frame = CGRectMake(15, 8, 147, 34);
                [cell addSubview:myFavBtn];
                
                historyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [historyBtn setImage:imageNamed(@"historyUnselect.png") forState:UIControlStateNormal];
                [historyBtn setImage:imageNamed(@"historyUnselect.png") forState:UIControlStateHighlighted];
                [historyBtn setImage:imageNamed(@"historySelect.png") forState:UIControlStateSelected];
                [historyBtn addTarget:self action:@selector(historyMode) forControlEvents:UIControlEventTouchDown];
                historyBtn.frame = CGRectMake(147+13, 8, 147, 34);
                historyBtn.selected = YES;
                [cell addSubview:historyBtn];
            }
        } else {
            NSArray *temp;
            if (myFavBtn.selected) {
                temp = [datas objectAtIndex:0];
            } else {
                temp = [datas objectAtIndex:1];
            }
            NSDictionary *dict = [temp objectAtIndex:indexPath.row-1];
            cell.textLabel.text = [dict valueForKey:@"title"];
            cell.detailTextLabel.text = [dict valueForKey:@"detailTitle"];
            UIImageView *fav = (UIImageView *)[cell viewWithTag:1];
            if (!fav) {
                fav = [[UIImageView alloc] initWithImage:imageNamed(myFavBtn.selected?@"fav.png":@"unFav.png")];
                fav.frame = CGRectMake(280, 20, 14, 13);
                fav.tag = 1;
                [cell addSubview:fav];
            } else {
                fav.image = imageNamed(myFavBtn.selected?@"fav.png":@"unFav.png");
            }
        }
    }
    return cell;
}

- (void)historyMode{
    historyBtn.selected = YES;
    myFavBtn.selected = NO;
    [self.tableView reloadData];
}

- (void)favMode{
    historyBtn.selected = NO;
    myFavBtn.selected = YES;
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadDatas:(NSArray *)datas_{
    datas = nil;
    datas = datas_;
    [self.tableView reloadData];
}

@end
