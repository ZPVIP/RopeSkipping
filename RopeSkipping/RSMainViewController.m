//
//  RSMainViewController.m
//  RopeSkipping
//
//  Created by 管理员 on 14-1-17.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSMainViewController.h"
#import "WYLineChartView.h"
#import <Masonry.h>
#import "RSRecordEntity.h"
#import <NSDate-Utilities.h>
#import <NSDate+CupertinoYankee.h>
#import "EGORefreshTableHeaderView.h"
#import "RSAppDelegate.h"
#import "RSConnectViewController.h"
#import "RSBluetoothManager.h"
#import "RSSkippingViewController.h"
#import "NSDate+WY.h"
#import <MBProgressHUD.h>
#import "RSRecordViewController.h"
#import "RSUserViewController.h"
#import "RSDynamicsDrawerViewController.h"
#import "RSKcalUtil.h"
#import "RSUserUtil.h"
#import <TWMessageBarManager.h>
#import "ObjectiveRecord.h"

// 显示，模式
typedef NS_ENUM(NSInteger, RSMainViewControllerModel) {
    RSMainViewControllerModelKcal,
    RSMainViewControllerModelCount,
    RSMainViewControllerModelTime
};
static NSString* const RSMainViewControllerModelKcalTitle = @"卡\n路\n里";
static NSString* const RSMainViewControllerModelKcalUnit = @"Kcal";
static NSString* const RSMainViewControllerModelCountTitle = @"次\n数";
static NSString* const RSMainViewControllerModelCountUnit = @"Count";
static NSString* const RSMainViewControllerModelTimeTitle = @"时\n间";
static NSString* const RSMainViewControllerModelTimeUnit = @"m";


@interface RSMainViewController ()<UIScrollViewDelegate,EGORefreshTableHeaderDelegate,WYLineChartViewDelegate>{
    // 左右拉,刷新
    EGORefreshTableHeaderView* _PullRightRefreshView;
    EGORefreshTableHeaderView* _PullLeftRefreshView;
    BOOL _reloading;
    
    // 显示模式
    RSMainViewControllerModel _model;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIButton *goTodayButton;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;

@property (weak,nonatomic) WYLineChartView* lineChartView;

// 数据库相关
@property (nonatomic) NSArray* recordArray;
@property (nonatomic) NSArray* lastRecordArray;
@property (nonatomic) NSArray* nextRecordArray;

// Component 相关
@property (nonatomic) NSArray* points;
@property (nonatomic) NSNumber* lastValueIndex;
@property (nonatomic) NSNumber* lastValue;
@property (nonatomic) NSNumber* nextValueIndex;
@property (nonatomic) NSNumber* nextValue;
@property (nonatomic) NSInteger maxValue;

// 设置按钮
@property (nonatomic,weak) UIButton* settingButton;
// 模式相关
@property (nonatomic,weak) UIButton* modelButton;
@property (nonatomic,weak) UILabel* modelUnitLabel;

// 图表X轴 日期
@property (nonatomic) NSArray* dates;

//// 目前的X轴索引
//@property (nonatomic) NSUInteger xIndex;
@property (nonatomic) NSDate* lastDate;
@end

@implementation RSMainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    _reloading = NO;
//    self.xIndex = NSUIntegerMax;
    //    self.index = 0;
    //    self.today = [NSDate date];
    _model = RSMainViewControllerModelKcal;
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:RSNotificationMainNeedUpdateUI object:nil];
    // 创建图表
    WYLineChartView* lineChartView = [[WYLineChartView alloc] initWithFrame:CGRectZero];
    lineChartView.delegate = self;
    lineChartView.valueLabelFont = [UIFont boldSystemFontOfSize:16];
    self.lineChartView = lineChartView;
    [self.scrollContentView addSubview:lineChartView];
    [self.scrollContentView sendSubviewToBack:lineChartView];
    
    // 左右拉刷新
    _PullRightRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:self.scrollView orientation:EGOPullOrientationRight];
    _PullRightRefreshView.delegate = self;
    
    _PullLeftRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:self.scrollView orientation:EGOPullOrientationLeft];
    _PullLeftRefreshView.delegate = self;
    
    // 更新UI
    [self updateUI];
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
            [hud hide:YES];
        });
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 抽屉
    CGFloat x = self.scrollView.contentOffset.x;
    if (self.index == 0 && x>self.scrollView.contentSize.width-self.scrollView.bounds.size.width*2) {
        // 激活抽屉
        RSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.dynamicsDrawerViewController setPaneDragRevealEnabled:YES forDirection:MSDynamicsDrawerDirectionRight];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 取消抽屉
    RSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.dynamicsDrawerViewController setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionRight];
}

