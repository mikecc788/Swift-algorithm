//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@protocol QTIAccessoryDelegate;

@interface QTIAccessory : NSObject

/// The accessory connection id
@property (nonatomic) NSUInteger connectionId;

/// The EAAccessory
@property (nonatomic) EAAccessory * _Nullable accessory;

/// The set of delegates
@property (nonatomic, weak, nullable) id <QTIAccessoryDelegate> delegate;

/// The current session
@property (nonatomic) EASession * _Nullable session;

/**
 Initialise the accessory

 @param delegate Delegate set
 @param accessory Accessory
 @param protocol Protocol string
 @return A QTIAccessory
 */
- (id _Nonnull )initWithDelegate:(nullable id <QTIAccessoryDelegate>)delegate
                       accessory:(EAAccessory * _Nonnull)accessory
                        protocol:(NSString *_Nullable)protocol;

/**
 Write data to the accessory

 @param data Data
 */
- (void)writeData:(NSData *_Nullable)data;

/// Connect to the accessory. Creates an EASession and connects input and output streams
- (void)connect;

/// Disconnect from the accessory. Closes the EASession and disconnects the input and output streams
- (void)disconnect;

@end

@protocol QTIAccessoryDelegate <NSObject>

@optional

/// @brief an new connection with id is available
- (void)didConnectAccessory:(QTIAccessory *_Nonnull)accessory;

/// @brief an new connection with id is available
- (void)didDisconnectAccessory:(QTIAccessory *_Nonnull)accessory;

/// @brief an new connection with id is available
- (void)dataAvailable:(NSData *_Nullable)data;

/// @brief an error occurred whilst streaming
- (void)streamError:(NSError *_Nullable)error;

@end
