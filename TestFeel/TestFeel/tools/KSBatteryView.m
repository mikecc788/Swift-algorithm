//
//  KSBatteryView.m
//  FastPair
//
//  Created by cl on 2019/7/26.
//  Copyright © 2019 KSB. All rights reserved.
//

#import "KSBatteryView.h"
#define RGB(x,y,z) [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:1]
@interface KSBatteryView()
@property(nonatomic,strong)UIView *batteryV;
@property(nonatomic,strong)UIView *batterV;
/** 线宽 */
@property (nonatomic, assign) CGFloat lineW;
@end

@implementation KSBatteryView

-(instancetype)initWithFrame:(CGRect)frame num:(NSInteger)num {
    if (self = [super initWithFrame:frame]) {
       
        self.backgroundColor = RGB(223, 195, 251);
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
//        UILabel *lab = [[UILabel alloc]init];
//        lab.text = @"电池";
//        [self addSubview:lab];
        UIView *batterV = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width - 20 -20, 10, 20, 10)];
        self.batterV = batterV;
        [self addSubview:batterV];
        [self creatBatteryView:num];
        
    }
    return self;
}
- (void)creatBatteryView:(NSInteger)num{
    // 电池的宽度
    CGFloat w = self.batterV.bounds.size.width;
    // 电池的高度
    CGFloat h = self.batterV.bounds.size.height;
    // 电池的x的坐标
    CGFloat x = self.batterV.bounds.origin.x;
    // 电池的y的坐标
    CGFloat y = self.batterV.bounds.origin.y;
    // 电池的线宽
    self.lineW = 1;
    // 画电池
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w, h) cornerRadius:2];
    CAShapeLayer *batteryLayer = [CAShapeLayer layer];
    batteryLayer.lineWidth = self.lineW;
    batteryLayer.strokeColor = [UIColor colorWithHexString:@"#006400"].CGColor;
    batteryLayer.fillColor = [UIColor clearColor].CGColor;
    batteryLayer.path = [path1 CGPath];
    [self.batterV.layer addSublayer:batteryLayer];
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(x+w+1, y+h/3)];
    [path2 addLineToPoint:CGPointMake(x+w+1, y+h*2/3)];
    
    CAShapeLayer *layer2 = [CAShapeLayer layer];
    layer2.lineWidth = 2;
    layer2.strokeColor = [UIColor colorWithHexString:@"#006400"].CGColor;
    layer2.fillColor = [UIColor clearColor].CGColor;
    layer2.path = [path2 CGPath];
    [self.batterV.layer addSublayer:layer2];
    CGFloat batteryViewxX = num > 0 ? (x+1):x;
    [self setBatteryNum:num];
}

-(void)setBatteryNum:(float)num{
    [self.batteryV removeFromSuperview];
    NSLog(@"num==%f",num);
    // 电池的高度
    CGFloat h = self.batterV.bounds.size.height;
    // 电池的x的坐标
    CGFloat x = self.batterV.bounds.origin.x;
    // 电池的y的坐标
    CGFloat y = self.batterV.bounds.origin.y;
    CGFloat batteryViewxX = num > 0 ? (x+1):x;
    UIView *batteryView = [[UIView alloc]initWithFrame:CGRectMake(batteryViewxX,y+_lineW, num -batteryViewxX*2, h-_lineW*2)];
    self.batteryV = batteryView;
   batteryView.layer.cornerRadius = 2;
   batteryView.backgroundColor = [UIColor colorWithHexString:@"#8B008B"];
   [self.batterV addSubview:batteryView];
    [self.batterV layoutSubviews];
}

@end
