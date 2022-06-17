//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import "QTIL2CAPChannel.h"

@interface QTIL2CAPChannel () <NSStreamDelegate>

@property (nonatomic) NSMutableData *writeBuffer;
@property (nonatomic) CBL2CAPChannel *l2pcapChannel;

@end

@implementation QTIL2CAPChannel

- (id)initWithChannel:(CBL2CAPChannel * _Nonnull)channel {
    if (self = [super init]) {
        _l2pcapChannel = channel;
        _writeBuffer = [NSMutableData data];
    }
    
    return self;
}

- (id)initWithDelegate:(id <QTIL2CAPChannelDelegate>)delegate
                        channel:(CBL2CAPChannel * _Nonnull)channel {
    if (self = [[QTIL2CAPChannel alloc] initWithChannel:channel]) {
        _delegate = delegate;
    }
    
    return self;
}

- (void)connect {
    _l2pcapChannel.inputStream.delegate = self;
    [_l2pcapChannel.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_l2pcapChannel.inputStream open];
    _l2pcapChannel.outputStream.delegate = self;
    [_l2pcapChannel.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_l2pcapChannel.outputStream open];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectChannel:)]) {
        [_delegate didConnectChannel:self];
    }
}

- (void)disconnect {
    _l2pcapChannel.inputStream.delegate = nil;
    [_l2pcapChannel.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_l2pcapChannel.inputStream close];
    _l2pcapChannel.outputStream.delegate = nil;
    [_l2pcapChannel.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_l2pcapChannel.outputStream close];

    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectChannel:)]) {
        [_delegate didDisconnectChannel:self];
    }
}

- (void)readData {
    uint8_t buf[1024];
    NSMutableData *buffer = [NSMutableData data];
    
    while ([_l2pcapChannel.inputStream hasBytesAvailable]) {
        NSInteger bytesRead = [_l2pcapChannel.inputStream read:buf maxLength:1024];
        
        [buffer appendBytes:(void *)buf length:bytesRead];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(l2pcapDataAvailable:)]) {
        [self.delegate l2pcapDataAvailable:buffer];
    }
}

- (void)writeData {
    NSInteger bytesWritten = 0;
    
    while ([_l2pcapChannel.outputStream hasSpaceAvailable] && [_writeBuffer length] > 0) {
        bytesWritten += [_l2pcapChannel.outputStream
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
