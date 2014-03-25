//
//  RSAboutDeviceViewController.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-21.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSAboutDeviceViewController.h"
#import <TTTAttributedLabel.h>

@interface RSAboutDeviceViewController ()<TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *tttLabel;

@end

@implementation RSAboutDeviceViewController

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
    self.tttLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.tttLabel.delegate = self;
    self.tttLabel.text = @"如需了解更多请前往www.coolplay.tv了解和购买";
    NSRange range = [self.tttLabel.text rangeOfString:@"www.coolplay.tv"];
    [self.tttLabel addLinkToURL:[NSURL URLWithString:@"http://github.com/mattt/"] withRange:range];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}
@end
