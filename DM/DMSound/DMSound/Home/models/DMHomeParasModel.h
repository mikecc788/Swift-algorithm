//
//  DMHomeParasModel.h
//  DMSound
//
//  Created by kiss on 2020/6/15.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMHomeParasModel : NSObject
@property(nonatomic,assign)BOOL isFirstResponse;//第一次更新成功不在回调那里进行更新
@property(nonatomic,assign)BOOL isSecondResponse;//第二次更新成功不在回调那里进行更新
@property(nonatomic,assign)BOOL isUpdateSecond;//开始更新第二个
@property(nonatomic,assign)BOOL isReceiveGaiaResponse;//第一次更新成功不在回调那里进行更新
@property(nonatomic,assign)BOOL isReceiveGaiaResponseSecond;//第二次更新成功不在回调那里进行更新
@property(nonatomic,copy)NSString *firstUpdateMacStr;//第一次更新的MAC地址
@property(nonatomic,assign)BOOL isUpdateScanFirst;
@property(nonatomic,assign)BOOL isUpdateScanSecond;//更新第2次扫描,扫到就停止
@end

NS_ASSUME_NONNULL_END
