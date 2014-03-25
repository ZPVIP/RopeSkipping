//
//  RSSkippingViewController.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-18.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSSkippingViewController.h"
#import <NSDate-Utilities.h>
#import "RSBluetoothManager.h"
#import <TWMessageBarManager.h>
#import "RSRecordEntity.h"
#import "RSUserUtil.h"
#import "RSKcalUtil.h"
#import "RSMainViewController.h"
#import "RSSyncManager.h"
#import "ObjectiveRecord.h"



#define UpdateTimeInterval 0.01

@interface RSSkippingViewController ()<RSBluetoothManagerDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *kcalLabel;
@property (weak, nonatomic) IBOutlet UIButton *beginAndOverButton;

// 定时器
@property (nonatomic,weak) NSTimer* timer;

@property (nonatomic) NSTimeInterval beginTimeInterval;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSInteger count;


@end

@implementation RSSkippingViewController

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
    [self resetDataAndUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 禁止自动休眠
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // 监听蓝牙
    [RSBluetoothManager shared].delegate = self;
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 启用自动休眠
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    // 取消监听蓝牙
    [RSBluetoothManager shared].delegate = nil;
}
#pragma mark - private

-(void) runLoopForTimer{
    self.time += UpdateTimeInterval;
    
    NSInteger minute = (NSInteger)((long long)self.time / D_MINUTE);
    NSTimeInterval second = self.time - minute * D_MINUTE;
    
    NSString* minuteStr = minute > 9 ? [NSString stringWithFormat:@"%ld",(long)minute] : [NSString stringWithFormat:@"0%ld",(long)minute];
    NSString* secondStr = second >= 10 ? [NSString stringWithFormat:@"%.2f",second] : [NSString stringWithFormat:@"0%.2f",second];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@",minuteStr,secondStr];
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)self.count];
    self.speedLabel.text = [NSString stringWithFormat:@"%d",(int)(self.count/self.time*D_MINUTE)];
    
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
}

-(void) resetDataAndUI{
    self.beginTimeInterval = 0;
    self.time = 0;
    self.count = 0;
    
    self.timeLabel.text = @"00:00.00";
    self.countLabel.text = @"0";
    self.speedLabel.text = @"0";
    self.kcalLabel.text = @"0";
    
    [self.beginAndOverButton setTitle:@"开始" forState:UIControlStateNormal];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void) saveDataAndSyncWithBlock:(void (^)(BOOL succress))block{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"保存此次数据");
        BOOL success = NO;
        
        if (self.count != 0) {
            NSLog(@"保存 %d 条数据",self.count);
            RSRecordEntity* record = [RSRecordEntity create];
            record.beginTime = @(self.beginTimeInterval);
            record.time = @(self.time);
            record.count = @(self.count);
            record.uuid = [[NSUUID UUID]UUIDString];
            record.sync = @(NO);
            success = [record save];;
            NSLog(@"保存完成,%@",success?@"成功":@"失败");
            
            [[RSSyncManager shared] upload];
            
        }else{
            NSLog(@"无数据,不保存");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            block(success);
        });
    });
}

-(void) didBecomeActive:(NSNotification *)notification{
    
}
-(void) willResignActive:(NSNotification *)notification{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"是否保存本次数据?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
        [alert show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - IBAction
- (IBAction)beginAndOverButtonClick:(id)sender {
    if (self.timer) {
        // 结束
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        // 保存数据
        [self saveDataAndSyncWithBlock:^(BOOL succress) {
            if (succress) {
                // 通知
                [[NSNotificationCenter defaultCenter] postNotificationName:RSNotificationMainNeedUpdateUI object:nil userInfo:nil];
                // 成功效果
                [[TWMessageBarManager sharedInstance] hideAll];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                               description:@"数据已保存"
                                                                      type:TWMessageBarMessageTypeSuccess];
            }else{
                
            }
            // UI
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    }else{
        // 开始
        [self resetDataAndUI];
        
        self.beginTimeInterval = [[NSDate date] timeIntervalSince1970];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:UpdateTimeInterval target:self selector:@selector(runLoopForTimer) userInfo:nil repeats:YES];
        // UI
        [self.beginAndOverButton setTitle:@"结束" forState:UIControlStateNormal];
    }
}
- (IBAction)againButtonClick:(id)sender {
    if (!self.timer) {
        return;
    }
    
    // 保存数据
    [self saveDataAndSyncWithBlock:^(BOOL succress) {
        if (succress) {
            // 通知
            [[NSNotificationCenter defaultCenter] postNotificationName:RSNotificationMainNeedUpdateUI object:nil userInfo:nil];
            
            [[TWMessageBarManager sharedInstance] hideAll];
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                           description:@"数据已保存"
                                                                  type:TWMessageBarMessageTypeSuccess];
        }
    }];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    // UI
    [self.beginAndOverButton setTitle:@"开始" forState:UIControlStateNormal];
}

#pragma mark - RSBluetoothManagerDelegate
- (void) contentResult:(BOOL) success{
    
}
- (void) disconnect{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"连接断开,是否保存本次数据?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
        [alert show];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"连接断开" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}
- (void) getMessage:(NSDictionary*)dictionary{
    if (self.timer) {
        self.count ++ ;
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
    if (buttonIndex == 1) {
        // 保存数据
        [self saveDataAndSyncWithBlock:^(BOOL succress) {
            if (succress) {
                // 通知
                [[NSNotificationCenter defaultCenter] postNotificationName:RSNotificationMainNeedUpdateUI object:nil userInfo:nil];
                [[TWMessageBarManager sharedInstance] hideAll];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"OK"
                                                               description:@"数据已保存"
                                                                      type:TWMessageBarMessageTypeSuccess];
            }
        }];
    }
}
@end
