//
//  KSAlertTool.h
//  FastPair
//
//  Created by kiss on 2019/9/5.
//  Copyright © 2019 KSB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSAlertTool : NSObject
+(UIAlertController *)alertOk:(NSString*)action mesasge:(NSString *)message  confirmHandler:(void(^)(UIAlertAction *))confirmActionHandle viewController:(UIViewController *)vc;

+(UIAlertController *)alertTitle:(NSString *)title mesasge:(NSString *)message confirmHandler:(void(^)(UIAlertAction *))confirmHandler cancleHandler:(void(^)(UIAlertAction *))cancleHandler viewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
