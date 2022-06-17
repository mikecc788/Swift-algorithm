//
//  DMFiemwareController.m
//  DMSound
//
//  Created by kiss on 2020/5/26.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMFirmwareController.h"
#import "DMUpdateAlert.h"
#import "DMGoBackButton.h"
#import "GaiaLibrary.h"
#import "BTLibrary.h"
#import "AppDelegate.h"
#import "KSAlertTool.h"
#import "MBProgressHUD+Extension.h"
#import "CLDataConver.h"
#import "DMHomeParasModel.h"
#import "DMProGressView.h"
#import "DMSuccessView.h"
#import "ZTGCDTimerManager.h"
#import "DMFailUpdateView.h"
#define DleSizeTextStr @"188"
#define DEFAULT_SIZE 23
#define GaiaServiceUUID     @"00001100-D102-11E1-9B23-00025B00A5A5"

@interface DMFirmwareController ()<DMUpdateAlertDelegate,CSRConnectionManagerDelegate,CSRUpdateManagerDelegate>
@property(nonatomic,strong)DMHomeParasModel *paraM;
@property(nonatomic,strong)NSString *leftMacVersion,*rightMacVersion;
@property(nonatomic,strong)NSString *leftAddress,*rightAddress;
@property(nonatomic,assign)BOOL isNeedUpdateOne;//只需要更新一个
@property(nonatomic,assign)BOOL isNotUpdate;
@property(nonatomic,strong)NSString *batteryL,*batteryR;
@property(nonatomic,assign)int currentV;//默认版本0002
@property(nonatomic,strong)DMUpdateAlert * updateView;
@property(nonatomic,strong)UIProgressView *progressView;
@property(nonatomic,strong)DMProGressView *gressV;
@property (nonatomic,assign) BOOL isDataEndPointAvailabile;
@property(nonatomic,strong)CSRPeripheral *connectPer;
@property(nonatomic,assign)BOOL isReconnectSecond;
@property(nonatomic,strong)UILabel *statusSecond;
@property(nonatomic,strong)UILabel *statusLabel;
@property(nonatomic,strong)UIButton *quitBtn;
@property (nonatomic,strong) CSRPeripheral *chosenPeripheral;

@property (nonatomic,assign) NSInteger   curCountDown;
@property (nonatomic,strong) UIView *updateBg;
@property (nonatomic,strong) UILabel *lableDes;
@end

@implementation DMFirmwareController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.paraM = [[DMHomeParasModel alloc]init];
    self.connectPer = [[CSRPeripheral alloc]init];
    self.connectPer.peripheral = self.myPeripheral;
    
    self.leftAddress = [self.macInfo substringWithRange:NSMakeRange(4, 12)];
    self.rightAddress = [self.macInfo substringWithRange:NSMakeRange(16, 12)];
    NSLog(@"macInfo=%@ macArr=%@",self.macInfo,self.macArr);
    
    self.view.backgroundColor = Gloabal_bg;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBattery:) name:DMBatteryLowPowerNotification object:nil];
    self.currentV = 2;
    NSString *content = NSLocalizedString(@"1.修复部分Bug\n2.修改连接问题", nil) ;
    DMUpdateAlert * updateView = [[DMUpdateAlert alloc]initWithFrame:kKeyWindow.frame content:content  currentV:self.currentV];
//    hq_weak(updateView)
//    hq_weak(self)
    updateView.delegate = self;
    [self.view addSubview:updateView];
    
    UIImageView *bgImg = [[UIImageView alloc]initWithFrame:self.view.bounds];
    bgImg.image = [UIImage imageNamed:@"scan_bg"];
    [self.view addSubview:bgImg];
    
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, 40, 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"耳機更新", nil) textFont:[UIFont systemFontOfSize:34]];
    [self.view addSubview:back];
}

