//
//  WYRandom.m
//  RopeSkipping
//
//  Created by 管理员 on 14-1-20.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "WYRandom.h"

@implementation WYRandom
+(NSInteger) randomFrom:(NSInteger) from to:(NSInteger)to{
    return from + (arc4random() % (to - from + 1));
}
@end
