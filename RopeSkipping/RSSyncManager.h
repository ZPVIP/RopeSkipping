//
//  RSSyncManager.h
//  RopeSkipping
//
//  Created by 管理员 on 14-2-25.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSyncManager : NSObject
+ (instancetype) shared;

-(void) upload;
-(void) downloadWithBlock:(void (^)(BOOL success))block;
@end
