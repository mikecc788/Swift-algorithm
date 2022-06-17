//
//  UIButton+Alignment.h
//  imageButtonDemo
//
//  Created by Xian Mo on 2020/8/20.
//  Copyright © 2020 Mo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 图文混排 */
@interface UIButton (Alignment)

/** 上图下文 (在控件布局完之后调用) */
- (void)alignment_TopToBottom;

/** 上文下图 (在控件布局完之后调用)*/
- (void)alignment_BottomToTop;

/** 左文右图 (在控件布局完之后调用) (若对间距没有要求，可使用 semanticContentAttribut 属性设置)*/
- (void)alignment_RightToLeft;

/** 设置图文间隔 (直接设置 或 设置完排列方式之后)*/
- (void)alignment_gap:(CGFloat)gap;

@end

NS_ASSUME_NONNULL_END
