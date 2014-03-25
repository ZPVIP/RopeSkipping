//
//  RSMainViewController.h
//  RopeSkipping
//
//  Created by 管理员 on 14-1-17.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* const RSNotificationMainNeedUpdateUI = @"RSNotificationMainNeedUpdateUI";

@interface RSMainViewController : RSBaseMobClickViewController
@property (nonatomic) NSDate* today;
@property (nonatomic) NSUInteger index;
//-(void) loadRecord;
@end
