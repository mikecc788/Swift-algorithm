//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>

/*!
 @header QTIRWCPSegment
 This object encapsulates commands sent over RWCP.
 */

/// @class QTIRWCPSegment encapsulates a data packet containing a frame and some data.
@interface QTIRWCPSegment : NSObject

/// @brief length of the segment
@property (nonatomic) uint8_t length;
/// @brief sequence number
@property (nonatomic) uint8_t sequence;
/// @brief flags or opCode
@property (nonatomic) uint8_t flags;
/// @brief data
@property (nonatomic) NSData * _Nullable data;

/*!
 @brief Create a new segment
 @param length Length of the segment
 @param sequence The sequence number
 @param data The data to send
 */
- (id _Nonnull )initWithLength:(uint8_t)length sequence:(uint8_t)sequence data:(NSData * _Nonnull)data;

- (id _Nonnull)initWithCode:(uint8_t)opCode sequence:(uint8_t)sequence;

- (id _Nonnull)initWithData:(uint8_t)opCode sequence:(uint8_t)sequence data:(NSData *_Nonnull)data;

@end
