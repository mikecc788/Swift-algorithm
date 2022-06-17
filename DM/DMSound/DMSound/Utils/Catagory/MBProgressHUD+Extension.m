//
//  MBProgressHUD+Extension.m
//  AMAP
//
//  Created by cl on 2019/1/28.
//  Copyright © 2019 AylaNetworks. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

@implementation MBProgressHUD (Extension)

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.label.numberOfLines = 0;
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1];
}

/**
 *  显示信息
 *
 *  @param text 信息内容
 *  @param icon 图标
 *  @param view 显示的视图
 */
+ (void)show:(NSString *)text detailText:(NSString*)detailText icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud.label.text = text;
    hud.label.font = CHINESE_SYSTEM(15);
    hud.detailsLabel.text = detailText;
    hud.detailsLabel.font = CHINESE_SYSTEM(14);
    // 设置图片
    
    
    //    UIImage *image = [[UIImage imageNamed:[NSString stringWithFormat:@"%@", icon]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //     hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    
    
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}



/**
 *  显示错误 成功信息
 *
 */
+(void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"photo_delete" view:view];
}

+(void)showSuccess:(NSString *)success toView:(UIView *)view{
    [self show:success icon:@"Checkmark" view:view];
}


//自动消失提示，无图
+ (void)showAutoMessage:(NSString *)message toView:(UIView *)view{
    [self showMessage:message ToView:view RemainTime:1 Model:MBProgressHUDModeText];
}

+(void)showMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time Model:(MBProgressHUDMode)model{
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text=message;
    hud.label.font=CHINESE_SYSTEM(15);
    hud.label.numberOfLines = 0;
    //模式
    hud.mode = model;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 代表需要蒙版效果
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color =[UIColor colorWithWhite:0.f alpha:.2f];
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // X秒之后再消失
    [hud hideAnimated:YES afterDelay:time];
}

+(void)showMessage:(NSString *)message ToView:(UIView *)view{
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text=message;
    hud.label.font=CHINESE_SYSTEM(15);
    hud.label.numberOfLines = 0;
    //模式
    hud.mode = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 代表需要蒙版效果
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color =[UIColor colorWithWhite:0.f alpha:.2f];
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
}

@end
