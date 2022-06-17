//
//  UIButton+Alignment.m
//  imageButtonDemo
//
//  Created by Xian Mo on 2020/8/20.
//  Copyright © 2020 Mo. All rights reserved.
//

#import "UIButton+Alignment.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, kAlignmentType) {
    kAlignmentTypeLeftToRight = 0,  // 默认，左图右文
    kAlignmentTypeRightToLeft,      // 左文右图
    kAlignmentTypeTopToBottom,      // 上图下文
    kAlignmentTypeBottomToTop,      // 上文下图
};

@implementation UIButton (Alignment)

- (void)alignment_TopToBottom {
    [self _alignment_vertical:kAlignmentTypeTopToBottom];
}

- (void)alignment_BottomToTop {
    [self _alignment_vertical:kAlignmentTypeBottomToTop];
}


- (void)_alignment_vertical:(kAlignmentType) verticalType {
    [self validity];
    [self layoutIfNeeded];
    
    CGRect imageFrame = self.imageView.frame;
    CGRect titleFrame = self.titleLabel.frame;
    
    CGFloat space = titleFrame.origin.x - imageFrame.origin.x - imageFrame.size.width;
    
    // 计算横向 image.center、title.center 到 button.center 的距离
    CGFloat horImageDelta = (titleFrame.size.width + space) /2;
    CGFloat horTitleDelta = (imageFrame.size.width + space) /2;
    // 计算纵向 image 和 title 需要移动的量
    CGFloat multiple = (verticalType == kAlignmentTypeTopToBottom) ? 1: -1;
    
    CGFloat verImageDelta = titleFrame.size.height /2 * multiple;
    CGFloat verTitleDelta = imageFrame.size.height /2 * multiple;
    
    self.imageEdgeInsets = UIEdgeInsetsMake(-verImageDelta, horImageDelta, verImageDelta, -horImageDelta);
    self.titleEdgeInsets = UIEdgeInsetsMake(verTitleDelta, -horTitleDelta, -verTitleDelta, horTitleDelta);
    
    CGFloat widthDelta = self.bounds.size.width - MAX(imageFrame.size.width, titleFrame.size.width);
    CGFloat heightDelta = imageFrame.size.height + titleFrame.size.height - self.bounds.size.height;
    
    self.contentEdgeInsets = UIEdgeInsetsMake(heightDelta/2, -widthDelta/2, heightDelta/2, -widthDelta/2);
    [self setAlignmentType:verticalType];
}


- (void)alignment_RightToLeft {
    [self validity];
    
    // 方法一：计算
    [self layoutIfNeeded];
    CGRect titleFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    CGFloat space = titleFrame.origin.x - imageFrame.origin.x - imageFrame.size.width;

    self.imageEdgeInsets = UIEdgeInsetsMake(0, titleFrame.size.width + space, 0, -(titleFrame.size.width + space));
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageFrame.size.width + space), 0, (imageFrame.size.width + space));
    
    /** 方法二：设置 semanticContentAttribute，但是计算添加 gap 时，加减 halfGap 需要反着来(不推荐)
     self.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
     */
    [self setAlignmentType:kAlignmentTypeRightToLeft];
}

- (void)alignment_gap:(CGFloat)gap {
    kAlignmentType type = [self alignmentType];
    
    CGFloat horDelta, verDelta, widthHalfDelta, heightHalfDelta;
    CGFloat halfGap = gap / 2;
    switch (type) {
        case kAlignmentTypeLeftToRight:
            verDelta = 0;
            horDelta = halfGap;
            widthHalfDelta = halfGap;
            heightHalfDelta = 0;
            break;
        case kAlignmentTypeRightToLeft:
            verDelta = 0;
            horDelta = -halfGap;
            widthHalfDelta = halfGap;
            heightHalfDelta = 0;
            break;
        case kAlignmentTypeTopToBottom:
            verDelta = halfGap;
            horDelta = 0;
            widthHalfDelta = 0;
            heightHalfDelta = halfGap;
            break;
        case kAlignmentTypeBottomToTop:
            verDelta = -halfGap;
            horDelta = 0;
            widthHalfDelta = 0;
            heightHalfDelta = halfGap;
            break;
    }
    
    self.imageEdgeInsets = UIEdgeInsetsMake(self.imageEdgeInsets.top - verDelta,
                                            self.imageEdgeInsets.left - horDelta,
                                            self.imageEdgeInsets.bottom + verDelta,
                                            self.imageEdgeInsets.right + horDelta);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(self.titleEdgeInsets.top + verDelta,
                                            self.titleEdgeInsets.left + horDelta,
                                            self.titleEdgeInsets.bottom - verDelta,
                                            self.titleEdgeInsets.right - horDelta);
    
    self.contentEdgeInsets = UIEdgeInsetsMake(self.contentEdgeInsets.top + heightHalfDelta,
                                              self.contentEdgeInsets.left + widthHalfDelta,
                                              self.contentEdgeInsets.bottom + heightHalfDelta,
                                              self.contentEdgeInsets.right + widthHalfDelta);
}


#pragma mark - private var
const void *alignmentTypeKey = @"alignmentTypeKey";
- (void)setAlignmentType:(kAlignmentType)type {
    objc_setAssociatedObject(self, alignmentTypeKey, @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (kAlignmentType)alignmentType {
    NSNumber *type = objc_getAssociatedObject(self, alignmentTypeKey);
    if (!type) {
        // 默认左图右文
        [self setAlignmentType:kAlignmentTypeLeftToRight];
        return kAlignmentTypeLeftToRight;
    }
    return [type integerValue];
}

#pragma mark - validity check
- (void)validity {
    kAlignmentType type = [self alignmentType];
    NSAssert(type == kAlignmentTypeLeftToRight, @"该控件之前设置过其它alinment，请先注释上次设置！");
}


@end
