//
// Copyright 2016 Qualcomm Technologies International, Ltd.
//

#import "GaiaLibrary.h"
#import <CommonCrypto/CommonDigest.h>

#define GAIA_MAX_LENGTH     12
#define RWCP_MAX_LENGTH     10

@interface CSRGaiaManager () <QTIRWCPDelegate>

@property (nonatomic) NSData *fileData;
@property (nonatomic) BOOL waitingForReconnect;
@property (nonatomic) BOOL disconnected;
@property (nonatomic) CSRPeripheral *connectedPeripheral;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) GaiaUpdateResumePoint resumePoint;
@property (nonatomic) uint16_t lastError;
@property (nonatomic) BOOL restart;
@property (nonatomic) BOOL aborted;
@property (nonatomic) NSMutableArray *dataBuffer;
@property (nonatomic) BOOL syncRequested;
@property (nonatomic) BOOL registeredForNotifications;
@property (nonatomic) BOOL dataEndpointAvailable;
@property (nonatomic) NSUInteger rwcpMaxLength;
@property (nonatomic) NSUInteger gaiaMaxLength;

@property (nonatomic) NSUInteger progress;
@property (nonatomic) NSUInteger transferSize;
@property (nonatomic) NSUInteger startOffset;
@property (nonatomic) NSUInteger bytesToSend;

@end

@implementation CSRGaiaManager

@synthesize aborted;
@synthesize connectedPeripheral;
@synthesize dataBuffer;
@synthesize dataEndpointAvailable;
@synthesize delegate=_delegate;
@synthesize disconnected;
@synthesize fileData;
@synthesize lastError;
@synthesize maximumMessageSize;
@synthesize registeredForNotifications;
@synthesize resumePoint;
@synthesize restart;
@synthesize startTime;
@synthesize syncRequested;
@synthesize updateFileName;
@synthesize updateInProgress;
@synthesize updateProgress;
@synthesize useDLEifAvailable;
@synthesize waitingForReconnect;

+ (CSRGaiaManager *)sharedInstance {
    static dispatch_once_t pred;
    static CSRGaiaManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[CSRGaiaManager alloc] init];
    });
    
    return shared;
}

- (id)init {
    if (self = [super init]) {
        self.syncRequested = NO;
        self.aborted = NO;
        self.fileData = nil;
        _progress = 0;
        _transferSize = 0;
        _startOffset = 0;
        _bytesToSend = 0;
        self.updateFileName = nil;
        self.updateInProgress = NO;
        self.waitingForReconnect = NO;
        self.disconnected = NO;
        self.updateProgress = 0.0;
        self.restart = NO;
        self.connectedPeripheral = nil;
        self.resumePoint = GaiaUpdateResumePoint_Start;
        self.dataBuffer = [NSMutableArray array];
    }
    
    return self;
}

- (void)setDelegate:(id<CSRUpdateManagerDelegate>)delegate {
    if (delegate != nil && delegate != _delegate) {
        NSLog(@"CSRGaiaManager delegate: %@", delegate);
        _delegate = delegate;
    }
}

- (id<CSRUpdateManagerDelegate>)delegate {
    return _delegate;
}

- (void)start:(NSString *)fileName useDataEndpoint:(BOOL)useDataEndpoint {
    self.aborted = NO;
    self.dataEndpointAvailable = useDataEndpoint;
    
    if (!self.updateInProgress) {
        self.updateFileName = fileName;
        self.fileData = [NSData dataWithContentsOfFile:fileName];
        _progress = 0;
        _transferSize = self.fileData.length;
        _startOffset = 0;
        _bytesToSend = 0;
        self.restart = NO;
        self.syncRequested = NO;
        [self.dataBuffer removeAllObjects];
        
        if (!self.fileData) {
            NSString *msg = [NSString stringWithFormat:@"Unable to open: %@", fileName];
            
            [_delegate didAbortWithError:[NSError
                                         errorWithDomain:CSRGaiaError
                                         code:0
                                         userInfo:@{CSRGaiaErrorParam: msg}]];
            
            return;
        } else {
            [CSRGaia sharedInstance].fileMD5 = [self MD5:self.fileData];
        }

        self.connectedPeripheral = [CSRConnectionManager sharedInstance].connectedPeripheral;
        
        if (useDataEndpoint) {
            [[QTIRWCP sharedInstance]
             connectPeripheral:self.connectedPeripheral
             dataCharacteristic:[CSRGaia sharedInstance].dataCharacteristic];
            [QTIRWCP sharedInstance].delegate = self;
            [QTIRWCP sharedInstance].fileSize = self.fileData.length;
            
            // Max size - 13
            if (self.useDLEifAvailable) {
                _rwcpMaxLength = self.maximumMessageSize - 13;

                if (_rwcpMaxLength % 2 == 1) {
                    _rwcpMaxLength -= 1;
                }
            } else {
                _rwcpMaxLength = RWCP_MAX_LENGTH;
            }
        } else {
            // Max size - 11
            if (self.useDLEifAvailable) {
                _gaiaMaxLength = self.maximumMessageSize - 11;

                if (_gaiaMaxLength % 2 == 1) {
                    _gaiaMaxLength -= 1;
                }
            } else {
                _gaiaMaxLength = GAIA_MAX_LENGTH;
            }
        }
        
        [CSRGaia sharedInstance].delegate = self;
        [[CSRConnectionManager sharedInstance] addDelegate:self];
        self.updateInProgress = YES;
    }
    
    DLog(@"GaiaEvent_VMUpgradeProtocolPacket > registerNotifications - start");
    self.registeredForNotifications = NO;
    [[CSRGaia sharedInstance] registerNotifications:GaiaEvent_VMUpgradeProtocolPacket];
}

- (void)connect {
    [CSRGaia sharedInstance].delegate = self;
    [[CSRConnectionManager sharedInstance] addDelegate:self];
    self.connectedPeripheral = [CSRConnectionManager sharedInstance].connectedPeripheral;
}

