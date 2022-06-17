//
//  ViewController.m
//  Firmware
//
//  Created by kiss on 2020/6/19.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+Extension.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "GaiaLibrary.h"
#import "BTLibrary.h"
#define DleSizeTextStr @"188"
#define DEFAULT_SIZE 23
#define GaiaServiceUUID     @"00001100-D102-11E1-9B23-00025B00A5A5"

@interface ViewController ()<CSRConnectionManagerDelegate,CSRUpdateManagerDelegate>
@property(nonatomic,strong)NSMutableArray *macArr;
@property (nonatomic,strong) CSRPeripheral *chosenPeripheral;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arr = @[@"00663300ff08",@"00331100ff01"];
    self.macArr = [[NSMutableArray alloc]init];
    [self.macArr addObjectsFromArray:arr];
    
    [[CSRConnectionManager sharedInstance] addDelegate:self];
    CBUUID *deviceInfoUUID = [CBUUID UUIDWithString:@"AE86"];
    NSArray *array = @[deviceInfoUUID];
    [[CSRConnectionManager sharedInstance] startScan:array withMacFilter:self.macArr];
}
- (void)didDiscoverPeripheral:(CSRPeripheral *)peripheral{
    NSLog(@"didDiscoverPeripheral %s%@",__func__,peripheral.peripheral.name);
    [[CSRConnectionManager sharedInstance] stopScan];
    [[CSRConnectionManager sharedInstance] connectPeripheral:peripheral];
    self.chosenPeripheral = peripheral;
//    [self discoveredPripheralDetails];
    
}
-(void)discoveredPripheralDetails{
    [self setDelegate];
}
-(void)setDelegate{
    [[CSRGaia sharedInstance]
    connectPeripheral:[CSRConnectionManager sharedInstance].connectedPeripheral];
    [CSRGaiaManager sharedInstance].delegate = self;
    [[CSRGaiaManager sharedInstance] connect];
    [[CSRGaiaManager sharedInstance] setDataEndPointMode:true];
}
@end
