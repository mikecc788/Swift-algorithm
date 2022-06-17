//
//  LFSDeviceInfo.m
//  FeelLife
//
//  Created by app on 2022/4/8.
//

#import "LFSDeviceInfo.h"

#define PREFIX_BIONEB  @"AN01"
#define PREFIX_AEROGO @"Aerogo"
#define PREFIX_JKY  @"JKY-"
#define PREFIX_AERO_B_PLUS @"AeroB"
#define PREFIX_AERO_CENTER  @"A15-"
#define PREFIX_AERO_CENTER_2 @"A99-"
#define PREFIX_AERO_LAB_2 @"A98-"
#define PREFIX_AERO_CENTER_BT301 @"A15BT-"
#define PREFIX_MINI_BEAR @"MiniBear"
#define PREFIX_AIR_SMART @"AirSmart"
#define PREFIX_AK_WK_03 @"AK001"
#define PREFIX_A8 @"A8"
#define PREFIX_GO3 @"go3-"
#define PREFIX_NANUS @"nanus-"
#define PREFIX_T01 @"T01-"
#define PREFIX_AIR_SMART_EXTRA @"Air Smart Extra"
#define PREFIX_AIR_SMART_T1 @"Air Smart T1"
#define PREFIX_AIR_RIGHT @"AirRight"
#define PREFIX_AIR_PRO @"Air Pro"
#define PREFIX_AIR_MASK @"Air Mask"
#define PREFIX_AIR_FIT @"Air Fit"

@interface LFSDeviceInfo()

@end

@implementation LFSDeviceInfo

+(NSString*)getDeviceDesignation:(NSString*)name{
    NSArray *product = @[@"BIONEB",@"AEROGO",@"JKY",@"AERO_B_PLUS",@"AERO_CENTER",@"AERO_CENTER_2",@"AERO_LAB_2",@"AERO_CENTER_BT301",@"MINI_BEAR",@"AIR_SMART",@"AIR_SMART_EXTRA",@"AIR_SMART_T1",@"AK_WK_03",@"A8",@"GO3",@"Nanus",@"T01",@"AirRight",@"AirPro",@"AirMask",@"AirFitSmart"];

    
    NSArray *arr =  @[PREFIX_BIONEB,PREFIX_AEROGO, PREFIX_JKY, PREFIX_AERO_B_PLUS, PREFIX_AERO_CENTER, PREFIX_AERO_CENTER_2, PREFIX_AERO_LAB_2, PREFIX_AERO_CENTER_BT301, PREFIX_MINI_BEAR, PREFIX_AIR_SMART, PREFIX_AK_WK_03, PREFIX_A8, PREFIX_GO3, PREFIX_NANUS, PREFIX_T01, PREFIX_AIR_SMART_EXTRA, PREFIX_AIR_SMART_T1, PREFIX_AIR_RIGHT, PREFIX_AIR_PRO, PREFIX_AIR_MASK,PREFIX_AIR_FIT];
    
    NSLog(@"%ld%ld",product.count,arr.count);
    __block NSString *target;
    [arr enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([name containsString:obj]) {
//            NSLog(@"idx==%ld  ==%@",idx,product[idx]);
            target = product[idx];
        }
//        else{
//            target = name;
//        }
    }];
    
    if (!target) {
        target = name;
    }
    
    return target;
}

@end