- (void)disconnect {
    [[CSRConnectionManager sharedInstance] disconnectPeripheral];
    [[CSRGaia sharedInstance] disconnectPeripheral];
    
    self.connectedPeripheral = nil;
}

- (void)abort {
    self.aborted = YES;
    
    [self stop];
    
    if (self.dataEndpointAvailable) {
        // Re-establish RWCP Connection
        [[QTIRWCP sharedInstance] abort];
    }
}

- (void)abortAndRestart {
    self.restart = YES;
    
    [self stop];
}

- (void)stop {
    if (self.updateInProgress) {
        DLog(@"GaiaUpdate_AbortRequest > vmUpgradeControl");
        [self.dataBuffer removeAllObjects];
        [[CSRGaia sharedInstance] abort];
    }
}

- (void)commitConfirm:(BOOL)value {
    [self commitConfirmRequest:value];
}

- (void)eraseSqifConfirm {
    [self eraseSquifConf];
}

- (void)confirmError {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint16_t last_error = CFSwapInt16(self.lastError);
    
    [payload appendBytes:&last_error length:sizeof(uint16_t)];
    
    DLog(@"GaiaUpdate_ErrorWarnResponse");
    
    [[CSRGaia sharedInstance]
     vmUpgradeControl:GaiaUpdate_ErrorWarnResponse
     length:sizeof(uint16_t)
     data:payload];
}

- (void)syncRequest {
    if (!self.syncRequested) {
        self.syncRequested = YES;
        _progress = 0;
        _transferSize = self.fileData.length;
        _startOffset = 0;
        _bytesToSend = 0;
        self.restart = NO;
        self.updateInProgress = YES;
        self.resumePoint = GaiaUpdateResumePoint_Start;
        DLog(@"GaiaCommand_VMUpgradeConnect > GaiaUpdate_SyncRequest");
        [[CSRGaia sharedInstance] vmUpgradeControl:GaiaUpdate_SyncRequest];
    }
}

- (void)sendGaiaCommand:(CSRGaiaGattCommand *)command {
    [[CSRGaia sharedInstance] sendGaiaCommand: command];
}

- (void)getLED {
    [[CSRGaia sharedInstance] getLEDState];
}

- (void)setLED:(BOOL)value {
    [[CSRGaia sharedInstance] setLED:value];
}

- (void)setVolume:(NSInteger)value {
    [[CSRGaia sharedInstance] setVolume:value];
}

- (void)getPower {
    [[CSRGaia sharedInstance] getPower];
}

- (void)setPowerOn:(BOOL)value {
    [[CSRGaia sharedInstance] setPowerOn:value];
}

- (void)getBattery {
    [[CSRGaia sharedInstance] getBattery];
}

- (void)getApiVersion {
    [[CSRGaia sharedInstance] getApiVersion];
}

- (void)avControl:(GaiaAVControlOperation)operation {
    [[CSRGaia sharedInstance] avControl:operation];
}

- (void)trimTWSVolume:(NSInteger)device volume:(NSInteger)value {
    [[CSRGaia sharedInstance] trimTWSVolume:device volume:value];
}

- (void)getTWSVolume:(NSInteger)device {
    [[CSRGaia sharedInstance] getTWSVolume:device];
}

- (void)setTWSVolume:(NSInteger)device volume:(NSInteger)value {
    [[CSRGaia sharedInstance] setTWSVolume:device volume:value];
}

- (void)getTWSRouting:(NSInteger)device {
    [[CSRGaia sharedInstance] getTWSRouting:device];
}

- (void)setTWSRouting:(NSInteger)device routing:(NSInteger)value {
    [[CSRGaia sharedInstance] setTWSRouting:device routing:value];
}

- (void)getBassBoost {
    [[CSRGaia sharedInstance] getBassBoost];
}

- (void)setBassBoost:(BOOL)value {
    [[CSRGaia sharedInstance] setBassBoost:value];
}

- (void)get3DEnhancement {
    [[CSRGaia sharedInstance] get3DEnhancement];
}

- (void)set3DEnhancement:(BOOL)value {
    [[CSRGaia sharedInstance] set3DEnhancement:value];
}

- (void)getAudioSource {
    [[CSRGaia sharedInstance] getAudioSource];
}

- (void)setAudioSource:(GaiaAudioSource)value {
    [[CSRGaia sharedInstance] setAudioSource:value];
}

- (void)findMe:(NSUInteger)value {
    [[CSRGaia sharedInstance] findMe:value];
}

- (void)getEQControl {
    [[CSRGaia sharedInstance] getEQControl];
}

- (void)setEQControl:(NSInteger)value {
    [[CSRGaia sharedInstance] setEQControl:value];
}

- (void)getEQParam:(NSData *)data {
    [[CSRGaia sharedInstance] getEQParam:data];
}

- (void)setEQParam:(NSData *)data {
    [[CSRGaia sharedInstance] setEQParam:data];
}

- (void)getGroupEQParam:(NSData *)data {
    [[CSRGaia sharedInstance] getGroupEQParam:data];
}

- (void)setGroupEQParam:(NSData *)data {
    [[CSRGaia sharedInstance] setGroupEQParam:data];
}

- (void)getUserEQ {
    [[CSRGaia sharedInstance] getUserEQ];
}

- (void)setUserEQ:(BOOL)value {
    [[CSRGaia sharedInstance] setUserEQ:value];
}

- (void)getDataEndPointMode {
    [[CSRGaia sharedInstance] getDataEndPointMode];
}

- (void)setDataEndPointMode:(BOOL)value {
    [[CSRGaia sharedInstance] setDataEndPointMode:value];
}

#pragma mark CSRConnectionManagerDelegate

