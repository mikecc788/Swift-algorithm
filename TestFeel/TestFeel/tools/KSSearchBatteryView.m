//
//  KSSearchBatteryView.m
//  FastPair
//
//  Created by kiss on 2020/5/8.
//  Copyright © 2020 KSB. All rights reserved.
//

#import "KSSearchBatteryView.h"
//size
#define BatteryYDistance 0.7
@implementation KSSearchBatteryView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatBatteryView];
    }
    return self;
}
- (void)creatBatteryView{
    // 电池的宽度
    CGFloat w = self.bounds.size.width;
    // 电池的高度
    CGFloat h = self.bounds.size.height;
    // 电池的x的坐标
    CGFloat x = self.bounds.origin.x;
    // 电池的y的坐标
    CGFloat y = self.bounds.origin.y;
    // 电池的线宽
    self.lineW = 1;
    // 画电池
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w, h) cornerRadius:1];
    CAShapeLayer *batteryLayer = [CAShapeLayer layer];
    batteryLayer.lineWidth = self.lineW;
    batteryLayer.strokeColor = [UIColor colorWithHexString:@"#2c2c2c"].CGColor;
    batteryLayer.fillColor = [UIColor clearColor].CGColor;
    batteryLayer.path = [path1 CGPath];
    [self.layer addSublayer:batteryLayer];
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(x+w/4,y-1)];
    [path2 addLineToPoint:CGPointMake(x+3*w/4, y-1)];
    
    CAShapeLayer *layer2 = [CAShapeLayer layer];
    layer2.lineWidth = 1;
    layer2.strokeColor =  [UIColor colorWithHexString:@"#2c2c2c"].CGColor;
    layer2.fillColor = [UIColor clearColor].CGColor;
    layer2.path = [path2 CGPath];
    [self.layer addSublayer:layer2];
   
}
-(void)createBattery:(float)num{
    NSLog(@"num==%f",num);
    // 电池的高度
    CGFloat h = self.bounds.size.height;
    // 电池的x的坐标
    CGFloat x = self.bounds.origin.x;
    // 电池的y的坐标
    CGFloat y = self.bounds.origin.y;
    CGFloat batteryViewxX = num > 0 ? (x+1):x;
    CGFloat w = self.bounds.size.width;
    UIView *batteryView = [[UIView alloc]initWithFrame:CGRectMake(batteryViewxX,y+h-num-BatteryYDistance,  w-batteryViewxX*2, num)];
    self.batteryV = batteryView;
   batteryView.layer.cornerRadius = 1;
   batteryView.backgroundColor = [UIColor colorWithHexString:@"#2c2c2c"];
   [self addSubview:batteryView];
    [self layoutSubviews];
}
@end
