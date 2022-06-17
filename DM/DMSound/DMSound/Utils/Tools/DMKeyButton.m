//
//  DMKeyButton.m
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMKeyButton.h"

@implementation DMKeyButton
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect btnBouns = self.bounds;
    btnBouns = CGRectInset(btnBouns, -20, -20);
    // 若点击的点在新的bounds里，就返回YES
    return CGRectContainsPoint(btnBouns, point);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    /** 修改 title 的 frame */
    // 1.获取 titleLabel 的 frame
    CGRect titleLabelFrame = self.titleLabel.frame;
    // 2.修改 titleLabel 的 frame
    titleLabelFrame.origin.x = 0;
    // 3.重新赋值
    self.titleLabel.frame = titleLabelFrame;
    
    /** 修改 imageView 的 frame */
    // 1.获取 imageView 的 frame
    CGRect imageViewFrame = self.imageView.frame;
    // 2.修改 imageView 的 frame
    imageViewFrame.origin.x = titleLabelFrame.size.width + 5;
    // 3.重新赋值
    self.imageView.frame = imageViewFrame;
}

@end
