//
//  RSConnectViewController.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-18.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSConnectViewController.h"
#import "RSSkippingViewController.h"
#import "RSBluetoothManager.h"
#import <MBProgressHUD.h>

@interface RSConnectViewController ()<RSBluetoothManagerDelegate>
@property (nonatomic,weak) MBProgressHUD* hud;
@end

@implementation RSConnectViewController

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
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // 点击了返回按钮
        [[RSBluetoothManager shared] disconnect];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectButtonClick:(id)sender {
    // 启动进度条
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    self.hud = hud;
    
    [RSBluetoothManager shared].delegate = self;
    [[RSBluetoothManager shared] content];
}

#pragma mark - RSBluetoothManagerDelegate
- (void) contentResult:(BOOL) success{
    if (self.hud) {
        [self.hud hide:YES];
        self.hud = nil;
    }
    if (success) {
        RSSkippingViewController* skippingViewController = [[RSSkippingViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController* navigation = self.navigationController;
        [self.navigationController popViewControllerAnimated:NO];
        [navigation pushViewController:skippingViewController animated:YES];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"失败" message:@"无法连接到跳绳" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}
- (void) disconnect{
    if (self.hud) {
        [self.hud hide:YES];
        self.hud = nil;
    }
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"失败" message:@"无法连接到跳绳" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
//    [alert show];
}
- (void) getMessage:(NSDictionary*)dictionary{

}
@end
