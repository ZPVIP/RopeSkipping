//
//  RSBluetoothManager.h
//  RopeSkipping
//
//  Created by 管理员 on 14-2-18.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol RSBluetoothManagerDelegate <NSObject>

- (void) contentResult:(BOOL) success;
- (void) disconnect;
- (void) getMessage:(NSDictionary*)dictionary;

@end

@interface RSBluetoothManager : NSObject
@property (nonatomic,readonly) BOOL contented;
+ (instancetype) shared;
@property (nonatomic,weak) id<RSBluetoothManagerDelegate> delegate;

-(void) content;
-(void) disconnect;
@end
