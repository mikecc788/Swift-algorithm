//
// © 2017-2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @header QTIRWCPSegment
 This object encapsulates commands sent over RWCP.
 */

/// @class QTIRWCPSegment encapsulates a data packet containing a frame and some data.
@interface QTIRWCPSegment : NSObject

/// @brief length of the segment
@property (nonatomic, readonly) uint8_t length;
/// @brief sequence number
@property (nonatomic, readonly) uint8_t sequence;
/// @brief flags or opCode
@property (nonatomic, readonly) uint8_t flags;
/// @brief data
@property (nonatomic,readonly) NSData * _Nullable data;

/*!
 @brief Create a new segment
 @param length Length of the segment
 @param sequence The sequence number
 @param data The data to send
 */
- (id _Nonnull )initWithLength:(uint8_t)length sequence:(uint8_t)sequence data:(NSData * _Nonnull)data;

- (id _Nonnull)initWithCode:(uint8_t)opCode sequence:(uint8_t)sequence;

- (id _Nonnull)initWithCode:(uint8_t)opCode sequence:(uint8_t)sequence data:(NSData *_Nonnull)data;

@end
