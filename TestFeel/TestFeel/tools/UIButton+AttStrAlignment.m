//
//  UIButton+AttStrAlignment.m
//  Utils
//
//  Created by Xian Mo on 2020/8/22.
//  Copyright © 2020 Mo. All rights reserved.
//

#import "UIButton+AttStrAlignment.h"

@implementation UIButton (AttStrAlignment)

+ (UIButton *)buttonWithTitle:(NSString *)title
              titleAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes
                    imageName:(NSString *)imageName
                      lineGap:(CGFloat)lineGap {
    UIImage *image = [UIImage imageNamed:imageName];
    return [self buttonWithTitle:title titleAttributes:attributes image:image imageSize:image.size lineGap:lineGap];
}


+ (UIButton *)buttonWithTitle:(NSString *)title
              titleAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes
                        image:(UIImage *)image
                    imageSize:(CGSize)size
                      lineGap:(CGFloat)lineGap {
    // resize
    image = [self resize:image size:size];
    // 构造 imgAttStr
    NSTextAttachment *attachment = [NSTextAttachment new];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    NSAttributedString *imgAttStr = [NSAttributedString attributedStringWithAttachment:attachment];
    // 构造 attStr
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    [attr appendAttributedString:imgAttStr];
    // \n
    [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    // title
    [attr appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:attributes]];
    // lineGap
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.lineSpacing = lineGap;
    style.alignment = NSTextAlignmentCenter;
    // ! 使用 addAttribute 追加属性，不要使用 setAttributes，会覆盖
    [attr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attr.length)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    // 设置 titleLabel 可接收 '\n'
    btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [btn setAttributedTitle:attr.copy forState:UIControlStateNormal];
    return btn;
    
}

+ (UIImage *)resize:(UIImage *)image size:(CGSize)size {
    if (CGSizeEqualToSize(image.size, size)) return image;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = (alpha == kCGImageAlphaFirst ||
                     alpha == kCGImageAlphaLast ||
                     alpha == kCGImageAlphaPremultipliedFirst ||
                     alpha == kCGImageAlphaPremultipliedLast);
    UIGraphicsBeginImageContextWithOptions(rect.size, !hasAlpha, 0.0f);
    [image drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