#pragma mark - Notification
- (void) receiveNotification:(NSNotification*) notification{
    // 启动进度条
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
            [hud hide:YES];
        });
    });
}
#pragma mark - private
-(NSDate*) dateWithXIndex:(NSUInteger)index{
    return self.dates[index];
}

#pragma mark - private UI

// 一屏显示的天数
#define ShowDayCount 31
// 如果本屏有今天,那么今天后多显示的天数,空间用来显示设置箭头
#define TodayMoreDayCount 3

-(void) updateUI{
    NSAssert(self.today != nil, @"today 为 nil");
    NSLog(@"mainView  开始更新UI");
    // 特殊UI（动态）
    if (self.settingButton) {
        [self.settingButton removeFromSuperview];
        self.settingButton = nil;
    }
    if (self.modelButton) {
        [self.modelButton removeFromSuperview];
        self.modelButton = nil;
    }
    if (self.modelUnitLabel) {
        [self.modelUnitLabel removeFromSuperview];
        self.modelUnitLabel = nil;
    }
    if (self.index == 0) {
        // 设置按钮
        UIButton* right = [UIButton buttonWithType:UIButtonTypeCustom];
        [right setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
        [self.scrollContentView addSubview:right];
        [right mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-28));
            make.centerY.equalTo(self.view.mas_centerY).with.offset(-18);
        }];
        [right addTarget:self action:@selector(settingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.settingButton = right;
        
        // 模式按钮
        UIButton* model = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"modelButtonBack"]];
        [model addSubview:imageView];
        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(-10));
            make.top.equalTo(@(4));
        }];
        UILabel* modelLabel = [[UILabel alloc] init];
        modelLabel.font = [UIFont systemFontOfSize:14];
        modelLabel.textColor = [UIColor redColor];
        modelLabel.numberOfLines = 0;
        UILabel* modelUnitLabel = [[UILabel alloc] init];
        modelUnitLabel.font = [UIFont systemFontOfSize:12];
        modelUnitLabel.textColor = [UIColor grayColor];
        switch (_model) {
            case RSMainViewControllerModelKcal:
                modelLabel.text = RSMainViewControllerModelKcalTitle;
                modelUnitLabel.text = RSMainViewControllerModelKcalUnit;
                break;
            case RSMainViewControllerModelCount:
                modelLabel.text = RSMainViewControllerModelCountTitle;
                modelUnitLabel.text = RSMainViewControllerModelCountUnit;
                break;
            case RSMainViewControllerModelTime:
                modelLabel.text = RSMainViewControllerModelTimeTitle;
                modelUnitLabel.text = RSMainViewControllerModelTimeUnit;
                break;
                
            default:
                break;
        }
        [model addSubview:modelLabel];
        [modelLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.right.equalTo(@(0));
            make.top.equalTo(@(0));
        }];
        [model addSubview:modelUnitLabel];
        [modelUnitLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.right.equalTo(@(0));
            make.top.equalTo(modelLabel.mas_bottom);
            make.bottom.equalTo(@(0));
        }];
        
        [self.scrollContentView addSubview:model];
        [model mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-100));
            make.top.equalTo(@(40));
        }];
        [model addTarget:self action:@selector(modelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.modelButton = model;
    }
    //    // 刷新月份
    //    static NSDateFormatter *dateFormatter1 = nil;
    //    if (!dateFormatter1) {
    //        dateFormatter1 = [[NSDateFormatter alloc] init];
    //        [dateFormatter1 setDateFormat:@"MMMM"];
    //    }
    //
    //    NSTimeInterval aTimeInterval = [self.today timeIntervalSinceReferenceDate] - D_DAY * ShowDayCount * self.index;
    //    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    //    self.monthLabel.text = [dateFormatter1 stringFromDate:date];
    
    // 左右拉刷新, 如果是当天数据, 则不能加载后30天的数据
    if (self.index == 0) {
        _PullLeftRefreshView.hidden = YES;
    }else{
        _PullLeftRefreshView.hidden = NO;
    }
    
    // 刷新图表
    [self updateLineChartView];
    
    // 左右拉刷新布局
    self.scrollView.contentSize = [self.scrollView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [_PullRightRefreshView adjustPosition];
    [_PullLeftRefreshView adjustPosition];
    
    // scrollView 滚动到最右边
    CGPoint rightOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width,0);
    [self.scrollView setContentOffset:rightOffset animated:NO];
    
    NSLog(@"mainView  结束更新UI");
}

