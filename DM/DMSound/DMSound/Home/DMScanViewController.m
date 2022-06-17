//
//  DMScanViewController.m
//  DMSound
//
//  Created by kiss on 2020/6/8.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMScanViewController.h"
#import "DMGoBackButton.h"
#import "DMNoFoundView.h"
#import "DMScanView.h"
#import "CLBLEManager.h"
#import "KSAlertTool.h"
#import "CLDataConver.h"
#import "DMHomeViewController.h"
#import "AppDelegate.h"
#import "DMMyDeviceController.h"
@interface DMScanViewController ()<DMScanViewDelegate,CLBLEManagerDelegate,DMGoBackButtonDelegate>
@property(nonatomic,strong)DMScanView *scanV;
@property(nonatomic,strong)DMGoBackButton *back;
@property(nonatomic,strong) DMNoFoundView *fail;
@property(nonatomic,strong)CLBLEManager *bleManager;
@property (strong, nonatomic) NSMutableDictionary  *nearbyPeripheralInfos;
@property(nonatomic,strong)NSMutableArray *peripheralDataArray;
@property(nonatomic,strong)NSMutableArray *macInfo;

@end

@implementation DMScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = Gloabal_bg;
    _nearbyPeripheralInfos = [NSMutableDictionary dictionary];
    self.peripheralDataArray =  [[NSMutableArray alloc]init];
    self.macInfo =  [[NSMutableArray alloc]init];
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, KScaleHeight(40), 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"搜寻耳机", nil) textFont:[UIFont systemFontOfSize:34]];
    self.back = back;
    back.isScanEnter = YES;
    back.delegate = self;
    [self.view addSubview:back];
    
    
    self.scanV = [[DMScanView alloc]initWithFrame:self.view.bounds];
    self.scanV.delegate = self;
    [self.view addSubview:self.scanV];
    [self initCBCentralManager];
    if ([DMAppUserSetting shareInstance].addressArr.count>0) {
        [self.bleManager startScanPeripheral];
    }
    
}
-(void)initCBCentralManager{
    self.bleManager = [CLBLEManager sharedInstance];
    self.bleManager.delegate = self;
    [self.bleManager initCBCentralManager];
    
}
//MARK:-蓝牙ble delegate
-(void)didUpdateState:(CBCentralManager *)central{
    switch (central.state) {
            case CBManagerStatePoweredOn:{
                NSLog(@"centralManagerDidUpdateState");
//                [self.connectPeripherals removeAllObjects];
//                CBUUID *deviceInfoUUID1 = [CBUUID UUIDWithString:@"0E80"];
//                NSArray *array1 = @[deviceInfoUUID1];
//                //系统已经连上的设备
//                NSArray *connectedArr = [self.bleManager.manager retrieveConnectedPeripheralsWithServices:array1];
//                [self.connectPeripherals addObjectsFromArray:connectedArr];
//                NSLog(@"connectedArrsum==%@",self.connectPeripherals);
//                if (connectedArr.count > 0) {
//                    for (CBPeripheral*per  in self.connectPeripherals) {
//                        [self.bleManager.manager cancelPeripheralConnection:per];
//
//                    }
//                }
                [self.bleManager startScanPeripheral];
            }
                break;
            case CBManagerStatePoweredOff:{
                NSLog(@"Bluetooth is turned off");
            }break;
            case CBManagerStateResetting:
                NSLog(@"System service resetting");
                break;
            case CBManagerStateUnauthorized:
                NSLog(@"We have not been unauthorized with permission");
                [KSAlertTool alertTitle:NSLocalizedString(@"請轉到設定隱私頁以啟用藍牙授權", nil) mesasge:@"" confirmHandler:^(UIAlertAction * _Nonnull action) {
                    NSURL *url2 = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if (@available(iOS 11.0, *)) {
                        if ([[UIApplication sharedApplication] canOpenURL:url2]){
                            [[UIApplication sharedApplication] openURL:url2 options:@{} completionHandler:nil];
                        }
                    }

                } cancleHandler:^(UIAlertAction * _Nonnull cancel) {
                    
                } viewController:self];
                break;
            case CBManagerStateUnknown:
                NSLog(@"Current state unknown");
                break;
            case CBManagerStateUnsupported:
                NSLog(@"The platform doesn't support Bluetooth LE");
                
                break;
        }
}


