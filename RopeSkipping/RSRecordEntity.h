//
//  RSRecordEntity.h
//  RopeSkipping
//
//  Created by 管理员 on 14-2-20.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RSRecordEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * beginTime;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * sync;

@end
