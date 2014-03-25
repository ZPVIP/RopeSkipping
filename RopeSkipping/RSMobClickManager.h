//
//  RSMobClickManager.h
//  RopeSkipping
//
//  Created by 管理员 on 14-3-5.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

// MobClick
static NSString* const MobClickAppKey = @"53157bc956240b4826022fef";

@interface RSMobClickManager : NSObject
+ (instancetype) shared;

-(void) setUp;
@end

@interface RSBaseMobClickViewController : UIViewController

@end
