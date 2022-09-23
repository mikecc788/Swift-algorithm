//
//  LoginTask.h
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import <Foundation/Foundation.h>
#import "LoginTaskProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface LoginTask : NSObject

/**
 向服务器发起登录请求，在子线程中处理

 @param params 登录请求参数，如 用户名、密码
 @param delegate 登录请求代理，用来接收请求结果
 */
-(void)loginWithParams:(id)params delegate:(id<LoginTaskProtocol>)delegate;//登录

@end

NS_ASSUME_NONNULL_END
