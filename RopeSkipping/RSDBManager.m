//
//  RSDBManager.m
//  RopeSkipping
//
//  Created by 管理员 on 14-3-11.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSDBManager.h"

@implementation RSDBManager

+(dispatch_queue_t) db_request_queue{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = dispatch_queue_create("com.mirror.db_request", NULL);
    });
    return _sharedInstance;
}
@end