- (void)discoveredPripheralDetails {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStatus:)]) {
        [self.delegate didUpdateStatus:CSRStatusPairingString];
    }
    
    [CSRGaia sharedInstance].delegate = self;
    [[CSRGaia sharedInstance]
     connectPeripheral:[CSRConnectionManager sharedInstance].connectedPeripheral];
    
    if (self.disconnected) {
        if (self.dataEndpointAvailable) {
            // Re-establish RWCP Connection
            [[QTIRWCP sharedInstance]
             connectPeripheral:self.connectedPeripheral
             dataCharacteristic:[CSRGaia sharedInstance].dataCharacteristic];
            [QTIRWCP sharedInstance].delegate = self;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStatus:)]) {
                [self.delegate didUpdateStatus:CSRStatusReStartingString];
            }
        }

        DLog(@"disconnected-- GaiaEvent_VMUpgradeProtocolPacket > registerNotifications - discoveredPripheralDetails");
        self.registeredForNotifications = NO;
        [[CSRGaia sharedInstance] registerNotifications:GaiaEvent_VMUpgradeProtocolPacket];
        
    }
}

- (void)chracteristicChanged:(CBCharacteristic *)characteristic {
    if (self.waitingForReconnect) {
        self.waitingForReconnect = NO;
        
        if (!self.dataEndpointAvailable) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStatus:)]) {
                [self.delegate didUpdateStatus:CSRStatusFinalisingString];
            }
        }
        
        DLog(@"GaiaEvent_VMUpgradeProtocolPacket > registerNotifications - chracteristicChanged");
        self.registeredForNotifications = NO;
        [[CSRGaia sharedInstance] registerNotifications:GaiaEvent_VMUpgradeProtocolPacket];
    } else {
        [[CSRGaia sharedInstance] handleResponse:characteristic];        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if (error) {
        DLog(@"didWriteValueForCharacteristic Error:%@\n\nThe Phone will now disconnect.", error.localizedDescription);
        [[CSRConnectionManager sharedInstance] disconnectPeripheral];
        
        return;
    }
    
    if (   [characteristic isEqual:[CSRGaia sharedInstance].commandCharacteristic]
        && [self.dataBuffer count] > 0
        && self.disconnected == NO) {
        NSData *data = [self.dataBuffer firstObject];

        [self.dataBuffer removeObjectAtIndex:0];

        _progress += data.length - 8;

        [[CSRGaia sharedInstance] sendData:data];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeProgress:eta:)]) {
            double fs = _transferSize;
            double fi = _progress;
            double prog = (fi / fs) * 100.0;
            NSString *eta = [self calculateEta:fs indexValue:fi];
            
            [self.delegate didMakeProgress:prog eta:eta];
        }
    }
}

- (void)didConnectToPeripheral:(CSRPeripheral *)peripheral {
    if (self.updateInProgress) {
        if (!self.disconnected) {
            DLog(@"GaiaEvent_VMUpgradeProtocolPacket > registerNotifications - didConnectToPeripheral");
            self.registeredForNotifications = NO;
            [[CSRGaia sharedInstance] registerNotifications:GaiaEvent_VMUpgradeProtocolPacket];
        }
        
        // Discover services and characteristics.
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStatus:)]) {
            [self.delegate didUpdateStatus:CSRStatusReconnectedString];
        }
    }
}

- (void)didPowerOff {
    [self didDisconnectFromPeripheral];
}

- (void)didPowerOn {
    [[CSRConnectionManager sharedInstance] connectPeripheral:self.connectedPeripheral];
    [[CSRConnectionManager sharedInstance] stopScan];
}

- (void)didDisconnectFromPeripheral:(CBPeripheral *)peripheral {
    [self didDisconnectFromPeripheral];
}

- (void)didDisconnectFromPeripheral {
    if (self.updateInProgress) {
        self.waitingForReconnect = YES;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStatus:)]) {
            [self.delegate didUpdateStatus:CSRStatusReconnectingString];
        }
        
        self.syncRequested = NO;
        self.disconnected = YES;
        _progress = 0;
        _startOffset = 0;
        _bytesToSend = 0;
        [[CSRConnectionManager sharedInstance] connectPeripheral:self.connectedPeripheral];
        
        if (self.useDLEifAvailable) {
            [[QTIRWCP sharedInstance] powerOff];
        }
    } else {
        if (self.aborted) {
            [self abortUpdate];
            self.aborted = NO;
        } else {
//            [self complete];
            /*自己改的**/
            [self completeError];
            
        }
    }
}

- (void)chracteristicSetNotifySuccess:(CBCharacteristic *)characteristic {
    if ([characteristic isEqual:[CSRGaia sharedInstance].responseCharacteristic]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(gaiaReady)]) {
            [self.delegate gaiaReady];
        }
    }
}

#pragma mark CSRGaiaDelegate

