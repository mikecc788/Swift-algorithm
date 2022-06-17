//
//  CLBLEManager.m
//  FastPair
//
//  Created by kiss on 2020/5/9.
//  Copyright © 2020 KSB. All rights reserved.
//

#import "CLBLEManager.h"

@interface CLBLEManager()
@property(nonatomic,assign)int num;
@end
static CLBLEManager* sharedInstance = nil;
@implementation CLBLEManager
+(CLBLEManager *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CLBLEManager alloc] init];
       
    });
    return sharedInstance;
}
- (instancetype)init{
    self = [super init];
    if (self) {
//        [self initCBCentralManager];

    }
    return self;
}
#pragma mark - Custom functions
/**
Initialize CBCentralManager instance
*/
-(void)initCBCentralManager{
    _connected         = false;
    _isConnecting      = false;
    self.num = 0;
    NSDictionary *dic  = @{CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:false]};
    _manager = [[CBCentralManager alloc]initWithDelegate:self
    queue:nil options:dic];
}
-(void)startScanPeripheral{
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [_manager scanForPeripheralsWithServices:nil options:nil];
    
}
-(void)stopScanPeripheral{
    [_manager stopScan];
}
-(void)connectPeripheral:(CBPeripheral *)peripheral{
    if (!_isConnecting) {
         _isConnecting = true;
         [_manager connectPeripheral:peripheral options:nil];
        _timeoutMonitor = [NSTimer scheduledTimerWithTimeInterval:AUTO_CANCEL_CONNECT_TIMEOUT target:self selector:@selector(connectTimeout:) userInfo:peripheral repeats:false];
    }
}
-(void)connectTimeout:(NSTimer *)timer{
    if (_isConnecting) {
        _isConnecting = false;
        CBPeripheral *peripheral = [timer userInfo];
        NSLog(@"connectTimeout");
        self.num++;
        [self connectPeripheral:peripheral];
        _timeoutMonitor = nil;
        if (self.num==10) {
            NSLog(@"10次connectTimeout了");
            if (_timeoutMonitor != nil) {
                [_timeoutMonitor invalidate];
                _timeoutMonitor = nil;
            }
            if (_connectedPeripheral !=nil) {
                [_manager cancelPeripheralConnection:_connectedPeripheral];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(cl_didConnectTimeout:)]) {
                [self.delegate cl_didConnectTimeout:peripheral];
            }
        }
    }
}
-(void)integrrogateTimeout:(NSTimer *)timer{
//    [self disconnectPeripheral];
    CBPeripheral *peripheral = [timer userInfo];
    
    if (_delegate && [(id)_delegate respondsToSelector:@selector(didFailedToInterrogate:)]) {
        [_delegate didFailedToInterrogate:peripheral];
    }
    NSLog(@"connectedPeripheral=%@",_connectedPeripheral);
    _connectedPeripheral.delegate = self;
    [_connectedPeripheral discoverServices:nil];
    
    
}
-(void)disconnectPeripheral{
    if (_connectedPeripheral != nil) {
        [_manager cancelPeripheralConnection:_connectedPeripheral];
        [self startScanPeripheral];
        _connectedPeripheral = nil;
    }
}
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
//    NSLog(@"开始扫描了");
    if (_delegate && [(id)_delegate respondsToSelector:@selector(didUpdateState:)]) {
        [_delegate didUpdateState:central];
    }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (_delegate && [(id)_delegate respondsToSelector:@selector(didDiscoverPeripheral:AdvertisementData:RSSI:)]) {
        [_delegate didDiscoverPeripheral:peripheral AdvertisementData:advertisementData RSSI:RSSI];
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    _connected = true;
     _isConnecting  = false;
    if (_timeoutMonitor != nil) {
        [_timeoutMonitor invalidate];
        _timeoutMonitor = nil;
    }
    self.connectedPeripheral = peripheral;
    
    if (_delegate && [(id)_delegate respondsToSelector:@selector(didConnectedPeripheral:)]) {
           [_delegate didConnectedPeripheral:peripheral];
       }
//    [self stopScanPeripheral];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    _interrogateMonitor = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(integrrogateTimeout:) userInfo:peripheral repeats:false];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    _connected = false;
    _isConnecting = false;
    if (_timeoutMonitor != nil) {
        [_timeoutMonitor invalidate];
        _timeoutMonitor = nil;
    }
    
    NSLog(@"Bluetooth Manager --> didFailToConnectPeripheral");
    if (_delegate && [(id)_delegate respondsToSelector:@selector(failToConnectPeripheral:Error:)]) {
        [_delegate failToConnectPeripheral:peripheral Error:error];
    }
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
   _connected = false;
    NSLog(@"didDisconnectPeripheral Error, error:%@",error.localizedDescription);
    if (_delegate && [(id)_delegate respondsToSelector:@selector(cl_didDisconnectPeripheral:)]) {
        [_delegate cl_didDisconnectPeripheral:peripheral];
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"Bluetooth Manager --> didDiscoverServices");
    _connectedPeripheral = peripheral;
    if (error != nil) {
        NSLog(@"Bluetooth Manager --> Discover Services Error, error:%@",error.localizedDescription);
        return ;
    }
    if (_interrogateMonitor != nil) {
        [_interrogateMonitor invalidate];
        _interrogateMonitor = nil;
    }
    if (_delegate && [(id)_delegate respondsToSelector:@selector(didDiscoverServices:)]) {
        [_delegate didDiscoverServices:peripheral];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    _connectedPeripheral = peripheral;
    
    if (error != nil) {
        NSLog(@"Bluetooth Manager --> Fail to discover characteristics! Error:%@",error.localizedDescription);
        if (_delegate && [(id)_delegate respondsToSelector:@selector(didFailToDiscoverCharacteritics:)]) {
             [_delegate didFailToDiscoverCharacteritics:error];
        }
        return ;
    }
    if (_delegate && [(id)_delegate respondsToSelector:@selector(didDiscoverCharacteritics:)]) {
        [_delegate didDiscoverCharacteritics:service];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    NSLog(@"Bluetooth Manager --> didUpdateValueForCharacteristic");
    if (_delegate && [_delegate respondsToSelector:@selector(didReadValueForCharacteristic:)]) {
        [_delegate didReadValueForCharacteristic:characteristic];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
        if (self.delegate && [self.delegate respondsToSelector:@selector(cl_didUpdateNotificationStateError:)]) {
            [self.delegate cl_didUpdateNotificationStateError:error];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cl_peripheral:didUpdateNotifiForCharacteristic:)]) {
        [self.delegate cl_peripheral:peripheral didUpdateNotifiForCharacteristic:characteristic];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cl_peripheral:didWriteValueForCharacteristic:)]) {
        [self.delegate cl_peripheral:peripheral didWriteValueForCharacteristic:characteristic];
    }
}
@end
