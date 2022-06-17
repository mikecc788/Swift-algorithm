//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//
#import "QTIRWCP.h"
#import "QTIRWCPSegment.h"
#import "GaiaLibrary.h"

#define GATT_MTU						(20)

// Timeout periods
#define RWCP_SYN_TIMEOUT_MS				(1500)
#define RWCP_RST_TIMEOUT_MS				(1500)
#define RWCP_DATA_TIMEOUT_MS_NORMAL		(500)
#define RWCP_DATA_TIMEOUT_MS_MAX		(2000)

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

@interface QTIRWCP () <CSRConnectionManagerDelegate>

@property (nonatomic) CSRPeripheral *connectedPeripheral;
@property (nonatomic) CBService *service;
@property (nonatomic) CBCharacteristic *dataCharacteristic;

@property (nonatomic) int lastAckSequence;
@property (nonatomic) int nextSequence;
@property (nonatomic) int window;
@property (nonatomic) int credits;
@property (nonatomic) int isResendingSegments;
@property (nonatomic) QTIRWCPState state;
@property (nonatomic) NSMutableArray *pendingData;
@property (nonatomic) NSMutableArray *unacknowledgedSegments;
@property (nonatomic) NSTimer *timerValue;
@property (nonatomic) Boolean timerRunning;
@property (nonatomic) int dataTimeout;
@property (nonatomic) int acknowledgedSegments;

@property (nonatomic) Boolean hasDisconnected;
@property (nonatomic) Boolean lastSegmentSent;

@end

@implementation QTIRWCP

+ (QTIRWCP *)sharedInstance {
    static dispatch_once_t pred;
    static QTIRWCP *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[QTIRWCP alloc] init];
    });
    
    return shared;
}

- (void)commonInit {
    _hasDisconnected = false;
    _lastAckSequence = -1;
    _nextSequence = 0;
    _window = [self getDefaultWindowSizeMax];
    _credits = _window;
    _isResendingSegments = false;
    _state = QTIRWCPState_Listen;
    _timerRunning = false;
    _acknowledgedSegments = 0;
    _pendingData = [NSMutableArray array];
    _unacknowledgedSegments = [NSMutableArray array];
    _dataTimeout = RWCP_DATA_TIMEOUT_MS_NORMAL;
    _maximumCongestionWindowSize = [self getMaximumWindowSize];
}

- (uint8_t)getDefaultWindowSizeMax {
    if (_initialCongestionWindowSize > 0) {
        return _initialCongestionWindowSize;
    } else {
        return RWCP_CWIN_MAX;
    }
}

- (uint8_t)getMaximumWindowSize {
    if (_maximumCongestionWindowSize > 0) {
        return _maximumCongestionWindowSize;
    } else {
        return RWCP_CWIN_MAX;
    }
}

// -------------------------------------------------------------------------------------------------
// Public methods
// -------------------------------------------------------------------------------------------------
- (void)startTransfer {
    if (_state == QTIRWCPState_Listen) {
        [self startSession];
    } else if (_state == QTIRWCPState_Established) {
        [self sendDataSegment];
    }
}

- (void)setPayload:(NSData *)data {
    DLog(@"Add RWCP payload: %@", data);
    [_pendingData addObject:data];
}

- (void)abort {
    if (_state == QTIRWCPState_Listen) {
        return;
    }
    
    [self reset: true];
    
    if (![self sendRSTSegment]) {
        [self terminateSession];
    }
}

- (void)cancelTimeout {
    if (_timerRunning) {
        _timerRunning = false;
        
        if (_timerValue) {
            [_timerValue invalidate];
            _timerValue = nil;
        }
    }
}

- (void)setTimer:(int)value {
    [self cancelTimeout];
    _timerRunning = true;
    _timerValue = [NSTimer scheduledTimerWithTimeInterval:(float)value * 0.001
                                                   target:self
                                                 selector:@selector(timeout)
                                                 userInfo:nil
                                                  repeats:NO];
}

