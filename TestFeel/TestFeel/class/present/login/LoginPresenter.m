//
//  LoginPresenter.m
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import "LoginPresenter.h"
#import "LoginTask.h"

@interface LoginPresenter()<LoginTaskProtocol>

@end

@implementation LoginPresenter
-(instancetype)initWithView:(id)view{
    self = [super initWithView:view];
    if (self) {

    }
    return self;
}

-(void)loginWithUserName:(NSString *)userNameString password:(NSString *)pwdString{
    //通过usercaseHandle 发起登录流程
    LoginTask *task = [[LoginTask alloc]init];
    [task loginWithParams:@{@"userNameString":userNameString,@"pwdString":pwdString} delegate:self];
}

//登录成功
-(void)responseSeccuss:(id)responseObject{
//    if ([_view respondsToSelector:@selector(loginSuccess:)]) {
//        [_view loginSuccess:responseObject];
//    }
    if ([self.loginDelegate respondsToSelector:@selector(loginSuccess:)]) {
        [self.loginDelegate loginSuccess:responseObject];
    }
}

//登录失败
-(void)resPoseFail:(NSInteger )errorCode error:(NSString *)errorMessage{
//    if ([_view respondsToSelector:@selector(loginFail:errorMessage:)]) {
//        [_view loginFail:errorCode errorMessage:errorMessage];
//    }
    if ([self.loginDelegate respondsToSelector:@selector(loginFail:errorMessage:)]) {
        [self.loginDelegate loginFail:errorCode errorMessage:errorMessage];
    }
}

@end
