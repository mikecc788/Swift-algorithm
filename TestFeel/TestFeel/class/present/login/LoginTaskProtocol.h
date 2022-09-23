//
//  LoginTaskProtocol.h
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoginTaskProtocol <NSObject>
/**
 登录成功回调

 @param responseObject 登录成功响应报文
 */
-(void)responseSeccuss:(id)responseObject;
/**
 登录失败回调

 @param errorCode 失败错误码
 @param errorMessage 失败原因描述
 */
-(void)resPoseFail:(NSInteger )errorCode error:(NSString *)errorMessage;
@end

NS_ASSUME_NONNULL_END