- (void)powerOff {
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
    self.connectedPeripheral = nil;
    self.service = nil;
    self.dataCharacteristic = nil;
    [self commonInit];
    _hasDisconnected = true;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeProgress:)]) {
//        [self.delegate didMakeProgress:0];
        [self.delegate didUpdateStatus:@"Disconnected. Waiting for reconnection..."];
    }
}

// -------------------------------------------------------------------------------------------------
// Delegates
// -------------------------------------------------------------------------------------------------
- (void)connectPeripheral:(CSRPeripheral *)peripheral
       dataCharacteristic:(CBCharacteristic *)characteristic {
    self.connectedPeripheral = peripheral;
    [[CSRConnectionManager sharedInstance] addDelegate:self];
    self.dataCharacteristic = characteristic;
    
    if (_hasDisconnected) {
        [[CSRGaiaManager sharedInstance] setDataEndPointMode:true];
        _hasDisconnected = false;
    }

    if (self.dataCharacteristic) {
        [[CSRConnectionManager sharedInstance]
         listenFor:UUID_GAIA_SERVICE
         characteristic:UUID_GAIA_DATA_ENDPOINT];
    }
    
    [self commonInit];
}

- (void)didDisconnectFromPeripheral:(CBPeripheral *)peripheral {
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
    self.connectedPeripheral = nil;
    self.service = nil;
    self.dataCharacteristic = nil;
    [self commonInit];
    _hasDisconnected = true;

    if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeProgress:)]) {
//        [self.delegate didMakeProgress:0];
        [self.delegate didUpdateStatus:@"Disconnected. Waiting for reconnection..."];
    }
}

- (void)chracteristicChanged:(CBCharacteristic *)characteristic {
    if ([characteristic isEqual:self.dataCharacteristic]) {
        DLog(@"Incoming RWCP data: %@", characteristic.value);
        NSData *data = characteristic.value;
        
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

- (Boolean)sendData:(NSData *)data {
    [_pendingData addObject:data];
    
    if (_state == QTIRWCPState_Listen) {
        return [self startSession];
    } else if (_state == QTIRWCPState_Established) {
        [self sendDataSegment];
        return true;
    }
    
    return true;
}

- (Boolean)startSession {
    DLog(@"startSession");
    
    if (_state != QTIRWCPState_Listen ) {
        DLog(@"Start RWCP session failed: already an ongoing session.");
        return false;
    }
    
    if ([self sendRSTSegment]) {
        return true;
    } else {
        DLog(@"Start RWCP session failed: sending of RST segment failed.");
        [self terminateSession];
        return false;
    }
}

- (void)terminateSession {
    DLog(@"terminateSession");
    [self reset: true];
}

- (Boolean)receiveSynAck:(QTIRWCPSegment *)segment {
    DLog(@"Receive SYN_ACK for sequence %d", segment.sequence);
    
    switch (_state) {
        case QTIRWCPState_SynSent:
            [self cancelTimeout];
            int validated = [self validateAckSequence:RWCP_HEADER_OPCODE_SYN sequence:segment.sequence];
            
            if (validated >= 0) {
                _state = QTIRWCPState_Established;
                if (_pendingData.count > 0) {
                    [self sendDataSegment];
                }
            } else {
                DLog(@"Receive SYN_ACK with unexpected sequence number: %d", segment.sequence);
                [self terminateSession];
                [self sendRSTSegment];
            }
            return true;
        case QTIRWCPState_Established:
            [self cancelTimeout];
            
            if (_unacknowledgedSegments.count > 0) {
                [self resendDataSegment];
            }
            return true;
        case QTIRWCPState_Listen:
        case QTIRWCPState_Closing:
            DLog(@"Received unexpected SYN_ACK segment with header while in state %@", [self getRWCPFlagString:_state]);
            return false;
    }
}

- (Boolean)receiveDataAck:(QTIRWCPSegment *)segment {
    DLog(@"Receive DATA_ACK for sequence %d", segment.sequence);
    
    switch (_state) {
        case QTIRWCPState_Established:
            [self cancelTimeout];
            int sequence = segment.sequence;
            int validated = [self validateAckSequence:RWCP_HEADER_OPCODE_DATA sequence:sequence];
            
            if (validated >= 0) {
                if (_credits > 0 && _pendingData.count > 0) {
                    [self sendDataSegment];
                } else if (_pendingData.count == 0 && _unacknowledgedSegments.count == 0) {
                    [self sendRSTSegment];
                } else if ((_pendingData.count == 0 && _unacknowledgedSegments.count > 0)
                           || (_credits == 0 && _pendingData.count > 0)) {
                    [self setTimer:_dataTimeout];
                }
            }
            return true;
        case QTIRWCPState_Closing:
            DLog(@"Received DATA_ACK(%d) segment while in state CLOSING: segment discarded.", segment.sequence);
            return true;
        case QTIRWCPState_SynSent:
        case QTIRWCPState_Listen:
            DLog(@"Received unexpected DATA_ACK segment with sequence %d while in state %@", segment.sequence, [self getRWCPFlagString:_state]);
            return false;
    }
}

- (Boolean)receiveRST:(QTIRWCPSegment *)segment {
    DLog(@"Receive RST or RST_ACK for sequence %d", segment.sequence);
    
    switch (_state) {
        case QTIRWCPState_SynSent:
            DLog(@"Received in SynSent state, ignoring segment");
            return true;
        case QTIRWCPState_Established:
            DLog(@"Received RST (sequence %d) in ESTABLISHED state, terminating session, transfer failed.", segment.sequence);
            [self terminateSession];
            return true;
        case QTIRWCPState_Closing:
            [self cancelTimeout];
            [self validateAckSequence:RWCP_HEADER_OPCODE_RST sequence: segment.sequence];
            [self reset: false];
            
            if (_pendingData.count > 0) {
                if (![self sendSYNSegment]) {
                    DLog(@"Start session of RWCP data transfer failed: sending of SYN failed.");
                    [self terminateSession];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteDataSend)]) {
                    [self.delegate didCompleteDataSend];
                }
            }
            return true;
        case QTIRWCPState_Listen:
            DLog(@"Received unexpected RST segment with sequence=%d while in state %@", segment.sequence, [self getRWCPFlagString:_state]);
            return false;
    }
}

