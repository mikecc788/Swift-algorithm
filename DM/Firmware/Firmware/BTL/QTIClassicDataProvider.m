//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import "QTIClassicDataProvider.h"

@interface QTIClassicDataProvider () <QTIAccessoryDelegate>

@end

@implementation QTIClassicDataProvider

- (id)initWithAccessory:(QTIAccessory *)accessory delegate:(nullable id <QTIDataProviderDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        _accessory = accessory;
    }
    
    return self;
}

- (void)write:(NSData *)data {
    [_accessory writeData:data];
}

- (void)disconnect {
    [_accessory disconnect];
}

- (void)didConnectAccessory:(QTIAccessory *_Nonnull)accessory {
    [self.delegate didConnect];
}

- (void)didDisconnectAccessory:(QTIAccessory *_Nonnull)accessory {
    [self.delegate didDisconnect];
}

- (void)dataAvailable:(NSData *_Nullable)data {
    [self.delegate dataAvailable:data];
}

- (void)streamError:(NSError *_Nullable)error {
    [self.delegate onError:error];
}

@end
