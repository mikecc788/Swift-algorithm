//
// Copyright 2016 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CSRPeripheral.h"
#import "QTIL2CAPChannel.h"

/*!
@header CSRConnectionManager
The connection manager class manages bluetooth low energy connections.
It enables the discovery of devices and their services and characteristics.
There are also methods to query characteristics or listen for changes made to them.
 */

@protocol CSRConnectionManagerDelegate;

/*!
@class CSRConnectionManager
@abstract Singleton class that manages connections to BTLE devices
@discussion The connection manager implements CBCentralManagerDelegate and CBPeripheralDelegate
*/
@interface CSRConnectionManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

/// @brief True if the connection manager is disconnecting and destroying itself
@property (atomic, readonly) BOOL isShuttingDown;

/// @brief List of available devices that have been found by the scan
@property (atomic) NSMutableDictionary * _Nullable devices;

//用来记录左右mac地址
@property (strong,atomic) NSMutableArray * _Nullable macArr;
/// @brief The currently connected peripheral
@property (nonatomic) CSRPeripheral * _Nullable connectedPeripheral;

/// @brief A list of delegates to callback
@property (nonatomic, nonnull) NSMutableSet *delegates;

/// @brief A list of services to save time after discovery list the services you want
@property (nonatomic) NSArray * _Nullable interestedServices;

/// @brief A list of characteristics to save time after discovery list the characteristics you want
@property (nonatomic) NSArray * _Nullable interestedCharacteristics;

/*!
 @brief The singleton instance
 @return id - The id of the singleton object.
 */
+ (CSRConnectionManager *_Nonnull)sharedInstance;
-(void)initCBCentralManager;
-(void)CSRConnectionDealloc;
-(void)initData;
/*!
 @brief Register a delegate object to callback. Duplicates will be ignored.
 @param delegate The delegate object specified to receive peripheral events.
 */
- (void)addDelegate:(nonnull id <CSRConnectionManagerDelegate>)delegate;

/*!
 @brief Remove an object to callbacks. Objects that are not present will be ignored.
 @param delegate The delegate object specified to no longer receive peripheral events.
 */
- (void)removeDelegate:(nonnull id <CSRConnectionManagerDelegate>)delegate;

/*!
 @brief Connect to a peripheral. Once connected the peripheral will discover all services and characteristics.
 @discussion The discoveredPripheralDetails delegate method will be called once the last characteristic has been discovered.
 @param peripheral A CSRPeripheral to connect to.
 */
- (void)connectPeripheral:(CSRPeripheral * _Nonnull)peripheral;

- (void)cl_connectPeripheral:(CSRPeripheral *_Nonnull)peripheral;
/*!
 @brief Disconnect from a peripheral.
 @discussion Any listeners on characteristics will be cleared.
 */
- (void)disconnectPeripheral;

/*!
 @brief Manually start scanning for devices in range.
 @param serviceUUIDs Restrict the scan to certain uuids. Pass nil if you want an unrestricted scan.
 */
- (void)startScan:(NSArray *_Nullable)serviceUUIDs withMacFilter:(NSMutableArray*_Nullable)macArr;

/*!
 @brief Manually stop scanning for devices in range.
 */
- (void)stopScan;

/*!
 @brief Read the descriptor value.
 @discussion This method must be called to populate the value field. The endianness will be swapped.
 @param descriptor The descriptor to read
 */
- (uint16_t)readDescriptor:(CBDescriptor *_Nonnull)descriptor;

/*!
 @brief Read a value. The delegate will be called back when the value is available
 @param service The service
 @param charactaristic_uuid The required characteristic
 @param failure The failure block.
 */
- (void)getValueForService:(CBService *_Nonnull)service
            characteristic:(NSString *_Nonnull)charactaristic_uuid
                   failure:(void (^_Nullable)(NSError * _Nonnull error))failure;

/*!
 @brief Get a boolean value from a characteristic.
 @discussion If the service or characteristic is not found the failure callback block is called.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param success Success callback block
 @param failure Failure callback block
 */
- (void)getBoolValue:(NSString *_Nonnull)service_uuid
      characteristic:(NSString *_Nonnull)charactaristic_uuid
             success:(void (^_Nullable)(BOOL value))success
             failure:(void (^_Nullable)(NSError * _Nonnull error))failure;

/*!
 @brief Get a int value from a characteristic.
 @discussion If the service or characteristic is not found the failure callback block is called.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param success Success callback block
 @param failure Failure callback block
 */
