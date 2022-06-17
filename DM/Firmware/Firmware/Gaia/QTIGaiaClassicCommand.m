//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import "QTIGaiaClassicCommand.h"

#define GAIA_CLASSIC_STATUS_LENGTH          1
#define GAIA_CLASSIC_ACKNOWLEDGMENT_MASK    0x8000
#define GAIA_CLASSIC_COMMAND_MASK           0x7fff

@interface QTIGaiaClassicCommand ()

@property NSData * _Nullable packet;
@property NSData * _Nullable payloadData;

@end

@implementation QTIGaiaClassicCommand

- (id)init:(uint16_t)vendor
   command:(uint16_t)command {
    return [[QTIGaiaClassicCommand alloc]
            initWithVendor:vendor
            command:command
            payload:nil
            checkSum:false];
}

- (id)initWithData:(NSData *)payload {
    if (self = [super init]) {
        _packet = payload;
        
        [payload getBytes:&_flags range:NSMakeRange(GAIA_CLASSIC_OFFSET_FLAGS, 1)];
        [payload getBytes:&_vendorId range:NSMakeRange(GAIA_CLASSIC_OFFSET_VENDOR_ID, 2)];
        [payload getBytes:&_commandId range:NSMakeRange(GAIA_CLASSIC_OFFSET_COMMAND_ID, 2)];

        if (payload.length > 8) {
            [payload getBytes:&_payloadSize range:NSMakeRange(GAIA_CLASSIC_OFFSET_PAYLOAD, 1)];
            _payloadSize = payload.length - GAIA_CLASSIC_OFFSET_PAYLOAD;
            
            if ((_flags & GAIA_CLASSIC_FLAG_CHECK_MASK) != 0) {
                --_payloadSize;
            }
        } else {
            _payloadSize = 0;
        }
        
        _vendorId = CFSwapInt16(_vendorId);
        _commandId = CFSwapInt16(_commandId);
        
        if (_payloadSize > 0) {
            _payloadData = [payload subdataWithRange:NSMakeRange(GAIA_CLASSIC_OFFSET_PAYLOAD, _payloadSize)];
        }
    }

    return self;
}

- (id)initWithVendor:(uint16_t)vendor
             command:(uint16_t)command
             payload:(NSData *)payload
            checkSum:(BOOL)checksum {
    if (self = [super init]) {
        NSMutableData *data = [NSMutableData data];
        uint8_t sof = GAIA_CLASSIC_SOF;
        uint8_t version = GAIA_CLASSIC_PROTOCOL_VERSION;
        uint8_t length = payload != nil ? payload.length + GAIA_CLASSIC_OFFSET_PAYLOAD + (checksum ? GAIA_CLASSIC_CHECK_LENGTH : 0) : 0;
        uint8_t check = 0;

        _flags = checksum ? 0x01 : 0x00;
        _vendorId = CFSwapInt16(vendor);
        _commandId = CFSwapInt16(command);
        
        [data appendBytes:&sof length:1];
        [data appendBytes:&version length:1];
        [data appendBytes:&_flags length:1];
        [data appendBytes:&length length:1];
        [data appendBytes:&_vendorId length:2];
        [data appendBytes:&_commandId length:2];
        
        if (payload && payload.length > 0) {
            _payloadData = payload;
            _payloadSize = payload.length;
            
            [data appendData:payload];
        }
        
        if (checksum) {
            uint8_t *bytes;

            [data getBytes:&bytes range:NSMakeRange(0, data.length)];
            
            for (int i = 0; i < [data length]; i++) {
                check ^= bytes[i];
            }
            
            [data appendBytes:&check length:1];
        }

        _packet = data;
    }

    return self;
}

- (id)initWithCommand:(uint16_t)command
               vendor:(uint16_t)vendor
             checkSum:(BOOL)checksum {
    return [[QTIGaiaClassicCommand alloc]
            initWithVendor:vendor
            command:command
            payload:nil
            checkSum:checksum];
}

- (id)initWithAck:(uint16_t)vendor
          command:(uint16_t)command
           status:(uint8_t)status
         checkSum:(BOOL)checksum {
    if (self = [super init]) {
        NSMutableData *data = [NSMutableData data];
        uint8_t sof = GAIA_CLASSIC_SOF;
        uint8_t version = GAIA_CLASSIC_PROTOCOL_VERSION;
        uint8_t length = 1; // The status
        uint8_t check = 0;
        
        _flags = checksum ? 0x01 : 0x00;
        _vendorId = CFSwapInt16(vendor);
        _commandId = CFSwapInt16(command | GAIA_CLASSIC_ACKNOWLEDGMENT_MASK);
        
        [data appendBytes:&sof length:1];
        [data appendBytes:&version length:1];
        [data appendBytes:&_flags length:1];
        [data appendBytes:&length length:1];
        [data appendBytes:&_vendorId length:2];
        [data appendBytes:&_commandId length:2];
        [data appendBytes:&status length:1];
        
        if (checksum) {
            uint8_t *bytes;
            
            [data getBytes:&bytes range:NSMakeRange(0, data.length)];
            
            for (int i = 0; i < [data length]; i++) {
                check ^= bytes[i];
            }
            
            [data appendBytes:&check length:1];
        }
        
        _packet = data;
    }
    
    return self;
}

- (NSData *)getPacket {
    return _packet;
}

- (NSData *)getPayload {
    return _payloadData;
}

- (GaiaCommandStatus)getStatus {
    if (![self isAcknowledgement] || _packet == nil || _packet.length < GAIA_CLASSIC_STATUS_LENGTH) {
        return GaiaStatus_NoStatusAvailable;
    } else {
        uint8_t status = 0;
        
        [_payloadData getBytes:&status range:NSMakeRange(0, 1)];

        return (GaiaCommandStatus)status;
    }
}

- (BOOL)isAcknowledgement {
    return (_commandId & GAIA_CLASSIC_ACKNOWLEDGMENT_MASK) > 0;
}

- (uint16_t)getCommand {
    return _commandId & GAIA_CLASSIC_COMMAND_MASK;
}

@end
