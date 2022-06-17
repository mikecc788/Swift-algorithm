//
//  DMHomeViewController.m
//  DMSound
//
//  Created by kiss on 2020/5/29.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMHomeViewController.h"
#import "KSAreaButton.h"
#import "KSTitleButton.h"
#import "DMFirmwareController.h"
#import "DMInfoViewController.h"
#import "DMKeyViewController.h"
#import "DMAboutViewController.h"
#import "DMEQViewController.h"
#import "DMGoBackButton.h"
#import "TNCircleSlider.h"
#import "CLBLEManager.h"
#import "CLDataConver.h"
#import "HYRadix.h"
#import "KSSearchBatteryView.h"
#import "MBProgressHUD+Extension.h"
#import "CYCircularSlider.h"
#import "AppDelegate.h"
#import "DMMyDeviceController.h"
#import "KSAlertTool.h"
#import <AVFoundation/AVFoundation.h>
#define BatteryH 14
#define BatteryYDistance 0.8
@interface DMHomeViewController ()<KSTitleButtonDelegate,UIGestureRecognizerDelegate,CLBLEManagerDelegate,DMKeyViewControllerDelegate,DMEQViewControllerDelegate,DMGoBackButtonDelegate,senderValueChangeDelegate,DMFirmwareVCDelegate>
@property (strong, nonatomic)CBCharacteristic *writeCharacteristic;
@property(nonatomic,strong)CBCharacteristic *notifCharacteristic;
@property(copy,nonatomic)NSString *leftDouble ,*rightDouble,*leftThree,*rightThree;
@property(nonatomic,assign)int leftDoubleBase,leftThreeBase,rightDoubleBase,rightThreeBase;
@property(nonatomic,strong)NSString *keyStr,*versionInfo,*macAddress;
@property(nonatomic,strong)UILabel *connectText;
@property(nonatomic,strong)KSSearchBatteryView *batteryLeftView,*batteryRightView;
@property(nonatomic,strong)UILabel *batteryLeft,*batteryRight;
@property(nonatomic,strong)CYCircularSlider *volumeSlider;
@property(nonatomic,assign)BOOL isClickResetKey;//重置按键
@property(nonatomic,assign)BOOL isUpdateBattery;//点击固件更新电量低于30提示
@property (strong, nonatomic) NSMutableDictionary  *nearbyPeripheralInfos;
@property(nonatomic,strong)UIButton *reconnectBtn;
@property (assign, nonatomic) BOOL isUpdateSuccess;
@property(nonatomic,strong)UIView *maskView;//遮照view
@property(nonatomic,assign)BOOL isNeedUpdate;
@property(nonatomic,assign)BOOL isConnected;
@property(nonatomic,assign)int currentV;
@end


@implementation DMHomeViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if (self.isUpdateSuccess) {
//        NSLog(@"%@===%@",self.bleManager,self.myPeripheral);
        if (self.bleManager&& self.myPeripheral != nil) {
            [self.bleManager connectPeripheral:self.myPeripheral];
            self.isUpdateSuccess = NO;
        }
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:DMSendSliderNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"macArr=%@",self.macArr);
//    [self addMaskView];//添加遮照
    self.currentV = 1;
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionPortBluetoothA2DP object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderNotice:) name:DMSendSliderNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetEq:) name:DMSetEQResetNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChangeNotification:)name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    self.isClickResetKey = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    _nearbyPeripheralInfos = [NSMutableDictionary dictionary];

    self.view.backgroundColor = Gloabal_bg;
    CGFloat titleVY = SCREEN_HEIGHT -titleVHeight;
    CGFloat offsetHeight = iPhoneX ? 100 : 60;
//    CYCircularSlider *volumeSlider = [[CYCircularSlider alloc] initWithFrame:CGRectMake(KScaleWidth(64),  0, SCREEN_WIDTH - KScaleWidth(64)- 55,700)];
    CYCircularSlider *volumeSlider = [[CYCircularSlider alloc] init];
    volumeSlider.delegate = self;
    [volumeSlider addTarget:self action:@selector(valueChange:) forControlEvents:(UIControlEventValueChanged)];
    self.volumeSlider = volumeSlider;
    if ([NSObject isSimuLator]) {
        self.volumeSlider.isStopSlider = NO;
    }else{
        self.volumeSlider.isStopSlider = YES;
    }
    [self.view addSubview:volumeSlider];
    [volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-(titleVHeight + offsetHeight));
        make.left.equalTo(self.view.mas_left).offset(KScaleWidth(64));
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - KScaleWidth(64)- 55, 700));
    }];
    UIImageView *horn = [[UIImageView alloc]init];
    horn.image = [UIImage imageNamed:@"laba"];
    [self.view addSubview:horn];
    CGFloat leftDis = iPhoneX ? 10:4;
