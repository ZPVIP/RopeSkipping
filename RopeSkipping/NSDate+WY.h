//
//  NSDate+WY.h
//  RopeSkipping
//
//  Created by 管理员 on 14-1-20.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (WY)
-(NSMutableArray*) daysInThisMonth;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
@end
