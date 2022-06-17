//
//  LFSAppUserSetting.m
//  FeelLife
//
//  Created by cl on 2022/3/19.
//

#import "LFSAppUserSetting.h"

@implementation LFSAppUserSetting
+(instancetype)shareInstance{
    static LFSAppUserSetting *setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[self alloc]init];
    });
    return setting;
}
- (void)save{
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(BOOL )isShowAlert{
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"DMShowProtocolAlert"];
    
}
-(void)setIsShowAlert:(BOOL)isShowAlert{
    [[NSUserDefaults standardUserDefaults]setBool:isShowAlert forKey:@"DMShowProtocolAlert"];
    [self save];
}
-(BOOL )isFirstUser{
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"isFirstUser"];
    
}
-(void)setIsFirstUser:(BOOL)isFirstUser{
    [[NSUserDefaults standardUserDefaults]setBool:isFirstUser forKey:@"isFirstUser"];
    [self save];
}
-(void)setUserInfo:(NSDictionary *)userInfo{
    [[NSUserDefaults standardUserDefaults]setObject:userInfo forKey:@"LFSUserInfo"];
    [self save];
}
-(NSDictionary *)userInfo{
     return [[NSUserDefaults standardUserDefaults] objectForKey:@"LFSUserInfo"];
}
-(void)setWxInfo:(NSDictionary *)wxInfo{
    [[NSUserDefaults standardUserDefaults]setObject:wxInfo forKey:@"LFSWxInfo"];
    [self save];
}
-(NSDictionary *)wxInfo{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"LFSWxInfo"];
}
-(void)setIsLogin:(BOOL)isLogin{
    [[NSUserDefaults standardUserDefaults]setBool:isLogin forKey:@"isLogin"];
    [self save];
}
-(BOOL)isLogin{
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"isLogin"];
}
-(NSMutableArray *)resultArr{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"resultArr"];
}
-(void)setResultArr:(NSMutableArray *)resultArr{
    [[NSUserDefaults standardUserDefaults]setObject:resultArr forKey:@"resultArr"];
    [self save];
}
@end
