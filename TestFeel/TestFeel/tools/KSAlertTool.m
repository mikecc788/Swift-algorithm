//
//  KSAlertTool.m
//  FastPair
//
//  Created by kiss on 2019/9/5.
//  Copyright © 2019 KSB. All rights reserved.
//

#import "KSAlertTool.h"

@implementation KSAlertTool
//没有取消按钮(确认后无跳转)
+(UIAlertController *)alertOk:(NSString *)action mesasge:(NSString *)message confirmHandler:(void (^)(UIAlertAction * _Nonnull))confirmActionHandle viewController:(UIViewController *)vc{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:action style:UIAlertActionStyleDefault handler:confirmActionHandle];
    
    [okAction setValue:[UIColor colorWithHexString:@"#854794"] forKey:@"titleTextColor"];
    
    [alertController addAction:okAction];
    [vc presentViewController:alertController animated:YES completion:^{
        
    }];
    return alertController;
}

//有取消按钮的
+(UIAlertController *)alertTitle:(NSString *)title mesasge:(NSString *)message confirmHandler:(void(^)(UIAlertAction *))confirmHandler cancleHandler:(void(^)(UIAlertAction *))cancleHandler viewController:(UIViewController *)vc{
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *confirmAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"前往",nil) style:UIAlertActionStyleDefault handler:confirmHandler];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:cancleHandler];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancleAction];
    [vc presentViewController:alertController animated:YES completion:nil];
    return alertController;
}
@end
