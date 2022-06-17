//
//  UIColor+Extension.h
//  FastPair
//
//  Created by cl on 2019/7/24.
//  Copyright © 2019 KSB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Extension)
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

// 返回一个十六进制表示的颜色: 0xFF0000
+ (UIColor *)colorFromHex:(int)hex;
+ (UIColor *)colorFromHex:(int)hex withAlpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)color;
+ (UIColor *)colorFromHexStr:(NSString *)hex;
@end

NS_ASSUME_NONNULL_END
