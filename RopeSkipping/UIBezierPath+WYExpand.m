//
//  UIBezierPath+WYExpand.m
//  WYChartDemo
//
//  Created by mirror on 14-1-8.
//  Copyright (c) 2014年 Mirror. All rights reserved.
//

#import "UIBezierPath+WYExpand.h"

void getPointsFromBezier(void *info, const CGPathElement *element);
NSArray *pointsFromBezierPath(UIBezierPath *bpath);


#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

@implementation UIBezierPath (WYExpand)

// Get points from Bezier Curve
void getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    
    // Retrieve the path element type and its points
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Add the points if they're available (per type)
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

NSArray *pointsFromBezierPath(UIBezierPath *bpath)
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(bpath.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}

- (UIBezierPath*)smoothedPathWithGranularity:(NSInteger)granularity;
{
    NSMutableArray *points = [pointsFromBezierPath(self) mutableCopy];
    
    if (points.count < 4) return [self copy];
    
    // Add control points to make the math make sense
    [points insertObject:[points objectAtIndex:0] atIndex:0];
    [points addObject:[points lastObject]];
    
    UIBezierPath *smoothedPath = [self copy];
    [smoothedPath removeAllPoints];
    
    [smoothedPath moveToPoint:POINT(0)];
    
    for (NSUInteger index = 1; index < points.count - 2; index++)
    {
        CGPoint p0 = POINT(index - 1);
        CGPoint p1 = POINT(index);
        CGPoint p2 = POINT(index + 1);
        CGPoint p3 = POINT(index + 2);
        
        // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
        for (int i = 1; i < granularity; i++)
        {
            float t = (float) i * (1.0f / (float) granularity);
            float tt = t * t;
            float ttt = tt * t;
            
            CGPoint pi; // intermediate point
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            [smoothedPath addLineToPoint:pi];
        }
        
        // Now add p2
        [smoothedPath addLineToPoint:p2];
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
    
    return smoothedPath;
}

+(UIBezierPath*) pathWithPoint:(NSArray*)points Ratio:(CGFloat)ratio{
    if (!points) {
        return nil;
    }
    if (points.count < 2) {
        return nil;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (NSValue* value in points) {
        NSUInteger index = [points indexOfObject:value];
        CGPoint point = [value CGPointValue];
        // 起始点  0
        if (index == 0) {
            [path moveToPoint:point];
            continue;
        }
        // 终点  n
        if (index == points.count-1) {
            [path addLineToPoint:point];
            continue;
        }
        // 中间点
        CGPoint pointLast = [points[index-1] CGPointValue];
        CGPoint pointControl1 = CGPointMake(pointLast.x+(point.x-pointLast.x)*ratio, pointLast.y+(point.y-pointLast.y)*ratio);
        
        CGPoint pointNext = [points[index+1] CGPointValue];
        CGPoint pointSymmetry = CGPointMake(point.x-(pointNext.x-point.x), point.y-(pointNext.y-point.y));
        
        CGPoint pointControl2 = CGPointMake(point.x-(point.x-pointSymmetry.x)*ratio, point.y-(point.y-pointSymmetry.y)*ratio);
        
        [path addCurveToPoint:point controlPoint1:pointControl1 controlPoint2:pointControl2];
    }
    return path;
}
@end
