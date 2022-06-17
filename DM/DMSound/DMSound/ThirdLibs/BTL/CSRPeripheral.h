//
// Copyright 2016 Qualcomm Technologies International, Ltd.
//

#import <CoreBluetooth/CoreBluetooth.h>

/*!
 @header CSRPeripheral
 A wrapper class to hold extra information about a CBPeripheral
 */

/*!
 @class CSRPeripheral
 @abstract A CBPeripheral wrapper
 @discussion A wrapper class to hold extra information about a CBPeripheral
 */
@interface CSRPeripheral : NSObject

/// @brief The CBPeripheral
@property (nonatomic) CBPeripheral * _Nullable peripheral;

/// @brief The advertisement data dictionary
@property (nonatomic) NSDictionary * _Nullable advertisementData;

/// @brief The signal strength upon discovery
@property (nonatomic) NSNumber * _Nullable signalStrength;

/// @brief Is DLE supported on this peripheral
@property (nonatomic) BOOL isDataLengthExtensionSupported;

/// @brief The maximum write length
@property (nonatomic) NSUInteger maximumWriteLength;

/// @brief The maximum write length
@property (nonatomic) NSUInteger maximumWriteWithoutResponseLength;

/*!
 @brief create a new instance of the wrapper class
 @param cbPeripheral The CBPeripheral
 @param dict A dictionary containing extra advertising data
 @param rssi The signal strength value
 @return CSRPeripheral
 */
- (id _Nonnull )initWithCBPeripheral:(CBPeripheral * _Nonnull)cbPeripheral
         advertisementData:(NSDictionary *_Nullable)dict
                      rssi:(NSNumber *_Nullable)rssi;

/*!
 @brief The current connection status of the peripheral
 @return BOOL true if the peripheral is currently connected
 */
- (BOOL)isConnected;


/*!
 @brief Check if the data length extension is supported.
 @return BOOL true if the peripheral supports DLE
 */
- (BOOL)checkDLE;

@end
