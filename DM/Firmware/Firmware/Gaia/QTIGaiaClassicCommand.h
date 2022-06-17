//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import "CSRGaiaGattCommand.h"

// 0 bytes  1         2        3        4        5        6        7         8         9       len+8
// +--------+---------+--------+--------+--------+--------+--------+--------+ +--------+--------+ +--------+
// |   SOF  | VERSION | FLAGS  | LENGTH |    VENDOR ID    |   COMMAND ID    | | PAYLOAD   ...   | | CHECK  |
// +--------+---------+--------+--------+--------+--------+--------+--------+ +--------+--------+ +--------+

// The maximum length of a complete packet.
#define GAIA_CLASSIC_MAX_PACKET     270
// The maximum length for the packet payload.
#define GAIA_CLASSIC_MAX_PAYLOAD    254
// The mask for the flag of this packet if requested.
#define GAIA_CLASSIC_FLAG_CHECK_MASK    0x01
// The offset for the bytes which represents the SOF - start of frame - in the byte structure.
#define GAIA_CLASSIC_OFFSET_SOF 0
// The offset for the bytes which represents the protocol version in the byte structure.
#define GAIA_CLASSIC_OFFSET_VERSION 1
// The offset for the bytes which represents the flag in the byte structure.
#define GAIA_CLASSIC_OFFSET_FLAGS 2
// The offset for the bytes which represents the payload length in the byte structure.
#define GAIA_CLASSIC_OFFSET_LENGTH 3
// The offset for the bytes which represents the vendor id in the byte structure.
#define GAIA_CLASSIC_OFFSET_VENDOR_ID 2
// The number of bytes which represents the vendor id in the byte structure.
#define GAIA_CLASSIC_LENGTH_VENDOR_ID 2
// The offset for the bytes which represents the command id in the byte structure.
#define GAIA_CLASSIC_OFFSET_COMMAND_ID 6
// The number of bytes which represents the command id in the byte structure.
#define GAIA_CLASSIC_LENGTH_COMMAND_ID 2
// The offset for the bytes which represents the payload in the byte structure.
#define GAIA_CLASSIC_OFFSET_PAYLOAD 8
// The protocol version to use for these packets.
#define GAIA_CLASSIC_PROTOCOL_VERSION 1
// The number of bytes for the check value.
#define GAIA_CLASSIC_CHECK_LENGTH 1
// The SOF - Start Of Frame - value to use for these packets.
#define GAIA_CLASSIC_SOF 0xFF

@interface QTIGaiaClassicCommand : NSObject

/// The flags field in the message
@property uint8_t flags;

/// The size of the payload section if the message
@property uint8_t payloadSize;

/// The vendor id
@property uint16_t vendorId;

/// The command id, when reading you may want to use getCommand.
@property uint16_t commandId;

/**
 Initialise a Gaia command with an empty payload and no check sum

 @param vendor Vendor id
 @param command Command id
 @return Gaia Command
 */
- (id _Nonnull)init:(uint16_t)vendor command:(uint16_t)command;

/**
 Create a Gaia command from some existing data

 @param payload Gaia frame
 @return Gaia Command
 */
- (id _Nonnull)initWithData:(NSData *_Nonnull)payload;

/**
 Create a Gaia command

 @param vendor Vendor id
 @param command Command id
 @param payload A payload
 @param checksum True if the packed should calculate a checksum bit
 @return A Gaia Command
 */
- (id _Nonnull)initWithVendor:(uint16_t)vendor
                      command:(uint16_t)command
                      payload:(NSData *_Nullable)payload
                     checkSum:(BOOL)checksum;

/**
 Create a Gaia command

 @param command Command id
 @param vendor Vendor id
 @param checksum True if the packed should calculate a checksum bit
 @return A Gaia Command
 */
- (id _Nonnull)initWithCommand:(uint16_t)command
                        vendor:(uint16_t)vendor
                      checkSum:(BOOL)checksum;

/**
 Create a Gaia Command

 @param vendor Vendor id
 @param command Command id
 @param status The first byte of the payload will have the status
 @param checksum True if the packed should calculate a checksum bit
 @return A Gaia Command
 */
- (id _Nonnull)initWithAck:(uint16_t)vendor
                   command:(uint16_t)command
                    status:(uint8_t)status
                  checkSum:(BOOL)checksum;

/// @brief The complete packet including SOF, header and data
- (NSData *_Nullable)getPacket;

/// @brief Just the payload portion of the command
- (NSData *_Nullable)getPayload;

/**
 * Gets the status byte from the payload of an acknowledgement packet. By convention in acknowledgement
 * packets the first byte contains the command status or 'result' of the command. Additional data may be present
 * in the acknowledgement packet, as defined by individual commands.
 *
 * @return The Gaia status.
 */
- (GaiaCommandStatus)getStatus;

/**
 Unmask and return the command portion of the frame

 @return The Gaia Command
 */
- (uint16_t)getCommand;

/**
 Check if the acknowledgement bit is set in the command

 @return True if the command is an acknowledgement
 */
- (BOOL)isAcknowledgement;

@end
