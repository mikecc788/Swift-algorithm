//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, QTIRWCPProtocolState) {
    QTIRWCPProtocolState_Listen,
    QTIRWCPProtocolState_Syn_Rcvd,
    QTIRWCPProtocolState_Established
};

typedef NS_ENUM(NSInteger, QTIRWCPServerState) {
    QTIRWCPServerState_Init,
    QTIRWCPServerState_Data,
    QTIRWCPServerState_Close
};

@protocol QTIRWCPServerDelegate <NSObject>

/**
 @brief The server wants to communicate back to the connected peripheral

 @param central The connected peripheral
 @param sequence The current sequence number
 @param command The RWCP command
 */
- (void)rwcpServerSendResponse:(CBCentral *_Nonnull)central
                      sequence:(uint8_t)sequence
                       command:(uint8_t)command;

/**
 @brief A data packet is ready for processing
 
 @param central The connected peripheral
 @param data Data from the connected peripheral
 */
- (void)rwcpDataPacketRecieved:(CBCentral *_Nonnull)central
                          data:(NSData *_Nonnull)data;

@optional
/**
 @brief The RWCP servers state has changed
 
 @param central The connected peripheral
 @param state The RWCP server state
 */
- (void)rwcpServerStateChange:(CBCentral *_Nonnull)central
                        state:(QTIRWCPServerState)state;

@end

@interface QTIRWCPServer : NSObject

@property (nonatomic) CBCentral * _Nullable central;
@property (nonatomic, weak, nullable) id<QTIRWCPServerDelegate> delegate;

/// @brief Initialise the server ready to accept data
- (void)serverInit:(CBCentral *_Nonnull)central;

/// @brief Handle incoming data from the peripheral
- (void)handleMessage:(NSData *_Nonnull)data;

@end
