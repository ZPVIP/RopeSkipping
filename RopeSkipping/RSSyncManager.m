//
//  RSSyncManager.m
//  RopeSkipping
//
//  Created by 管理员 on 14-2-25.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "RSSyncManager.h"
#import <ASIHTTPRequest.h>
#import "RSRecordEntity.h"
#import <OpenUDID.h>
#import <JSONKit.h>
#import "ObjectiveRecord.h"


// 生产环境
static NSString* const uploadURL = @"http://srv.coolplay.tv:8888/ios/upload/data";
static NSString* const downloadURL = @"http://srv.coolplay.tv:8888/ios/search/data";
// 开发环境
//static NSString* const uploadURL = @"http://coolplay.mirror-networks.com/ios/upload/data";
//static NSString* const downloadURL = @"http://coolplay.mirror-networks.com/ios/search/data";

@implementation RSSyncManager
+ (instancetype) shared {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(void) upload{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 读取数据库
        NSArray* records = [RSRecordEntity where:@{@"sync":@NO}];
        if (!records || records.count == 0) {
            NSLog(@"无数据,不用上传");
            return;
        }
        NSLog(@"上传数据 %d 条",records.count);
        // 参数设计
        NSMutableDictionary* jsonD = [@{} mutableCopy];
        NSMutableArray* array = [@[] mutableCopy];
        for (RSRecordEntity* entity in records) {
            NSMutableDictionary* dic = [@{} mutableCopy];
            [dic setObject:[OpenUDID value] forKey:@"mac"];
            [dic setObject:entity.uuid forKey:@"uuid"];
            [dic setObject:entity.beginTime forKey:@"beginTime"];
            [dic setObject:entity.time forKey:@"endTime"];
            [dic setObject:entity.count forKey:@"frequency"];
            [array addObject:dic];
        }
        [jsonD setObject:array forKey:@"data"];
        ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadURL]];
        __weak ASIHTTPRequest* weakRequest = request;
        NSLog(@"上传请求参数:%@",jsonD);
        [request setPostBody:[NSMutableData dataWithData:[[jsonD JSONString] dataUsingEncoding:NSUTF8StringEncoding]]];
        [request setCompletionBlock:^{
            NSLog(@"请求完成:%@",weakRequest.responseString);
            NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
            NSNumber* errorNum = [json objectForKey:@"errno"];
            NSString* errmsg = [json objectForKey:@"errmsg"];
            NSLog(@"errorNum : %@",errorNum);
            NSLog(@"errmsg: %@",errmsg);
            if (errorNum && errorNum.integerValue == 0) {
                NSLog(@"修改状态位");
                for (RSRecordEntity* entity in records) {
                    entity.sync = @YES;
                    [entity save];
                }
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"请求未完成:%@",weakRequest.responseString);
        }];
        [request startSynchronous];
    });
}
-(void) downloadWithBlock:(void (^)(BOOL success))block{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"下载数据");
        // 参数设计
        NSMutableDictionary* jsonD = [@{@"mac":[OpenUDID value]} mutableCopy];
        
        ASIHTTPRequest* request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:downloadURL]];
        __weak ASIHTTPRequest* weakRequest = request;
        NSLog(@"下载请求参数:%@",jsonD);
        [request setPostBody:[NSMutableData dataWithData:[[jsonD JSONString] dataUsingEncoding:NSUTF8StringEncoding]]];
        [request setCompletionBlock:^{
            NSLog(@"请求完成:%@",weakRequest.responseString);
            NSMutableDictionary* json = [[weakRequest responseString] objectFromJSONStringWithParseOptions:JKParseOptionStrict];
            NSNumber* errorNum = [json objectForKey:@"errno"];
            NSString* errmsg = [json objectForKey:@"errmsg"];
            NSArray* data = [json objectForKey:@"data"];
            NSLog(@"errorNum : %@",errorNum);
            NSLog(@"errmsg: %@",errmsg);
            if (errorNum && errorNum.integerValue == 0) {
                NSLog(@"下载成功,更新数据库");
                for (int i=0; i<data.count; i++) {
                    NSDictionary* dic = data[i];
                    NSString* uuid = [dic objectForKey:@"uuid"];
                    RSRecordEntity* record = [RSRecordEntity findOrCreate:@{@"uuid":uuid}];
                    [record update:@{@"beginTime":[dic objectForKey:@"beginTime"]}];
                    [record update:@{@"count":[dic objectForKey:@"frequency"]}];
                    [record update:@{@"time":[dic objectForKey:@"endTime"]}];
                    [record update:@{@"sync":@YES}];
                    [record save];
                }
                block(YES);
            }else{
                block(NO);
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"请求未完成:%@",weakRequest.responseString);
            block(NO);
        }];
        [request startSynchronous];
    });
}
@end
