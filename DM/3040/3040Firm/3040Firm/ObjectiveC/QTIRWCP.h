//
// © 2017-2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @enum QTIRWCPState
 @brief The current state of the transfer
 */
typedef NS_ENUM(NSInteger, QTIRWCPState) {
    /// Client and Server. Client is waiting to send the first SYN to initiate the session. Server is waiting for the SYN.
    QTIRWCPState_Listen,
    /// Client only. The client has sent the SYN and is waiting for the server to reply with the SYN+ACK.
    QTIRWCPState_SynSent,
    /// Client and Server. The client sends DATA segments to the server. The server received DATA segments from the client. The server sends ACK+sequence segments to the client.
    QTIRWCPState_Established,
    /// Client only. The client has sent a RST packet to the server. The server is waiting for a RST+ACK from the server.
    QTIRWCPState_Closing
};

@protocol QTIRWCPDelegate;
@protocol GaiaDeviceConnectionProtocol;

@interface QTIRWCP : NSObject

/// @brief Delegate class for callbacks.
@property (nonatomic, weak, nullable) id<QTIRWCPDelegate> delegate;

/// @brief A buffer to hold data whist RWCP is busy. Once the recent segments are exhaused data will be moved from the data buffer.
@property (nonatomic) NSMutableArray * _Nullable dataBuffer;

/// @brief Setting this flag to true tells RWCP that the last byte of the file has been written to the data buffer or recent segments.
@property (nonatomic) BOOL lastByteSent;

/// @brief The file size which is used to calculate progress.
@property (nonatomic) NSUInteger fileSize;

/// @brief Override the default congestion window size
@property (nonatomic) NSInteger initialCongestionWindowSize;

/// @brief Override the maximum congestion window size
@property (nonatomic) NSInteger maximumCongestionWindowSize;

/*!
 @brief Connect to the Gaia service. Set up the characteristics ready for executing commands.
 @param connection The connection to use for communication
 */
- (instancetype _Nonnull)initWithConnection:(id<GaiaDeviceConnectionProtocol> _Nonnull)connection;

- (void)teardown;

- (void)didReceiveData:(NSData * _Nonnull)data;

/// @brief The Bluetooth interface has been powered off.
- (void)powerOff;

/*!
 @brief Add data to the write buffers
 @param data The file data
 */
- (void)setPayload:(NSData *_Nonnull)data;

/*!
 @brief The payload has been set, start the RWCP transfer
 */
- (void)startTransfer;

/*!
 @brief Stop the current transfer
 */
- (void)abort;

@end


/*!
 @protocol CSRUpdateManagerDelegate
 @discussion Callbacks from changes to state
 */
@protocol QTIRWCPDelegate <NSObject>

/*!
 @brief The upgrade aborted.
 @param error Look at the error so see what went wrong
 */
- (void)didAbortWithError:(NSError *_Nonnull)error;

@optional
/// @brief The final packet was sent. A packet with the more data set to GaiaCommandAction_Abort.
- (void)didCompleteDataSend;

/*!
 @brief The upgrade made some progress
 @param value Percentage complete
 */
- (void)didMakeProgress:(double)value;

/*!
 @brief State information about the device. Used when the device is in it's reboot cycle.
 @param value A string with some status information
 */
- (void)didUpdateStatus:(NSString *_Nonnull)value;

@end
