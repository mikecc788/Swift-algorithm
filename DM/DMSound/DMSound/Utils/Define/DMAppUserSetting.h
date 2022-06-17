//
//  DMAppUserSetting.h
//  DMSound
//
//  Created by kiss on 2020/5/28.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMAppUserSetting : NSObject
+(instancetype)shareInstance;
@property (assign,nonatomic)BOOL isShowAlert;//隐私协议
@property(nonatomic,assign)NSInteger selectTag;//选中的tag 退出eq之后再重新进来
@property(nonatomic,strong)NSDictionary *addressDic;//耳机mac地址 是一对
@property(nonatomic,strong)NSMutableArray *addressArr;//耳机mac地址 是一对
@property(nonatomic,strong)NSArray *customEqFirst;

//自定义EQ八个
@property(nonatomic,strong)NSArray *customPopArr;
@property(nonatomic,strong)NSArray *customVocalArr;
@property(nonatomic,strong)NSArray *customClassicArr;
@property(nonatomic,strong)NSArray *customBassBoosterArr;
@property(nonatomic,strong)NSArray *customTrebleReducerArr;
@property(nonatomic,strong)NSArray *customRockArr;
@property(nonatomic,strong)NSArray *customJazzArr;
@property(nonatomic,strong)NSArray *customHipHopArr;

@end

NS_ASSUME_NONNULL_END