//    if (![NSObject isConnectOutput]){
//        volumeSlider.hidden = YES;
//        horn.hidden = YES;
//    }
//
    [horn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(volumeSlider.mas_left).offset(leftDis);
        make.bottom.equalTo(volumeSlider.mas_bottom).offset(-32);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    UIImageView *topBg = [[UIImageView alloc]init];
    topBg.image = [UIImage imageNamed:@"top_bg"];
    [self.view addSubview:topBg];
    [topBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(KScaleHeight(316));
    }];
    
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, 45, 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"BE3000AI", nil) textFont:[UIFont systemFontOfSize:33]];
    back.delegate = self;
    if (self.isScan) {
        back.isScanEnter = YES;
    }
    [self.view addSubview:back];
    
    UIImageView *earImg = [[UIImageView alloc]init];
    earImg.image = [UIImage imageNamed:@"ear_image"];
    [self.view addSubview:earImg];
    [earImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
       make.size.mas_equalTo(CGSizeMake(241, 159));
        make.top.equalTo(self.view.mas_top).offset(KScaleHeight(105));
    }];
    
    
    KSAreaButton *aboutBtn = [KSAreaButton buttonWithType:UIButtonTypeCustom];
    [aboutBtn setImage:[UIImage imageNamed:@"组 30"] forState:(UIControlStateNormal)];
    [aboutBtn addTarget:self action:@selector(aboutClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:aboutBtn];
    [aboutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(49);
        make.right.equalTo(self.view.mas_right).offset(-25);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
   
    /**底部四个*/
    NSArray *titleArray = @[NSLocalizedString(@"按键设置", nil),NSLocalizedString(@"音效模式", nil),NSLocalizedString(@"耳机资料", nil),NSLocalizedString(@"耳机更新", nil)] ;
    
    KSTitleButton *titleV = [[KSTitleButton alloc]initWithFrame:CGRectMake(0, titleVY, SCREEN_WIDTH, titleVHeight) TitleArr:titleArray LineNumber:2 ColumnsNumber:2 EdgeInsetsStyle:LZHEdgeInsetsStyleLeft ImageTitleSpace:5 isUpdate:NO isFemale:NO];
    titleV.delegate = self;
    [self.view addSubview:titleV];
    
    /**电池栏*/
    UIView *batteryV = [[UIView alloc]initWithFrame:CGRectMake(20, titleVY -60, SCREEN_WIDTH -20 *2, 60)];
    batteryV.backgroundColor = [UIColor colorFromHexStr:@"#242529"];
    batteryV.layer.cornerRadius = 10;
    batteryV.layer.masksToBounds =YES;
    [self.view addSubview:batteryV];
    
    self.reconnectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.reconnectBtn addTarget:self action:@selector(reconnectClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.reconnectBtn setTitle:NSLocalizedString(@"連接斷開，点击重连", nil) forState:(UIControlStateNormal)];
    [self.reconnectBtn setTitleColor:[UIColor colorFromHexStr:@"#903A3A"] forState:(UIControlStateNormal)];
    self.reconnectBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [batteryV addSubview:self.reconnectBtn];
    self.reconnectBtn.hidden = YES;
    [self.reconnectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(batteryV);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    
    self.connectText = [[UILabel alloc]init];
    self.connectText.textAlignment = NSTextAlignmentRight;
    self.connectText.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
    self.connectText.font = [UIFont systemFontOfSize:13];
    self.connectText.text =NSLocalizedString(@"连接中…", nil);
    [batteryV addSubview:self.connectText];
    [self.connectText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(batteryV);
        make.left.equalTo(batteryV.mas_left).offset(30);
    }];
    [self.connectText sizeToFit];
    
    KSSearchBatteryView *batteryL= [[KSSearchBatteryView alloc]initWithFrame:CGRectMake(30,  20, 8, BatteryH)];
    [batteryV addSubview:batteryL];
    [batteryL createBattery:30 * 0.1];
    self.batteryLeftView = batteryL;
    
    UILabel *leftL = [[UILabel alloc]init];
    leftL.textAlignment = NSTextAlignmentLeft;
    leftL.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
    leftL.font = [UIFont systemFontOfSize:12];
    leftL.text = [[NSString stringWithFormat:@"L:%d",35] stringByAppendingString:@"%"];
    self.batteryLeft = leftL;
    [batteryV addSubview:leftL];
    [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(batteryL);
        make.leading.equalTo(batteryL.mas_trailing).offset(10);
    }];
    [leftL sizeToFit];
    
    KSSearchBatteryView *batteryR= [[KSSearchBatteryView alloc]initWithFrame:CGRectMake(30,  20, 8, BatteryH)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        batteryR.x = kMaxX(leftL.frame) + 30;
    });
    self.batteryRightView = batteryR;
    [batteryV addSubview:batteryR];
    [batteryR createBattery:40 * 0.1];
    
    UILabel *rightL = [[UILabel alloc]init];
    rightL.textAlignment = NSTextAlignmentLeft;
    rightL.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
    rightL.font = [UIFont systemFontOfSize:12];
    rightL.text = [[NSString stringWithFormat:@"R:%d",35] stringByAppendingString:@"%"];
    self.batteryRight = rightL;
    [batteryV addSubview:rightL];
    [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(batteryL);
        make.leading.equalTo(batteryR.mas_trailing).offset(10);
    }];
    [leftL sizeToFit];
    [self hiddenBattery];
    
    [self initCBCentralManager];
}
-(void)addMaskView{
    self.maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.maskView.backgroundColor = [UIColor clearColor];
    self.maskView.hidden = NO;
    [self.view addSubview:self.maskView];
}
-(void)initCBCentralManager{
     NSLog(@"initCBCentralManager ===== %@ myPeripheral=%@",self.bleManager.manager,self.myPeripheral);
    self.bleManager = [CLBLEManager sharedInstance];
    self.bleManager.delegate = self;
    [self.bleManager initCBCentralManager];
//    [self.bleManager startScanPeripheral];
}
//MARK:-Hidden show Battery
-(IBAction)reconnectClick:(UIButton*)sender{
    [self.bleManager connectPeripheral:self.myPeripheral];
}
-(void)hiddenBattery{
    self.batteryLeft.hidden = YES;
    self.batteryRight.hidden = YES;
    self.batteryLeftView.hidden = YES;
    self.batteryRightView.hidden = YES;
    
}
-(void)showBattery{
    self.batteryLeft.hidden = NO;
    self.batteryRight.hidden = NO;
    self.batteryLeftView.hidden = NO;
    self.batteryRightView.hidden = NO;
    self.connectText.hidden = NO;
    self.reconnectBtn.hidden = YES;
}
-(void)hiddenVolume{//隐藏音量条
    
}
-(void)showVolume{//显示音量条
    
}
//MARK:-音频输出改变
-(void)handleRouteChange:(NSNotification*)nc{
    NSLog(@"handleRouteChange");
}
//MARK:-VolumeDelegate
-(void)senderVlueWithNum:(int)num{//滑动结束时候变化
    NSLog(@"num===%d",num);
    [self writeDataWtihAngle:num];
}
-(void)valueChange:(CYCircularSlider*)slider{
    NSLog(@"value===%d",slider.slideValue);
//    if (!self.bleManager.connected) {
//        slider.slideValue = 1;
//    }
}
-(void)writeDataWtihAngle:(int)angle{
    NSString * str1 = [NSString stringWithFormat:@"%@%@",@"0003",[NSObject to16:angle]];
    NSData *data = [CLDataConver dataWithHexstring:str1];
    [self writeData:data];
}
//MARK:-CLBLEManagerDelegate
-(void)getBatteryInfo{
    [self sendDataCommand:KsGetCommand_Battery];
}
-(void)getkeyFunction{
    [self sendDataCommand:KsGetCommand_Key];
}
-(void)getEq{
    [self sendDataCommand:KsGetCommand_EQ];
}
-(void)getBaseInfo{
    [self sendDataCommand:KsGetCommand_BaseInfo];
}
-(void)getVolumeInfo{
    [self sendDataCommand:KsGetCommand_Volume];
}
-(void)sendDataCommand:(KsGetMessageCommand)command{
    NSMutableData *data = [NSMutableData data];
    char head1 = 0x00;
    [data appendBytes:&head1 length:1];
    [data appendBytes:&command length:1];
    [self writeData:data];
}
- (void)writeData:(NSData *)data{
     [self.myPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
-(void)Unauthorized{
    [KSAlertTool alertTitle:NSLocalizedString(@"Please go to the settings privacy page to enable Bluetooth authorization", nil) mesasge:@"" confirmHandler:^(UIAlertAction * _Nonnull action) {
        NSURL *url2 = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 11.0, *)) {
            if ([[UIApplication sharedApplication] canOpenURL:url2]){
                [[UIApplication sharedApplication] openURL:url2 options:@{} completionHandler:nil];
            }
        }
    } cancleHandler:^(UIAlertAction * _Nonnull cancel) {
    } viewController:self];
}
-(void)adjustEarWithMacAddress{
    [self.nearbyPeripheralInfos enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CBPeripheral*  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self.macArr containsObject:[key substringWithRange:NSMakeRange(4, 12)]]) {
            NSLog(@"obj==%@",obj);
            self.myPeripheral = obj;
        }else{
            
        }
    }];
}

