//
//  DMHomeViewController.h
//  DMSound
//
//  Created by kiss on 2020/5/29.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "RootViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@class CLBLEManager;
NS_ASSUME_NONNULL_BEGIN

@interface DMHomeViewController : RootViewController
@property (strong,nonatomic) CLBLEManager *bleManager;
@property (nonatomic,strong) CBPeripheral *  myPeripheral;
@property(nonatomic,assign)BOOL isScan;
@property(nonatomic,strong)NSString *advStr;
@property(nonatomic,strong)NSMutableArray *macArr;
@end

NS_ASSUME_NONNULL_END
