//
//  CYCircularSlider.m
//  CYCircularSlider
//
//  Created by user on 2018/3/23.
//  Copyright © 2018年 com. All rights reserved.
//

#import "CYCircularSlider.h"
// 极坐标
typedef struct {
    CGFloat radius;
    CGFloat angle;
} DMPolarCoordinate;

#define ToRad(deg)         ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)        ( (180.0 * (rad)) / M_PI )
#define SQR(x)            ( (x) * (x) )
//StartAngle
#define leftAngle 70
//EndAngle
#define rightAngle 110

#define offsetY 0
@interface CYCircularSlider()
@property(assign,nonatomic)CGFloat minY;
@property(assign,nonatomic)CGFloat maxX;
@property(assign,nonatomic)CGFloat minX;
//起始位置
@property (nonatomic, assign) CGPoint circleStartPoint;

@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, assign) CGFloat value;// 当前值

@end

@implementation CYCircularSlider{
    int _angle;
    CGFloat radius;
    int _fixedAngle;
    CGFloat _imgWidth;
    
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _maximumValue = 15.0f;
        _minimumValue = 0.0f;
        _currentValue = 0.0f;
        _lineWidth = 3.0f;
        _imgWidth =14;
        self.value = 0;
        _unfilledColor= [UIColor colorFromHexStr:@"#414145"];
        _filledColor = [UIColor colorFromHexStr:@"#FFFFFF"];
        radius = 330;
        _angle = rightAngle+360; //400 = 360+40
        self.backgroundColor = [UIColor clearColor];
        
        self.centerPoint = CGPointMake(self.width / 2, self.height/2);
        self.circleStartPoint = CGPointMake(self.centerPoint.x - radius, self.centerPoint.y);
        
    }
    
    return  self;
}

#pragma mark 画圆
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGFloat valueWidth = self.maximumValue - self.minimumValue;
    CGFloat angleWidth = rightAngle - leftAngle;
    CGFloat currentAngle = ((self.value - self.minimumValue) / valueWidth) * angleWidth +_angle;
    
    //画固定的下层圆
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2 -offsetY, radius, M_PI/180*leftAngle, M_PI/180*rightAngle, 0);
    [_unfilledColor setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2 - offsetY, radius, M_PI/180*rightAngle, M_PI/180*_angle, 1);
    
   //画可滑动的上层圆
    [_filledColor setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
    [self drawHandle:ctx];
    self.minY = [self pointFromAngle:rightAngle].y;
    self.minX = [self pointFromAngle:rightAngle].x;
    self.maxX = [self pointFromAngle:leftAngle].x;
//    NSLog(@"minY==%f x=%f minx=%f",self.minY,self.maxX,self.minX);
    
}

#pragma mark 画按钮
-(void)drawHandle:(CGContextRef)ctx{
    CGContextSaveGState(ctx);
    CGPoint handleCenter =  [self pointFromAngle: _angle];
    [[UIColor whiteColor] set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x-_imgWidth/2, handleCenter.y-_imgWidth/2, _lineWidth+_imgWidth, _lineWidth+_imgWidth));
    CGContextRestoreGState(ctx);
}
-(CGPoint)pointRoundFromAngle:(int)angleInt{
    
    //Define the Circle center
    CGPoint centerPoint = CGPointMake(radius, radius);
    //Define The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(angleInt)));
    
    return result;
}


-(CGPoint)pointFromAngle:(int)angleInt{
    //centerPoint={149, 116.5}
//    [CYCircularSlider.m:89行] minY==253.000000 x=199.000000 minx=99.000000
    
    //Define the Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - _lineWidth/2, self.frame.size.height/2 - _lineWidth/2 -offsetY);
    //Define The point position on the circumference
//    NSLog(@"centerPoint=%@",NSStringFromCGPoint(centerPoint));
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(angleInt)));
    
    return result;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

