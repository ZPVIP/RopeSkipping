//
//  RSUserViewController.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-20.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSUserViewController.h"
#import "RSUserUtil.h"
#import "RSMainViewController.h"

@interface RSUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;

//@property (weak, nonatomic) IBOutlet UIButton *manCheckBoxButton;
//@property (weak, nonatomic) IBOutlet UIButton *womanCheckBoxButton;

@property (weak, nonatomic) IBOutlet UIImageView *manImageView;
@property (weak, nonatomic) IBOutlet UIImageView *womanImageView;


@property (nonatomic) NSNumber* gender;
@end

@implementation RSUserViewController

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
    NSInteger weight = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserWeight];
    if (!weight) {
        weight = RSUserWeightDefault;
    }
    NSInteger height = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserHeight];
    if (!height) {
        height = RSUserHeightDefault;
    }
    
    NSInteger age = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserAge];
    
    self.weightTextField.text = [NSString stringWithFormat:@"%ld",(long)weight];
    self.heightTextField.text = [NSString stringWithFormat:@"%ld",(long)height];
    self.ageTextField.text = age?[NSString stringWithFormat:@"%ld",(long)age]:@"";
    
    self.gender = [[NSUserDefaults standardUserDefaults] objectForKey:RSUserGender];
    [self updateGenderUI];
}

-(void) updateGenderUI{
    if (self.gender) {
        BOOL genderB = [self.gender boolValue];
        if (genderB) {
            self.manImageView.image = [UIImage imageNamed:@"uncheck"];
            self.womanImageView.image = [UIImage imageNamed:@"check"];
        }else{
            self.manImageView.image = [UIImage imageNamed:@"check"];
            self.womanImageView.image = [UIImage imageNamed:@"uncheck"];
        }
    }else{
        self.manImageView.image = [UIImage imageNamed:@"uncheck"];
        self.womanImageView.image = [UIImage imageNamed:@"uncheck"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)Confirm:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.gender forKey:RSUserGender];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.weightTextField.text integerValue] forKey:RSUserWeight];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.heightTextField.text integerValue] forKey:RSUserHeight];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.ageTextField.text integerValue] forKey:RSUserAge];
    [self.navigationController popViewControllerAnimated:YES];
    
    // 通知
    [[NSNotificationCenter defaultCenter] postNotificationName:RSNotificationMainNeedUpdateUI object:nil userInfo:nil];
}

- (IBAction)manCheckBoxButtonClick:(id)sender {
    self.gender = @(NO);
    [self updateGenderUI];
}
- (IBAction)womanCheckBoxButtonClick:(id)sender {
    self.gender = @(YES);
    [self updateGenderUI];
}
@end
