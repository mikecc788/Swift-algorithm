//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import "QTIL2CAPDataProvider.h"

@interface QTIL2CAPDataProvider () <QTIL2CAPChannelDelegate>

@end

@implementation QTIL2CAPDataProvider

- (id)initWithChannel:(QTIL2CAPChannel *)channel delegate:(nullable id <QTIDataProviderDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        _channel = channel;
        _channel.delegate = self;
    }
    
    return self;
}

- (void)write:(NSData *)data {
    [_channel writeData:data];
}

- (void)connect {
    [_channel connect];
}

- (void)disconnect {
    [_channel disconnect];
}

- (void)didConnectChannel:(QTIL2CAPChannel *)channel {
    [self.delegate didConnect];
}

- (void)didDisconnectChannel:(QTIL2CAPChannel *)channel {
    [self.delegate didDisconnect];
}

- (void)dataAvailable:(NSData *)data {
    [self.delegate dataAvailable:data];
}

- (void)streamError:(NSError *)error {
    [self.delegate onError:error];
}

@end
