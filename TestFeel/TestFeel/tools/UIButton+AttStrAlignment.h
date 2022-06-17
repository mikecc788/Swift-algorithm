//
//  UIButton+AttStrAlignment.h
//  Utils
//
//  Created by Xian Mo on 2020/8/22.
//  Copyright © 2020 Mo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 使用属性字符串实现图文混排 */
@interface UIButton (AttStrAlignment)

/// 图文混排(AttributedString)
/// @param title 文字
/// @param attributes 文字属性(颜色、大小等)
/// @param imageName 图片名称
/// @param lineGap 间距
+ (UIButton *)buttonWithTitle:(NSString *)title
              titleAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes
                    imageName:(NSString *)imageName
                      lineGap:(CGFloat)lineGap;


/// 图文混排(AttributedString)
/// @param title 文字
/// @param attributes 文字属性(颜色、大小等)
/// @param image 图片
/// @param size 预期尺寸
/// @param lineGap 间距
+ (UIButton *)buttonWithTitle:(NSString *)title
              titleAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes
                        image:(UIImage *)image
                    imageSize:(CGSize)size
                      lineGap:(CGFloat)lineGap;

@end

NS_ASSUME_NONNULL_END