-(BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    
//    NSLog(@"lastPoint=%@",NSStringFromCGPoint(lastPoint));
    
    
    if((lastPoint.x>=self.minX&&lastPoint.x<=self.maxX)&&(lastPoint.y>=self.minY)) { //263.5
        [self moveHandle:lastPoint];
        
//         DMPolarCoordinate polarCoordinate = pointToPolarCoordinate(self.centerPoint, lastPoint);
//        NSLog(@"polarCoordinate==%f leftAngle=%f",polarCoordinate.angle,ToRad(leftAngle));
//         double angleOffset = (polarCoordinate.angle > ToRad(leftAngle)) ? ( polarCoordinate.angle - ToRad(leftAngle)) : (polarCoordinate.angle - ToRad(leftAngle));
//        double newValue = (angleOffset / (ToRad(rightAngle) - ToRad(leftAngle))) * (self.maximumValue - self.minimumValue) + self.minimumValue;
//        newValue = MIN(MAX(newValue, self.minimumValue), self.maximumValue);
//        self.value = self.minimumValue;
//        NSLog(@"newValue = %f %f",newValue,angleOffset);
        
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)moveHandle:(CGPoint)point {
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    int currentAngle = floor(AngleFromNorth(centerPoint, point, NO));
//    NSLog(@"currentAngle=%d",currentAngle);
    if (currentAngle >=rightAngle) {
        _angle = rightAngle;
    }else if (currentAngle<=leftAngle) {
        _angle = leftAngle;
        
    }else{
        _angle = currentAngle;
    }
    _currentValue =[self valueFromAngle];
//    NSLog(@"currentFinish=%d",currentAngle);
    [self setNeedsDisplay];
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

//在这个地方调整进度条
-(float) valueFromAngle {
//    NSLog(@"valueFromAngle=%d",_angle);
    if(_angle <= leftAngle) {
        _currentValue = leftAngle;
    } else if(_angle>leftAngle && _angle <= rightAngle){
        _currentValue = _angle;
    }else if (_angle > rightAngle){
        _currentValue = rightAngle;
    }
    _fixedAngle = _currentValue;
    int sub = rightAngle - leftAngle;
//    NSLog(@"fixedAngle=%f",_currentValue);
    int temp =round(_fixedAngle*(_maximumValue - _minimumValue) /sub);
    NSLog(@"temp=%d",temp);
    self.slideValue = abs(temp-41)+1;
    return abs(temp-41)+1;//abs(temp-41);
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
       CGPoint lastPoint = [touch locationInView:self];
//     NSLog(@"endtouch==%@",NSStringFromCGPoint(lastPoint));
    int value  = (int8_t)roundf(_currentValue);
//    NSLog(@"endTrackingWithTouch value=%d",value);
    if (value>=15) {
        value = 15;
    }
    if (value<=1) {
        value =1;
    }
    [self.delegate senderVlueWithNum:value];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    //集合转数组,其实只有一个对象
    NSArray *arr = [touches allObjects];
    UITouch *touch = arr[0];
    CGPoint lastPoint = [touch locationInView:self];
//    NSLog(@"%@",NSStringFromCGPoint(lastPoint));
//    NSLog(@"%d",touches.count);
    
    if((lastPoint.x>=self.minX&&lastPoint.x<=self.maxX)&&(lastPoint.y>=self.minY)) {
            
            [self moveHandle:lastPoint];
        }
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];

}
/**
 点转化为极坐标
 @param center 圆心
 @param point 点
 @return 极坐标
 */
DMPolarCoordinate pointToPolarCoordinate(CGPoint center, CGPoint point) {
    DMPolarCoordinate polarCoordinate;
    double x = point.x - center.x;
    double y = point.y - center.y;
    polarCoordinate.radius = sqrt(pow(x, 2.0) + pow(y, 2.0));
    polarCoordinate.angle = acos(x / (sqrt(pow(x, 2.0) + pow(y, 2.0))));
    if (y < 0) {
        polarCoordinate.angle = 2 * M_PI - polarCoordinate.angle;
    }
    return polarCoordinate;
}
#pragma mark 设置进度条位置
-(void)setAngel:(int)num{
    _angle = rightAngle+360 - num * (rightAngle -leftAngle)/15;
    [self setNeedsDisplay];
}

-(void)setIsStopSlider:(BOOL)isStopSlider{
    if (isStopSlider) {
        self.userInteractionEnabled = NO;
    }else{
        self.userInteractionEnabled = YES;
    }
}
@end
