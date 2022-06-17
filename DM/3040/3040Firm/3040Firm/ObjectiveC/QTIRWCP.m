//
// © 2017-2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//
#import "QTIRWCP.h"
#import "QTIRWCPSegment.h"
#import "_040Firm-Swift.h"

#define GATT_MTU						(20)

// Timeout periods
#define RWCP_SYN_TIMEOUT_MS				(1500)
#define RWCP_RST_TIMEOUT_MS				(1500)
#define RWCP_DATA_TIMEOUT_MS_NORMAL		(500)
#define RWCP_DATA_TIMEOUT_MS_MAX		(5000)

// RWCP protocol definitions
#define RWCP_MAX_SEQUENCE				(63)
#define RWCP_SEQUENCE_SPACE_SIZE		(RWCP_MAX_SEQUENCE + 1)
#define RWCP_HEADER_SIZE				(1)
#define RWCP_DATA_PAYLOAD_LEN			(GATT_MTU - RWCP_HEADER_SIZE)
#define RWCP_HEADER_MASK_SEQ_NUMBER		(0x3F)
#define RWCP_HEADER_MASK_OPCODE			(0xC0)
#define RWCP_HEADER_OPCODE_DATA			(0 << 6)
#define RWCP_HEADER_OPCODE_DATA_ACK		(0 << 6)
#define RWCP_HEADER_OPCODE_SYN			(1 << 6)
#define RWCP_HEADER_OPCODE_SYN_ACK		(1 << 6)
#define RWCP_HEADER_OPCODE_RST			(2 << 6)
#define RWCP_HEADER_OPCODE_RST_ACK		(2 << 6)
#define RWCP_HEADER_OPCODE_GAP			(3 << 6)
#define RWCP_CWIN_MAX					(15)			// Maximum size of congestion window. i.e. maximum number of outstanding segments
#define RWCP_CWIN_ADJUSTMENT_THRESHOLD	(32)			// The number of successful acknowledgements before congestion window expansion is considered.

@interface QTIRWCP ()

@property (nonatomic, weak) id<GaiaDeviceConnectionProtocol> connection;

@property (nonatomic) int lastAckSequence;
@property (nonatomic) int nextSequence;
@property (nonatomic) NSInteger window;
@property (nonatomic) NSInteger credits;
@property (nonatomic) BOOL isResendingSegments;
@property (nonatomic) QTIRWCPState state;
@property (nonatomic) NSMutableArray *pendingData;
@property (nonatomic) NSMutableArray *unacknowledgedSegments;
@property (nonatomic) NSTimer *timerValue;
@property (nonatomic) BOOL timerRunning;
@property (nonatomic) int dataTimeout;
@property (nonatomic) int acknowledgedSegments;

@property (nonatomic) BOOL hasDisconnected;
@property (nonatomic) BOOL lastSegmentSent;

@end

@implementation QTIRWCP

- (instancetype _Nonnull)initWithConnection:(id<GaiaDeviceConnectionProtocol> _Nonnull)connection
{
    if (self = [self init]) {
        self->_connection = connection;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.hasDisconnected = false;
    self.lastAckSequence = -1;
    self.nextSequence = 0;
    self.window = [self getDefaultWindowSizeMax];
    self.credits = self.window;
    self.isResendingSegments = false;
    self.state = QTIRWCPState_Listen;
    self.timerRunning = false;
    self.acknowledgedSegments = 0;
    self.pendingData = [NSMutableArray array];
    self.unacknowledgedSegments = [NSMutableArray array];
    self.dataTimeout = RWCP_DATA_TIMEOUT_MS_NORMAL;
    self.maximumCongestionWindowSize = [self getMaximumWindowSize];
}

- (void)teardown {
    [self reset: true];
}

- (NSInteger)getDefaultWindowSizeMax {
    if (self.initialCongestionWindowSize > 0) {
        return self.initialCongestionWindowSize;
    } else {
        return RWCP_CWIN_MAX;
    }
}

- (NSInteger)getMaximumWindowSize {
    if (self.maximumCongestionWindowSize > 0) {
        return self.maximumCongestionWindowSize;
    } else {
        return RWCP_CWIN_MAX;
    }
}

// -------------------------------------------------------------------------------------------------
// Public methods
// -------------------------------------------------------------------------------------------------
- (void)startTransfer {
    if (self.state == QTIRWCPState_Listen) {
        [self startSession];
    } else if (self.state == QTIRWCPState_Established) {
        [self sendDataSegment];
    }
}

- (void)setPayload:(NSData *)data {
    [self.pendingData addObject:data];
}

- (void)abort {
    if (self.state == QTIRWCPState_Listen) {
        NSLog(@"State is listen so not aborting...");
        return;
    }
    
    [self reset: true];
    
    if (![self sendRSTSegment]) {
        [self terminateSession];
    }
}

- (void)cancelTimeout {
    if (self.timerRunning) {
        self.timerRunning = false;
        
        if (self.timerValue) {
            [self.timerValue invalidate];
            self.timerValue = nil;
        }
    }
}

- (void)setTimer:(int)value {
    [self cancelTimeout];
    self.timerRunning = true;
    self.timerValue = [NSTimer scheduledTimerWithTimeInterval:(float)value * 0.001
                                                   target:self
                                                 selector:@selector(timeout)
                                                 userInfo:nil
                                                  repeats:NO];
}

- (void)powerOff {
    [self commonInit];
    self.hasDisconnected = true;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeProgress:)]) {
        [self.delegate didMakeProgress:0];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStatus:)]) {
        [self.delegate didUpdateStatus:@"Disconnected. Waiting for reconnection..."];
    }
}

