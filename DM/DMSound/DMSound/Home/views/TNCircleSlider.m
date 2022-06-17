//
//  TNCircleSlider.m
//  ZCircleSliderDemo
//
//  Created by TigerNong on 2019/10/18.
//  Copyright © 2019 Jixin. All rights reserved.
//

#import "TNCircleSlider.h"
#define kThumbTag 1000

@interface TNCircleSlider ()
@property (nonatomic, assign) CGPoint lastPoint;
//起始位置
@property (nonatomic, assign) CGPoint circleStartPoint;

//红点
@property (nonatomic, strong) CAShapeLayer *thumbLayer;

@end

@implementation TNCircleSlider

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    //设置一些默认值
    self.clockwise = YES;
    self.centerPoint = CGPointMake(self.frame.size.width / 2, 0);
    self.circleRadius = self.frame.size.width / 2 - 30;
    self.circleBorderWidth = 4;
    self.backgroundTintColor = [UIColor colorFromHexStr:@"#414145"];
    self.minimumTrackTintColor = [UIColor colorFromHexStr:@"#FFFFFF"];
    
    self.startEngle = M_PI;
    self.endEngle = 0;
    
    self.circleStartPoint = CGPointMake(self.centerPoint.x - self.circleRadius, self.centerPoint.y);
    
    self.value = 0;
    self.thumbRadius = self.circleBorderWidth + 4;
    self.thumbColor = [UIColor whiteColor];
    self.lastPoint = self.circleStartPoint;
}


- (void)setThumbColor:(UIColor *)thumbColor{
    _thumbColor = thumbColor;
    [self setNeedsDisplay];
}

- (void)setCircleStartPoint:(CGPoint)circleStartPoint{
    _circleStartPoint = circleStartPoint;
    [self setNeedsDisplay];
}

- (void)setCircleBorderWidth:(CGFloat)circleBorderWidth{
    _circleBorderWidth = circleBorderWidth;
    [self setNeedsDisplay];
}

- (void)setBackgroundTintColor:(UIColor *)backgroundTintColor{
    _backgroundTintColor = backgroundTintColor;
    [self setNeedsDisplay];
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor{
    _minimumTrackTintColor = minimumTrackTintColor;
    [self setNeedsDisplay];
}

- (void)setCircleRadius:(CGFloat)circleRadius{
    _circleRadius = circleRadius;
    self.circleStartPoint = CGPointMake(self.centerPoint.x - self.circleRadius, self.centerPoint.y);
    [self setNeedsDisplay];
}

- (void)setCenterPoint:(CGPoint)centerPoint{
    _centerPoint = centerPoint;
    [self setNeedsDisplay];
}

- (void)setClockwise:(BOOL)clockwise{
    _clockwise = clockwise;
    CGFloat offsetY = iPhoneX ? KScaleHeight(200):KScaleHeight(250);
    self.centerPoint = CGPointMake(self.frame.size.width / 2,  -offsetY);
    [self setNeedsDisplay];
}

- (void)setValue:(CGFloat)value{
    _value = value;
//    [self setNeedsDisplay];
}

- (void)setThumbRadius:(CGFloat)thumbRadius{
    _thumbRadius = thumbRadius;
    
//    [self setNeedsDisplay];
}

- (void)setStartEngle:(CGFloat)startEngle{
    _startEngle = startEngle;
    
   
    if (_startEngle > M_PI) {
        _startEngle  = M_PI;
    }
    
    if (_startEngle < 3/4.0 * M_PI) {
//            _startEngle = 3/4.0 * M_PI;
    }
    
    
    CGFloat start = ABS(M_PI - _startEngle);
    
    double x = self.centerPoint.x - self.circleRadius * cos(start);
    double y = ABS(self.centerPoint.y - self.circleRadius * sin(start));

    y = self.centerPoint.y + self.circleRadius * sin(start);
    self.circleStartPoint = CGPointMake(x, y);
    [self setNeedsDisplay];
}


//开始绘制
-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    NSLog(@"drawRect=====");
   //绘制底本背景
       [self drawBackCircle];

   //    点击滑块移动的值
       [self drawCircleValue];

   //    滑块的初始位置
       [self drawtThumbView];
  
}