-(void) updateUIWhenScroll{
    CGFloat x = self.scrollView.contentOffset.x;
    // goToday 按钮
    if (self.index == 0 && x>self.scrollView.contentSize.width-self.scrollView.bounds.size.width*2) {
        [self.goTodayButton setHidden:YES];
    }else{
        [self.goTodayButton setHidden:NO];
    }
    // 抽屉
    if (self.index == 0 && x>self.scrollView.contentSize.width-self.scrollView.bounds.size.width*2) {
        // 激活抽屉
        RSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.dynamicsDrawerViewController setPaneDragRevealEnabled:YES forDirection:MSDynamicsDrawerDirectionRight];
    }else{
        // 取消抽屉
        RSAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.dynamicsDrawerViewController setPaneDragRevealEnabled:NO forDirection:MSDynamicsDrawerDirectionRight];
    }
    // 月份和年份
    if (x >= 0 && x <= self.scrollView.contentSize.width - self.scrollView.frame.size.width) {
        NSUInteger index = [self.lineChartView indexFromX:x+self.scrollView.frame.size.width/2];
        NSDate* date = [self dateWithXIndex:index];
        // 月份
        static NSDateFormatter *dateFormatter1 = nil;
        if (!dateFormatter1) {
            dateFormatter1 = [[NSDateFormatter alloc] init];
            [dateFormatter1 setDateFormat:@"MMMM"];
        }
        self.monthLabel.text = [dateFormatter1 stringFromDate:date];
        // 年份
        if (self.lastDate) {
            if (self.lastDate.year != date.year) {
                [[TWMessageBarManager sharedInstance] hideAll];
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:[NSString stringWithFormat:@"%d年",date.year]
                                                               description:nil
                                                                      type:TWMessageBarMessageTypeSuccess];
            }
        }
        self.lastDate = date;
    }
}

#pragma mark private UI lineChartView

