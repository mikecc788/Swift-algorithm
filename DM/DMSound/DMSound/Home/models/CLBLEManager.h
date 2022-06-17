//
//  CLBLEManager.h
//  FastPair
//
//  Created by kiss on 2020/5/9.
//  Copyright © 2020 KSB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN
#define AUTO_CANCEL_CONNECT_TIMEOUT 2

#define PeripheralNotificationKeys_DisconnectNotif @"disconnectNotif"
#define PeripheralNotificationKeys_CharacteristicNotif @"characteristicNotif"

@protocol CLBLEManagerDelegate <NSObject>
-(void)didUpdateState:(CBCentralManager *)central;
-(void)didDiscoverPeripheral:(CBPeripheral *)peripheral AdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)rssi;
-(void)didConnectedPeripheral:(CBPeripheral *)connectedPeripheral;
-(void)failToConnectPeripheral:(CBPeripheral *)peripheral Error:(NSError *)error;
-(void)didDiscoverServices:(CBPeripheral *)peripheral;
-(void)cl_didDisconnectPeripheral:(CBPeripheral *)peripheral;
-(void)didDiscoverCharacteritics:(CBService *)service;
-(void)didFailToDiscoverCharacteritics:(NSError *)error;
-(void)didFailToDiscoverDescriptors:(NSError *)error;
-(void)didReadValueForCharacteristic:(CBCharacteristic *)characteristic;
-(void)cl_peripheral:(CBPeripheral *)peripheral didUpdateNotifiForCharacteristic:(CBCharacteristic *)characteristic;
-(void)cl_didUpdateNotificationStateError:(NSError*)error;
-(void)cl_peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic;
-(void)didFailedToInterrogate:(CBPeripheral *)peripheral;
-(void)cl_didConnectTimeout:(CBPeripheral *)peripheral;
@end

@interface CLBLEManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
+(CLBLEManager *)sharedInstance;
@property (nonatomic,assign) BOOL connected;
@property (nonatomic,assign) BOOL isConnecting;@property (strong,nonatomic) NSTimer *timeoutMonitor; /// Timeout
@property (strong,nonatomic) NSTimer * interrogateMonitor ; /// Timeout monitor of interrogate the peripheral

@property (strong,nonatomic) CBPeripheral *connectedPeripheral;
@property (strong,nonatomic) CBCentralManager *manager;
@property (strong, nonatomic) id<CLBLEManagerDelegate> delegate;
-(void)initCBCentralManager;
-(void)startScanPeripheral;
-(void)stopScanPeripheral;
-(void)connectPeripheral:(CBPeripheral *)peripheral;
@end

NS_ASSUME_NONNULL_END