- (void)getIntValue:(NSString *_Nonnull)service_uuid
     characteristic:(NSString *_Nonnull)charactaristic_uuid
            success:(void (^_Nullable)(NSInteger value))success
            failure:(void (^_Nullable)(NSError * _Nonnull error))failure;

/*!
 @brief Get a int value from a characteristic.
 @discussion If the service or characteristic is not found the failure callback block is called.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param success Success callback block
 @param failure Failure callback block
 */
- (void)getDoubleValue:(NSString *_Nonnull)service_uuid
        characteristic:(NSString *_Nonnull)charactaristic_uuid
               success:(void (^_Nullable)(double value))success
               failure:(void (^_Nonnull)(NSError * _Nullable error))failure;

/*!
 @brief Get a data value from a characteristic.
 @discussion If the service or characteristic is not found the failure callback block is called.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param success Success callback block
 @param failure Failure callback block
 */
- (void)getDataValue:(NSString *_Nonnull)service_uuid
      characteristic:(NSString *_Nonnull)charactaristic_uuid
             success:(void (^_Nullable)(NSData * _Nonnull data))success
             failure:(void (^ _Nullable)(NSError * _Nonnull error))failure;

/*!
 @brief Get a int value from a characteristic.
 @discussion If the characteristic is not found the failure callback block is called.
 @param service The service
 @param charactaristic_uuid The characteristic UUID
 @param success Success callback block
 @param failure Failure callback block
 */
- (void)getIntValueForService:(CBService *_Nonnull)service
               characteristic:(NSString *_Nonnull)charactaristic_uuid
                      success:(void (^_Nullable)(NSInteger value))success
                      failure:(void (^_Nullable)(NSError * _Nonnull error))failure;

/*!
 @brief Get a string value from a characteristic.
 @discussion If the service or characteristic is not found the failure callback block is called.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param success Success callback block
 @param failure Failure callback block
 */
- (void)getStringValue:(NSString *_Nonnull)service_uuid
        characteristic:(NSString *_Nonnull)charactaristic_uuid
               success:(void (^_Nullable)(NSString * _Nonnull value))success
               failure:(void (^_Nullable)(NSError * _Nonnull error))failure;

/*!
 @brief Set an int value from a characteristic.
 @discussion If the service or characteristic is not found the failure callback block is called.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param value The value to set
 @param success Success callback block
 @param failure Failure callback block
 */
- (void)setIntValue:(NSString *_Nonnull)service_uuid
     characteristic:(NSString *_Nonnull)charactaristic_uuid
              value:(NSInteger)value
            success:(void (^_Nullable)(void))success
            failure:(void (^_Nullable)(NSError * _Nonnull error))failure;

/*!
 @brief Set an int value from a characteristic.
 @discussion If the service or characteristic is not found an error will be logged in debugging.
 If the characteristic is not writable an error will be logged in debugging.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param value The value to set
 */
- (void)setIntValue:(NSString *_Nonnull)service_uuid
     characteristic:(NSString *_Nonnull)charactaristic_uuid
              value:(NSInteger)value;
/*!
 @brief Set an data value from a characteristic.
 @discussion If the service or characteristic is not found an error will be logged in debugging.
 If the characteristic is not writable an error will be logged in debugging.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param data The value to set
 */
- (void)setDataValue:(NSString *_Nonnull)service_uuid
      characteristic:(NSString *_Nonnull)charactaristic_uuid
               value:(NSData *_Nullable)data;

/*!
 @brief Set a data value from a characteristic.
 @discussion If the service or characteristic is not found the failure callback block is called.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 @param data The value to set
 @param success Success callback block
 @param failure Failure callback block
 */
- (void)setDataValue:(NSString *_Nonnull)service_uuid
      characteristic:(NSString *_Nonnull)charactaristic_uuid
               value:(NSData *_Nullable)data
             success:(void (^_Nullable)(void))success
             failure:(void (^_Nullable)(NSError * _Nonnull error))failure;

/*!
 @brief Start listening for changes on a characteristic.
 @discussion The characteristicChanged delegate method will be called when a change is reported.
 This method is useful if you have multiple services of the same type.
 @param service The service object
 @param charactaristic_uuid The characteristic UUID
 */
- (BOOL)listenForService:(CBService *_Nonnull)service
   characteristic:(NSString *_Nonnull)charactaristic_uuid;

/*!
 @brief Start listening for changes on a characteristic.
 @discussion The characteristicChanged delegate method will be called when a change is reported.
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 */
- (BOOL)listenFor:(NSString *_Nonnull)service_uuid
   characteristic:(NSString *_Nonnull)charactaristic_uuid;