-(void) updateLineChartView{
    // 红色标记
    self.lineChartView.redIndex = -1;
    // X轴日期
    if (!self.lineChartView.xLabels) {
        self.lineChartView.xLabels = [NSMutableArray arrayWithCapacity:ShowDayCount];
    }
    [self.lineChartView.xLabels removeAllObjects];
    
    static NSDateFormatter *dateFormatter2 = nil;
    if (!dateFormatter2) {
        dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"EEE\ndd"];
    }
    self.dates = nil;
    NSMutableArray* dates = [NSMutableArray arrayWithCapacity:ShowDayCount];
    
    // 删除月份的label
    for (UIView* view in self.scrollContentView.subviews) {
        if (view.tag == 0) {
            continue;
        }
        [view removeFromSuperview];
    }
    
    for (int i=0; i<ShowDayCount; i++) {
        NSTimeInterval aTimeInterval = [self.today timeIntervalSinceReferenceDate] - D_DAY * ((ShowDayCount - i -1) + ShowDayCount * self.index);
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
        [self.lineChartView.xLabels addObject:[dateFormatter2 stringFromDate:date]];
        [dates addObject:date];
        // 红色标记
        if (self.index == 0 && [date isToday]) {
            self.lineChartView.redIndex = i;
        }
        //        // 月份变化
        //        static NSDateFormatter *dateFormatter3 = nil;
        //        if (!dateFormatter3) {
        //            dateFormatter3 = [[NSDateFormatter alloc] init];
        //            [dateFormatter3 setDateFormat:@"MMMM"];
        //        }
        //        if (date.day == 1) {
        //            UILabel* month = [[UILabel alloc] init];
        //            month.tag = 1;
        //            month.font = [UIFont systemFontOfSize:24];
        //            month.text = [dateFormatter3 stringFromDate:date];
        //            [self.scrollContentView addSubview:month];
        //            CGFloat x = 320.0 / 7 * i;
        //            [month mas_updateConstraints:^(MASConstraintMaker *make) {
        //                make.left.equalTo(@(x));
        //                make.bottom.equalTo(@(-10));
        //            }];
        //        }
    }
    self.dates = dates;
    // 如果当前屏是今天，则多出3天的列
    if (self.index == 0) {
        for (int i=0; i<TodayMoreDayCount; i++) {
            NSTimeInterval aTimeInterval = [self.today timeIntervalSinceReferenceDate] + D_DAY * (i + 1);
            NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
            [self.lineChartView.xLabels addObject:[dateFormatter2 stringFromDate:date]];
        }
    }
    
    //    CGFloat width = 0;
    //    for (NSString* label in self.lineChartView.xLabels) {
    //        width += [label sizeWithAttributes:@{NSFontAttributeName:self.lineChartView.xLabelFont}].width + 20;
    //    }
    
    CGFloat width = 320.0 / 7 * [self.lineChartView.xLabels count];
    [self.lineChartView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@(0));
        make.width.equalTo(@(width));
    }];
    
    // 计算点， 启动
    [self setUpLineChartView];
    
    [self.lineChartView setNeedsDisplay];
    [self.lineChartView setNeedsLayout];
    [self.lineChartView layoutIfNeeded];
}

-(void) setUpLineChartView{
    if (!self.lineChartView.components) {
        self.lineChartView.components = [NSMutableArray arrayWithCapacity:1];
    }
    [self.lineChartView.components removeAllObjects];
    
    // 图表组件
    WYLineChartViewComponent *component = [[WYLineChartViewComponent alloc] init];
    [component setPoints:self.points];
    component.lastValueIndex = self.lastValueIndex;
    component.lastValue = self.lastValue;
    component.nextValueIndex = self.nextValueIndex;
    component.nextValue = self.nextValue;
    [component setShouldLabelValues:YES];
    [component setLabelFormat:@"%.0f"];
    [component setColour:[UIColor redColor]];
    
    // 最大值
    self.lineChartView.maxValue = self.maxValue == 0? 1:self.maxValue ;
    self.lineChartView.autoscaleYAxis = YES;
    
    [self.lineChartView setComponents:[@[component] mutableCopy]];
    [self.lineChartView setNeedsDisplay];
}

