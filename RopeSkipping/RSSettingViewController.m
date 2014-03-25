//
//  RSSettingViewController.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-21.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSSettingViewController.h"
#import "RSAboutDeviceViewController.h"
#import "RSDynamicsDrawerViewController.h"
#import "RSShareManager.h"
#import "RSHelpViewController.h"

@interface RSSettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *coolLabel;

@end

@implementation RSSettingViewController

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
    // 版本
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
    self.coolLabel.text = [NSString stringWithFormat:@"跳一跳 %@   www.coolplay.tv",versionNum];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sharedButtonClick:(id)sender {
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"icon@2x"  ofType:@"png"];
    [[RSShareManager shared] shareAppWithText:@"跳一跳健康运动,锻炼娱乐两不误,快来下载吧!地址:http://www.coolplay.tv/download" imagePath:imagePath];
}
- (IBAction)helpButtonClick:(id)sender {
    RSHelpViewController* helpController = [[RSHelpViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:helpController animated:YES];
}
- (IBAction)aboutDeviceButtonClick:(id)sender {
    RSAboutDeviceViewController* aboutController = [[RSAboutDeviceViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:aboutController animated:YES];
}
- (IBAction)backButtonClick:(id)sender {
    RSDynamicsDrawerViewController* dd = (RSDynamicsDrawerViewController*)self.parentViewController;
    [dd setPaneState:MSDynamicsDrawerPaneStateClosed inDirection:MSDynamicsDrawerDirectionRight animated:YES allowUserInterruption:YES completion:nil];
}

@end