- (void)didReceiveData:(NSData *)data {
//    NSLog(@"Incoming RWCP data: %@", data);
    if (!data) {
        return;
    }

    if (data.length < RWCP_HEADER_SIZE) {
        return;
    }

    uint8_t header = 0;
    uint8_t received_seq = 0;
    uint8_t opcode = 0;

    [data getBytes:&header range:NSMakeRange(0, 1)];
    opcode = header & RWCP_HEADER_MASK_OPCODE;
    received_seq = header & RWCP_HEADER_MASK_SEQ_NUMBER;

    QTIRWCPSegment *segment = [[QTIRWCPSegment alloc]
                               initWithLength:data.length
                               sequence:received_seq
                               data:data];

    switch (opcode) {
        case RWCP_HEADER_OPCODE_SYN_ACK:
            [self receiveSynAck: segment];
            break;
        case RWCP_HEADER_OPCODE_DATA_ACK:
            [self receiveDataAck: segment];
            break;
        case RWCP_HEADER_OPCODE_RST:
            [self receiveRST: segment];
            break;
        case RWCP_HEADER_OPCODE_GAP:
            [self receiveGAP: segment];
            break;
    }
}

// -------------------------------------------------------------------------------------------------
// Private methods
// -------------------------------------------------------------------------------------------------
- (NSString *)getRWCPFlagString:(uint8_t)header {
    switch (header & RWCP_HEADER_MASK_OPCODE) {
        case RWCP_HEADER_OPCODE_DATA_ACK:
            return @"DATA/ACK";
        case RWCP_HEADER_OPCODE_SYN_ACK:
            return @"SYN/SYN+ACK";
        case RWCP_HEADER_OPCODE_RST_ACK:
            return @"RES/RES+ACK";
        case RWCP_HEADER_OPCODE_GAP:
            return @"GAP";
        default:
            return nil;
    }
}

- (BOOL)sendData:(NSData *)data {
    [self.pendingData addObject:data];
    
    if (self.state == QTIRWCPState_Listen) {
        return [self startSession];
    } else if (self.state == QTIRWCPState_Established) {
        [self sendDataSegment];
        return true;
    }
    
    return true;
}

- (BOOL)startSession {
    NSLog(@"startSession");
    
    if (self.state != QTIRWCPState_Listen ) {
        NSLog(@"Start RWCP session failed: already an ongoing session.");
        return false;
    }
    
    if ([self sendRSTSegment]) {
        return true;
    } else {
        NSLog(@"Start RWCP session failed: sending of RST segment failed.");
        [self terminateSession];
        return false;
    }
}

- (void)terminateSession {
    NSLog(@"terminateSession");
    [self reset: true];
}

- (BOOL)receiveSynAck:(QTIRWCPSegment *)segment {
    NSLog(@"Receive SYN_ACK for sequence %d", segment.sequence);
    
    switch (self.state) {
        case QTIRWCPState_SynSent:
            [self cancelTimeout];
            int validated = [self validateAckSequence:RWCP_HEADER_OPCODE_SYN sequence:segment.sequence];
            
            if (validated >= 0) {
                self.state = QTIRWCPState_Established;
                if (self.pendingData.count > 0) {
                    [self sendDataSegment];
                }
            } else {
                NSLog(@"Receive SYN_ACK with unexpected sequence number: %d", segment.sequence);
                [self terminateSession];
                [self sendRSTSegment];
            }
            return true;
        case QTIRWCPState_Established:
            [self cancelTimeout];
            
            if (self.unacknowledgedSegments.count > 0) {
                [self resendDataSegment];
            }
            return true;
        case QTIRWCPState_Listen:
        case QTIRWCPState_Closing:
            NSLog(@"Received unexpected SYN_ACK segment with header while in state %@", [self getRWCPFlagString:_state]);
            return false;
    }
}

