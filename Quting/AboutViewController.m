//
//  AboutViewController.m
//  Quting
//
//  Created by Johnil on 13-7-2.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "AboutViewController.h"
#import "HelpViewController.h"
@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:imageNamed(@"about.png")];
    imgView.center = CGPointMake(self.view.center.x, self.view.center.y-100);
    [self.view addSubview:imgView];
    self.navigationItem.title = @"关于";
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:imageNamed(@"close_btn.png") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.rightBarButtonItem = back;
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    version.text = @"V1.0";
    version.textAlignment = NSTextAlignmentCenter;
    version.backgroundColor = [UIColor clearColor];
    version.font = [UIFont boldSystemFontOfSize:20];
    version.textColor = [UIColor colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:1];
    version.center = CGPointMake(self.view.center.x, self.view.center.y+30);
    [self.view addSubview:version];
    
    UILabel *support = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
    support.text = @"技术支持:";
    support.textAlignment = NSTextAlignmentRight;
    support.backgroundColor = [UIColor clearColor];
    support.font = [UIFont systemFontOfSize:13];
    support.textColor = [UIColor colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:1];
    support.center = CGPointMake(60, self.view.center.y+60);
    [self.view addSubview:support];
    
    UILabel *page = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
    page.text = @"官方网站:";
    page.textAlignment = NSTextAlignmentRight;
    page.backgroundColor = [UIColor clearColor];
    page.font = [UIFont systemFontOfSize:13];
    page.textColor = [UIColor colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:1];
    page.center = CGPointMake(60, self.view.center.y+90);
    [self.view addSubview:page];
    
    UIButton *supportURL = [UIButton buttonWithType:UIButtonTypeCustom];
    supportURL.frame = CGRectMake(0, 0, 150, 20);
    [supportURL setTitle:@"support@quting.fm" forState:UIControlStateNormal];
    [supportURL setTitleColor:[UIColor colorWithRed:36/255.0 green:134/255.0 blue:97/255.0 alpha:1] forState:UIControlStateNormal];
    [supportURL setTitleColor:[UIColor colorWithRed:136/255.0 green:134/255.0 blue:97/255.0 alpha:1] forState:UIControlStateHighlighted];
    supportURL.titleLabel.font = [UIFont systemFontOfSize:13];
    supportURL.center = CGPointMake(200, self.view.center.y+60);
    [supportURL addTarget:self action:@selector(mail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:supportURL];

    
    UIButton *pageURL = [UIButton buttonWithType:UIButtonTypeCustom];
    pageURL.frame = CGRectMake(0, 0, 150, 20);
    [pageURL setTitle:@"http://quting.fm" forState:UIControlStateNormal];
    [pageURL setTitleColor:[UIColor colorWithRed:36/255.0 green:134/255.0 blue:97/255.0 alpha:1] forState:UIControlStateNormal];
    [pageURL setTitleColor:[UIColor colorWithRed:136/255.0 green:134/255.0 blue:97/255.0 alpha:1] forState:UIControlStateHighlighted];
    pageURL.titleLabel.font = [UIFont systemFontOfSize:13];
    pageURL.center = CGPointMake(190, self.view.center.y+90);
    [pageURL addTarget:self action:@selector(openPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pageURL];
}

- (void)openPage{
    HelpViewController *help = [[HelpViewController alloc] initWithURL:@"http://quting.fm"];
    [self.navigationController pushViewController:help animated:YES];
}

- (void)mail{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @""];
    
    // 添加发送者
    NSArray *toRecipients = [NSArray arrayWithObject: @"support@quting.fm"];
    [mailPicker setToRecipients: toRecipients];
    
    NSString *emailBody = @"";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController: mailPicker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
