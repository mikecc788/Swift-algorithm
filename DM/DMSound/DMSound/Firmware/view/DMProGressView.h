//
//  DMProGressView.h
//  DMSound
//
//  Created by kiss on 2020/6/15.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMProGressView : UIView
/**
    进度值
 */
@property (nonatomic,assign) float progressValue;

/**
    进度条的颜色
 */
@property (nonatomic,strong) UIColor *progressColor;

/**
    进度条的背景色
 */
@property (nonatomic,strong) UIColor *bottomColor;

/**
    进度条的速度
 */
@property (nonatomic,assign) float time;
@end

NS_ASSUME_NONNULL_END