-(void)clickUpdateNow{
    //先判断电量
    [self checkBattery];
    if ([NSObject isSimuLator]) {
        [self loadProgressView];
    }
}
-(IBAction)quitClick:(UIButton*)sender{
    LogMethod();
    [self resetBool];
    [[CSRGaiaManager sharedInstance] abort];
    if (self.updateSuccessBlock) {
        self.updateSuccessBlock(YES);
    }
    [[ZTGCDTimerManager sharedInstance]cancelTimerWithName:@"dm.first.singleTimer"];
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK:-Update Delegate
- (void)didReceiveGaiaGattResponse:(CSRGaiaGattCommand *)command {
    GaiaCommandType cmdType = [command getCommandId];
    NSData *requestPayload = [command getPayload];
    uint8_t success = 0;
    NSLog(@"%s",__func__);
    [requestPayload getBytes:&success range:NSMakeRange(0, sizeof(uint8_t))];
    if (cmdType == GaiaCommand_SetDataEndPointMode && requestPayload.length > 0) {
        uint8_t value = 0;
        [requestPayload getBytes:&value range:NSMakeRange(0, sizeof(uint8_t))];
        
        if (value == GaiaStatus_Success) {
            NSLog(@"GaiaStatus_Success");
            self.isDataEndPointAvailabile = true;
        } else {
            self.isDataEndPointAvailabile = false;
        }

        if (self.isReconnectSecond){
            
            if (!self.paraM.isReceiveGaiaResponseSecond) {
                if (!self.paraM.isSecondResponse) {
                    NSLog(@"isReconnectSecondDataEndPoint");
                    self.paraM.isReceiveGaiaResponseSecond = YES;
                    [self startLoadFile];
                    [[ZTGCDTimerManager sharedInstance]cancelTimerWithName:@"dm.firstSuccess.singleTimer"];
                }
            }
        }else{
            if (!self.paraM.isReceiveGaiaResponse) {
                if (!self.paraM.isFirstResponse){
                    NSLog(@"firstdataEndPointUpdate");
                    self.paraM.isReceiveGaiaResponse = YES;
                    [self startLoadFile];
                    [[ZTGCDTimerManager sharedInstance]cancelTimerWithName:@"dm.first.singleTimer"];
                }
            }
        }
    }
}

- (void)didDiscoverPeripheral:(CSRPeripheral *)peripheral{
    NSLog(@"didDiscoverPeripheral %s%@",__func__,peripheral.peripheral.name);
//    if (self.isReconnectSecond) {
//        [[CSRConnectionManager sharedInstance] stopScan];
//        self.chosenPeripheral = peripheral;
//        [[CSRConnectionManager sharedInstance] connectPeripheral:peripheral];
//    }else{
//        if (!self.paraM.isUpdateScanFirst) {
//            [[CSRConnectionManager sharedInstance] stopScan];
//            self.chosenPeripheral = peripheral;
//            if (![self.chosenPeripheral isConnected]){
//                NSLog(@"chosenPeripheral isConnected");
//                 [[CSRConnectionManager sharedInstance] connectPeripheral:peripheral];
//            }
//            self.paraM.isUpdateScanFirst = YES;
//        }
//    }
    
    [[CSRConnectionManager sharedInstance] stopScan];
    self.chosenPeripheral = peripheral;
    [[CSRConnectionManager sharedInstance] connectPeripheral:peripheral];
}
-(void)discoveredPripheralDetails{

    if (self.isReconnectSecond){
        NSLog(@"更新第二个耳机\n%@\nsecondService==%@",self.chosenPeripheral.peripheral.name ,self.chosenPeripheral.peripheral.services);
    }else{
        NSString *firstMac = [CLDataConver hexadecimalString:self.chosenPeripheral.advertisementData[@"kCBAdvDataManufacturerData"]];
        if ([[firstMac substringWithRange:NSMakeRange(4, 12)] isEqualToString:self.leftAddress]){
            NSLog(@"开始更新第一个耳机 左==%@ firstmac==%@ 版本=%d",self.chosenPeripheral.peripheral.name,self.leftAddress,self.currentV);
            self.paraM.firstUpdateMacStr = self.leftAddress;
        }else{
            NSLog(@"开始更新第一个耳机 右=%@",[firstMac substringWithRange:NSMakeRange(4, 12)]);
            self.paraM.firstUpdateMacStr = self.rightAddress;
        }
    }
    
    for (CBService *service in self.chosenPeripheral.peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:GaiaServiceUUID]){
             [self setDelegate];
        }
    }
}
-(void)setDelegate{
    [[CSRGaia sharedInstance]
    connectPeripheral:[CSRConnectionManager sharedInstance].connectedPeripheral];
    [CSRGaiaManager sharedInstance].delegate = self;
    [[CSRGaiaManager sharedInstance] connect];
    [[CSRGaiaManager sharedInstance] setDataEndPointMode:true];
}

