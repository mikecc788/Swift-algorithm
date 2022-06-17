//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//#if (NSFoundationVersionNumber > NSFoundationVersionNumber10_10_Max)

@protocol QTIL2CAPChannelDelegate;

API_AVAILABLE(ios(11), macosx(10.13))
@interface QTIL2CAPChannel : NSObject

/// The set of delegates
@property (nonatomic, weak, nullable) id <QTIL2CAPChannelDelegate> delegate;


/**
 Initialise the accessory
 
 @param delegate Delegate set
 @param CBL2CAPChannel
 @return A QTIL2CAPChannel
 */
- (id _Nonnull )initWithDelegate:(nullable id <QTIL2CAPChannelDelegate>)delegate
                         channel:(CBL2CAPChannel * _Nonnull)channel;

- (id _Nonnull )initWithChannel:(CBL2CAPChannel * _Nonnull)channel;

/**
 Write data to the accessory
 
 @param data Data
 */
- (void)writeData:(NSData *_Nullable)data;

/// Connect to the accessory. Creates an Channel and connects input and output streams
- (void)connect;

/// Disconnect from the accessory. Closes the Channel and disconnects the input and output streams
- (void)disconnect;

@end

//#endif

@protocol QTIL2CAPChannelDelegate <NSObject>

@optional

/// @brief an new connection with id is available
- (void)didConnectChannel:(QTIL2CAPChannel *_Nonnull)accessory NS_AVAILABLE(NA, 11_0);

/// @brief an new connection with id is available
- (void)didDisconnectChannel:(QTIL2CAPChannel *_Nonnull)accessory NS_AVAILABLE(NA, 11_0);

/// @brief an new connection with id is available
- (void)l2pcapDataAvailable:(NSData *_Nullable)data;

/// @brief an error occurred whilst streaming
- (void)streamError:(NSError *_Nullable)error;

@end

