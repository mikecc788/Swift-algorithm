//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import "QTIRWCPServer.h"

typedef NS_ENUM(uint8_t, QTIRWCPClientCommands) {
    RWCP_CLIENT_CMD_DATA         = 0x00,
    RWCP_CLIENT_CMD_SYN          = 0x40,
    RWCP_CLIENT_CMD_RST          = 0x80,
    RWCP_CLIENT_CMD_RESERVED     = 0xc0
};

typedef NS_ENUM(uint8_t, QTIRWCPServerCommands) {
    RWCP_SERVER_CMD_DATA_ACK     = 0x00,
    RWCP_SERVER_CMD_SYN_ACK      = 0x40,
    RWCP_SERVER_CMD_RST          = 0x80,
    RWCP_SERVER_CMD_GAP          = 0xc0
};

#define RWCP_COMMAND_MASK                               0xc0
#define RWCP_SEQUENCE_MASK                              0x3f
#define RWCP_HEADER_OFFSET                              0
#define RWCP_HEADER_SIZE                                1
#define RWCP_PAYLOAD_OFFSET                             1
#define RWCP_SEQUENCE_NUMBER_MAX                        64
#define RWCP_RECEIVE_WINDOW_MAX                         32

@interface QTIRWCPServer ()

@property (nonatomic) QTIRWCPProtocolState protocol_state;
@property (nonatomic) Boolean gap_mute;
@property (nonatomic) uint8_t last_sequence_number;
@property (nonatomic) Boolean accept_segments;

@end

@implementation QTIRWCPServer

- (void)serverInit:(CBCentral *)central {
    _protocol_state = QTIRWCPProtocolState_Listen;
    _accept_segments = true;
    _central = central;
}

- (void)rwcpSendNotification:(uint8_t)sequence
                     command:(uint8_t)command {
    uint8_t rwcp_header = 0;
    
    // create the RWCP header
    rwcp_header |= sequence & RWCP_SEQUENCE_MASK;
    rwcp_header |= command & RWCP_COMMAND_MASK;
    
    [_delegate rwcpServerSendResponse:_central sequence:RWCP_HEADER_SIZE command:rwcp_header];
}

- (void)rwcpDataAck:(uint8_t)sequence {
    NSLog(@"A%d,", sequence);
    [self rwcpSendNotification:sequence command:RWCP_SERVER_CMD_DATA_ACK];
}

- (void)rwcpRstAck:(uint8_t)sequence {
    NSLog(@"RA%d,", sequence);
    [self rwcpSendNotification:sequence command:RWCP_SERVER_CMD_RST];
}

- (void)rwcpRst:(uint8_t)sequence {
    NSLog(@"R%d,", sequence);
    [self rwcpSendNotification:sequence command:RWCP_SERVER_CMD_RST];
}

- (void)rwcpSynAck:(uint8_t)sequence {
    NSLog(@"SA%d,", sequence);
    [self rwcpSendNotification:sequence command:RWCP_SERVER_CMD_SYN_ACK];
}

- (void)rwcpGap:(uint8_t)sequence {
    NSLog(@"G%d,", sequence);
    [self rwcpSendNotification:sequence command:RWCP_SERVER_CMD_GAP];
}

- (uint8_t)nextExpectedSequenceNumber:(uint8_t)current_sequence_number {
    return (_last_sequence_number + 1) % RWCP_SEQUENCE_NUMBER_MAX;
}

- (uint8_t)isNextSequence:(uint8_t)sequence {
    return sequence == [self nextExpectedSequenceNumber:_last_sequence_number];
}

- (Boolean)isOutOfSequence:(uint8_t)sequence {
    uint16_t norm = (sequence - _last_sequence_number + RWCP_SEQUENCE_NUMBER_MAX) % RWCP_SEQUENCE_NUMBER_MAX;
    
    return norm > 0 && norm < RWCP_RECEIVE_WINDOW_MAX;
}

- (void)handleDataSegment:(uint8_t)sequence_number
                     data:(NSData*)data {
    // payload received, check the sequence number
    // Send an ACK if: the sequence number is as expected, and the callback
    // was successful. Ask to resend the segment if the callback can't accept the
    // payload.
    // Send a GAP if the sequence number is unexpected.
    // ACK duplicates.
    if (_accept_segments ) {
        if ([self isNextSequence:sequence_number]) {
            _gap_mute = FALSE;
            [self rwcpDataAck:sequence_number];
            _last_sequence_number = sequence_number;
            NSRange dataRange = {RWCP_PAYLOAD_OFFSET, data.length - RWCP_HEADER_SIZE};
            uint8_t dataBytes[dataRange.length];

            [data getBytes:&dataBytes range:dataRange];
            
            [_delegate rwcpDataPacketRecieved:_central
                                         data:[NSData dataWithBytes:dataBytes length:dataRange.length]];
        } else if ([self isOutOfSequence:sequence_number]) {
            if ( !_gap_mute) {
                _gap_mute = TRUE;
                [self rwcpGap:_last_sequence_number];
                NSLog(@"rx:%d ex:%d,", sequence_number,
                      [self nextExpectedSequenceNumber:_last_sequence_number]);
            } else {
                NSLog(@"g:%d,", sequence_number);
            }
        } else { // must be a duplicate, ACK in case the previous ACK was lost
            NSLog(@"dup");
            [self rwcpDataAck:sequence_number];
        }
    } else {
        ;   // silently discard when the server can't accept any more segments
    }
}

