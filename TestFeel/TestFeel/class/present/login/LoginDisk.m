//
//  LoginDisk.m
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import "LoginDisk.h"
#import "NetworkManager.h"
@implementation LoginDisk
+(void)getLoginDataWithParams:(id)params success:(void (^)(UserInfoModel * _Nonnull))success fail:(void (^)(ErrorMessage * _Nonnull))fail{
    //在此，登录验证，登录成功后,解析数据，本地存储登录信息
    
    [[NetworkManager sharedManager] tokenCheckWithSuccess:^(id responseObject){
        
            // Allow User Access and load content
            //[self loadContent];
        } failure:^(NSString *failureReason, NSInteger statusCode) {
            // Logout user if logged in and deny access and show login view
            //[self showLoginView];
    }];
    
    
    //测试数据，
    int arcCode = 1 ; //arc4random()%10;
    NSDictionary * dicParams = (NSDictionary*)params;
    NSString *userName = dicParams[@"userNameString"];
    if ([userName isEqualToString:@"success"]) {
        arcCode = 0;
    }
    
    switch (arcCode) {
        case 0:{
            UserInfoModel *testModel = [[UserInfoModel alloc]init];
            testModel.userId = @"testId";
            testModel.userName = @"testName";
            testModel.userToken = @"TestToken";
            //数据处理完，都有主线程返回
            dispatch_async(dispatch_get_main_queue(), ^{ // 2
                success(testModel);
            });

        }break;
        case 1:{
            ErrorMessage * testError = [[ErrorMessage alloc]init];
            testError.code = -1;
            testError.errorMessage = @"测试登录失败";
            //数据处理完，都有主线程返回
            dispatch_async(dispatch_get_main_queue(), ^{ // 2
                fail(testError);
            });

        }break;
        default:
            break;
    }
    
}
@end
