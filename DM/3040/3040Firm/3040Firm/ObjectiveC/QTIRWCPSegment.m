//
// © 2017-2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

#import "QTIRWCPSegment.h"

#define RWCP_HEADER_MASK_SEQ_NUMBER		(0x3F)
#define RWCP_HEADER_MASK_OPCODE			(0xC0)

@interface QTIRWCPSegment ()
@property (nonatomic, assign) uint8_t length;
@property (nonatomic, assign) uint8_t sequence;
@property (nonatomic, assign) uint8_t flags;
@property (nonatomic, copy) NSData * _Nullable data;
@end

@implementation QTIRWCPSegment

- (id)initWithLength:(uint8_t)length sequence:(uint8_t)sequence data:(NSData *)data {
    if (self = [super init]) {
        _length = length;
        _sequence = sequence;
        _data = data;
    }
    
    return self;
}

- (id _Nonnull)initWithCode:(uint8_t)opCode sequence:(uint8_t)sequence {
    if (self = [super init]) {
        _length = 1;
        _sequence = sequence;
        _flags = opCode;
        _data = [NSData dataWithBytes:&opCode length:sizeof(uint8_t)];
    }
    
    return self;
}

- (id _Nonnull)initWithCode:(uint8_t)opCode sequence:(uint8_t)sequence data:(NSData *_Nonnull)data {
    if (self = [super init]) {
        _length = data.length;
        
        NSMutableData *payload = [[NSMutableData alloc] init];
        uint8_t header = (sequence & RWCP_HEADER_MASK_SEQ_NUMBER) |
                         (opCode & ~(RWCP_HEADER_MASK_SEQ_NUMBER));
        
        [payload appendBytes:&header length:sizeof(uint8_t)];
        
        if (data) {
            [payload appendData:data];
        }

        _data = payload;
        _sequence = sequence;
        _flags = opCode;
    }
    
    return self;
}

@end