- (void)didReceiveResponse:(CSRGaiaGattCommand *)command {
    GaiaCommandType cmdType = [command getCommandId];
    
    if ([command isControl]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveGaiaGattResponse:)]) {
            [self.delegate didReceiveGaiaGattResponse:command];
        }
    } else {
        if (   self.updateInProgress
            || self.restart
            || cmdType == GaiaCommand_VMUpgradeDisconnect
            || cmdType == GaiaCommand_CancelNotification) {
            if (self.disconnected) {
                if (cmdType == GaiaCommand_RegisterNotification) {
                    self.disconnected = NO;
                    self.startTime = [NSDate timeIntervalSinceReferenceDate];
                    DLog(@"No longer skipping buffered commands");
                } else {
                    DLog(@"Skipping command");
                    return;
                }
            }
            
            switch (cmdType) {
                case GaiaCommand_VMUpgradeConnect:
                    if ([self abortWithError:command] == 0) {
                        if (!self.syncRequested) {
                            DLog(@"GaiaCommand_VMUpgradeConnect > GaiaUpdate_SyncRequest");
                            self.syncRequested = YES;
                            [[CSRGaia sharedInstance] vmUpgradeControl:GaiaUpdate_SyncRequest];
                        }
                    }
                    break;
                case GaiaCommand_VMUpgradeControl:
                    [self abortWithError:command];
                    break;
                case GaiaCommand_EventNotification:
                    if ([command event] == GaiaEvent_VMUpgradeProtocolPacket) { // Read off the update status from the beginning of the payload
                        switch ([command updateStatus]) {
                            case GaiaUpdate_SyncConfirm: // Battery level is also included in the response
                                DLog(@"GaiaUpdate_StartRequest");
                                [self handleSyncConfirm:command];
                                break;
                            case GaiaUpdate_StartConfirm:
                                [self handleStartConfirm:command];
                                break;
                            case GaiaUpdate_DataBytesRequest:
                                if (self.dataEndpointAvailable) {
                                    [self dataBytesRequestRWCP:command];
                                } else {
                                    [self dataBytesReguest:command];
                                }
                                break;
                            case GaiaUpdate_AbortConfirm:
                                if (self.restart) {
                                    self.restart = NO;
                                    
                                    if (!self.registeredForNotifications) {
                                        DLog(@"GaiaEvent_VMUpgradeProtocolPacket > registerNotifications - didReceiveResponse");
                                        [[CSRGaia sharedInstance] registerNotifications:GaiaEvent_VMUpgradeProtocolPacket];
                                    } else {
                                        self.syncRequested = NO;
                                        [self syncRequest];
                                    }
                                } else {
                                    [[CSRGaia sharedInstance] vmUpgradeDisconnect];
                                    NSLog(@"vmUpgradeDisconnect------------");
                                }
                                break;
                            case GaiaUpdate_ErrorWarnIndicator: // Any error will abort the upgrade.
                                [self abortUpgradeWithError:command];
                                break;
                            case GaiaUpdate_ProgressConfirm:
                                [self readProgress:command];
                                break;
                            case GaiaUpdate_IsValidationDoneConfirm:
                                [self validationConfirm:command];
                                break;
                            case GaiaUpdate_TransferCompleteIndicator:
                                if (self.delegate && [self.delegate respondsToSelector:@selector(confirmTransferRequired)]) {
                                    [self.delegate confirmTransferRequired];
                                } else {
                                    [self updateTransferComplete];
                                }
                                break;
                            case GaiaUpdate_InProgressIndicator: // The device says it has rebooted.
                                [self updateComplete];
                                break;
                            case GaiaUpdate_CommitRequest:
                                if (self.delegate && [self.delegate respondsToSelector:@selector(confirmRequired)]) {
                                    [self.delegate confirmRequired];
                                } else {
                                    [self commitConfirmRequest:YES];
                                }
                                break;
                            case GaiaUpdate_HostEraseSquifRequest:
                                // Need to ask a question
                                if (self.delegate && [self.delegate respondsToSelector:@selector(okayRequired)]) {
                                    [self.delegate okayRequired];
                                } else {
                                    [self eraseSquifConf];
                                }
                                break;
                            case GaiaUpdate_CompleteIndicator:
                                DLog(@"GaiaUpdate_CompleteIndicator > vmUpgradeDisconnect");
                                self.updateInProgress = NO;
                                [[CSRGaia sharedInstance] vmUpgradeDisconnect];
                                [self complete];
                                break;
                            default:
                                break;
                        }
                    }
                    break;
                case GaiaCommand_VMUpgradeDisconnect:
                    DLog(@"GaiaCommand_VMUpgradeDisconnect > cancelNotification");
                    [[CSRGaia sharedInstance] cancelNotifications:GaiaEvent_VMUpgradeProtocolPacket];
                    break;
                case GaiaCommand_RegisterNotification:
                    if (!self.registeredForNotifications) {
                        self.registeredForNotifications = YES;
                        DLog(@"GaiaCommand_RegisterNotification > vmUpgradeConnect");
                        [[CSRGaia sharedInstance] vmUpgradeConnect];
                    }
                    break;
                case GaiaCommand_CancelNotification:
                    DLog(@"GaiaCommand_CancelNotification > upgrade complete...");
                    if (self.aborted) {
                        [self abortUpdate];
                        self.aborted = NO;
                    } else {
//                        [self complete];
                    }
                    break;
                default:
                    break;
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveGaiaGattResponse:)]) {
                [self.delegate didReceiveGaiaGattResponse:command];
            }
        }
    }
}

- (void)resetUpdate {
    self.updateFileName = nil;
    self.updateInProgress = NO;
    self.updateProgress = 0.0;
    _progress = 0;
    _transferSize = 0;
    self.fileData = nil;
    [self.dataBuffer removeAllObjects];
}

- (void)dataBytesReguest:(CSRGaiaGattCommand *)command {
    NSData *requestPayload = [command getPayload];
    uint32_t numberOfBytes = 0;
    uint32_t fileOffset = 0;
    
    [requestPayload getBytes:&numberOfBytes range:NSMakeRange(4, 4)];
    [requestPayload getBytes:&fileOffset range:NSMakeRange(8, 4)];
    
    numberOfBytes = CFSwapInt32BigToHost(numberOfBytes);
    fileOffset = CFSwapInt32BigToHost(fileOffset);
    
    DLog(@"Start: %u length: %u filesize: %lu", fileOffset, numberOfBytes, (unsigned long)self.fileData.length);
    
    if (fileOffset + numberOfBytes > self.fileData.length) {
        [self stop];
        [self.delegate didAbortWithError:[NSError
                                          errorWithDomain:CSRGaiaError
                                          code:2
                                          userInfo:@{CSRGaiaErrorParam: CSRGaiaError_2}]];
        return;
    }
    
    uint8_t more_data = (uint8_t)GaiaCommandAction_Continue;
    _bytesToSend = numberOfBytes;
    _startOffset += (fileOffset > 0 && fileOffset + _startOffset < self.fileData.length) ? fileOffset : 0;
    
    NSUInteger remainingLength = self.fileData.length - _startOffset;
    
    _bytesToSend = (_bytesToSend < remainingLength) ? _bytesToSend : remainingLength;

    while (_bytesToSend > 0) {
        NSMutableData *payload = [[NSMutableData alloc] init];
        NSUInteger bytesToSend = _bytesToSend < _gaiaMaxLength - 1 ? _bytesToSend : _gaiaMaxLength - 1;
        Boolean lastPacket = self.fileData.length - _startOffset <= bytesToSend;
        NSRange range = {_startOffset, bytesToSend};
        
        if (lastPacket) {
            more_data = (uint8_t)GaiaCommandAction_Abort; // Sent all the data now
            _bytesToSend = 0;
        } else {
            _startOffset += bytesToSend;
            _bytesToSend -= bytesToSend;
        }
        
        [payload appendBytes:&more_data length:1];
        [payload appendData:[self.fileData subdataWithRange:range]];
        
        [self.dataBuffer addObject:
         [[CSRGaia sharedInstance]
          vmUpgradeControlData:GaiaUpdate_Data
          length:range.length + 1
          data:payload]];
    }

    if ([self.dataBuffer count] > 0) {
        NSData *data = [self.dataBuffer firstObject];
        
        [self.dataBuffer removeObjectAtIndex:0];
        
        [[CSRGaia sharedInstance] sendData:data];
    }
    
    if (more_data == GaiaCommandAction_Abort) {
        if ([self.dataBuffer count] > 0) {
            DLog(@"vmUpgradeControlData:GaiaUpdate_IsValidationDoneRequest");
            [self.dataBuffer addObject:
             [[CSRGaia sharedInstance]
              vmUpgradeControlData:GaiaUpdate_IsValidationDoneRequest
              length:0
              data:nil]];
        } else {
            DLog(@"GaiaUpdate_IsValidationDoneRequest");
            [[CSRGaia sharedInstance] vmUpgradeControl:GaiaUpdate_IsValidationDoneRequest];
        }
    }
}