//MARK:-蓝牙ble delegate
-(void)didUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOn:{
            NSLog(@"centralManagerDidUpdateState");
            
            NSArray *array1 = @[[CBUUID UUIDWithString:@"0E80"]];
                NSArray *connectedArr = [self.bleManager.manager retrieveConnectedPeripheralsWithServices:array1];
            if (connectedArr.count > 0){
                NSLog(@"系统已经连接的设备==%@",connectedArr);
                CBPeripheral *peripheral = [connectedArr firstObject];
                [self.bleManager connectPeripheral:peripheral];
            }else{
                [self.bleManager startScanPeripheral];
            }
            
            
        }
            break;
        case CBManagerStatePoweredOff:{
            NSLog(@"Bluetooth is turned off");
        }break;
        case CBManagerStateResetting:
            NSLog(@"System service resetting");
            break;
        case CBManagerStateUnauthorized:
            [self Unauthorized];
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
//    NSLog(@"data=%@",data);
    if ([rssi integerValue] >= -60) {
        NSString *adStr = [CLDataConver hexadecimalString:data];
        if ([[adStr substringToIndex:4] isEqualToString:@"dc08"]){
            if ([[adStr substringWithRange:NSMakeRange(16, 4)] isEqualToString:@"0004"]){
                [self.nearbyPeripheralInfos setObject:peripheral forKey:adStr];
                if ([self.macArr containsObject:[adStr substringWithRange:NSMakeRange(4,12)]]) {
                     NSLog(@"didDiscoverPeripheral-->%@ adv=%@ data=%@",peripheral.name,advertisementData,adStr);
                    self.myPeripheral = peripheral;
                    [self.bleManager connectPeripheral:peripheral];
                    [self.bleManager stopScanPeripheral];
                }
            }
        }
    }
}

