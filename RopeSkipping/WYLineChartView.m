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

#import "WYLineChartView.h"
#import "UIBezierPath+WYExpand.h"



float circle_diameter = 38;



@implementation WYLineChartViewComponent

- (id)init
{
    self = [super init];
    if (self)
    {
        _labelFormat = @"%.1f%%";
    }
    return self;
}

@end

@implementation WYLineChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        _interval = 20;
		_maxValue = 100;
		_minValue = 0;
		_yLabelFont = [UIFont boldSystemFontOfSize:14];
		_xLabelFont = [UIFont boldSystemFontOfSize:12];
		_valueLabelFont = [UIFont boldSystemFontOfSize:10];
		_legendFont = [UIFont boldSystemFontOfSize:10];
        _numYIntervals = 5;
        _numXIntervals = 1;
		
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapGesture:(id)sender
{
    if (!self.delegate) {
        return;
    }
    
    UITapGestureRecognizer* tap = sender;
    CGPoint point = [tap locationInView:self];
    
    for (WYLineChartViewComponent* component in self.components) {
        for (NSValue* value in component.pointsXY) {
            CGPoint pointTest = [value CGPointValue];
            
            CGRect rect = CGRectMake(pointTest.x-circle_diameter/2, pointTest.y-circle_diameter/2, circle_diameter,circle_diameter);
            
            if (CGRectContainsPoint(rect, point)) {
                
                NSUInteger count = [component.pointsXY indexOfObject:value];
                if (component.lastValueIndex) {
                    count--;
                }
                NSInteger i = -1;
                NSInteger index = -1;
                for (id num in component.points) {
                    if (num != [NSNull null]) {
                        i++;
                    }
                    if (i == count) {
                        index = [component.points indexOfObject:num];
                        break;
                    }
                }
                NSAssert(index >=0, @"index 小于 0");
                [self.delegate tapComponent:component xIndex:index];
                return;
            }
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    
    int n_div;
    int power;
    float scale_min, scale_max, div_height;
    float top_margin = 35;
    float bottom_margin = 30;
	float x_label_height = 40;
	
    if (self.autoscaleYAxis) {
        scale_min = 0.0;
        power = floor(log10(self.maxValue/5));
        float increment = self.maxValue / (5 * pow(10,power));
        increment = (increment <= 5) ? ceil(increment) : 10;
        increment = increment * pow(10,power);
        scale_max = 5 * increment;
        self.interval = scale_max / self.numYIntervals;
    } else {
        scale_min = self.minValue;
        scale_max = self.maxValue;
    }
    n_div = (scale_max-scale_min)/self.interval + 1;
    div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);
    
    
    float margin = 0;
    float div_width = (self.frame.size.width-2*margin)/([self.xLabels count]);
    for (NSUInteger i=0; i<[self.xLabels count]; i++)
    {
        if (i % self.numXIntervals == 1 || self.numXIntervals==1) {
            int x = (int) (margin + div_width * i);
            NSString *x_label = [NSString stringWithFormat:@"%@", [self.xLabels objectAtIndex:i]];
            CGRect textFrame = CGRectMake(x, self.frame.size.height - x_label_height, div_width, x_label_height);
            
            // 红色标记
            if (self.redIndex == i) {
                CGSize size = [x_label sizeWithFont:self.valueLabelFont];
                size.width -= 26;
                size.height += 6;
                CGRect rectRed = CGRectMake(textFrame.origin.x + (textFrame.size.width - size.width)/2, textFrame.origin.y+ (textFrame.size.height - size.height)/2 - 6, size.width, size.height);
                CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
                CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
                CGContextFillRect(ctx, rectRed);
            }
            
            // X周 日期坐标
            if (self.redIndex == i) {
                CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
                CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
            }else{
                CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
                CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            }
            
            [x_label drawInRect:textFrame
                       withFont:self.xLabelFont
                  lineBreakMode:UILineBreakModeWordWrap
                      alignment:UITextAlignmentCenter];
            
            
            
            // 竖线
            if (i>30) {
                continue;
            }
            x += div_width;
            CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
            CGContextSetLineWidth(ctx, 0.5);
            CGContextMoveToPoint(ctx, x ,20);
            CGContextAddLineToPoint(ctx, x , self.frame.size.height - x_label_height - 16);
            CGContextStrokePath(ctx);
            
        };
        
    }
    
    // X轴  上边的 横线
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    float y = self.frame.size.height - x_label_height - 8;
    CGContextMoveToPoint(ctx, 0,y);
    CGContextAddLineToPoint(ctx, self.frame.size.width, y);
    CGContextStrokePath(ctx);
    
    
	
    NSMutableArray *legends = [NSMutableArray array];
    
    /////////
    
    float line_width = 8;
    
    /////////
	
    for (WYLineChartViewComponent *component in self.components)
    {
        int last_x = 0;
        int last_y = 0;
        
        if (!component.colour)
        {
            component.colour = WYColorBlue;
        }
		
        NSMutableArray* points = [NSMutableArray array];
        
		for (int x_axis_index=0; x_axis_index<[component.points count]; x_axis_index++)
        {
            id object = [component.points objectAtIndex:x_axis_index];
			
			
            if (object!=[NSNull null] && object)
            {
                float value = [object floatValue];
                
                /////////
				
				CGContextSetStrokeColorWithColor(ctx, [component.colour CGColor]);
                
                float x = margin + div_width*x_axis_index + div_width/2;
                float y = top_margin + (scale_max-value)/self.interval*div_height;
                
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                
                
                CGRect circleRect = CGRectMake(x-circle_diameter/2, y-circle_diameter/2, circle_diameter,circle_diameter);
                // 今日黄色效果
                if (self.redIndex == x_axis_index) {
                    UIImage* image = [UIImage imageNamed:@"todayYello"];
                    [image drawAtPoint:CGPointMake(x-image.size.width/2+1, y-image.size.height/2)];
                }
                
                // 画圆点
				CGContextSetFillColorWithColor(ctx, [component.colour CGColor]);
                CGContextAddEllipseInRect(ctx, circleRect);
                CGContextDrawPath(ctx, kCGPathFill);
                
                
                if (x_axis_index==[component.points count]-1)
                {
                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
                    if (component.title)
                    {
                        [info setObject:component.title forKey:@"title"];
                    }
                    ////////
                    [info setObject:[NSNumber numberWithFloat:x] forKey:@"x"];
                    [info setObject:[NSNumber numberWithFloat:y] forKey:@"y"];
                    
                    ////////
                    
					[info setObject:component.colour forKey:@"colour"];
                    [legends addObject:info];
				}
                
                last_x = x;
                last_y = y;
            }
            
        }
        if (component.lastValueIndex) {
            int x = margin + div_width*component.lastValueIndex.integerValue;
            int y = top_margin + (scale_max-component.lastValue.floatValue)/self.interval*div_height;
            [points insertObject:[NSValue valueWithCGPoint:CGPointMake(x, y)] atIndex:0];
        }
        if (component.nextValueIndex) {
            int x = margin + div_width*([component.points count] -1 + component.nextValueIndex.integerValue);
            int y = top_margin + (scale_max-component.nextValue.floatValue)/self.interval*div_height;
            [points insertObject:[NSValue valueWithCGPoint:CGPointMake(x, y)] atIndex:points.count];
        }
        
        // 弱引用
        component.pointsXY = points;
        
        // 折线
        
//        UIBezierPath* path = [UIBezierPath bezierPath];
//        for (NSValue* value in points) {
//            CGPoint point = [value CGPointValue];
//            if (value == points.firstObject) {
//                [path moveToPoint:point];
//            }else{
//                [path addLineToPoint:point];
//            }
//        }
//        //        path = [path smoothedPathWithGranularity:20];
//        path.lineWidth = line_width;
//        [path stroke];
        
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextSetLineWidth(ctx, line_width);
        
        for (int i=0; i<points.count; i++) {
            if (i == 0) {
                continue;
            }
            CGPoint pointLast = [points[i-1] CGPointValue];
            CGPoint point = [points[i] CGPointValue];
            CGContextMoveToPoint(ctx, pointLast.x ,pointLast.y);
            CGContextAddLineToPoint(ctx,point.x ,point.y);
            CGContextStrokePath(ctx);
        }
    }
	
    for (int i=0; i<[self.xLabels count]; i++)
    {
        int y_level = top_margin;
		
        for (int j=0; j<[self.components count]; j++)
        {
			NSArray *items = [[self.components objectAtIndex:j] points];
            id object = [items objectAtIndex:i];
            if (object!=[NSNull null] && object)
            {
                float value = [object floatValue];
                int x = margin + div_width*i + div_width/2;
                int y = top_margin + (scale_max-value)/self.interval*div_height;
                
                // 画数字
				if ([[self.components objectAtIndex:j] shouldLabelValues]) {
                    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
                    NSString *perc_label = value<1?[NSString stringWithFormat:@"<1"]:[NSString stringWithFormat:[[self.components objectAtIndex:j] labelFormat], value];
                    CGSize size = [perc_label sizeWithFont:self.valueLabelFont];
                    CGRect textFrame = CGRectMake(x-size.width/2,y-size.height/2, size.width,size.height);
                    [perc_label drawInRect:textFrame
                                  withFont:self.valueLabelFont
                             lineBreakMode:UILineBreakModeWordWrap
                                 alignment:UITextAlignmentCenter];
                }
                if (y>y_level) y_level = y;
            }
            
        }
    }
    
	NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"y" ascending:YES];
	[legends sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
	
    //CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
    float y_level = 0;
    for (NSMutableDictionary *legend in legends)
    {
		UIColor *colour = [legend objectForKey:@"colour"];
		CGContextSetFillColorWithColor(ctx, [colour CGColor]);
		
        NSString *title = [legend objectForKey:@"title"];
        float x = [[legend objectForKey:@"x"] floatValue];
        float y = [[legend objectForKey:@"y"] floatValue];
        if (y<y_level)
        {
            y = y_level;
        }
        
        CGRect textFrame = CGRectMake(x,y,margin,15);
        [title drawInRect:textFrame withFont:self.legendFont];
        
        y_level = y + 15;
    }
}





-(NSUInteger) indexFromX:(CGFloat) x{
    if (self.frame.size.width == 0) {
        return 0;
    }
    float div_width = (self.frame.size.width)/([self.xLabels count]);
    NSUInteger index = x/div_width;
    return index;
}
-(CGFloat) xFromIndex:(NSUInteger) index{
    float div_width = (self.frame.size.width)/([self.xLabels count]);
    return div_width * index;
}
@end
