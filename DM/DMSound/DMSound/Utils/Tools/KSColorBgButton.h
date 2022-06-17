//
//  KSColorBgButton.h
//  FastPair
//
//  Created by kiss on 2019/10/15.
//  Copyright © 2019 KSB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, HVGradientDirection){
    /**
     *  水平方向
     */
    HVGradientDirectionHor,
    /**
     *  垂直方向
     */
    HVGradientDirectionVer
};


@interface KSGradientColor : UIButton
@property (nonatomic, strong, readonly) NSArray *colors;

/**
 *  初始化渐变色对象
 *
 *  @param colors 颜色数组，从上到下的顺序
 *
 *  @return 渐变色对象
 */
+ (instancetype)gradientColorWithColors:(NSArray *)colors;

@end

@interface KSColorBgButton : UIButton

/**
 *  边框宽, 默认0，无边框
 */
@property (nonatomic, assign) CGFloat borderWidth;
/**
 *  边框颜色，默认nil，无颜色
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 *  圆角，默认UIRectCornerAllCorners
 */
@property (nonatomic, assign) UIRectCorner corner;
/**
 *  圆角半径，默认0
 */
@property (nonatomic, assign) CGFloat cornerRadius;

@property(nonatomic,assign)HVGradientDirection directionType;

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (UIColor *)backgroundColorForState:(UIControlState)state;

- (void)setGradientColor:(KSColorBgButton *)gradientColor forState:(UIControlState)state;
- (KSColorBgButton *)gradientColorForState:(UIControlState)state;




@end

NS_ASSUME_NONNULL_END
