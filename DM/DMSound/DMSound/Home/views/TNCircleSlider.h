//
//  TNCircleSlider.h
//  ZCircleSliderDemo
//
//  Created by TigerNong on 2019/10/18.
//  Copyright © 2019 Jixin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TNCircleSlider : UIControl

//绘制圆弧的中心点
@property (nonatomic, assign) CGPoint centerPoint;

//开始的角度顺时针为大于M_PI，小于5 / 4 * M_PI，逆时针为小于M_PI，大于3 / 4 * M_PI
@property (nonatomic, assign) CGFloat startEngle;

@property (nonatomic, assign) CGFloat endEngle;

//是否为顺时针
@property (nonatomic, assign) BOOL clockwise;

//圆弧半径
@property (nonatomic, assign) CGFloat circleRadius;

//圆弧的宽度
@property (nonatomic, assign) CGFloat circleBorderWidth;

//圆弧的背景色
@property (nullable, nonatomic, strong) UIColor *backgroundTintColor;

//圆弧滑过的颜色
@property (nullable, nonatomic, strong) UIColor *minimumTrackTintColor;

//数值
@property (nonatomic, assign) CGFloat value;

//滑块默认情况下的半径
@property (nonatomic, assign) CGFloat thumbRadius;

//圆弧滑过的颜色
@property (nullable, nonatomic, strong) UIColor *thumbColor;



@end

NS_ASSUME_NONNULL_END
