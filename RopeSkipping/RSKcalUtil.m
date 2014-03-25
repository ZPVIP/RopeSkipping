//
//  RSKcalUtil.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-20.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSKcalUtil.h"

@implementation RSKcalUtil
+(double) kcalWithHeight:(NSInteger) height count:(NSInteger) count weight:(NSInteger) weight{
    return height * count * weight * 6.07 / 1000000;
}
@end
