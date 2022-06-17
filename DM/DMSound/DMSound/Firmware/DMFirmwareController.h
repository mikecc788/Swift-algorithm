//
//  DMFiemwareController.h
//  DMSound
//
//  Created by kiss on 2020/5/26.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "RootViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CLBLEManager.h"
NS_ASSUME_NONNULL_BEGIN
@protocol DMFirmwareVCDelegate <NSObject>
-(void)getBattery;
@end

@interface DMFirmwareController : RootViewController
@property (strong,nonatomic) CLBLEManager *bleManager;
@property (nonatomic,strong) CBPeripheral *  myPeripheral;
@property(nonatomic,strong)NSString *baseInfo;
@property(nonatomic,assign)id <DMFirmwareVCDelegate>delegate;
@property(nonatomic,strong)NSMutableArray *macArr;
@property(nonatomic,strong)NSString *macInfo;
@property(copy,nonatomic)void(^updateSuccessBlock)(BOOL isSuccess);//
@end

NS_ASSUME_NONNULL_END