-(void)didConnectedPeripheral:(CBPeripheral *)connectedPeripheral{
    NSLog(@" --> didConnectedPeripheral==%@",connectedPeripheral);
}
-(void)failToConnectPeripheral:(CBPeripheral *)peripheral Error:(NSError *)error{
    NSLog(@"failToConnectPeripheral---%@", error);
}
- (void)didFailedToInterrogate:(CBPeripheral *)peripheral {
    NSLog(@"didFailedToInterrogate");
}
-(void)didDiscoverServices:(CBPeripheral *)peripheral{
     NSLog(@"--> didDiscoverService:%@",peripheral.services);
    CBService * __nullable findService = nil;
    for (CBService *service in peripheral.services) {
         
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"0E80"]]){
            findService = service;
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
    if (findService) {
        NSLog(@"serviceUUID:%@",[findService UUID]);
    }
    
}
-(void)cl_didConnectTimeout:(CBPeripheral *)peripheral{
    NSLog(@"cl_didConnectTimeout");
}
-(void)cl_didDisconnectPeripheral:(CBPeripheral *)peripheral{
    LogMethod();
    [self hiddenBattery];
    self.connectText.hidden = YES;
    self.reconnectBtn.hidden = NO;
}
- (void)didDiscoverCharacteritics:(CBService *)service{
    NSLog(@"--> didDiscoverCharacteritics:%@",service);
    for (CBCharacteristic *characteristic in service.characteristics){
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0E81"]]){
            [self.myPeripheral readValueForCharacteristic:characteristic];
        }
        
        if ((characteristic.properties & CBCharacteristicPropertyNotify) || (characteristic.properties & CBCharacteristicPropertyIndicate)) {
            // 订阅通知
//            self.notifCharacteristic = characteristic;
            [self.myPeripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0E82"]]){
            _writeCharacteristic = characteristic;
           [self getBatteryInfo];
           [self getkeyFunction];
           [self getBaseInfo];
           [self getVolumeInfo];
            [self.myPeripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
//
//        [self.myPeripheral readValueForCharacteristic:characteristic];
//        [self.myPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
    
}
-(void)didReadValueForCharacteristic:(CBCharacteristic *)characteristic{
//    NSLog(@"value=%@",[CLDataConver hexadecimalString: characteristic.value]);
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0E82"]]) {
            _writeCharacteristic = characteristic;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"0E81"]]){
        NSLog(@"didReadValueForCharacteristic");
        NSString *str = [CLDataConver hexadecimalString: characteristic.value];
        if (str.length>=4){
            NSString *subStr = [str substringToIndex:4];
            if ([subStr isEqualToString:ksBatteryPower]){
                if (self.isUpdateBattery) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:DMBatteryLowPowerNotification object:[str substringFromIndex:4]];
                    self.isUpdateBattery = NO;
                }else{
                    [self getBatteryWithStr:[str substringFromIndex:4]];
                }
            }else if ([subStr isEqualToString:ksGetKeyFunction]){
                self.keyStr= [str stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:ksSetKeyFunction];
                [self calculKeyWithKey:str];
            }else if ([str isEqualToString:@"000901"]){
                NSLog(@"设置按键功能成功");
                [self getkeyFunction];
                if (self.isClickResetKey) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:DMSetkeyResetNotification object:nil];
                    self.isClickResetKey = NO;
                }
            }else if ([subStr isEqualToString:ksAcquireVolume]){
               int value =  [[CLDataConver to10:[str substringFromIndex:str.length - 2]] intValue];
                [self.volumeSlider setAngel:value];
                 NSLog(@"value=%d",value);
            }else if ([subStr isEqualToString:ksGetEqInfo]){
                if ([NSObject isBleToothOutput]){
                    if ([str isEqualToString:@"00a1ff"]) {
                        [MBProgressHUD showAutoMessage:NSLocalizedString(@"请播放歌曲然后再设置EQ",nil) toView:kKeyWindow];
                    }else{
                        [self setEqWithStr:str];
                    }
                }
            }else if ([str isEqualToString:@"00a201"]){
                NSLog(@"EQ设置成功");
            }else if ([subStr isEqualToString:ksGetMacAddress]){
                NSLog(@"baseinfo=%@",str);
                [self setBaseInfo:str];
            }
        }
    }
}
-(void)cl_didUpdateNotificationStateError:(NSError *)error{
    NSLog(@"cl_didUpdateNotificationStateError");
}
-(void)cl_peripheral:(CBPeripheral *)peripheral didUpdateNotifiForCharacteristic:(CBCharacteristic *)characteristic{
    if(characteristic.isNotifying){
         NSLog(@"Notification began on %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
       
    }else{
        NSLog(@"Notification stopped on %@. Disconnting", characteristic);
        //读取值完毕 设置
        [self loadData];
    }
}
-(void)cl_peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic{
    [self.myPeripheral readValueForCharacteristic:characteristic];
}
//MARK:- Read Value
-(void)loadData{
    if (self.advStr.length>0) {//从扫描进来
        //保存当前连接上的耳机
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        if ([DMAppUserSetting shareInstance].addressArr.count>0) {
            [tempArray addObjectsFromArray:[DMAppUserSetting shareInstance].addressArr];//存在的加到数组
        }
        
        NSString *leftMacStr = [self.advStr substringWithRange:NSMakeRange(4, 12)];
        NSString *rightMacStr = [self.advStr substringFromIndex:self.advStr.length -12];
        NSArray *arr = @[leftMacStr,rightMacStr];
         [tempArray addObject:arr];
        NSLog(@"扫描进来的 tempArr=%@",tempArray);
        [[DMAppUserSetting shareInstance] setAddressArr:tempArray];
        
    }else{
        //判断包不包含这个
        if ([DMAppUserSetting shareInstance].addressArr.count>0) {
            
            NSMutableArray * arr1 = [[NSMutableArray alloc]init];
            [arr1 addObjectsFromArray:[DMAppUserSetting shareInstance].addressArr];
//
//            for (int x= 0; x< arr1.count; x++) {
//                for (int y =x+1; y<arr1.count; y++) {
//                    if ([arr1[x] containsObject:arr1[y][0]] && [arr1[x] containsObject:arr1[y][1]]) {
//                        [arr1 removeObject:arr1[y]];
//                    }
//                }
//            }
             NSLog(@"arrTemp==%@",arr1);
//            [[DMAppUserSetting shareInstance] setAddressArr:arr1];
        }
    }
    self.volumeSlider.isStopSlider = NO;
    [self showBattery];
    self.connectText.text = NSLocalizedString(@"連接成功!", nil);
    self.maskView.hidden = YES;
    [self.connectText mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view.mas_trailing).offset(-60);
    }];
}
-(void)getBatteryWithStr:(NSString*)temp{
    NSString *tempStr = [HYRadix hy_convertToDecimalFromHexadecimal:@"7f"];
    int leftNum = [[HYRadix hy_convertToDecimalFromHexadecimal:[temp substringToIndex:2]] intValue] & [tempStr intValue];
    int rightNum = [[HYRadix hy_convertToDecimalFromHexadecimal:[temp substringFromIndex:2]] intValue] & [tempStr intValue];
    NSLog(@"leftNum=%d rightNum=%d",leftNum,rightNum);
    self.batteryLeft.text = [[NSString stringWithFormat:@"L:%d",leftNum] stringByAppendingString:@"%"];
    self.batteryRight.text = [[NSString stringWithFormat:@"R:%d",rightNum] stringByAppendingString:@"%"];
    [self.batteryLeftView.batteryV removeFromSuperview];
    [self.batteryRightView.batteryV removeFromSuperview];
    
    [self.batteryLeftView createBattery:leftNum *(BatteryH-BatteryYDistance*2)/100];
    [self.batteryRightView createBattery:rightNum *(BatteryH-BatteryYDistance*2)/100];
}
-(void)calculKeyWithKey:(NSString*)key{
    
    self.leftDouble =  [key substringWithRange:NSMakeRange(8, 4)]; //左双击
    self.leftThree =  [key substringWithRange:NSMakeRange(12, 4)]; //左三击
    self.rightDouble =  [key substringWithRange:NSMakeRange(24, 4)]; //右双击
    self.rightThree =  [key substringWithRange:NSMakeRange(28, 4)]; //右三击
   
    //计算四个基数
    self.leftDoubleBase = [NSObject getBaseKey:self.leftDouble];
    self.leftThreeBase= [NSObject getBaseKey:self.leftThree];
    self.rightDoubleBase = [NSObject getBaseKey:self.rightDouble];
    self.rightThreeBase = [NSObject getBaseKey:self.rightThree];
}
-(void)setBaseInfo:(NSString*)info{
    //00331100ff0100663300ff08
    self.versionInfo = [info substringFromIndex:info.length -8];
    self.macAddress = info;
    
    NSString *left= [self.versionInfo substringWithRange:NSMakeRange(2, 2)];
    
    if ([[HYRadix hy_convertToDecimalFromHexadecimal:left] intValue] <self.currentV) {
        self.isNeedUpdate = YES;
    }
}
-(void)setEqWithStr:(NSString*)str{
    if ([str substringFromIndex:4].length ==20){
        DMEQViewController *eq = [[DMEQViewController alloc]init];
        eq.delegate = self;
        eq.eqValue = [str substringFromIndex:4];
        [self.navigationController pushViewController:eq animated:YES];
    }
}
//MARK:-DMKeyViewControllerDelegate
-(void)clickSelectRow:(NSInteger)row selectName:(NSString *)name{
    
    int selectNum = [CLDataConver toCurrentStr:name];
    NSLog(@"select=%d %@",selectNum,name);
    if (row == 0) { //左双击
         int newKey = self.leftDoubleBase + selectNum;//当前设置的值+Base值
        [self isEqualName:name location:8 keyBase:newKey];
    }
    if (row == 1) { //左耳三击
        int newKey = self.leftThreeBase + selectNum;
        [self isEqualName:name location:12 keyBase:newKey];
    }
    if (row == 2) { //左耳三击
        int newKey = self.rightDoubleBase + selectNum;
        [self isEqualName:name location:24 keyBase:newKey];
    }
    if (row == 3) {
        int newKey = self.rightThreeBase + selectNum;
        [self isEqualName:name location:28 keyBase:newKey];
    }
}
-(void)isEqualName:(NSString*)name location:(NSInteger)loc keyBase:(int)baseKey{
    NSString *value = [HYRadix hy_convertToHexadecimalFromDecimal:[NSString stringWithFormat:@"%d",baseKey]];
    NSString *value1 = [NSString stringWithFormat:@"0000%@",value];
    NSString *value2 = [value1 substringFromIndex:value1.length -4];
    NSLog(@"newValue==%@",value2);
    [self writeDataLocation:loc Str:value2];
}
-(void)writeDataLocation:(NSInteger)loc Str:(NSString*)str{
    self.keyStr = [self.keyStr stringByReplacingCharactersInRange:NSMakeRange(loc, 4) withString:str];
    //00090003 00080001 00440003 00040010 0044
    NSString *time1 = [HYRadix hy_convertToHexadecimalFromDecimal:[NSString getCurrentTimestamp]];
    NSData *data1 = [CLDataConver dataWithHexstring:[NSString stringWithFormat:@"%@%@",self.keyStr,time1]];
    [self writeData:data1];
}
-(void)clickResetKeyBtn{
    self.isClickResetKey = YES;
    char send[18] = {0x00,0x09,0x00,0x03,0x00,0x06,0x00,0x08,0x01,0x40,0x00,0x03,0x00,0xa0,0x00,0x10,0x01,0x40};
    NSData *sendData = [NSData dataWithBytes:send length:18];
    NSString *time1 = [HYRadix hy_convertToHexadecimalFromDecimal:[NSObject getCurrentTimestamp]];
    NSString *keyStr = [CLDataConver hexadecimalString:sendData];
    NSData *data = [CLDataConver dataWithHexstring:[NSString stringWithFormat:@"%@%@",keyStr,time1]];
    NSLog(@"clickResetKey==%@",data);
    [self writeData:data];
}
//MARK:-DMEQViewControllerDelegate
-(void)sendCustomArr:(NSArray *)eqArr{
    NSMutableArray * arr1 = [[NSMutableArray alloc]init];
    for (NSString *num in eqArr){
         NSString *subStr;
        if ([num intValue] < 0) {
            NSString *str1 = [NSObject getHexByDecimal:[num intValue]];
            subStr = [str1 substringFromIndex:str1.length -2];
            
        }else{
            subStr = [NSObject to16:[num intValue]];
        }
        [arr1 addObject:subStr];
    }
    NSString *eqStr =  [arr1 componentsJoinedByString:@""];
    NSString *time1 = [HYRadix hy_convertToHexadecimalFromDecimal:[NSString getCurrentTimestamp]];
    NSString *eqStr1 = [NSString stringWithFormat:@"%@%@%@",@"00a2",eqStr,time1];
    NSLog(@"eqStr1=%@",eqStr1);
    NSData *data = [CLDataConver dataWithHexstring:eqStr1];
    [self writeData:data];
}
//MARK:-DMFirmViewControllerDelegate
-(void)getBattery{
    self.isUpdateBattery = YES;
    [self getBatteryInfo];
}
#pragma mark -
#pragma mark notification destruction
-(void)sliderNotice:(NSNotification*)nc{
    NSLog(@"notice==%@",nc.object);
    NSMutableArray * arr1 = [[NSMutableArray alloc]initWithObjects:@"0f",@"0f",@"0f",@"0f",@"0f",@"0f",@"0f",@"0f",@"0f",@"0f",nil];
    NSArray *arr = [[nc.object allValues] firstObject];
    NSInteger tag = [[[nc.object allKeys] firstObject] integerValue];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           if (tag == idx) {
               int value = [obj intValue];
               NSString *subStr;
               if (value < 0) {
                   
                   NSString *str1 = [NSObject getHexByDecimal:value];
                   subStr = [str1 substringFromIndex:str1.length -2];
//                   NSLog(@"value===%d str=%@",value,subStr);
               }else{
                   subStr = [NSString to16:value];
               }
               
                [arr1 replaceObjectAtIndex:tag withObject:subStr];
           }
       }];
    NSString *eqStr =  [arr1 componentsJoinedByString:@""];
    NSString *time1 = [HYRadix hy_convertToHexadecimalFromDecimal:[NSString getCurrentTimestamp]];
    NSString *eqStr1 = [NSString stringWithFormat:@"%@%@%@",@"00a2",eqStr,time1];
    NSData *data = [CLDataConver dataWithHexstring:eqStr1];
    [self writeData:data];
}
-(void)resetEq:(NSNotification*)nc{
   
    NSInteger selectItem = [[[nc.object allKeys] firstObject] integerValue];
    if (selectItem>0) {
        [self sendCustomArr:[[nc.object allValues]firstObject]];
    }else{
        NSString *time1 = [HYRadix hy_convertToHexadecimalFromDecimal:[NSObject getCurrentTimestamp]];
        NSString *eqStr1 = [NSString stringWithFormat:@"%@%@",@"00a9",time1];
        NSData *data = [CLDataConver dataWithHexstring:eqStr1];
        [self writeData:data];
    }
   
}
-(void)clickBackBtn{
    if (self.myPeripheral!=nil) {
        [self.bleManager.manager cancelPeripheralConnection:self.myPeripheral];
    }
    if (self.isScan) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        DMMyDeviceController *device = [DMMyDeviceController new];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:device];
        [appDelegate.window setRootViewController:nav];
        self.isScan = NO;
    }
    
    
}
//MARK:- clickNextPage Method
-(void)clickBtnIndex:(KSTitleViewStyle)style Title:(NSString *)title{
    
    #if (TARGET_IPHONE_SIMULATOR)
    DMInfoViewController *eq1 = [[DMInfoViewController alloc]init];
//    eq1.delegate = self;
    [self.navigationController pushViewController:eq1 animated:YES];
    #else
   
    #endif
    
    if (!self.bleManager.connected) {
         [MBProgressHUD showAutoMessage:NSLocalizedString(@"未连接", nil)  toView:self.view];
    }else{
        switch (style) {
            case KSKeyConfigStyle:{
                DMKeyViewController *key = [[DMKeyViewController alloc]init];
                key.keyStr = self.keyStr; 
                key.delegate = self;
                if (![NSObject isBlankString:self.leftDouble]) {
                    [self.navigationController pushViewController:key animated:YES];
                }
                
            }break;
            case KSGeneralSetStyle:{//EQ
                
                #if (TARGET_IPHONE_SIMULATOR)
                DMEQViewController *eq = [[DMEQViewController alloc]init];
                eq.delegate = self;
                [self.navigationController pushViewController:eq animated:YES];
                 #else
                [self getEq];
                 #endif
            }break;
            case KSEQGainStyle:{
                DMInfoViewController *info = [[DMInfoViewController alloc]init];
                info.versionInfo = self.versionInfo;
                [self.navigationController pushViewController:info animated:YES];
            }break;
            case KSFirmwareUpdateStyle:{
                if (self.isNeedUpdate) {
                    DMFirmwareController *firm = [[DMFirmwareController alloc]init];
                    firm.delegate = self;
                    firm.macArr = self.macArr;
                    firm.macInfo = self.macAddress;
                    firm.baseInfo = self.versionInfo;
                    firm.bleManager = self.bleManager;
                    firm.myPeripheral = self.myPeripheral;
                    hq_weak(self)
                    self.isUpdateSuccess = NO;
                    firm.updateSuccessBlock = ^(BOOL isSuccess) {
                        hq_strong(self)
                        self.isUpdateSuccess = isSuccess;
                    };
                    [self.navigationController pushViewController:firm animated:YES];
                }else{
                    [MBProgressHUD showAutoMessage:NSLocalizedString(@"已经是最新版本", nil) toView:kKeyWindow];
                }
            }break;
            default:
                break;
        }
    }
}
//系统音量回调
- (void)volumeChangeNotification:(NSNotification *)noti {
    float volume = [[[noti userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    NSLog(@"系统音量:%f", volume);
}

//MARK:-method click
-(IBAction)aboutClick:(KSAreaButton*)sender{
    [self.navigationController pushViewController:[DMAboutViewController new] animated:YES];
}

-(void)dealloc{
//    LogMethod();
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DMSendSliderNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DMSetEQResetNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionPortBluetoothA2DP object:nil];
}
@end
