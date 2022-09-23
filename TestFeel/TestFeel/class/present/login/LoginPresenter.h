//
//  LoginPresenter.h
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import <Foundation/Foundation.h>
#import "Presenter.h"

#import "LoginProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginPresenter : Presenter
/**
 Presenter 响应登录事件

 @param userNameString 用户名
 @param pwdString 密码
 */
-(void)loginWithUserName:(NSString*)userNameString password:(NSString*)pwdString;

@property(nonatomic,weak)id<LoginProtocol> loginDelegate;

@end

NS_ASSUME_NONNULL_END