- (void)drawCircleValue{
    UIBezierPath *circlePath = nil;
    
    CGFloat originstart = self.startEngle;
    
    CGFloat currentOrigin = originstart + (M_PI - ABS(self.startEngle - M_PI) * 2) * self.value;
   
    currentOrigin = originstart - (M_PI - ABS(self.startEngle - M_PI) * 2) * self.value;
    
    circlePath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.circleRadius startAngle:originstart endAngle:currentOrigin clockwise:self.clockwise];
    
    CAShapeLayer *valueLayer = [CAShapeLayer layer];
    valueLayer.lineWidth = self.circleBorderWidth;
    valueLayer.strokeColor = self.minimumTrackTintColor.CGColor;
    valueLayer.fillColor = [UIColor clearColor].CGColor;
    valueLayer.path = circlePath.CGPath;
    valueLayer.lineCap = @"round";
    valueLayer.shouldRasterize = YES;
    [self.layer addSublayer:valueLayer];
    
}

- (void)drawtThumbView{
    
    double alpha = self.value * (M_PI - ABS(M_PI - self.startEngle) * 2);
 
    CGFloat start = ABS(M_PI - self.startEngle);
    
    double x = self.centerPoint.x - self.circleRadius * cos(alpha + start);
    double y = ABS(self.centerPoint.y - self.circleRadius * sin(alpha + start));
   
    y = self.centerPoint.y + self.circleRadius * sin(alpha + start);
    
    self.lastPoint = CGPointMake(x, y);
    
    UIBezierPath *thumbPath = [UIBezierPath bezierPathWithArcCenter:self.lastPoint radius:self.thumbRadius startAngle:0 endAngle:2 * M_PI clockwise:NO];

    CAShapeLayer *thumbLayer = [CAShapeLayer layer];
    thumbLayer.strokeColor = self.thumbColor.CGColor;
    thumbLayer.fillColor = self.thumbColor.CGColor;
    thumbLayer.path = thumbPath.CGPath;

    if (self.thumbLayer) {
        [self.thumbLayer removeFromSuperlayer];
    }
    self.thumbLayer = thumbLayer;
    [self.layer addSublayer:thumbLayer];
}

- (void)drawBackCircle{

    NSLog(@"-----drawBackCircle");
    UIBezierPath *valuePath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.circleRadius startAngle: self.startEngle endAngle:self.endEngle clockwise:self.clockwise];;

    valuePath.lineCapStyle = kCGLineJoinRound;
    
    CAShapeLayer *backLayer = [CAShapeLayer layer];
    backLayer.lineWidth = self.circleBorderWidth;
    backLayer.strokeColor = self.backgroundTintColor.CGColor;
    backLayer.fillColor = [UIColor clearColor].CGColor;
    backLayer.path = valuePath.CGPath;
    backLayer.lineCap = @"round";
    backLayer.shouldRasterize = YES;
    [self.layer addSublayer:backLayer];
    backLayer.drawsAsynchronously = YES;
    backLayer.contentsScale = [UIScreen mainScreen].scale;
   
    
}

#pragma mark - UIControl methods