- (BOOL)receiveDataAck:(QTIRWCPSegment *)segment {
//    NSLog(@"Receive DATA_ACK for sequence %d", segment.sequence);
    
    switch (self.state) {
        case QTIRWCPState_Established:
            [self cancelTimeout];
            int sequence = segment.sequence;
            int validated = [self validateAckSequence:RWCP_HEADER_OPCODE_DATA sequence:sequence];
            
            if (validated >= 0) {
                if (self.credits > 0 && self.pendingData.count > 0) {
                    [self sendDataSegment];
                } else if (self.pendingData.count == 0 && self.unacknowledgedSegments.count == 0) {
                    [self sendRSTSegment];
                } else if ((self.pendingData.count == 0 && self.unacknowledgedSegments.count > 0)
                           || (self.credits == 0 && self.pendingData.count > 0)) {
                    [self setTimer:_dataTimeout];
                }
            }
            return true;
        case QTIRWCPState_Closing:
            NSLog(@"Received DATA_ACK(%d) segment while in state CLOSING: segment discarded.", segment.sequence);
            return true;
        case QTIRWCPState_SynSent:
        case QTIRWCPState_Listen:
            NSLog(@"Received unexpected DATA_ACK segment with sequence %d while in state %@", segment.sequence, [self getRWCPFlagString:_state]);
            return false;
    }
}

- (BOOL)receiveRST:(QTIRWCPSegment *)segment {
    NSLog(@"Receive RST or RST_ACK for sequence %d", segment.sequence);
    
    switch (self.state) {
        case QTIRWCPState_SynSent:
            NSLog(@"Received in SynSent state, ignoring segment");
            return true;
        case QTIRWCPState_Established:
            NSLog(@"Received RST (sequence %d) in ESTABLISHED state, terminating session, transfer failed.", segment.sequence);
            [self terminateSession];
            return true;
        case QTIRWCPState_Closing:
            [self cancelTimeout];
            [self validateAckSequence:RWCP_HEADER_OPCODE_RST sequence: segment.sequence];
            [self reset: false];
            
            if (self.pendingData.count > 0) {
                if (![self sendSYNSegment]) {
                    NSLog(@"Start session of RWCP data transfer failed: sending of SYN failed.");
                    [self terminateSession];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteDataSend)]) {
                    [self.delegate didCompleteDataSend];
                }
            }
            return true;
        case QTIRWCPState_Listen:
            NSLog(@"Received unexpected RST segment with sequence=%d while in state %@", segment.sequence, [self getRWCPFlagString:_state]);
            return false;
    }
}

- (BOOL)isGAPDiscarded:(NSInteger)sequence last:(NSInteger)last window:(NSInteger)window {
    NSInteger difference = ((last > sequence) ? RWCP_MAX_SEQUENCE : 0) + sequence - last;
    return difference > 0 && difference <= window;
}

- (BOOL)receiveGAP:(QTIRWCPSegment *)segment {
    NSLog(@"Receive GAP for sequence %d", segment.sequence);
    
    switch (self.state) {
        case QTIRWCPState_Established:
           //if (self.lastAckSequence > segment.sequence) {
            if ([self isGAPDiscarded:segment.sequence last:self.lastAckSequence window:self.window]) {
                NSLog(@"Ignoring GAP (%d) as last ack sequence is %d.", segment.sequence, self.lastAckSequence);
                return true;
            }
 //           if (self.lastAckSequence != segment.sequence) {
                [self decreaseWindow];
                [self validateAckSequence:RWCP_HEADER_OPCODE_DATA sequence: segment.sequence];
   //         }
            
            [self cancelTimeout];
            [self resendDataSegment];
            return true;
        case QTIRWCPState_Closing:
            NSLog(@"Received GAP(%d) segment while in state CLOSING: segment discarded.", segment.sequence);
            return true;
        case QTIRWCPState_Listen:
        case QTIRWCPState_SynSent:
            NSLog(@"Received unexpected GAP segment with header while in state %@", [self getRWCPFlagString:_state]);
            return false;
    }
}

