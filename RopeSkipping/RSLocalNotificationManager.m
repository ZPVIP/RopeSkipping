//
//  RSLocalNotificationManager.m
//  RopeSkipping
//
//  Created by 管理员 on 14-3-5.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSLocalNotificationManager.h"
#import <NSDate-Utilities.h>
#import <NSDate+CupertinoYankee.h>

@implementation RSLocalNotificationManager

+ (instancetype) shared {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(void) fire{
    static NSDateFormatter *dateFormatter1 = nil;
    if (!dateFormatter1) {
        dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    //发送通知
    if ([UIApplication sharedApplication].scheduledLocalNotifications.count!=0) {
        return;
    }
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        // 预计提醒时间
        NSDate *fireDate=[[NSDate new] dateByAddingTimeInterval:D_DAY];
        NSLog(@"预计提醒时间:%@",[dateFormatter1 stringFromDate:fireDate]);
        // 提醒日 晚上八点
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:fireDate.year];
        [components setMonth:fireDate.month];
        [components setDay:fireDate.day];
        [components setHour:20];
        [components setMinute:0];
        [components setSecond:0];
        NSDate* date8 = [calendar dateFromComponents:components];
        // 提醒日 早晨十点
        [components setHour:10];
        NSDate* date10 = [calendar dateFromComponents:components];
        // 计算真实提醒时间
        if ([fireDate compare:date10] == NSOrderedAscending) {
            fireDate = date10;
        }
        if ([fireDate compare:date8] == NSOrderedDescending) {
            fireDate = [date10 dateByAddingDays:1];
        }
        NSLog(@"真实提醒时间:%@",[dateFormatter1 stringFromDate:fireDate]);
        notification.fireDate=fireDate;
        notification.repeatInterval=NSCalendarUnitDay;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber=1; //应用的红色数字
        notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
        //去掉下面2行就不会弹出提示框
        notification.alertBody=@"该运动了哦";//提示信息 弹出提示框
        notification.alertAction = @"打开";  //提示框按钮
        //notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        
        // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
        //notification.userInfo = infoDict; //添加额外的信息
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}
-(void) down{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
@end
