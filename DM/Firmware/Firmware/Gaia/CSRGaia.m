//
// Copyright 2016 Qualcomm Technologies International, Ltd.
//

#import "GaiaLibrary.h"

@interface CSRGaia ()

@property (nonatomic) CSRPeripheral *connectedPeripheral;

@end

@implementation CSRGaia

@synthesize connectedPeripheral;
@synthesize fileMD5;
@synthesize delegate=_delegate;

+ (CSRGaia *)sharedInstance {
    static dispatch_once_t pred;
    static CSRGaia *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[CSRGaia alloc] init];
    });
    
    return shared;
}

- (void)setDelegate:(id<CSRGaiaDelegate>)delegate {
    if (delegate != nil && delegate != _delegate) {
        NSLog(@"CSRGaia delegate: %@", delegate);
        _delegate = delegate;
    }
}

- (id<CSRGaiaDelegate>)delegate {
    return _delegate;
}

- (void)connectPeripheral:(CSRPeripheral *)peripheral {
    self.connectedPeripheral = peripheral;
    self.service = [[CSRConnectionManager sharedInstance] findService:UUID_GAIA_SERVICE];
    
    if (self.service) {
        self.commandCharacteristic = [[CSRConnectionManager sharedInstance]
                                      findCharacteristic:self.service
                                      characteristic:UUID_GAIA_COMMAND_ENDPOINT];
        self.responseCharacteristic = [[CSRConnectionManager sharedInstance]
                                       findCharacteristic:self.service
                                       characteristic:UUID_GAIA_RESPONSE_ENDPOINT];
        self.dataCharacteristic = [[CSRConnectionManager sharedInstance]
                                   findCharacteristic:self.service
                                   characteristic:UUID_GAIA_DATA_ENDPOINT];
        
        if (self.responseCharacteristic) {
            [[CSRConnectionManager sharedInstance]
             listenFor:UUID_GAIA_SERVICE
             characteristic:UUID_GAIA_RESPONSE_ENDPOINT];
        }
    }
}

- (void)disconnectPeripheral {
    self.connectedPeripheral = nil;
    self.service = nil;
    self.commandCharacteristic = nil;
    self.responseCharacteristic = nil;
    self.dataCharacteristic = nil;
}

#pragma mark public GAIA commands

- (void)handleResponse:(CBCharacteristic *)characteristic {
    if ([characteristic isEqual:self.responseCharacteristic]) {
        [self processIncomingResponse:characteristic.value];
    }
}

- (void)sendGaiaCommand:(CSRGaiaGattCommand *)command {
    NSData *packet = [command getPacket];
    
    DLog(@"Outgoing packet: %@", packet);
    
    [self.connectedPeripheral.peripheral
     writeValue:packet
     forCharacteristic:self.commandCharacteristic
     type:CBCharacteristicWriteWithResponse];
}