#pragma mark CSRUpdateManager delegate methods
- (void)confirmRequired {
    [[CSRGaiaManager sharedInstance] commitConfirm:YES];
    NSLog(@"complete the upgrade");
}
- (void)confirmForceUpgrade {
     [[CSRGaiaManager sharedInstance] abortAndRestart];
}
- (void)okayRequired {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"SQIF Erase"
                                message:@"About to erase SQIF partition"
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [[CSRGaiaManager sharedInstance] eraseSqifConfirm];
                               }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)didAbortWithError:(NSError *)error {
     [[CSRGaiaManager sharedInstance] confirmError];
    [self removeProgress];
    DMFailUpdateView *fail = [[DMFailUpdateView alloc]initWithFrame:CGRectMake(0, KScaleHeight(150), SCREEN_WIDTH, 400)];
    [self.view addSubview:fail];
    fail.onButtonTouchUpFail = ^(DMFailUpdateView * _Nonnull failView) {
        [failView removeFromSuperview];
        [self cancelUpdate];
        [self loadProgressView];
    };
}
- (void)didMakeProgress:(double)value eta:(NSString *)eta{
    if (self.isReconnectSecond){
        self.gressV.progressValue = value *0.5/ 100 +0.5;
    }else{
        self.gressV.progressValue = value *0.5/ 100;
    }
//    self.lableDes.text =eta;
    NSLog(@"progressValue=%f eta=%@",self.gressV.progressValue,eta);
    
}
- (void)didCompleteUpgrade{
    if (self.isReconnectSecond) {//更新第二个
        NSLog(@"------ didSecondCompleteUpgrade 第二个更新成功-----");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self resetBool];
        [self tidyupSecond];
        [[CSRConnectionManager sharedInstance] CSRConnectionDealloc];
        [self removeProgress];
        DMSuccessView *successV = [[DMSuccessView alloc]initWithFrame:CGRectMake(0, KScaleHeight(200), SCREEN_WIDTH, 300)];
        [self.view addSubview:successV];
        successV.onButtonTouchUpSuccess = ^(DMSuccessView * _Nonnull successView) {
            [successView removeFromSuperview];
            if (self.updateSuccessBlock) {
                self.updateSuccessBlock(YES);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        };
    }else{
        NSLog(@"第一个耳机 Update successful %s",__func__);
        self.paraM.isFirstResponse = NO;
        self.paraM.isReceiveGaiaResponse = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //断开第一个
        [self tidyupFirst];
        self.isReconnectSecond = YES;
        NSMutableArray *arrayMAc = [[NSMutableArray alloc]init];
        [arrayMAc addObjectsFromArray:self.macArr];
        
        [arrayMAc enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:self.paraM.firstUpdateMacStr]) {
                [arrayMAc removeObject:obj];
            }
        }];
        CBUUID *deviceInfoUUID = [CBUUID UUIDWithString:@"AE86"];
        NSArray *array = @[deviceInfoUUID];
        [[CSRConnectionManager sharedInstance] addDelegate:self];
        [[CSRConnectionManager sharedInstance] startScan:array withMacFilter:arrayMAc];
        //第一个成功之后加个定时器
        [[ZTGCDTimerManager sharedInstance] scheduleGCDTimerWithName:@"dm.firstSuccess.singleTimer" interval:1 queue:dispatch_get_main_queue() repeats:YES option:CancelPreviousTimerAction action:^{
            [self clickCountDown];
        }];
        self.curCountDown = 60;
    }
}
- (void)didAbortUpgrade{
    if (self.isReconnectSecond){
           NSLog(@"didAbortUpgrade");
    }else{
        [self removeProgress];
        DMFailUpdateView *fail = [[DMFailUpdateView alloc]initWithFrame:CGRectMake(0, KScaleHeight(150), SCREEN_WIDTH, 400)];
        [self.view addSubview:fail];
        fail.onButtonTouchUpFail = ^(DMFailUpdateView * _Nonnull failView) {
            [failView removeFromSuperview];
            [self cancelUpdate];
            [self loadProgressView];
        };
    }
}
//文件传输完成
- (void)confirmTransferRequired {
    /*文件传输完成设备重启页面 第一个耳机更新时候不用跳转**/
    [[CSRGaiaManager sharedInstance] updateTransferComplete];
    
    NSLog(@"confirmTransferRequired");
}
- (void)abortTidyUp {
    LogMethod();
    [CSRGaiaManager sharedInstance].updateInProgress = NO;
}
-(void)didUpdateStatus:(NSString *)value{
    if (self.isReconnectSecond) {
        [self.statusSecond setText:value];
        NSLog(@"statusSecondText==%@",self.statusSecond.text);
    }else{
        [self.statusLabel setText:value];
        NSLog(@"statusText==%@",self.statusLabel.text);
    }
}
- (void)didWarmBoot{
    if (self.isReconnectSecond) {
        [[CSRConnectionManager sharedInstance] removeDelegate:self];
        self.statusSecond = [[UILabel alloc]init];
        self.statusSecond.text = @"";
        [self.view addSubview:self.statusSecond];
        self.paraM.isSecondResponse = YES;
    }else{
        [[CSRConnectionManager sharedInstance] removeDelegate:self];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        self.statusLabel = [[UILabel alloc]init];
        self.statusLabel.text = @"";
        [self.view addSubview:self.statusLabel];
        self.paraM.isFirstResponse = YES;
    }
}
-(void)didCompleteError{
    [self abortTidyUp];
    [self removeProgress];
    DMFailUpdateView *fail = [[DMFailUpdateView alloc]initWithFrame:CGRectMake(0, KScaleHeight(150), SCREEN_WIDTH, 400)];
    [self.view addSubview:fail];
    fail.onButtonTouchUpFail = ^(DMFailUpdateView * _Nonnull failView) {
        [failView removeFromSuperview];
        [self cancelUpdate];
        [self loadProgressView];
    };
}
-(void)resetBool{
    self.paraM.isReceiveGaiaResponseSecond = NO;
    self.isReconnectSecond = NO;
    self.paraM.isUpdateScanFirst = NO;
    self.paraM.isUpdateScanSecond = NO;
    self.paraM.isSecondResponse = NO;
    self.paraM.isFirstResponse = NO;
    self.paraM.isReceiveGaiaResponse = NO;
//    self.isUpdateConnect = NO;
//    self.isUpdateBattery = NO;
}
-(void)cancelUpdate{
    [self resetBool];
    [[CSRGaiaManager sharedInstance] abort];
    [[CSRGaiaManager sharedInstance] disconnect];
    [CSRGaiaManager sharedInstance].delegate = nil;
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
    
}
//MARK:-update Method
-(void)updateFailed{//
    [[CSRGaiaManager sharedInstance] abort];
    [[CSRGaiaManager sharedInstance] disconnect];
    [CSRGaiaManager sharedInstance].delegate = nil;
    [CSRGaiaManager sharedInstance].updateInProgress = NO;
    [[CSRConnectionManager sharedInstance] stopScan];
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
    [self resetBool];
    
}
-(void)checkBattery{
    [self checkVersion];
    if (self.isNotUpdate) {
        [MBProgressHUD showAutoMessage:NSLocalizedString(@"No Update at Present", nil) toView:kKeyWindow];
    }else{
        int left = [self.batteryL intValue];
        int right = [self.batteryR intValue];
        NSLog(@"leftbattery==%d rightbattery==%d",left,right);
        if (left > 20 && right > 20) {
            NSLog(@"直接获取到的电量值可以更新");
            [self loadProgressView];
        }else{
            //先去判断耳机电量值
           if ([self.delegate respondsToSelector:@selector(getBattery)]) {
               [self.delegate getBattery];
           }
        }
    }
}
-(void)checkVersion{
    
    #if (TARGET_IPHONE_SIMULATOR)
    self.baseInfo = @"20012001";
    #else
    #endif
    self.leftMacVersion = [self.baseInfo substringFromIndex:self.baseInfo.length-2];
    self.rightMacVersion = [self.baseInfo substringWithRange:NSMakeRange(self.baseInfo.length-6, 2)];
    int left = (int)strtoul([self.leftMacVersion UTF8String], 0,16);
    int right = (int)strtoul([self.rightMacVersion UTF8String], 0,16);
    NSLog(@"ver==%d=%d",left,right);
    if (self.currentV > left && self.currentV > right) {
        NSLog(@"需要更新两个");
    }else if(self.currentV > left || self.currentV > right){
        NSLog(@"需要更新1个");
        self.isNeedUpdateOne = YES;
    }else{
        NSLog(@"不需要更新");
        self.isNotUpdate = YES;
    }
}
-(void)tidyupFirst{
    [CSRGaiaManager sharedInstance].delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [CSRGaiaManager sharedInstance].updateInProgress = NO;
    [[CSRGaiaManager sharedInstance] disconnect];
}
-(void)tidyupSecond{
    [[CSRGaiaManager sharedInstance] abort];
    [[CSRGaiaManager sharedInstance] disconnect];
    [CSRGaiaManager sharedInstance].delegate = nil;
    [CSRGaiaManager sharedInstance].updateInProgress = NO;
    [[CSRConnectionManager sharedInstance] disconnectPeripheral];
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
}
/**update delegate*/
-(void)startLoadFile{
    NSString *fileName;
    fileName = SmallFileName;
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"bin"];
    if ([CSRConnectionManager sharedInstance].connectedPeripheral.isDataLengthExtensionSupported){
        NSUInteger value = DleSizeTextStr.integerValue;
        NSUInteger maxValue = [CSRConnectionManager sharedInstance].connectedPeripheral.maximumWriteLength;
        
        maxValue = [CSRConnectionManager sharedInstance].connectedPeripheral.maximumWriteWithoutResponseLength;
        
        [CSRGaiaManager sharedInstance].useDLEifAvailable = true;
        [CSRGaiaManager sharedInstance].maximumMessageSize = value;
    }else{
         [CSRGaiaManager sharedInstance].maximumMessageSize = DEFAULT_SIZE;
    }
    
    if (self.isDataEndPointAvailabile) {
        [QTIRWCP sharedInstance].initialCongestionWindowSize = 3;
        [QTIRWCP sharedInstance].maximumCongestionWindowSize = 4;
        [[CSRGaiaManager sharedInstance]start:dataPath useDataEndpoint:true];
    }else{
//        self.gressV.progressValue = [CSRGaiaManager sharedInstance].updateProgress;
    }
}
-(void)startUpdate{
    self.isDataEndPointAvailabile = false;
    if (!(self.myPeripheral.state == CBPeripheralStateConnected)) {
        NSLog(@"myPeripheral=%@",self.myPeripheral);
//           [[CSRConnectionManager sharedInstance] startScan:nil withMacFilter:self.macArr];
        [[CSRConnectionManager sharedInstance]initCBCentralManager];
    }else{
      [self.bleManager.manager cancelPeripheralConnection:self.myPeripheral];
    }
    
//    [[CSRConnectionManager sharedInstance] initData];
    [[CSRConnectionManager sharedInstance] addDelegate:self];
//    [[CSRConnectionManager sharedInstance] cl_connectPeripheral:self.connectPer];
    [CSRConnectionManager sharedInstance].macArr = self.macArr;
}

