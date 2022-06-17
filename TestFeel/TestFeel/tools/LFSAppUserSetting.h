//
//  LFSAppUserSetting.h
//  FeelLife
//
//  Created by cl on 2022/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFSAppUserSetting : NSObject
+(instancetype)shareInstance;
@property (assign,nonatomic)BOOL isShowAlert;//隐私协议
@property (assign,nonatomic)BOOL isFirstUser;//第一次进个人信息页面
@property(nonatomic,strong)NSDictionary *userInfo;//个人信息
@property(nonatomic,strong)NSDictionary *wxInfo;//个人信息
@property (assign,nonatomic)BOOL isLogin;//登录
@property (strong,nonatomic)NSMutableArray *resultArr;//呼吸仪结果
@end

NS_ASSUME_NONNULL_END