/*----------------------------------------------------------------------------*
 *  NAME
 *      RwcpServerHandleMessage
 *
 *  DESCRIPTION
 *      This function handles a message delivered to the RWCP.
 *
 *  RWCP Message Header
 *  Bit  [  0  ][  1  ][  2  ][  3  ][  4  ][  5  ][  6  ][  7  ]
 *       [ Sequence Number 0 to 63                ][  COMMAND   ]
 *
 *  RETURNS
 *      Nothing.
 *
 *---------------------------------------------------------------------------*/
- (void)handleMessage:(NSData *)data {
    uint8_t rwcp_header = 0;
    uint8_t sequence_number = 0;
    uint8_t command = 0;
    
    [data getBytes:&rwcp_header range:NSMakeRange(RWCP_HEADER_OFFSET, sizeof(uint8_t))];
    
    // decode the header
    sequence_number = rwcp_header & RWCP_SEQUENCE_MASK;
    command = rwcp_header & RWCP_COMMAND_MASK;
    
    // if no callback has been registered, dump the segment and refuse all
    if (!_delegate) {
        [self rwcpRst:sequence_number];
        return;
    }
    
    // handle messages according to state
    switch (_protocol_state) {
        // Waiting for a SYN segment, send RST on all others
        // This segment contains the starting sequence number (which may be non zero).
        case QTIRWCPProtocolState_Listen:
            switch (command) {
                case RWCP_CLIENT_CMD_SYN: // SYN received, start the protocol
                    NSLog(@"SYN received, LISTEN => SYN_RCVD");
                    
                    [self rwcpSynAck:sequence_number];
                    [_delegate rwcpServerStateChange:_central state:QTIRWCPServerState_Init];
                    _last_sequence_number = sequence_number;
                    _protocol_state = QTIRWCPProtocolState_Syn_Rcvd;
                    break;
                case RWCP_CLIENT_CMD_RST: // handle the ReSeT command
                    [self rwcpRstAck:sequence_number];
                    [_delegate rwcpServerStateChange:_central state:QTIRWCPServerState_Close];
                    break;
                case RWCP_CLIENT_CMD_DATA: // unexpected command
                case RWCP_CLIENT_CMD_RESERVED:
                default:
                    NSLog(@"Unexpected, hdr = %x, LISTEN => LISTEN", rwcp_header);
                    [self rwcpRst:sequence_number];
                    break;
            }
            break;
        case QTIRWCPProtocolState_Syn_Rcvd: // SYN was received, waiting for the first data segment
            switch(command) {
                case RWCP_CLIENT_CMD_SYN: // duplicate SYN received, keep going
                    NSLog(@"SYN received, SYN_RCVD => SYN_RCVD=");
                    [self rwcpSynAck:sequence_number];
                    _last_sequence_number = sequence_number;
                    break;
                case RWCP_CLIENT_CMD_RST: // handle the ReSeT command
                    NSLog(@"RST received, SYN_RCVD => LISTEN");
                    [self rwcpRstAck:sequence_number];
                    [_delegate rwcpServerStateChange:_central state:QTIRWCPServerState_Close];
                    _protocol_state = QTIRWCPProtocolState_Listen;
                    break;
                case RWCP_CLIENT_CMD_DATA: // first DATA segment arrived, handle it, and change state
                    NSLog(@"DATA received, SYN_RCVD => ESTABLISHED");
                    _gap_mute = FALSE;
                    [self handleDataSegment:sequence_number data:data];
                    _protocol_state = QTIRWCPProtocolState_Established;
                    break;
                    
                case RWCP_CLIENT_CMD_RESERVED: // unexpected command
                default:
                    NSLog(@"Unexpected, hdr = %x, SYN_RCVD => LISTEN", rwcp_header);
                    [self rwcpRst:sequence_number];
                    [_delegate rwcpServerStateChange:_central state:QTIRWCPServerState_Close];
                    _protocol_state = QTIRWCPProtocolState_Listen;
                    break;
            }
            break;
        case QTIRWCPProtocolState_Established:
            switch(command) {
                case RWCP_CLIENT_CMD_RST: // handle the ReSeT command
                    NSLog(@"RST received, ESTABLISHED => LISTEN");
                    [self rwcpRstAck:sequence_number];
                    [_delegate rwcpServerStateChange:_central state:QTIRWCPServerState_Close];
                    _protocol_state = QTIRWCPProtocolState_Listen;
                    break;
                case RWCP_CLIENT_CMD_DATA: // DATA segment arrived, handle it
                    [self handleDataSegment:sequence_number data:data];
                    break;
                case RWCP_CLIENT_CMD_SYN: // unexpected command
                case RWCP_CLIENT_CMD_RESERVED:
                default:
                    NSLog(@"Unexpected, hdr = %x, ESTABLISHED => LISTEN", rwcp_header);
                    [self rwcpRst:sequence_number];
                    [_delegate rwcpServerStateChange:_central state:QTIRWCPServerState_Close];
                    _protocol_state = QTIRWCPProtocolState_Listen;
                    break;
            }
            break;
        default:
            break;
    }
}

@end