-(void)loadProgressView{
    [[ZTGCDTimerManager sharedInstance] scheduleGCDTimerWithName:@"dm.first.singleTimer" interval:1 queue:dispatch_get_main_queue() repeats:YES option:CancelPreviousTimerAction action:^{
        [self clickCountDown];
    }];
    self.curCountDown = 60;
    
    self.updateBg = [[UIView alloc]initWithFrame:self.view.bounds];
    self.updateBg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.updateBg];
    
    self.gressV = [[DMProGressView alloc]initWithFrame:CGRectMake(60, 250, SCREEN_WIDTH -120, 10)];
    
    if (self.isReconnectSecond) {
        self.gressV.progressValue = 0.5;
    }else{
        self.gressV.progressValue = 0.001;
    }
    [self.updateBg addSubview:self.gressV];
    
    UILabel * label1 = [[UILabel alloc]init];
    label1.textColor = [UIColor colorFromHexStr:@"#FFFFFF"];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:22];
    label1.text = NSLocalizedString(@"正在更新中…", nil) ;
    [self.updateBg addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.gressV.mas_bottom).offset(50);
        make.size.mas_equalTo(CGSizeMake(250, 25));
    }];
    self.lableDes = label1;
    
    UILabel * label2 = [[UILabel alloc]init];
    label2.textColor = [UIColor colorFromHexStr:@"#DFDFDF"];
    label2.numberOfLines = 0;
    label2.textAlignment = NSTextAlignmentLeft;
    label2.font = [UIFont systemFontOfSize:14];
    label2.text = NSLocalizedString(@"請確保左右耳機都保持開機，並與手機保持50cm範圍內",nil);
    [self.updateBg addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(label1.mas_bottom).offset(20);
        make.width.mas_equalTo(SCREEN_WIDTH-90);
    }];
    [label2 sizeToFit];
    
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateButton addTarget:self action:@selector(quitClick:) forControlEvents:UIControlEventTouchUpInside];
    [updateButton setTitle:NSLocalizedString(@"退出", nil) forState:UIControlStateNormal];
    [updateButton setTitleColor:[UIColor colorFromHexStr:@"#D0D0D0"] forState:UIControlStateNormal];
    [updateButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    updateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    updateButton.backgroundColor = [UIColor colorFromHexStr:@"#414145"];
    [updateButton.layer setCornerRadius:20];
    [self.updateBg addSubview:updateButton];
    self.quitBtn = updateButton;
    [updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-150);
        make.size.mas_equalTo(CGSizeMake(150, 45));
    }];
    [self startUpdate];
}
//MARK:timer update failed
-(void)clickCountDown{
    _curCountDown -= 1;
    if (_curCountDown == 0) {
         NSLog(@"60s了 更新失败");
        [self removeProgress];
        DMFailUpdateView *fail = [[DMFailUpdateView alloc]initWithFrame:CGRectMake(0, KScaleHeight(150), SCREEN_WIDTH, 400)];
        [self.view addSubview:fail];
        fail.onButtonTouchUpFail = ^(DMFailUpdateView * _Nonnull failView) {
            [failView removeFromSuperview];
            [self cancelUpdate];
            [self loadProgressView];
        };
    }
}
-(void)removeProgress{
//    [self.quitBtn removeFromSuperview];
//    [self.gressV removeFromSuperview];
    [self.updateBg removeFromSuperview];
}
//MARK:- update notification  首页返回可以更新的通知
-(void)getBattery:(NSNotification *)notification {
    //处理消息
    NSString *str1 = notification.object;
    NSLog(@"notification===%@",notification.object);
    self.batteryL = [CLDataConver to10:[str1 substringToIndex:2]];
    self.batteryR = [CLDataConver to10:[str1 substringFromIndex:2]];
    if ([self.batteryR intValue] < 30 || [self.batteryL intValue] < 30) {
           NSLog(@"L==%@ R==%@",self.batteryL,self.batteryR);
           NSString * test = [NSObject compareInt:[self.batteryL intValue] right:[self.batteryR intValue]];
           NSString *message = [NSString stringWithFormat:@"%@ %@ 30%@,%@",test,NSLocalizedString(@"Headset power below", nil), @"%",NSLocalizedString(@"Please charge.", nil)];
           [KSAlertTool alertOk:NSLocalizedString(@"Got it", nil)  mesasge:message confirmHandler:^(UIAlertAction * action) {
               [self.navigationController popViewControllerAnimated:YES];
           } viewController:self];
           
       }else{
           [self loadProgressView];
       }
}
- (void)dealloc {
    //单条移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DMBatteryLowPowerNotification object:nil];
}
@end