- (void)noOperation {
    [self sendCommand:GaiaCommand_NoOperation
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)getApiVersion {
    [self sendCommand:GaiaCommand_GetApplicationVersion
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)getLEDState {
    [self sendCommand:GaiaCommand_GetLEDControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)setLED:(BOOL)enabled {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = 0;
    
    if (enabled) {
        payload_event = 1;
    }
    
    [payload appendBytes:&payload_event length:1];
    [self sendCommand:GaiaCommand_SetLEDControl
                   vendor:CSR_GAIA_VENDOR_ID
                     data:payload];
}

- (void)getBattery {    
    [self sendCommand:GaiaCommand_GetCurrentBatteryLevel
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)setVolume:(NSInteger)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)value;
    
    [payload appendBytes:&payload_event length:1];
    [self sendCommand:GaiaCommand_Volume
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)trimTWSVolume:(NSInteger)device volume:(NSInteger)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t dev = (uint8_t)device;
    uint8_t volume = (uint8_t)value;
    
    [payload appendBytes:&dev length:1];
    [payload appendBytes:&volume length:1];
    [self sendCommand:GaiaCommand_TrimTWSVolume
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)getTWSVolume:(NSInteger)device {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t dev = (uint8_t)device;
    
    [payload appendBytes:&dev length:1];
    [self sendCommand:GaiaCommand_GetTWSVolume
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)setTWSVolume:(NSInteger)device volume:(NSInteger)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t dev = (uint8_t)device;
    uint8_t volume = (uint8_t)value;
    
    [payload appendBytes:&dev length:1];
    [payload appendBytes:&volume length:1];
    [self sendCommand:GaiaCommand_SetTWSVolume
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)getTWSRouting:(NSInteger)device {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t dev = (uint8_t)device;

    [payload appendBytes:&dev length:sizeof(uint8_t)];
    [self sendCommand:GaiaCommand_GetTWSAudioRouting
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)setTWSRouting:(NSInteger)device routing:(NSInteger)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t dev = (uint8_t)device;
    uint8_t routing = (uint8_t)value;
    
    [payload appendBytes:&dev length:1];
    [payload appendBytes:&routing length:1];
    [self sendCommand:GaiaCommand_SetTWSAudioRouting
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)getBassBoost {
    [self sendCommand:GaiaCommand_GetBassBoostControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)setBassBoost:(BOOL)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t boost = (uint8_t)value;
    
    [payload appendBytes:&boost length:1];
    [self sendCommand:GaiaCommand_SetBassBoostControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)get3DEnhancement {
    [self sendCommand:GaiaCommand_Get3DEnhancementControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)set3DEnhancement:(BOOL)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t boost = (uint8_t)value;
    
    [payload appendBytes:&boost length:1];
    [self sendCommand:GaiaCommand_Set3DEnhancementControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)getAudioSource {
    [self sendCommand:GaiaCommand_GetAudioSource
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)findMe:(NSUInteger)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t level = (uint8_t)value;
    
    [payload appendBytes:&level length:1];
    [self sendCommand:GaiaCommand_FindMe
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)setAudioSource:(GaiaAudioSource)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t boost = (uint8_t)value;
    
    [payload appendBytes:&boost length:1];
    [self sendCommand:GaiaCommand_SetAudioSource
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)getEQControl {
    [self sendCommand:GaiaCommand_GetEQControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];    
}

- (void)setEQControl:(NSInteger)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t preset = (uint8_t)value;
    
    [payload appendBytes:&preset length:1];
    [self sendCommand:GaiaCommand_SetEQControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)getUserEQ {
    [self sendCommand:GaiaCommand_GetUserEQControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)setUserEQ:(BOOL)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t user_eq = (uint8_t)value;
    
    [payload appendBytes:&user_eq length:1];
    [self sendCommand:GaiaCommand_SetUserEQControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)getEQParam:(NSData *)data {
    [self sendCommand:GaiaCommand_GetEQParameter
               vendor:CSR_GAIA_VENDOR_ID
                 data:data];
}

- (void)setEQParam:(NSData *)data {
    [self sendCommand:GaiaCommand_SetEQParameter
               vendor:CSR_GAIA_VENDOR_ID
                 data:data];
}

- (void)getGroupEQParam:(NSData *)data {
    [self sendCommand:GaiaCommand_GetEQGroupParameter
               vendor:CSR_GAIA_VENDOR_ID
                 data:data];
}

- (void)setGroupEQParam:(NSData *)data {
    [self sendCommand:GaiaCommand_SetEQGroupParameter
               vendor:CSR_GAIA_VENDOR_ID
                 data:data];
}

- (void)getPower {
    [self sendCommand:GaiaCommand_GetPowerState
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)setPowerOn:(BOOL)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t power = (uint8_t)value;
    
    [payload appendBytes:&power length:1];
    [self sendCommand:GaiaCommand_SetPowerState
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)avControl:(GaiaAVControlOperation)operation {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)operation;
    
    [payload appendBytes:&payload_event length:sizeof(uint8_t)];
    [self sendCommand:GaiaCommand_AVRemoteControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)getDataEndPointMode {
    [self sendCommand:GaiaCommand_GetDataEndPointMode
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)setDataEndPointMode:(BOOL)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t endPointMode = (uint8_t)value;
    
    [payload appendBytes:&endPointMode length:1];
    [self sendCommand:GaiaCommand_SetDataEndPointMode
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)registerNotifications:(GaiaEvent)eventType {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)eventType;
    
    [payload appendBytes:&payload_event length:1];
    [self sendCommand:GaiaCommand_RegisterNotification
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)cancelNotifications:(GaiaEvent)eventType {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)eventType;
    
    [payload appendBytes:&payload_event length:1];
    [self sendCommand:GaiaCommand_CancelNotification
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)vmUpgradeConnect {
    [self sendCommand:GaiaCommand_VMUpgradeConnect
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)vmUpgradeDisconnect {
    [self sendCommand:GaiaCommand_VMUpgradeDisconnect
               vendor:CSR_GAIA_VENDOR_ID
                 data:nil];
}

- (void)abort {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)GaiaUpdate_AbortRequest;
    uint16_t len = 0;
    
    [payload appendBytes:&payload_event length:sizeof(uint8_t)];
    [payload appendBytes:&len length:sizeof(uint16_t)];
    [self sendCommand:GaiaCommand_VMUpgradeControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)vmUpgradeControl:(GaiaCommandUpdate)command {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint16_t len = CFSwapInt16(4);
    uint8_t payload_event = (uint8_t)command;
    NSData *md5 = [self.fileMD5 subdataWithRange:NSMakeRange(12, 4)];
    
    [payload appendBytes:&payload_event length:1];
    [payload appendBytes:&len length:2];
    [payload appendData:md5];
    [self sendCommand:GaiaCommand_VMUpgradeControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)vmUpgradeControlNoData:(GaiaCommandUpdate)command {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)command;
    uint16_t len = 0;
    
    [payload appendBytes:&payload_event length:1];
    [payload appendBytes:&len length:2];
    [self sendCommand:GaiaCommand_VMUpgradeControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (void)vmUpgradeControl:(GaiaCommandUpdate)command
                  length:(NSInteger)length
                    data:(NSData *)data {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)command;
    uint16_t len = CFSwapInt16(length);

    [payload appendBytes:&payload_event length:1];
    [payload appendBytes:&len length:2];
    [payload appendData:data];
    [self sendCommand:GaiaCommand_VMUpgradeControl
               vendor:CSR_GAIA_VENDOR_ID
                 data:payload];
}

- (NSData *)vmUpgradeControlData:(GaiaCommandUpdate)command
                          length:(NSInteger)length
                            data:(NSData *)data {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)command;
    uint16_t len = CFSwapInt16(length);
    
    [payload appendBytes:&payload_event length:1];
    [payload appendBytes:&len length:2];
    [payload appendData:data];
    return [self dataForCommand:GaiaCommand_VMUpgradeControl
                         vendor:CSR_GAIA_VENDOR_ID
                           data:payload];
}

#pragma mark private GAIA commands

- (NSData *)dataForCommand:(GaiaCommandType)command
                    vendor:(uint16_t)vendor_id
                      data:(NSData *)params {
    if (self.commandCharacteristic) {
        CSRGaiaGattCommand *cmd = [[CSRGaiaGattCommand alloc] initWithLength:GAIA_GATT_HEADER_SIZE];
        
        if (cmd) {
            [cmd setCommandId:command];
            [cmd setVendorId:vendor_id];
            
            if (params) {
                [cmd addPayload:params];
            }
            
            return [cmd getPacket];
        }
    }
    
    return nil;
}

- (void)sendCommand:(GaiaCommandType)command
             vendor:(uint16_t)vendor_id
               data:(NSData *)params {
    if (self.commandCharacteristic) {// && self.responseCharacteristic.isNotifying) {
        CSRGaiaGattCommand *cmd = [[CSRGaiaGattCommand alloc] initWithLength:GAIA_GATT_HEADER_SIZE];
        
        if (cmd) {
            [cmd setCommandId:command];
            [cmd setVendorId:vendor_id];
            
            if (params) {
                [cmd addPayload:params];
            }
            
            NSData *packet = [cmd getPacket];
            
            DLog(@"Outgoing packet: %@ command==%d", packet,command);
            
            [self.connectedPeripheral.peripheral
             writeValue:packet
             forCharacteristic:self.commandCharacteristic
             type:CBCharacteristicWriteWithResponse];
        }
    } else {
        NSLog(@"%d%d%@",command,vendor_id,params);
        DLog(@"Rejecting GAIA command, notifications not set up yet.");
    }
}

- (void)sendData:(NSData *)data {
    DLog(@"Outgoing data: %@", data);
    [self.connectedPeripheral.peripheral
     writeValue:data
     forCharacteristic:self.commandCharacteristic
     type:CBCharacteristicWriteWithResponse];
}

- (void)processIncomingResponse:(NSData *)data {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveResponse:)]) {
        CSRGaiaGattCommand *command = [[CSRGaiaGattCommand alloc]
                                       initWithNSData:data];
        
        DLog(@"Incoming packet: %@", data);

        [self.delegate didReceiveResponse:command];
    }
}

@end
