//
//  MBProgressHUD+Extension.h
//  AMAP
//
//  Created by cl on 2019/1/28.
//  Copyright © 2019 AylaNetworks. All rights reserved.
//

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUD (Extension)

+ (void)show:(NSString *)text detailText:(NSString*)detailText icon:(NSString *)icon view:(UIView *)view;

+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (void)showAutoMessage:(NSString *)message toView:(UIView *)view;
+(void)showMessage:(NSString *)message ToView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