- (void)timeout {
    if (self.timerRunning) {
        NSLog(@"TIME OUT > re sending segments");
        self.timerRunning = false;
        self.isResendingSegments = false;
        self.acknowledgedSegments = 0;
        
        if (self.state == QTIRWCPState_Established) {
            self.dataTimeout *= 2;
            
            if (self.dataTimeout > RWCP_DATA_TIMEOUT_MS_MAX) {
                self.dataTimeout = RWCP_DATA_TIMEOUT_MS_MAX;
            }
            
            [self resendDataSegment];
        } else {
            [self resendSegment];
        }
    }
}

- (int)validateAckSequence:(int)opCode sequence:(int)sequence {
    int notValidated = -1;
    
    if (sequence < 0) {
        NSLog(@"Received ACK sequence (%d) is less than 0.", sequence);
        return notValidated;
    }
    if (sequence > RWCP_MAX_SEQUENCE) {
        NSLog(@"Received ACK sequence (%d) is bigger than its maximum value (%d)", sequence, RWCP_MAX_SEQUENCE);
        return notValidated;
    }
    if (self.lastAckSequence < self.nextSequence && (sequence < self.lastAckSequence || sequence > self.nextSequence)) {
        NSLog(@"Received ACK sequence (%d) is out of interval: last received is %d and next will be %d", sequence, self.lastAckSequence, self.nextSequence);
        return notValidated;
    }
    if (self.lastAckSequence > self.nextSequence && sequence < self.lastAckSequence && sequence > self.nextSequence) {
        NSLog(@"Received ACK sequence (%d) is out of interval: last received is %d and next will be %d", sequence, self.lastAckSequence, self.nextSequence);
        return notValidated;
    }
    
    int acknowledged = 0;
    int nextAckSequence = self.lastAckSequence;
    
    while (nextAckSequence != sequence) {
        nextAckSequence = [self increaseSequenceNumber: nextAckSequence];
        
        if ([self removeSegmentFromQueue:opCode sequence: nextAckSequence]) {
            self.lastAckSequence = nextAckSequence;
            
            if (self.credits < self.window) {
                self.credits++;
            }
            
            acknowledged++;
        } else {
            NSLog(@"Error validating sequence %d: no corresponding segment in pending segments.", nextAckSequence);
        }
    }
    
//    NSLog(@"%d segment(s) validated with ACK sequence(code=%d, seq=%d)", acknowledged, opCode, sequence);
    
    // increase the window size if qualified.
    [self increaseWindow: acknowledged];
    
    return acknowledged;
}
    
- (BOOL)sendRSTSegment {
    if (self.state == QTIRWCPState_Closing) {
        return true;
    }
    
    [self reset: false];
    self.state = QTIRWCPState_Closing;
    
    QTIRWCPSegment *segment = [[QTIRWCPSegment alloc] initWithCode:RWCP_HEADER_OPCODE_RST sequence: self.nextSequence];
    BOOL done = [self sendSegment:segment delay:RWCP_RST_TIMEOUT_MS];
    
    if (done) {
        [self.unacknowledgedSegments addObject:segment];
        self.nextSequence = [self increaseSequenceNumber: self.nextSequence];
        self.credits--;
        NSLog(@"send RST segment");
    }
    
    return done;
}
    
- (BOOL)sendSYNSegment {
    self.state = QTIRWCPState_SynSent;

    QTIRWCPSegment *segment = [[QTIRWCPSegment alloc] initWithCode:RWCP_HEADER_OPCODE_SYN sequence: self.nextSequence];
    BOOL done = [self sendSegment:segment delay: RWCP_SYN_TIMEOUT_MS];
    
    if (done) {
        [self.unacknowledgedSegments addObject:segment];
        self.nextSequence = [self increaseSequenceNumber:_nextSequence];
        self.credits--;
        NSLog(@"send SYN segment");
    }
    
    return done;
}
    
- (void)sendDataSegment {
    while (self.credits > 0 && self.pendingData.count > 0 && !_isResendingSegments && self.state == QTIRWCPState_Established) {
        NSData *data = [self.pendingData firstObject];
        QTIRWCPSegment *segment = [[QTIRWCPSegment alloc]
                                   initWithCode:RWCP_HEADER_OPCODE_DATA
                                   sequence:_nextSequence
                                   data:data];
        
        [self.pendingData removeObjectAtIndex:0];
        [self sendSegment:segment delay:_dataTimeout];
        [self.unacknowledgedSegments addObject:segment];
        self.nextSequence = [self increaseSequenceNumber:_nextSequence];
        self.credits--;
    }
//    NSLog(@"send DATA segments");
}

- (int)increaseSequenceNumber:(int)sequence {
    return (sequence + 1) % RWCP_SEQUENCE_SPACE_SIZE;
}

