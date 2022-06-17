//
// Copyright 2016 Qualcomm Technologies International, Ltd.
//

#import "CSRPeripheral.h"

#define STANDARD_LENGTH 23

@implementation CSRPeripheral

- (id)initWithCBPeripheral:(CBPeripheral *)cbPeripheral
         advertisementData:(NSDictionary *)dict
                      rssi:(NSNumber *)rssi {
    if (self = [super init]) {
        _peripheral = cbPeripheral;
        _advertisementData = dict;
        _signalStrength = rssi;
        _isDataLengthExtensionSupported = false;
        _maximumWriteLength = STANDARD_LENGTH;
        _maximumWriteWithoutResponseLength = STANDARD_LENGTH;
    }
    
    return self;
}

- (BOOL)isConnected {
    if (_peripheral) {
        return (_peripheral.state == CBPeripheralStateConnected);
    }
    
    return NO;
}

- (BOOL)checkDLE {
    if (@available(iOS 9, *)) {
        _maximumWriteLength = [_peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
        _maximumWriteWithoutResponseLength = [_peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
        _isDataLengthExtensionSupported = (_maximumWriteLength > STANDARD_LENGTH);
    }
    
    return _isDataLengthExtensionSupported;
}

@end