- (Boolean)receiveGAP:(QTIRWCPSegment *)segment {
    DLog(@"Receive GAP for sequence %d", segment.sequence);
    
    switch (_state) {
        case QTIRWCPState_Established:
            if (_lastAckSequence > segment.sequence) {
                DLog(@"Ignoring GAP (%d) as last ack sequence is %d.", segment.sequence, _lastAckSequence);
                return true;
            }
            if (_lastAckSequence <= segment.sequence) {
                [self decreaseWindow];
                [self validateAckSequence:RWCP_HEADER_OPCODE_DATA sequence: segment.sequence];
            }
            
            [self cancelTimeout];
            [self resendDataSegment];
            return true;
        case QTIRWCPState_Closing:
            DLog(@"Received GAP(%d) segment while in state CLOSING: segment discarded.", segment.sequence);
            return true;
        case QTIRWCPState_Listen:
        case QTIRWCPState_SynSent:
            DLog(@"Received unexpected GAP segment with header while in state %@", [self getRWCPFlagString:_state]);
            return false;
    }
}

- (void)timeout {
    if (_timerRunning) {
        DLog(@"TIME OUT > re sending segments");
        _timerRunning = false;
        _isResendingSegments = false;
        _acknowledgedSegments = 0;
        
        if (_state == QTIRWCPState_Established) {
            _dataTimeout *= 2;
            
            if (_dataTimeout > RWCP_DATA_TIMEOUT_MS_MAX) {
                _dataTimeout = RWCP_DATA_TIMEOUT_MS_MAX;
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
        DLog(@"Received ACK sequence (%d) is less than 0.", sequence);
        return notValidated;
    }
    if (sequence > RWCP_MAX_SEQUENCE) {
        DLog(@"Received ACK sequence (%d) is bigger than its maximum value (%d)", sequence, RWCP_MAX_SEQUENCE);
        return notValidated;
    }
    if (_lastAckSequence < _nextSequence && (sequence < _lastAckSequence || sequence > _nextSequence)) {
        DLog(@"Received ACK sequence (%d) is out of interval: last received is %d and next will be %d", sequence, _lastAckSequence, _nextSequence);
        return notValidated;
    }
    if (_lastAckSequence > _nextSequence && sequence < _lastAckSequence && sequence > _nextSequence) {
        DLog(@"Received ACK sequence (%d) is out of interval: last received is %d and next will be %d", sequence, _lastAckSequence, _nextSequence);
        return notValidated;
    }
    
    int acknowledged = 0;
    int nextAckSequence = _lastAckSequence;
    
    while (nextAckSequence != sequence) {
        nextAckSequence = [self increaseSequenceNumber: nextAckSequence];
        
        if ([self removeSegmentFromQueue:opCode sequence: nextAckSequence]) {
            _lastAckSequence = nextAckSequence;
            
            if (_credits < _window) {
                _credits++;
            }
            
            acknowledged++;
        } else {
            DLog(@"Error validating sequence %d: no corresponding segment in pending segments.", nextAckSequence);
        }
    }
    
    DLog(@"%d segment(s) validated with ACK sequence(code=%d, seq=%d)", acknowledged, opCode, sequence);
    
    // increase the window size if qualified.
    [self increaseWindow: acknowledged];
    
    return acknowledged;
}
    
- (Boolean)sendRSTSegment {
    if (_state == QTIRWCPState_Closing) {
        return true;
    }
    
    [self reset: false];
    _state = QTIRWCPState_Closing;
    
    QTIRWCPSegment *segment = [[QTIRWCPSegment alloc] initWithCode:RWCP_HEADER_OPCODE_RST sequence: _nextSequence];
    Boolean done = [self sendSegment:segment delay:RWCP_RST_TIMEOUT_MS];
    
    if (done) {
        [_unacknowledgedSegments addObject:segment];
        _nextSequence = [self increaseSequenceNumber: _nextSequence];
        _credits--;
        DLog(@"send RST segment");
    }
    
    return done;
}
    
- (Boolean)sendSYNSegment {
    _state = QTIRWCPState_SynSent;

    QTIRWCPSegment *segment = [[QTIRWCPSegment alloc] initWithCode:RWCP_HEADER_OPCODE_SYN sequence: _nextSequence];
    Boolean done = [self sendSegment:segment delay: RWCP_SYN_TIMEOUT_MS];
    
    if (done) {
        [_unacknowledgedSegments addObject:segment];
        _nextSequence = [self increaseSequenceNumber:_nextSequence];
        _credits--;
        DLog(@"send SYN segment");
    }
    
    return done;
}
    
- (void)sendDataSegment {
    while (_credits > 0 && _pendingData.count > 0 && !_isResendingSegments && _state == QTIRWCPState_Established) {
        NSData *data = [_pendingData firstObject];
        QTIRWCPSegment *segment = [[QTIRWCPSegment alloc]
                                   initWithData:RWCP_HEADER_OPCODE_DATA
                                   sequence:_nextSequence
                                   data:data];
        
        [_pendingData removeObjectAtIndex:0];
        [self sendSegment:segment delay:_dataTimeout];
        [_unacknowledgedSegments addObject:segment];
        _nextSequence = [self increaseSequenceNumber:_nextSequence];
        _credits--;
    }
    DLog(@"send DATA segments");
}

- (int)increaseSequenceNumber:(int)sequence {
    return (sequence + 1) % RWCP_SEQUENCE_SPACE_SIZE;
}

- (int)decreaseSequenceNumber:(int)sequence decrease:(int)decrease {
    return (sequence - decrease + RWCP_SEQUENCE_SPACE_SIZE) % RWCP_SEQUENCE_SPACE_SIZE;
}

- (void)resendSegment {
    if (_state == QTIRWCPState_Established) {
        DLog(@"Trying to resend non data segment while in ESTABLISHED state.");
        return;
    }
    
    _isResendingSegments = true;
    _credits = _window;
    
    for (QTIRWCPSegment *segment in _unacknowledgedSegments) {
        int delay = segment.flags == RWCP_HEADER_OPCODE_SYN ? RWCP_SYN_TIMEOUT_MS :
                    segment.flags == RWCP_HEADER_OPCODE_RST ? RWCP_RST_TIMEOUT_MS : _dataTimeout;
        
        [self sendSegment:segment delay:delay];
        _credits--;
    }
    
    DLog(@"resend segments");
    _isResendingSegments = false;
}

- (void)resendDataSegment {
    if (_state != QTIRWCPState_Established) {
        DLog(@"Trying to resend non data segment while in ESTABLISHED state.");
        return;
    }

    _isResendingSegments = true;
    _credits = _window;
    DLog(@"reset credits");
    
    int moved = 0;
    
    while (_unacknowledgedSegments.count > _credits) {
        QTIRWCPSegment *segment = _unacknowledgedSegments.lastObject;
        
        if (segment.flags == RWCP_HEADER_OPCODE_DATA) {
            NSRange range = {1, segment.data.length - 1};

            [self removeSegmentFromQueue:segment];
            [_pendingData insertObject:[segment.data subdataWithRange:range] atIndex:0];
            moved++;
        } else {
            DLog(@"Segment %d", segment.sequence);
            break;
        }
    }
    
    _nextSequence = [self decreaseSequenceNumber:_nextSequence decrease:moved];
    
    for (QTIRWCPSegment *segment in _unacknowledgedSegments) {
        DLog(@"Resend %d", segment.sequence);
        [self sendSegment:segment delay: _dataTimeout];
        _credits--;
    }
    
    DLog(@"Resend DATA segments");
    _isResendingSegments = false;
    
    if (_credits > 0) {
        [self sendDataSegment];
    }
}

- (Boolean)sendSegment:(QTIRWCPSegment *)segment delay:(int)delay {
    DLog(@"Write characteristic data: %@", segment.data);
    [self.connectedPeripheral.peripheral
     writeValue:segment.data
     forCharacteristic:self.dataCharacteristic
     type:CBCharacteristicWriteWithoutResponse];
    [self setTimer:delay];
    
    return true;
}

- (Boolean)removeSegmentFromQueue:(int)code sequence:(int)sequence {
    for (QTIRWCPSegment *segment in _unacknowledgedSegments) {
        if (segment.flags == code && segment.sequence == sequence) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeProgress:)]) {
                if (code == RWCP_HEADER_OPCODE_DATA) {
                    [self.delegate didMakeProgress:segment.length - 8];
                }
            }
            
            [_unacknowledgedSegments removeObject:segment];
            return true;
        }
    }
    
    DLog(@"Pending segments does not contain acknowledged segment: code=%d\tsequence=%d", code, sequence);
    return false;
}

- (Boolean)removeSegmentFromQueue:(QTIRWCPSegment *)segment {
    [_unacknowledgedSegments removeObject:segment];
    return true;
}

- (void)reset:(Boolean)complete {
    _lastAckSequence = -1;
    _nextSequence = 0;
    _state = QTIRWCPState_Listen;
    [_unacknowledgedSegments removeAllObjects];
    _window = [self getDefaultWindowSizeMax];
    _acknowledgedSegments = 0;
    _credits = _window;
    [self cancelTimeout];
    
    if (complete) {
        [_pendingData removeAllObjects];
    }
    
    DLog(@"reset");
}

- (void)increaseWindow:(int)acknowledged {
    _acknowledgedSegments += acknowledged;
    
    if (_acknowledgedSegments > _window && _window < [self getMaximumWindowSize]) {
        _acknowledgedSegments = 0;
        _window++;
        _credits++;
        DLog(@"increase window to %d", _window);
    }
}

- (void)decreaseWindow {
    _window = ((_window - 1) / 2) + 1;
    
    if (_window > [self getMaximumWindowSize] || _window < 1) {
        _window = 1;
    }
    
    _acknowledgedSegments = 0;
    _credits = _window;
    
    DLog(@"decrease window to %d", _window);
}

@end