//点击开始
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    CGPoint starTouchPoint = [touch locationInView:self];
    
    if (starTouchPoint.y < self.centerPoint.y - self.thumbRadius) {
            return NO;
        
    }
    //获取圆弧圆心与滑块最远和最近的距离
    CGFloat thumViewToMinCenterDist = self.circleRadius - self.thumbRadius;
    CGFloat thumViewToMaxCenterDist = self.circleRadius + self.thumbRadius;
    
    //计算点击点与圆心的距离
    //获取点击点在x轴上投影的距离
    CGFloat distX = ABS(starTouchPoint.x - self.centerPoint.x);
    
    //计算点击点的y到x轴的距离
    CGFloat distY = ABS(self.centerPoint.y - starTouchPoint.y);
    
    CGFloat distCenter = sqrt(pow(distX, 2) + pow(distY, 2));
    
    //现在点击的范围
    if (distCenter < thumViewToMinCenterDist || distCenter > thumViewToMaxCenterDist) {
        return NO;
    }
    
    [self moveHandlerWithPoint:starTouchPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

//拖动过程中
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint starTouchPoint = [touch locationInView:self];
    
    [self moveHandlerWithPoint:starTouchPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

//拖动结束
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    CGPoint starTouchPoint = [touch locationInView:self];
    [self moveHandlerWithPoint:starTouchPoint];
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}


#pragma mark - Handle move

- (void)moveHandlerWithPoint:(CGPoint)point {
    CGFloat centerX = self.centerPoint.x;
    CGFloat centerY = self.centerPoint.y;
    
    CGFloat moveX = point.x;
    CGFloat moveY = point.y;
    
    
    //获取点击的点与圆心的距离，主要使用用来计算此时点击的点与起始点的角度
    double dist = sqrt(pow((moveX - centerX), 2) + pow(moveY - centerY, 2));

    /*
     * 计算移动点的坐标
     * sinAlpha = 亮点在x轴上投影的长度 ／ 距离
     * xT = r * sin(alpha) + 圆心的x坐标
     * yT 算法同上
     */
    
    double sinAlpha = 0;
    double xT = 0;
    double yT = 0;

        if (moveX > centerX) {
            CGFloat cosTh = (moveX - centerX) / dist;
            xT = self.circleRadius * cosTh + centerX;
        }else{
            CGFloat cosTh = (centerX - moveX) / dist;
            xT = centerX - self.circleRadius * cosTh  ;
        }
        
         yT = centerY + sqrt((self.circleRadius * self.circleRadius - (xT - centerX) * (xT - centerX)));
    
    self.lastPoint = CGPointMake(xT, yT);
    
    CGFloat th = ABS(self.startEngle - M_PI);
    
    CGFloat minY = centerY + self.circleRadius * sin(th) ;
    if (yT < minY || moveY < minY) {
        return;
    }
    
    
    
    CGFloat angle = [TNCircleSlider calculateAngleWithRadius:self.circleRadius  center:self.centerPoint startCenter:self.circleStartPoint endCenter:self.lastPoint startEngle:self.startEngle];
    
    CGFloat totle = (180 / M_PI * (M_PI - ABS(M_PI - self.startEngle) * 2));

    self.value = angle / totle;
    if (self.value >0.99) {
        self.value = 1.0;
    }
    if (self.value < 0.02) {
        self.value = 0.0;
    }
}

#pragma mark - Util

/**
 计算圆上两点间的角度

 @param radius 半径
 @param center 圆心
 @param startCenter 起始点坐标
 @param endCenter 结束点坐标
 @return 圆上两点间的角度
 */
+ (CGFloat)calculateAngleWithRadius:(CGFloat)radius
                             center:(CGPoint)center
                        startCenter:(CGPoint)startCenter
                          endCenter:(CGPoint)endCenter startEngle:(CGFloat)startEngle{

    CGFloat sinA = ABS(endCenter.y - center.y) / radius;
    CGFloat an = asinf(sinA);
    CGFloat angle = 360 / (M_PI * 2) * (an - ABS(startEngle - M_PI));
    
    if (center.x < endCenter.x) {
        angle = (180 / M_PI * (M_PI - ABS(M_PI - startEngle) * 2)) - angle;
    }
    
    return angle;
}

/**
 两点间的距离

 @param pointA 点A的坐标
 @param pointB 点B的坐标
 @return 两点间的距离
 */
+ (double)distanceBetweenPointA:(CGPoint)pointA pointB:(CGPoint)pointB {
    double x = fabs(pointA.x - pointB.x);
    double y = fabs(pointA.y - pointB.y);
    return hypot(x, y);//hypot(x, y)函数为计算三角形的斜边长度
}



@end
