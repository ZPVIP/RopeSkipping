//
//  NSDate+WY.m
//  RopeSkipping
//
//  Created by 管理员 on 14-1-20.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "NSDate+WY.h"

@implementation NSDate (WY)
- (NSMutableArray*) daysInThisMonth{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:31];
    NSRange days = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:self];
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self];
    for (int i=(int)days.location; i<=days.length; i++) {
        [comp setDay:i];
        [result addObject:[[NSCalendar currentCalendar] dateFromComponents:comp]];
    }
    return result;
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}
@end
