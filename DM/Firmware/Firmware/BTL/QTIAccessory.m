//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import "QTIAccessory.h"

#define EAD_INPUT_BUFFER_SIZE   128
#define IVOR_BUFFER_SIZE        1024

@interface QTIAccessory () <EAAccessoryDelegate, NSStreamDelegate>

@property (nonnull) NSString *protocol;
@property (nonatomic) NSMutableData *writeBuffer;

@end

@implementation QTIAccessory

@synthesize accessory = _accessory;
@synthesize connectionId = _connectionId;
@synthesize session = _session;

- (id)initWithDelegate:(id<QTIAccessoryDelegate>)delegate
             accessory:(EAAccessory *)accessory
              protocol:(NSString *)protocol {
    if (self = [super init]) {
        _protocol = protocol;
        _delegate = delegate;
        _accessory = accessory;
        _connectionId = accessory.connectionID;
        _writeBuffer = [NSMutableData data];
    }
    
    return self;
}

- (void)connect {
    _session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocol];
    _session.inputStream.delegate = self;
    [_session.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_session.inputStream open];
    _session.outputStream.delegate = self;
    [_session.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_session.outputStream open];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectAccessory:)]) {
        [self.delegate didConnectAccessory:self];
    }
}

- (void)readData {
    uint8_t buf[IVOR_BUFFER_SIZE];
    NSMutableData *buffer = [NSMutableData data];

    if (_session.inputStream.hasBytesAvailable) {
        NSUInteger totalBytes = 0;
        NSUInteger bytesRead = [_session.inputStream read:buf maxLength:IVOR_BUFFER_SIZE];

        totalBytes += bytesRead;

        while (bytesRead > 0) {
            [buffer appendBytes:(void *)buf length:bytesRead];

            bytesRead = [_session.inputStream read:buf maxLength:IVOR_BUFFER_SIZE];
            totalBytes += bytesRead;
        }
    }
    
    while ([_session.inputStream hasBytesAvailable]) {
        NSInteger bytesRead = [_session.inputStream read:buf maxLength:1024];

        [buffer appendBytes:(void *)buf length:bytesRead];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataAvailable:)]) {
        [self.delegate dataAvailable:buffer];
    }
}

- (void)writeData {
    NSInteger bytesWritten = 0;
    
    while ([_session.outputStream hasSpaceAvailable] && [_writeBuffer length] > 0) {
        bytesWritten += [_session.outputStream
                         write:[_writeBuffer bytes]
                         maxLength:[_writeBuffer length]];
        
        if (bytesWritten == -1) {
            NSLog(@"write error");
            break;
        } else if (bytesWritten > 0) {
            [_writeBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
        }
    }
}

- (void)writeData:(NSData *)data {
    [_writeBuffer appendData:data];
 
    [self writeData];
}

- (void)disconnect {
    _session.inputStream.delegate = nil;
    [_session.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_session.inputStream close];
    _session.outputStream.delegate = nil;
    [_session.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_session.outputStream close];
    _session = nil;
}

#pragma mark EAAccessoryDelegate
- (void)accessoryDidDisconnect:(QTIAccessory *)accessory {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectAccessory:)]) {
        [self.delegate didDisconnectAccessory:accessory];
    }
}

#pragma mark NSStreamDelegateEventExtensions
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventNone:
        case NSStreamEventOpenCompleted:
        case NSStreamEventEndEncountered:
            break;
        case NSStreamEventHasBytesAvailable:
            [self readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            [self writeData];
            break;
        case NSStreamEventErrorOccurred:
            if (self.delegate && [self.delegate respondsToSelector:@selector(streamError:)]) {
                [self.delegate streamError:[aStream streamError]];
            }
            break;
    }
}

@end
