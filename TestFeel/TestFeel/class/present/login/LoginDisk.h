//
//  LoginDisk.h
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import <Foundation/Foundation.h>
#import "ErrorMessage.h"
#import"UserInfoModel.h"
NS_ASSUME_NONNULL_BEGIN

/**
 *  Repository 部分，Remote+Local
 *  模拟数据，实际使用中应该是先（从Local）取本地数据，如果不存在，再请求服务器接口（Remote）
 */

@interface LoginDisk : NSObject
/**
* 获取登录数据

 @param params 登录请求参数
 @param success 登录成功返回结果
 @param fail 登录失败信息
 */
+(void)getLoginDataWithParams:(id)params success:(void(^)(UserInfoModel * responseData))success fail:(void(^)(ErrorMessage * errorData))fail;

@end

NS_ASSUME_NONNULL_END