- (void)didMakeProgress:(double)value {
    
    _progress += value;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeProgress:eta:)]) {
        double fs = _transferSize;
        double fi = _progress;
        NSLog(@"----%f %f normalValue=%f",fs,fi,value);
        double prog = (fi / fs) * 100.0;
        NSString *eta = [self calculateEta:fs indexValue:fi];
        [self.delegate didMakeProgress:prog eta:eta];
    }
}

- (void)dataBytesRequestRWCP:(CSRGaiaGattCommand *)command {
    NSData *requestPayload = [command getPayload];
    uint32_t numberOfBytes = 0;
    uint32_t fileOffset = 0;
    
    [requestPayload getBytes:&numberOfBytes range:NSMakeRange(4, 4)];
    [requestPayload getBytes:&fileOffset range:NSMakeRange(8, 4)];
    
    numberOfBytes = CFSwapInt32BigToHost(numberOfBytes);
    fileOffset = CFSwapInt32BigToHost(fileOffset);
    
    NSLog(@"Start: %u length: %u filesize: %lu", fileOffset, numberOfBytes, (unsigned long)self.fileData.length);

    if (fileOffset + numberOfBytes > self.fileData.length) {
        [self stop];
        [self.delegate didAbortWithError:[NSError
                                          errorWithDomain:CSRGaiaError
                                          code:2
                                          userInfo:@{CSRGaiaErrorParam: CSRGaiaError_2}]];
        return;
    }
    
    if (fileOffset > 0) {
        _progress = fileOffset;
        NSLog(@"fileOffset==%d",fileOffset);
    }
    
    uint8_t more_data = (uint8_t)GaiaCommandAction_Continue;
    _bytesToSend = numberOfBytes;
    _startOffset += (fileOffset > 0 && fileOffset + _startOffset < self.fileData.length) ? fileOffset : 0;
    NSUInteger remainingLength = self.fileData.length - _startOffset;
    
    _bytesToSend = (_bytesToSend < remainingLength) ? _bytesToSend : remainingLength;

    while (_bytesToSend > 0) {
        NSMutableData *payload = [[NSMutableData alloc] init];
        NSUInteger bytesToSend = _bytesToSend < _rwcpMaxLength - 1 ? _bytesToSend : _rwcpMaxLength - 1;
        Boolean lastPacket = self.fileData.length - _startOffset <= bytesToSend;
        NSRange range = {_startOffset, bytesToSend};

        if (lastPacket) {
            more_data = (uint8_t)GaiaCommandAction_Abort; // Sent all the data now
            _bytesToSend = 0;
            [QTIRWCP sharedInstance].lastByteSent = YES;
        } else {
            _startOffset += bytesToSend;
            _bytesToSend -= bytesToSend;
        }

        [payload appendBytes:&more_data length:1];
        [payload appendData:[self.fileData subdataWithRange:range]];

        [[QTIRWCP sharedInstance]
         setPayload:[[CSRGaia sharedInstance]
                     vmUpgradeControlData:GaiaUpdate_Data
                     length:range.length + 1
                     data:payload]];
    }
    
    [[QTIRWCP sharedInstance] startTransfer];
}

- (NSString *)calculateEta:(double)fs indexValue:(double)fi {
    NSString *eta = nil;
    double speed = fi / ([NSDate timeIntervalSinceReferenceDate] - self.startTime);
    double remainingInSeconds = (fs - fi) / speed;
    long long int s = [[NSString stringWithFormat:@"%f", remainingInSeconds] longLongValue];
    
    if (s < 60) {
        eta = [NSString stringWithFormat:@"%lld s", s];
    } else {
        if (s < 3600) {
            eta = [NSString stringWithFormat:@"%lld minutes remaining", s / 60];
        } else {
            long long int moduloS = s % 3600;
            eta = [NSString stringWithFormat:@"%lld h, %lld m remaining", s / 3600, moduloS / 60];
        }
    }
    
    return eta;
}

- (CSRGaiaGattCommand *)createCompleteCommand:(GaiaCommandUpdate)command
                                       length:(NSInteger)length
                                         data:(NSData *)data {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)command;
    uint16_t len = CFSwapInt16(length);
    
    [payload appendBytes:&payload_event length:1];
    [payload appendBytes:&len length:2];
    
    if (data) {
        [payload appendData:data];
    }
    
    CSRGaiaGattCommand *cmd = [[CSRGaiaGattCommand alloc]
                               initWithLength:GAIA_GATT_HEADER_SIZE];
    
    if (cmd) {
        [cmd setCommandId:GaiaCommand_VMUpgradeControl];
        [cmd setVendorId:CSR_GAIA_VENDOR_ID];
        
        if (data) {
            [cmd addPayload:payload];
        }
    }
    
    return cmd;
}

