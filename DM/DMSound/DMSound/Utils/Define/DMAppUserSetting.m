//
//  DMAppUserSetting.m
//  DMSound
//
//  Created by kiss on 2020/5/28.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMAppUserSetting.h"

@implementation DMAppUserSetting
+(instancetype)shareInstance{
    static DMAppUserSetting *setting = nil;
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
-(void)setSelectTag:(NSInteger)selectTag{
    [[NSUserDefaults standardUserDefaults] setInteger:selectTag forKey:@"selectTag"];
    [self save];
}
-(NSInteger)selectTag{
     return [[NSUserDefaults standardUserDefaults]integerForKey:@"selectTag"];
}

-(void)setAddressDic:(NSDictionary *)addressDic{
    [[NSUserDefaults standardUserDefaults]setObject:addressDic forKey:@"DMaddressDic"];
    [self save];
}
-(NSDictionary *)addressDic{
     return [[NSUserDefaults standardUserDefaults] objectForKey:@"DMaddressDic"];
}
-(void)setAddressArr:(NSMutableArray *)addressArr{
    [[NSUserDefaults standardUserDefaults]setObject:addressArr forKey:@"DMaddressArr"];
    [self save];
}
-(NSMutableArray *)addressArr{
     return [[NSUserDefaults standardUserDefaults] objectForKey:@"DMaddressArr"];
}
-(NSArray *)customEqFirst{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customEqFirst"];
}
-(void)setCustomEqFirst:(NSArray *)customEqFirst{
    [[NSUserDefaults standardUserDefaults]setObject:customEqFirst forKey:@"customEqFirst"];
    [self save];
}

-(NSArray *)customPopArr{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customPopArr"];
}
-(void)setCustomPopArr:(NSArray *)customPopArr{
    [[NSUserDefaults standardUserDefaults]setObject:customPopArr forKey:@"customPopArr"];
    [self save];
}
-(NSArray *)customVocalArr{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customVocalArr"];
}
-(void)setCustomVocalArr:(NSArray *)customVocalArr{
    [[NSUserDefaults standardUserDefaults]setObject:customVocalArr forKey:@"customVocalArr"];
    [self save];
}

-(NSArray *)customClassicArr{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customClassicArr"];
}
-(void)setCustomClassicArr:(NSArray *)customClassicArr{
    [[NSUserDefaults standardUserDefaults]setObject:customClassicArr forKey:@"customClassicArr"];
    [self save];
}
-(NSArray *)customTrebleReducerArr{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customTrebleReducerArr"];
}
-(void)setCustomTrebleReducerArr:(NSArray *)customTrebleReducerArr{
    [[NSUserDefaults standardUserDefaults]setObject:customTrebleReducerArr forKey:@"customTrebleReducerArr"];
    [self save];
}
-(NSArray *)customBassBoosterArr{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customBassBoosterArr"];
}
-(void)setCustomBassBoosterArr:(NSArray *)customBassBoosterArr{
    [[NSUserDefaults standardUserDefaults]setObject:customBassBoosterArr forKey:@"customBassBoosterArr"];
    [self save];
}

-(NSArray *)customRockArr{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customRockArr"];
}
-(void)setCustomRockArr:(NSArray *)customRockArr{
    [[NSUserDefaults standardUserDefaults]setObject:customRockArr forKey:@"customRockArr"];
    [self save];
}
-(NSArray *)customJazzArr{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customJazzArr"];
}
-(void)setCustomJazzArr:(NSArray *)customJazzArr{
    [[NSUserDefaults standardUserDefaults]setObject:customJazzArr forKey:@"customJazzArr"];
    [self save];
}
-(NSArray *)customHipHopArr{
     return [[NSUserDefaults standardUserDefaults]objectForKey:@"customHipHopArr"];
}
-(void)setCustomHipHopArr:(NSArray *)customHipHopArr{
    [[NSUserDefaults standardUserDefaults]setObject:customHipHopArr forKey:@"customHipHopArr"];
    [self save];
}

@end
