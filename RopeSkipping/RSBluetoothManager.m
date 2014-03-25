//
//  RSBluetoothManager.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-18.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSBluetoothManager.h"
#import "OWUProximityManager.h"

@interface RSBluetoothManager ()<OWUProximityServerDelegate>

// 定时器
@property (nonatomic,weak) NSTimer* timer;
@end

@implementation RSBluetoothManager

- (id)init
{
    self = [super init];
    if (self) {
        _contented = NO;
    }
    return self;
}

+ (instancetype) shared {
    static RSBluetoothManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RSBluetoothManager alloc] init];
    });
    
    return _sharedInstance;
}

#define TryContentTime 10

-(void) content{
    NSLog(@"开始连接");
    if (self.contented) {
        return;
    }
    
    [[OWUProximityManager shared] startupServerWithDelegate:self];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TryContentTime target:self selector:@selector(checkConnectForTimer) userInfo:nil repeats:NO];
}
-(void) checkConnectForTimer{
    NSLog(@"定时器,检查是否连接上");
    if (!self.contented) {
        NSLog(@"未连接上,取消搜索");
        // 停止搜索
        [[OWUProximityManager shared] teardownService];
        // 通知
        [self proximityServerCannotConnectToClient];
    }
}
-(void) disconnect{
    NSLog(@"主动断开连接");
    [[OWUProximityManager shared] teardownService];
    [self proximityServerDisconnect];
}


#pragma mark - OWUBlueBeaconServerDelegate

- (void)proximityServerDidConnectToClient {
    NSLog(@"连接成功");
    _contented = YES;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.delegate) {
        [self.delegate contentResult:YES];
    }
}

- (void)proximityServerDidReceiveNewDictionary:(NSDictionary*)dictionary {
    if (self.delegate) {
        [self.delegate getMessage:dictionary];
    }
}

- (void) proximityServerCannotConnectToClient{
    NSLog(@"连接失败");
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.delegate) {
        [self.delegate contentResult:NO];
    }
}
- (void) proximityServerDisconnect{
    NSLog(@"断开连接");
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    _contented = NO;
    if (self.delegate) {
        [self.delegate disconnect];
    }
}
@end
