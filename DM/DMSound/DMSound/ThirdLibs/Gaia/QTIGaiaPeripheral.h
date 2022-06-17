//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define PERIPHERAL_NAME @"iPhone"

@protocol QTIGaiaPeripheralDelegate <NSObject>

- (void)gaiaCommandReceived:(NSData *_Nonnull)data;

@optional
- (void)deviceConnected:(CBCentral * _Nonnull)central;
- (void)deviceDisconnected:(CBCentral *_Nonnull)central;
- (void)gaiaDataReceived:(NSData *_Nonnull)data;

@end

@interface QTIGaiaPeripheral : NSObject <CBPeripheralManagerDelegate>

@property (nonatomic, weak, nullable) id<QTIGaiaPeripheralDelegate> delegate;

+ (QTIGaiaPeripheral *_Nonnull)sharedInstance;

- (void)stopAdvertising;
- (void)startAdvertising;
- (void)sendGaiaResponse:(NSData *_Nonnull)data;

@end
