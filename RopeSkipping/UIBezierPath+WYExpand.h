//
//  UIBezierPath+WYExpand.h
//  WYChartDemo
//
//  Created by mirror on 14-1-8.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (WYExpand)
- (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity;
+(UIBezierPath*) pathWithPoint:(NSArray*)points Ratio:(CGFloat)ratio;
@end