- (NSInteger)abortWithError:(CSRGaiaGattCommand *)command {
    NSData *payload = [command getPayload];
    const unsigned char *data = (const unsigned char *)[payload bytes];
    NSInteger error_code = payload.length == 6 ? data[5] : data[0];
    self.lastError = error_code;
    
    if (error_code > GaiaStatus_Success) {
        NSString *errorMessage = nil;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didAbortWithError:)]) {
            switch (error_code) {
                case GaiaStatus_Success:
                    DLog(@"Success response decoded.");
                    break;
                case GaiaStatus_FailedNotSupported:
                    errorMessage = CSRGaiaCommandError_1;
                    break;
                case GaiaStatus_FailedNotAuthenticated:
                    errorMessage = CSRGaiaCommandError_2;
                    break;
                case GaiaStatus_FailedInsufficientResources:
                    errorMessage = CSRGaiaCommandError_3;
                    break;
                case GaiaStatus_Authenticating:
                    errorMessage = CSRGaiaCommandError_4;
                    break;
                case GaiaStatus_InvalidParameter:
                    errorMessage = CSRGaiaCommandError_5;
                    break;
                case GaiaStatus_IncorrectState:
                    errorMessage = CSRGaiaCommandError_6;
                    break;
                case GaiaStatus_InProgress:
                    errorMessage = CSRGaiaCommandError_7;
                    break;
                case GaiaStatus_NoStatusAvailable:
                    errorMessage = CSRGaiaCommandError_FF;
                    break;
                default:
                    errorMessage = [NSString stringWithFormat:CSRGaiaError_Unknown, (long)error_code];
                    break;
            }
            
            if (errorMessage) {
                DLog(@"Gaia update error: %ld %@", (long)error_code, errorMessage);
                
                [self resetUpdate];
                self.aborted = YES;
                [self.delegate didAbortWithError:[NSError
                                                  errorWithDomain:CSRGaiaError
                                                  code:error_code
                                                  userInfo:@{CSRGaiaErrorParam: errorMessage}]];
            }
        }
    }
    
    return error_code;
}

