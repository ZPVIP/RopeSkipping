//
//  RSLocalNotificationManager.h
//  RopeSkipping
//
//  Created by 管理员 on 14-3-5.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSLocalNotificationManager : NSObject
+ (instancetype) shared;
-(void) fire;
-(void) down;
@end
