//
//  RSRecordViewController.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-20.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSRecordViewController.h"
#import <NSDate+CupertinoYankee.h>
#import "RSRecordEntity.h"
#import "RSUserUtil.h"
#import "RSKcalUtil.h"
#import <NSDate-Utilities.h>
#import "RSShareManager.h"
#import "ObjectiveRecord.h"

@interface RSRecordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *kcalLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic) NSArray* recordArray;

@property (nonatomic) NSInteger count;
@property (nonatomic) NSTimeInterval time;
@end

@implementation RSRecordViewController

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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sharedButtonClick:(id)sender {
    // 卡路里
    NSInteger weight = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserWeight];
    if (!weight) {
        weight = RSUserWeightDefault;
    }
    NSInteger height = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserHeight];
    if (!height) {
        height = RSUserHeightDefault;
    }
    NSInteger kcalInt = roundf([RSKcalUtil kcalWithHeight:height count:self.count weight:weight]);
    NSString* kcal = [NSString stringWithFormat:@"%ld",(long)kcalInt];
    
    // 时间
    NSInteger minute = (NSInteger)((long long)self.time / D_MINUTE);
    NSTimeInterval second = self.time - minute * D_MINUTE;
    
    NSString* minuteStr = [NSString stringWithFormat:@"%ld",(long)minute];
    NSString* secondStr = [NSString stringWithFormat:@"%.0f",second];
    
    // 截屏
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    }else{
        UIGraphicsBeginImageContext(self.view.bounds.size);
    }
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [[RSShareManager shared] shareRecordWithText:[NSString stringWithFormat:@"我在跳一跳运动了%@分%@秒,消耗了%@卡路里,锻炼娱乐两不误,快来试试吧!地址:http://www.coolplay.tv/download",minuteStr,secondStr,kcal] image:viewImage];
}

#pragma mark - private UI
-(void) updateUI{
    // 计算时间和次数
    NSInteger count = 0;
    NSTimeInterval time = 0;
    for (RSRecordEntity* record in self.recordArray) {
        count += [record.count integerValue];
        time += [record.time doubleValue];
    }
    self.count = count;
    self.time = time;
    
    // 卡路里
    NSInteger weight = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserWeight];
    if (!weight) {
        weight = RSUserWeightDefault;
    }
    NSInteger height = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserHeight];
    if (!height) {
        height = RSUserHeightDefault;
    }
    NSInteger kcalInt = roundf([RSKcalUtil kcalWithHeight:height count:self.count weight:weight]);
    NSString* kcal = [NSString stringWithFormat:@"%ld",(long)kcalInt];
    self.kcalLabel.text = kcal;
    // 时间
    NSInteger minute = (NSInteger)((long long)self.time / D_MINUTE);
    NSTimeInterval second = self.time - minute * D_MINUTE;
    
    NSString* minuteStr = minute > 9 ? [NSString stringWithFormat:@"%ld",(long)minute] : [NSString stringWithFormat:@"0%ld",(long)minute];
    NSString* secondStr = second >= 10 ? [NSString stringWithFormat:@"%.2f",second] : [NSString stringWithFormat:@"0%.2f",second];
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@",minuteStr,secondStr];
    // 平均速度
    self.speedLabel.text = [NSString stringWithFormat:@"%d", (int)(count/time*D_MINUTE)];
    // 总次数
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
}

#pragma mark - private DB
-(void) loadRecord{
    // 本屏的记录数据
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.timeInterval];
    NSTimeInterval beginTimeInterval = [[date beginningOfDay] timeIntervalSince1970];
    NSTimeInterval endTimeInterval = [[date endOfDay] timeIntervalSince1970];
    
    self.recordArray = [RSRecordEntity where:@"beginTime>=%f AND beginTime<=%f",beginTimeInterval,endTimeInterval];
}

@end