-(void) setUpComponent{
    // 归0
    self.points = nil;
    self.lastValue = nil;
    self.lastValueIndex = nil;
    self.nextValue = nil;
    self.nextValueIndex = nil;
    self.maxValue = 0;
    
    
    // 计算卡路里的数据
    NSInteger weight = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserWeight];
    if (!weight) {
        weight = RSUserWeightDefault;
    }
    NSInteger height = [[NSUserDefaults standardUserDefaults] integerForKey:RSUserHeight];
    if (!height) {
        height = RSUserHeightDefault;
    }
    
    NSMutableArray* points = [NSMutableArray array];
    
    for (int i=0; i<ShowDayCount; i++) {
        NSTimeInterval aTimeInterval = [self.today timeIntervalSinceReferenceDate] - D_DAY * ((ShowDayCount - i -1) + ShowDayCount * self.index);
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
        
        double value = -1;
        for (RSRecordEntity* record in self.recordArray) {
            NSDate* recordDate = [NSDate dateWithTimeIntervalSince1970:record.beginTime.doubleValue];
            if ([date isEqualToDateIgnoringTime:recordDate]) {
                if (value == -1) {
                    value = 0;
                }
                // 模式相关转换
                double count = 0;
                switch (_model) {
                    case RSMainViewControllerModelKcal:
                        count = [RSKcalUtil kcalWithHeight:height count:[record.count integerValue] weight:weight];
                        break;
                    case RSMainViewControllerModelCount:
                        count = [record.count integerValue];
                        break;
                    case RSMainViewControllerModelTime:
                        count = [record.time doubleValue]/D_MINUTE;
                        break;
                    default:
                        break;
                }
                value += count;
            }
        }
        if (value == -1) {
            [points addObject:[NSNull null]];
        }else{
            value = roundf(value);
            [points addObject:@((NSInteger)value)];
            if (self.maxValue < value) {
                self.maxValue = value;
            }
        }
    }
    // 如果当前屏是今天，则多出3天的列
    if (self.index == 0) {
        for (int i=0; i<TodayMoreDayCount; i++) {
            [points addObject:[NSNull null]];
        }
    }
    
    // 上个点
    if (self.lastRecordArray) {
        RSRecordEntity* firstEntity = self.lastRecordArray.firstObject;
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:firstEntity.beginTime.doubleValue];
        NSInteger index = [NSDate daysBetweenDate:date andDate:self.today];
        index = index - ShowDayCount * (self.index + 1) + 1;
        self.lastValueIndex = @(-index);
        double value = 0;
        for (RSRecordEntity* record in self.lastRecordArray) {
            // 模式相关转换
            double count = 0;
            switch (_model) {
                case RSMainViewControllerModelKcal:
                    count = [RSKcalUtil kcalWithHeight:height count:[record.count integerValue] weight:weight];
                    break;
                case RSMainViewControllerModelCount:
                    count = [record.count integerValue];
                    break;
                case RSMainViewControllerModelTime:
                    count = [record.time doubleValue];
                    break;
                default:
                    break;
            }
            value += count;
        }
        value = roundf(value);
        self.lastValue = @((NSInteger)value);
        if (self.maxValue < value) {
            self.maxValue = value;
        }
    }
    // 下个点
    if (self.nextRecordArray) {
        RSRecordEntity* firstEntity = self.nextRecordArray.firstObject;
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:firstEntity.beginTime.doubleValue];
        NSInteger index = [NSDate daysBetweenDate:date andDate:self.today];
        index = ShowDayCount * self.index - index;
        self.nextValueIndex = @(index);
        double value = 0;
        for (RSRecordEntity* record in self.nextRecordArray) {
            // 模式相关转换
            double count = 0;
            switch (_model) {
                case RSMainViewControllerModelKcal:
                    count = [RSKcalUtil kcalWithHeight:height count:[record.count integerValue] weight:weight];
                    break;
                case RSMainViewControllerModelCount:
                    count = [record.count integerValue];
                    break;
                case RSMainViewControllerModelTime:
                    count = [record.time doubleValue];
                    break;
                default:
                    break;
            }
            value += count;
        }
        value = roundf(value);
        self.nextValue = @((NSInteger)value);
        if (self.maxValue < value) {
            self.maxValue = value;
        }
    }
    self.points = points;
}
#pragma mark - private DB
-(void) loadRecord{
    NSAssert(self.today != nil, @"today 为 nil");
    NSLog(@"mainView  开始加载数据库");
    // 本屏的记录数据
    NSTimeInterval beginningTimeInterval = [self.today timeIntervalSinceReferenceDate] - D_DAY * (ShowDayCount -1) - D_DAY * ShowDayCount * self.index;
    NSDate *beginningDate = [[NSDate dateWithTimeIntervalSinceReferenceDate:beginningTimeInterval] beginningOfDay];
    
    NSTimeInterval endTimeInterval = [self.today timeIntervalSinceReferenceDate] - D_DAY * ShowDayCount * self.index;
    NSDate *endDate = [[NSDate dateWithTimeIntervalSinceReferenceDate:endTimeInterval] endOfDay];
    
    NSArray* recordArray = [RSRecordEntity where:@"beginTime>=%f AND beginTime<=%f",[beginningDate timeIntervalSince1970],[endDate timeIntervalSince1970]];
    self.recordArray = recordArray;
    // 上次的记录
    NSArray* lastRecordArray = nil;
    RSRecordEntity* lastRecord = [[RSRecordEntity where:[NSString stringWithFormat:@"beginTime<%f",[beginningDate timeIntervalSince1970]] order:@{@"beginTime" : @"DESC"} limit:@(1)] lastObject];
    if (lastRecord) {
        NSDate* lastDate = [NSDate dateWithTimeIntervalSince1970:[lastRecord.beginTime doubleValue]];
        NSDate* beginningOfDay = [lastDate beginningOfDay];
        NSDate* endOfDay = [lastDate endOfDay];
        lastRecordArray = [RSRecordEntity where:@"beginTime>=%f AND beginTime<=%f",[beginningOfDay timeIntervalSince1970],[endOfDay timeIntervalSince1970]];
    }
    self.lastRecordArray = lastRecordArray;
    // 下次的记录
    NSArray* nextRecordArray = nil;
    RSRecordEntity* nextRecord = [[RSRecordEntity where:[NSString stringWithFormat:@"beginTime>%f",[endDate timeIntervalSince1970]] order:@{@"beginTime" : @"ASC"} limit:@(1)] lastObject];
    if (nextRecord) {
        NSDate* nextDate = [NSDate dateWithTimeIntervalSince1970:[nextRecord.beginTime doubleValue]];
        NSDate* beginningOfDay = [nextDate beginningOfDay];
        NSDate* endOfDay = [nextDate endOfDay];
        nextRecordArray = [RSRecordEntity where:@"beginTime>=%f AND beginTime<=%f",[beginningOfDay timeIntervalSince1970],[endOfDay timeIntervalSince1970]];
    }
    self.nextRecordArray = nextRecordArray;
    [self setUpComponent];
    NSLog(@"mainView  结束加载数据库");
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_PullRightRefreshView egoRefreshScrollViewDidScroll:scrollView];
    
    if (!_PullLeftRefreshView.hidden) {
        [_PullLeftRefreshView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    //    // 月份年份变化
    //    [self updateMonthYear:scrollView];
    
    // UI变化
    [self updateUIWhenScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_PullRightRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
    
    if (!_PullLeftRefreshView.hidden) {
        [_PullLeftRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}
#pragma mark - EGORefreshTableHeaderDelegate
- (void)refreshDone {
    _reloading = NO;
    [_PullRightRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    [_PullLeftRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
}

#define LOAD_SLEEP 1
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    _reloading = YES;
//    NSLog(@"---------------可耻的分割线-------------------");
    if (view == _PullLeftRefreshView) {
        self.index = self.index - 1;
        // 加载数据,刷新视图
//        NSLog(@"看右边的数据  线程:%@",[NSThread currentThread]);
//        dispatch_queue_t urls_queue = dispatch_queue_create("blog.devtang.com", NULL);
//        dispatch_async(urls_queue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"加载前  线程:%@",[NSThread currentThread]);
            [self loadRecord];
//            NSLog(@"加载后  线程:%@",[NSThread currentThread]);
//            NSLog(@"睡眠前  线程:%@",[NSThread currentThread]);
            sleep(LOAD_SLEEP);
//            NSLog(@"睡眠后  线程:%@",[NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"更新UI前  线程:%@",[NSThread currentThread]);
                [self updateUI];
//                NSLog(@"更新UI后  线程:%@",[NSThread currentThread]);
                CGPoint leftOffset = CGPointMake(0,0);
                [self.scrollView setContentOffset:leftOffset animated:NO];
//                NSLog(@"停止load前  线程:%@",[NSThread currentThread]);
                [self refreshDone];
//                NSLog(@"停止load后  线程:%@",[NSThread currentThread]);
            });
        });
    }
    if (view == _PullRightRefreshView) {
        self.index = self.index + 1;
        // 加载数据,刷新视图
//        NSLog(@"看左边的数据  线程:%@",[NSThread currentThread]);
//        dispatch_queue_t urls_queue = dispatch_queue_create("blog.devtang.com", NULL);
//        dispatch_async(urls_queue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"加载前  线程:%@",[NSThread currentThread]);
            [self loadRecord];
//            NSLog(@"加载后  线程:%@",[NSThread currentThread]);
//            NSLog(@"睡眠前  线程:%@",[NSThread currentThread]);
            sleep(LOAD_SLEEP);
//            NSLog(@"睡眠后  线程:%@",[NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"更新UI前  线程:%@",[NSThread currentThread]);
                [self updateUI];
//                NSLog(@"更新UI后  线程:%@",[NSThread currentThread]);
                CGPoint rightOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width,0);
                [self.scrollView setContentOffset:rightOffset animated:NO];
//                NSLog(@"停止load前  线程:%@",[NSThread currentThread]);
                [self refreshDone];
//                NSLog(@"停止load后  线程:%@",[NSThread currentThread]);
            });
        });
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    return _reloading;
}