- (NSInteger)abortUpgradeWithError:(CSRGaiaGattCommand *)command {
    NSData *payload = [command getPayload];
    const unsigned char *data = (const unsigned char *)[payload bytes];
    NSInteger error_code = payload.length == 6 ? data[5] : data[0];
    self.lastError = error_code;
    
    if (error_code > GaiaUpdateResponse_Success) {
        NSString *errorMessage = nil;
        BOOL abortUpdate = YES;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didAbortWithError:)]) {
            switch (error_code) {
                case GaiaUpdateResponse_Success:
                    DLog(@"Success response decoded.");
                    break;
                case GaiaUpdateResponse_ErrorUnknownId:
                    errorMessage = CSRGaiaError_1;
                    break;
                case GaiaUpdateResponse_ErrorBadLength:
                    errorMessage = CSRGaiaError_2;
                    break;
                case GaiaUpdateResponse_ErrorWrongVariant:
                    errorMessage = CSRGaiaError_3;
                    break;
                case GaiaUpdateResponse_ErrorWrongPartitionNumber:
                    errorMessage = CSRGaiaError_4;
                    break;
                case GaiaUpdateResponse_ErrorPartitionSizeMismatch:
                    errorMessage = CSRGaiaError_5;
                    break;
                case GaiaUpdateResponse_ErrorPartitionTypeNotFound:
                    errorMessage = CSRGaiaError_6;
                    break;
                case GaiaUpdateResponse_ErrorPartitionOpenFailed:
                    errorMessage = CSRGaiaError_7;
                    break;
                case GaiaUpdateResponse_ErrorPartitionWriteFailed:
                    errorMessage = CSRGaiaError_8;
                    break;
                case GaiaUpdateResponse_ErrorPartitionCloseFailed:
                    errorMessage = CSRGaiaError_9;
                    break;
                case GaiaUpdateResponse_ErrorSFSValidationFailed:
                    errorMessage = CSRGaiaError_10;
                    break;
                case GaiaUpdateResponse_ErrorOEMValidationFailed:
                    errorMessage = CSRGaiaError_11;
                    break;
                case GaiaUpdateResponse_ErrorUpdateFailed:
                    errorMessage = CSRGaiaError_12;
                    break;
                case GaiaUpdateResponse_ErrorAppNotReady:
                    errorMessage = CSRGaiaError_13;
                    break;
                case GaiaUpdateResponse_WarnAppConfigVersionIncompatible:
                    errorMessage = CSRGaiaError_14;
                    break;
                case GaiaUpdateResponse_ErrorLoaderError:
                    errorMessage = CSRGaiaError_15;
                    break;
                case GaiaUpdateResponse_ErrorUnexpectedLoaderMessage:
                    errorMessage = CSRGaiaError_16;
                    break;
                case GaiaUpdateResponse_ErrorMissingLoaderMessage:
                    errorMessage = CSRGaiaError_17;
                    break;
                case GaiaUpdateResponse_ErrorBatteryLow:
                    errorMessage = CSRGaiaError_18;
                    abortUpdate = NO;
                    break;
                case GaiaUpdateResponse_ErrorInvalidSyncId:
                    errorMessage = CSRGaiaError_22;
                    break;
                case GaiaUpdateResponse_ErrorInErrorState:
                    errorMessage = CSRGaiaError_23;
                    break;
                case GaiaUpdateResponse_ErrorNoMemory:
                    errorMessage = CSRGaiaError_24;
                    break;
                case GaiaUpdateResponse_ErrorBadLengthPartitionParse:
                    errorMessage = CSRGaiaError_30;
                    break;
                case GaiaUpdateResponse_ErrorBadLengthTooShort:
                    errorMessage = CSRGaiaError_31;
                    break;
                case GaiaUpdateResponse_ErrorBadLengthUpgradeHeader:
                    errorMessage = CSRGaiaError_32;
                    break;
                case GaiaUpdateResponse_ErrorBadLengthPartitionHeader:
                    errorMessage = CSRGaiaError_33;
                    break;
                case GaiaUpdateResponse_ErrorBadLengthSignature:
                    errorMessage = CSRGaiaError_34;
                    break;
                case GaiaUpdateResponse_ErrorBadLengthDataHeaderResume:
                    errorMessage = CSRGaiaError_35;
                    break;
                case GaiaUpdateResponse_ErrorOEMValidationFailedHeader:
                    errorMessage = CSRGaiaError_38;
                    break;
                case GaiaUpdateResponse_ErrorOEMValidationFailedUpgradeHeader:
                    errorMessage = CSRGaiaError_39;
                    break;
                case GaiaUpdateResponse_ErrorOEMValidationFailedPartitionHeader:
                    errorMessage = CSRGaiaError_3A;
                    break;
                case GaiaUpdateResponse_ErrorOEMValidationFailedPartitionHeader2:
                    errorMessage = CSRGaiaError_3B;
                    break;
                case GaiaUpdateResponse_ErrorOEMValidationFailedPartitionData:
                    errorMessage = CSRGaiaError_3C;
                    break;
                case GaiaUpdateResponse_ErrorOEMValidationFailedFooter:
                    errorMessage = CSRGaiaError_3D;
                    break;
                case GaiaUpdateResponse_ErrorOEMValidationFailedMemory:
                    errorMessage = CSRGaiaError_3E;
                    break;
                case GaiaUpdateResponse_ErrorPartitionCloseFailed2:
                    errorMessage = CSRGaiaError_40;
                    break;
                case GaiaUpdateResponse_ErrorPartitionCloseFailedHeader:
                    errorMessage = CSRGaiaError_41;
                    break;
                case GaiaUpdateResponse_ErrorPartitionCloseFailedPSSpace:
                    errorMessage = CSRGaiaError_42;
                    break;
                case GaiaUpdateResponse_ErrorPartitionTypeNotMatching:
                    errorMessage = CSRGaiaError_48;
                    break;
                case GaiaUpdateResponse_ErrorPartitionTypeTwoDFU:
                    errorMessage = CSRGaiaError_49;
                    break;
                case GaiaUpdateResponse_ErrorPartitionWriteFailedHeader:
                    errorMessage = CSRGaiaError_50;
                    break;
                case GaiaUpdateResponse_ErrorPartitionWriteFailedData:
                    errorMessage = CSRGaiaError_51;
                    break;
                case GaiaUpdateResponse_ErrorFileTooSmall:
                    errorMessage = CSRGaiaError_58;
                    break;
                case GaiaUpdateResponse_ErrorFileTooBig:
                    errorMessage = CSRGaiaError_59;
                    break;
                case GaiaUpdateResponse_ErrorInternalError1:
                    errorMessage = CSRGaiaError_65;
                    break;
                case GaiaUpdateResponse_ErrorInternalError2:
                    errorMessage = CSRGaiaError_66;
                    break;
                case GaiaUpdateResponse_ErrorInternalError3:
                    errorMessage = CSRGaiaError_67;
                    break;
                case GaiaUpdateResponse_ErrorInternalError4:
                    errorMessage = CSRGaiaError_68;
                    break;
                case GaiaUpdateResponse_ErrorInternalError5:
                    errorMessage = CSRGaiaError_69;
                    break;
                case GaiaUpdateResponse_ErrorInternalError6:
                    errorMessage = CSRGaiaError_6A;
                    break;
                case GaiaUpdateResponse_ErrorInternalError7:
                    errorMessage = CSRGaiaError_6B;
                    break;
                case GaiaUpdateResponse_ForceSync:
                    errorMessage = @"";
                    abortUpdate = NO;
                    break;
                default:
                    errorMessage = [NSString stringWithFormat:CSRGaiaError_Unknown, (long)error_code];
                    break;
            }
            
            if (errorMessage) {
                DLog(@"Gaia update error: %ld %@", (long)error_code, errorMessage);
                
                if (abortUpdate) {
                    [self resetUpdate];
                }
                
                if (error_code == GaiaUpdateResponse_ForceSync) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmForceUpgrade)]) {
                        [self.delegate confirmForceUpgrade];
                    }
                } else if (error_code == GaiaUpdateResponse_ErrorBatteryLow) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmBatteryOkay)]) {
                        [self.delegate confirmBatteryOkay];
                    }
                } else {
                    [self.delegate didAbortWithError:[NSError
                                                      errorWithDomain:CSRGaiaError
                                                      code:error_code
                                                      userInfo:@{CSRGaiaErrorParam: errorMessage}]];
                }
            }
        }
    }
    
    return error_code;
}

- (void)readProgress:(CSRGaiaGattCommand *)command {
    NSData *payload = [command getPayload];
    const unsigned char *data = (const unsigned char *)[payload bytes];
    NSInteger prog = data[1];
    
    self.updateProgress = (double)prog / 100.0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMakeProgress:eta:)]) {
        [self.delegate didMakeProgress:prog eta:@""];
    }
}

- (void)updateTransferComplete {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)GaiaCommandAction_Continue;
    
    [payload appendBytes:&payload_event length:1];
    
    // A warm reboot will follow
    self.connectedPeripheral = [CSRConnectionManager sharedInstance].connectedPeripheral;
    
    DLog(@"GaiaUpdate_TransferCompleteResult");
    
    [[CSRGaia sharedInstance]
     vmUpgradeControl:GaiaUpdate_TransferCompleteResult
     length:1
     data:payload];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didWarmBoot)]) {
        [self.delegate didWarmBoot];
    }
}

- (void)updateTransferAborted {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)GaiaCommandAction_Abort;
    
    [payload appendBytes:&payload_event length:1];
    
    DLog(@"GaiaUpdate_TransferCompleteResult - Abort");
    
    [[CSRGaia sharedInstance]
     vmUpgradeControl:GaiaUpdate_TransferCompleteResult
     length:1
     data:payload];
    
    DLog(@"GaiaUpdate_VMUpgradeControl - Abort");
    [[CSRGaia sharedInstance] abort];
}

