/**
 * Copyright (c) 2011 Muh Hon Cheng
 * Created by honcheng on 28/4/11.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2011	Muh Hon Cheng
 * @version
 * 
 */

#import <UIKit/UIKit.h>

@class WYLineChartViewComponent;

@protocol WYLineChartViewDelegate <NSObject>

-(void) tapComponent:(WYLineChartViewComponent*)component xIndex:(NSInteger)index;

@end


@interface WYLineChartViewComponent : NSObject
@property (nonatomic, assign) BOOL shouldLabelValues;
@property (nonatomic, strong) NSArray *points;
@property (nonatomic, strong) UIColor *colour;
@property (nonatomic, copy) NSString *title, *labelFormat;

@property (nonatomic) NSNumber* lastValueIndex;
@property (nonatomic) NSNumber* lastValue;
@property (nonatomic) NSNumber* nextValueIndex;
@property (nonatomic) NSNumber* nextValue;

@property (nonatomic) NSArray* pointsXY;
@end

#define WYColorBlue [UIColor colorWithRed:0.0 green:153/255.0 blue:204/255.0 alpha:1.0]
#define WYColorGreen [UIColor colorWithRed:153/255.0 green:204/255.0 blue:51/255.0 alpha:1.0]
#define WYColorOrange [UIColor colorWithRed:1.0 green:153/255.0 blue:51/255.0 alpha:1.0]
#define WYColorRed [UIColor colorWithRed:1.0 green:51/255.0 blue:51/255.0 alpha:1.0]
#define WYColorYellow [UIColor colorWithRed:1.0 green:220/255.0 blue:0.0 alpha:1.0]
#define WYColorDefault [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]

@interface WYLineChartView : UIView
@property (nonatomic, assign) float interval;
@property (nonatomic, assign) float minValue;
@property (nonatomic, assign) float maxValue;
@property (nonatomic, strong) NSMutableArray *components, *xLabels;
@property (nonatomic, strong) UIFont *yLabelFont, *xLabelFont, *valueLabelFont, *legendFont;
// Use these to autoscale the y axis to 'nice' values.
// If used, minValue is ignored (0) and interval computed internally
@property (nonatomic, assign) BOOL autoscaleYAxis;
@property (nonatomic, assign) NSUInteger numYIntervals; // Use n*5 for best results
@property (nonatomic, assign) NSUInteger numXIntervals;

@property (nonatomic, weak) id<WYLineChartViewDelegate> delegate;

@property (nonatomic) NSInteger redIndex;



-(NSUInteger) indexFromX:(CGFloat) x;

-(CGFloat) xFromIndex:(NSUInteger) index;
@end