-(void)didDiscoverPeripheral:(CBPeripheral *)peripheral AdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)rssi{
     NSData *data  =[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    
    if ([rssi integerValue] >= -60){
        NSString *adStr = [CLDataConver hexadecimalString:data];
        if ([[adStr substringToIndex:4] isEqualToString:@"dc08"]){
            if ([[adStr substringWithRange:NSMakeRange(16, 4)] isEqualToString:@"0004"]){
                if ([[adStr substringWithRange:NSMakeRange(20, 4)] isEqualToString:self.productCode]) {
                    if (![self.peripheralDataArray containsObject:peripheral]){
                        [self.peripheralDataArray addObject:peripheral];
                        [self.macInfo addObject:adStr];
                        [self.nearbyPeripheralInfos setObject:peripheral forKey:adStr];
//                        NSLog(@"搜索到了设备:%@ peripherals=%@ info=%@ ",peripheral.name,adStr,self.nearbyPeripheralInfos);
                        
                    }
                }
            }
        }
    }
    
    
}
//MARK:-Animation delegate
-(void)animationDidStop{
    
    //首先过滤掉已经添加的设备
    [self deletePeriInfo:[self.nearbyPeripheralInfos allKeys]];
    NSLog(@"originArr=%@ near=%@",[DMAppUserSetting shareInstance].addressArr,self.nearbyPeripheralInfos);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    [self.macInfo enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       NSString *leftMacStr = [obj substringWithRange:NSMakeRange(4, 12)];
        NSString *rightMacStr = [obj substringFromIndex:obj.length -12];
        NSArray *arr = @[leftMacStr,rightMacStr];
        [tempArray addObject:arr];
    }];
    for (int x= 0; x< tempArray.count; x++) {
        for (int y =x+1; y<tempArray.count; y++) {
            if ([tempArray[x] containsObject:tempArray[y][0]] && [tempArray[x] containsObject:tempArray[y][1]]) {
                [tempArray removeObject:tempArray[y]];
            }
        }
    }
//    [[DMAppUserSetting shareInstance] setAddressArr:tempArray];
    NSLog(@"beforeArr=%@",tempArray);
//    NSLog(@"dic=%@",dic);
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSArray*  _Nonnull obj, BOOL * _Nonnull stop) {
        
    }];
    
    [self.bleManager stopScanPeripheral];
    if ([self.nearbyPeripheralInfos allKeys].count>0){//到首页去连接
        DMHomeViewController *home = [[DMHomeViewController alloc]init];
        home.bleManager = self.bleManager;
        
        if ([self.nearbyPeripheralInfos allKeys].count >0) {
//               home.myPeripheral = [self.peripheralDataArray firstObject];
            home.myPeripheral = [[self.nearbyPeripheralInfos allValues] firstObject];
           }
        home.advStr =  [[self.nearbyPeripheralInfos allKeys] firstObject];
        NSString *leftMacStr = [home.advStr substringWithRange:NSMakeRange(4, 12)];
        NSString *rightMacStr = [home.advStr substringFromIndex:home.advStr.length -12];
//        NSArray *arr = @[leftMacStr,rightMacStr];
        NSMutableArray *arrM = [[NSMutableArray alloc]init];
        [arrM addObject:leftMacStr];
        [arrM addObject:rightMacStr];
        home.macArr = arrM;
        NSLog(@"per=%@ advStr=%@",home.myPeripheral,home.advStr);
        home.isScan = YES;
        [self.navigationController pushViewController:home animated:YES];
    }else{
        [self.scanV removeFromSuperview];
       DMNoFoundView *fail = [[DMNoFoundView alloc]initWithFrame:self.view.bounds];
       [self.view addSubview:fail];
       self.fail = fail;
       [self.view bringSubviewToFront:self.back];
       hq_weak(fail)
       fail.reconectBlock = ^{
           hq_strong(fail);
           [fail removeFromSuperview];
           self.scanV = [[DMScanView alloc]initWithFrame:self.view.bounds];
           self.scanV.delegate = self;
           [self.view addSubview:self.scanV];
           [self.bleManager startScanPeripheral];
       };
    }
}
-(void)clickBackBtn{
    if ([DMAppUserSetting shareInstance].addressArr.count>0) {//有耳机的话返回直接到我的耳机
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)deletePeriInfo:(NSArray*)keys{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];;
    [tempArray addObjectsFromArray:[DMAppUserSetting shareInstance].addressArr];
    
    [tempArray enumerateObjectsUsingBlock:^(NSArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSString *adStr in keys) {
            if ([obj containsObject:[adStr substringWithRange:NSMakeRange(4, 12)]]) {
                NSLog(@"已经存在的adStr==%@",adStr);
                [self.nearbyPeripheralInfos removeObjectForKey:adStr];
            }
        }
    }];
    
}
@end
