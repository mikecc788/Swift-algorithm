//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>

@protocol QTIDataProviderDelegate;

// Each derived class is responsible for creating an init method
@interface QTIDataProvider : NSObject

@property (nonatomic, weak, nullable) id <QTIDataProviderDelegate> delegate;

/**
 Write data to the provider.
 The caller is responsible for ensuring that the provder can handle the size and type of the data passed.

 @param data Data to write to the provider
 */
- (void)write:(NSData *)data;

/**
 Disconnect the data provider
 */
- (void)disconnect;

@end

@protocol QTIDataProviderDelegate <NSObject>

@optional

/// @brief An accessory was found maching the protocol
- (void)dataAvailable:(NSData *)data;

/// @brief An new connection is available
- (void)didConnect;

/// @brief The device disconnected
- (void)didDisconnect;

/// @brief An error occured
- (void)onError:(NSError *)error;

/// @brief Test callback to indicate data is expected.
- (void)dataExpected;

@end