/*!
 @brief Stop listening for a change on a given characteristic
 @param service_uuid The service UUID
 @param charactaristic_uuid The characteristic UUID
 */
- (void)clearListener:(NSString *_Nonnull)service_uuid
       characteristic:(NSString *_Nonnull)charactaristic_uuid;

/*!
 @brief Remove all the listeners
 */
- (void)clearListeners;

/*!
 @brief Find a service object
 @param service_uuid The service UUID
 @return CBService or nil if not found.
*/
- (CBService *_Nullable)findService:(NSString *_Nonnull)service_uuid;

/*!
 @brief Find a service object
 @param peripheral The peripheral to search
 @param service_uuid The service UUID
 @return CBService or nil if not found.
*/
- (CBService *_Nullable)findService:(CBPeripheral *_Nonnull)peripheral
                      uuid:(NSString *_Nonnull)service_uuid;

/*!
 @brief Find a characteristic object
 @param service The service object
 @param characteristic_uuid The characteristic UUID
 @return CBCharacteristic or nil if not found.
*/
- (CBCharacteristic *_Nullable)findCharacteristic:(CBService *_Nonnull)service
                          characteristic:(NSString *_Nonnull)characteristic_uuid;

/*!
 @brief Ask the connected peripheral for it's current signal strength.
 */
- (void)updateRSSI;

/*!
 @brief Disconnect peripherals and destroy the manager for example when applicationWillTerminate is called by the App Delegate
 */
- (void)shutDown;

/*!
 @brief Open an LE Connection oriented Channel
 @param csrPeripheral The peripheral to open the channel on
 @param characteristic The characteristic
 */
- (void)openChannel:(CSRPeripheral * _Nonnull)csrPeripheral characteristic:(CBL2CAPPSM)psm API_AVAILABLE(ios(11), macosx(10.13));
@end

/*!
 @protocol CSRConnectionManagerDelegate
 @discussion Callbacks from changes to state
 */
@protocol CSRConnectionManagerDelegate <NSObject>

@optional
/*!
 @brief Called immediately after discovery
 @param peripheral The peripheral
 */
- (void)didDiscoverPeripheral:(CSRPeripheral *_Nonnull)peripheral;

/*!
 @brief Bluetooth has been powered on
 */
- (void)didPowerOn;

/*!
 @brief Bluetooth has been powered off
 */
- (void)didPowerOff;

/*!
 @brief Called after all the services and characteristics have been discovered for the connected peripheral
 */

- (void)discoveredPripheralDetails;
/***加一个发送DFU命令返回*/
-(void)getDFUResponseInfo:(NSString*_Nullable)response;
/*!
 @brief Called when a characteristic has changed
 @param characteristic Changed characteristic. Check the value property
 */
- (void)chracteristicChanged:(CBCharacteristic *_Nonnull)characteristic;

/*!
 @brief Called when a peripheral connects
 @param peripheral The peripheral that connected
 */
- (void)didConnectToPeripheral:(CSRPeripheral *_Nonnull)peripheral;

/*!
 @brief Called when a value that needs acknowledgement has written
 @param peripheral The peripheral that connected
 @param characteristic The characteristic that was written to
 @param error An error object.
 */
- (void)peripheral:(CSRPeripheral *_Nonnull)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *_Nonnull)characteristic
             error:(NSError *_Nullable)error;

/*!
 @brief Called when a peripheral disconnects
 @param peripheral The peripheral that has disconnected
 */
- (void)didDisconnectFromPeripheral:(CBPeripheral *_Nonnull)peripheral;

/*!
 @brief Called when a peripheral updates its signal strength
 Read the signalStrength property of the connected peripheral.
 */
- (void)didUpdateRSSI;

/*!
 @brief Called when a setting notify on a characteristic succeeds
 */
- (void)chracteristicSetNotifySuccess:(CBCharacteristic *_Nonnull)characteristic;

/*!
 @brief Called when a setting notify on a characteristic fails
 */
- (void)chracteristicSetNotifyFailed:(CBCharacteristic *_Nonnull)characteristic;


/**
 @brief The CoC channel opened or encountered an error.
 
 @partial Only available in iOS 11
 @param peripheral A reference to the peripheral
 @param channel The new channel object
 */
- (void)didOpenChannel:(CSRPeripheral *_Nonnull)peripheral
               channel:(QTIL2CAPChannel *_Nullable)channel
                 error:(NSError *_Nullable)error API_AVAILABLE(ios(11), macosx(10.13));

@end