#pragma mark - IBAction
- (IBAction)jumpButtonClick:(UIButton *)sender {
    if ([RSBluetoothManager shared].contented) {
        RSSkippingViewController* skippingViewController = [[RSSkippingViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:skippingViewController animated:YES];
    }else{
        RSConnectViewController* connectViewController = [[RSConnectViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:connectViewController animated:YES];
    }
}
- (IBAction)userButtonClick:(id)sender {
    RSUserViewController* userViewController = [[RSUserViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:userViewController animated:YES];
}
-(void) settingButtonClick:(id)sender{
    RSDynamicsDrawerViewController* dd = (RSDynamicsDrawerViewController*)self.parentViewController;
    [dd setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionRight animated:YES allowUserInterruption:YES completion:nil];
}
-(void) modelButtonClick:(id)sender{
    _model++;
    if (_model>RSMainViewControllerModelTime) {
        _model = RSMainViewControllerModelKcal;
    }
    [self setUpComponent];
    [self updateUI];
}
- (IBAction)goTodayButtonClick:(id)sender {
    self.index = 0;
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadRecord];
        sleep(LOAD_SLEEP);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
            CGPoint rightOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width,0);
            [self.scrollView setContentOffset:rightOffset animated:NO];
            [hud hide:YES];
        });
    });
}

#pragma mark - WYLineChartViewDelegate
-(void) tapComponent:(WYLineChartViewComponent*)component xIndex:(NSInteger)index{
    for (int i=0; i<ShowDayCount; i++) {
        if (index != i) {
            continue;
        }
        NSTimeInterval aTimeInterval = [self.today timeIntervalSince1970] - D_DAY * ((ShowDayCount - i -1) + ShowDayCount * self.index);
        // 跳转
        RSRecordViewController* recordViewController = [[RSRecordViewController alloc] initWithNibName:nil bundle:nil];
        recordViewController.timeInterval = aTimeInterval;
        [self.navigationController pushViewController:recordViewController animated:YES];
        break;
    }
}
@end