- (int)decreaseSequenceNumber:(int)sequence decrease:(int)decrease {
    return (sequence - decrease + RWCP_SEQUENCE_SPACE_SIZE) % RWCP_SEQUENCE_SPACE_SIZE;
}

- (void)resendSegment {
    if (self.state == QTIRWCPState_Established) {
        NSLog(@"Trying to resend non data segment while in ESTABLISHED state.");
        return;
    }
    
    self.isResendingSegments = true;
    self.credits = self.window;
    
    for (QTIRWCPSegment *segment in self.unacknowledgedSegments) {
        int delay = segment.flags == RWCP_HEADER_OPCODE_SYN ? RWCP_SYN_TIMEOUT_MS :
                    segment.flags == RWCP_HEADER_OPCODE_RST ? RWCP_RST_TIMEOUT_MS : self.dataTimeout;
        
        [self sendSegment:segment delay:delay];
        self.credits--;
    }
    
    NSLog(@"resend segments");
    self.isResendingSegments = false;
}

- (void)resendDataSegment {
    if (self.state != QTIRWCPState_Established) {
        NSLog(@"Trying to resend non data segment while in ESTABLISHED state.");
        return;
    }

    self.isResendingSegments = true;
    self.credits = self.window;
    NSLog(@"reset credits");
    
    int moved = 0;
    
    while (self.unacknowledgedSegments.count > self.credits) {
        QTIRWCPSegment *segment = self.unacknowledgedSegments.lastObject;
        
        if (segment.flags == RWCP_HEADER_OPCODE_DATA) {
            NSRange range = {1, segment.data.length - 1};

            [self removeSegmentFromQueue:segment];
            [self.pendingData insertObject:[segment.data subdataWithRange:range] atIndex:0];
            moved++;
        } else {
            NSLog(@"Segment %d", segment.sequence);
            break;
        }
    }
    
    self.nextSequence = [self decreaseSequenceNumber:_nextSequence decrease:moved];
    
    for (QTIRWCPSegment *segment in self.unacknowledgedSegments) {
        NSLog(@"Resend %d", segment.sequence);
        [self sendSegment:segment delay: self.dataTimeout];
        self.credits--;
    }
    
    NSLog(@"Resend DATA segments");
    self.isResendingSegments = false;
    
    if (self.credits > 0) {
        [self sendDataSegment];
    }
}

- (BOOL)sendSegment:(QTIRWCPSegment *)segment delay:(int)delay {
//    NSLog(@"Write characteristic data: %@", segment.data);
    [self.connection sendDataWithChannel: GaiaDeviceConnectionChannelData
                                 payload: segment.data
                        responseExpected: NO];

    [self setTimer:delay];
    
    return true;
}

- (BOOL)removeSegmentFromQueue:(int)code sequence:(int)sequence {
    for (QTIRWCPSegment *segment in self.unacknowledgedSegments) {
        if (segment.flags == code && segment.sequence == sequence) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeProgress:)]) {
                if (code == RWCP_HEADER_OPCODE_DATA) {
                    [self.delegate didMakeProgress:segment.length - 8];
                }
            }
            
            [self.unacknowledgedSegments removeObject:segment];
            return true;
        }
    }
    
    NSLog(@"Pending segments does not contain acknowledged segment: code=%d\tsequence=%d", code, sequence);
    return false;
}

- (BOOL)removeSegmentFromQueue:(QTIRWCPSegment *)segment {
    [self.unacknowledgedSegments removeObject:segment];
    return true;
}

- (void)reset:(BOOL)complete {
    self.lastAckSequence = -1;
    self.nextSequence = 0;
    self.state = QTIRWCPState_Listen;
    [self.unacknowledgedSegments removeAllObjects];
    self.window = [self getDefaultWindowSizeMax];
    self.acknowledgedSegments = 0;
    self.credits = self.window;
    [self cancelTimeout];
    
    if (complete) {
        [self.pendingData removeAllObjects];
    }
    
    NSLog(@"reset");
}

- (void)increaseWindow:(int)acknowledged {
    self.acknowledgedSegments += acknowledged;
    
    if (self.acknowledgedSegments > self.window && self.window < [self getMaximumWindowSize]) {
        self.acknowledgedSegments = 0;
        self.window++;
        self.credits++;
        NSLog(@"increase window to %ld", (long)_window);
    }
}

- (void)decreaseWindow {
    self.window = ((self.window - 1) / 2) + 1;
    
    if (self.window > [self getMaximumWindowSize] || self.window < 1) {
        self.window = 1;
    }
    
    self.acknowledgedSegments = 0;
    self.credits = self.window;
    
    NSLog(@"decrease window to %ld", (long)_window);
}

@end