- (void)updateComplete {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = (uint8_t)GaiaCommandAction_Continue;
    
    [payload appendBytes:&payload_event length:1];
    
    DLog(@"GaiaUpdate_InProgressResult");
    
    [[CSRGaia sharedInstance]
     vmUpgradeControl:GaiaUpdate_InProgressResult
     length:1
     data:payload];
}

- (void)complete {
    [self resetUpdate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteUpgrade)]) {
        [self.delegate didCompleteUpgrade];
    }
    
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
}

- (void)abortUpdate {
    [self resetUpdate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didAbortUpgrade)]) {
        [self.delegate didAbortUpgrade];
    }
    
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
}
-(void)completeError{
    [self resetUpdate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCompleteError)]) {
        [self.delegate didCompleteError];
    }
    
    [[CSRConnectionManager sharedInstance] removeDelegate:self];
}

- (void)eraseSquifConf {
    DLog(@"GaiaUpdate_HostEraseSquifConfirm");
    
    [[CSRGaia sharedInstance]
     vmUpgradeControlNoData:GaiaUpdate_HostEraseSquifConfirm];
}

- (void)commitConfirmRequest:(BOOL)value {
    NSMutableData *payload = [[NSMutableData alloc] init];
    uint8_t payload_event = value ? (uint8_t)GaiaCommandAction_Continue : (uint8_t)GaiaCommandAction_Abort;
    
    [payload appendBytes:&payload_event length:1];
    
    DLog(@"GaiaUpdate_CommitConfirm");
    
    [[CSRGaia sharedInstance]
     vmUpgradeControl:GaiaUpdate_CommitConfirm
     length:1
     data:payload];
}

- (void)handleStartConfirm:(CSRGaiaGattCommand *)command {
    if (self.resumePoint == GaiaUpdateResumePoint_Start) {
        NSData *requestPayload = [command getPayload];
        uint16_t length = 0;
        uint8_t status = 0;
        uint16_t batt = 0;
        
        [requestPayload getBytes:&length range:NSMakeRange(3, 2)];
        [requestPayload getBytes:&status range:NSMakeRange(4, 1)];
        [requestPayload getBytes:&batt range:NSMakeRange(5, 2)];
        
        if (status != GaiaUpdateResponse_Success) {
            [self abortWithError:command];
            [self resetUpdate];
        } else {
            DLog(@"GaiaUpdate_StartDataRequest");
            self.startTime = [NSDate timeIntervalSinceReferenceDate];
            [[CSRGaia sharedInstance] vmUpgradeControlNoData:GaiaUpdate_StartDataRequest];
        }
    } else {
        switch (self.resumePoint) {
            case GaiaUpdateResumePoint_Start:
                [[CSRGaia sharedInstance] vmUpgradeControlNoData:GaiaUpdate_StartRequest];
                break;
            case GaiaUpdateResumePoint_Validate:
                [[CSRGaia sharedInstance] vmUpgradeControl:GaiaUpdate_IsValidationDoneRequest];
                break;
            case GaiaUpdateResumePoint_Reboot:
                if (self.delegate && [self.delegate respondsToSelector:@selector(confirmTransferRequired)]) {
                    [self.delegate confirmTransferRequired];
                } else {
                    [self updateTransferComplete];
                }
                break;
            case GaiaUpdateResumePoint_PostReboot:
                [self updateComplete];
                break;
            case GaiaUpdateResumePoint_Commit:
                [self commitConfirmRequest:YES];
                break;
            default:
                if (self.delegate && [_delegate respondsToSelector:@selector(didAbortWithError:)]) {
                    NSString *msg = [NSString stringWithFormat:CSRGaiaError_UnknownResponse, (long)self.resumePoint];
                    
                    self.updateInProgress = NO;
                    [self.delegate didAbortWithError:[NSError
                                                      errorWithDomain:CSRGaiaError
                                                      code:0
                                                      userInfo:@{CSRGaiaErrorParam: msg}]];
                }
                break;
        }
    }
}

- (void)handleSyncConfirm:(CSRGaiaGattCommand *)command {
    NSData *requestPayload = [command getPayload];
    uint8_t state = 0;
    
    [requestPayload getBytes:&state range:NSMakeRange(4, 1)];
    
    // TODO: The protocol version number may be sent
    DLog(@"State: %d", state);

    [[CSRGaia sharedInstance] vmUpgradeControlNoData:GaiaUpdate_StartRequest];
    
    self.resumePoint = state;
}

- (void)validationConfirm:(CSRGaiaGattCommand *)command {
    NSData *requestPayload = [command getPayload];
    uint16_t delay = 0;
    
    [requestPayload getBytes:&delay range:NSMakeRange(4, 2)];
    
    delay = CFSwapInt16HostToBig(delay);
    
    if (delay > 0) {
        [NSTimer scheduledTimerWithTimeInterval:delay / 1000
                                         target:self
                                       selector:@selector(validationDone:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)validationDone:(NSTimer *)timer {
    if (!self.aborted) {
        DLog(@"GaiaUpdate_IsValidationDoneRequest");
        [[CSRGaia sharedInstance] vmUpgradeControl:GaiaUpdate_IsValidationDoneRequest];
    }
}

- (NSData *)MD5:(NSData *)data {
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, (CC_LONG)data.length, buffer);
    
    NSMutableData *hv = [[NSMutableData alloc] init];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hv appendBytes:&buffer[i] length:sizeof(uint8_t)];
    }
    
    return hv;
}

- (void)didCompleteDataSend {
    if (!self.aborted) {
        DLog(@"GaiaUpdate_IsValidationDoneRequest");
        [[CSRGaia sharedInstance] vmUpgradeControl:GaiaUpdate_IsValidationDoneRequest];
    }
}

- (void)didAbortWithError:(NSError *)error {
    [self resetUpdate];
    [self.delegate didAbortWithError:error];
}

- (void)didUpdateStatus:(NSString *)value {
    [self.delegate didUpdateStatus:value];
}

@end
