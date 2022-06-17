//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import "QTIGaiaPeripheral.h"
#import "CSRGaia.h"
#import "QTIRWCPServer.h"

@interface QTIGaiaPeripheral () <QTIRWCPServerDelegate>

@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) CBMutableService *iaService;
@property (nonatomic) CBMutableCharacteristic *commandCharacteristic;
@property (nonatomic) CBMutableCharacteristic *responseCharacteristic;
@property (nonatomic) CBMutableCharacteristic *dataCharacteristic;
@property (nonatomic) BOOL pendingInit;

/* List of subscribed centrals */
@property (nonatomic) NSMutableDictionary *subscribedCentrals;
@property (nonatomic) NSMutableDictionary *rwcpServers;
@property (nonatomic) NSData *failedCommand;

@end

@implementation QTIGaiaPeripheral

@synthesize delegate=_delegate;
@synthesize peripheralManager;
@synthesize iaService;
@synthesize commandCharacteristic;
@synthesize responseCharacteristic;
@synthesize dataCharacteristic;
@synthesize pendingInit;

+ (QTIGaiaPeripheral *)sharedInstance {
    static dispatch_once_t pred;
    static QTIGaiaPeripheral *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[QTIGaiaPeripheral alloc] init];
    });
    
    return shared;
}

- (id)init {
    if (self = [super init]) {
        self.peripheralManager = [[CBPeripheralManager alloc]
                                  initWithDelegate:self
                                  queue:nil];
        self.pendingInit = YES;
        self.subscribedCentrals = [NSMutableDictionary dictionary];
        self.rwcpServers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)setupIAService {
    self.iaService = [[CBMutableService alloc]
                      initWithType:[CBUUID UUIDWithString:UUID_GAIA_SERVICE]
                      primary:YES];    
    self.commandCharacteristic = [[CBMutableCharacteristic alloc]
                                  initWithType:[CBUUID UUIDWithString:UUID_GAIA_COMMAND_ENDPOINT]
                                  properties:CBCharacteristicPropertyWrite
                                  value:nil
                                  permissions:CBAttributePermissionsWriteable];
    self.responseCharacteristic = [[CBMutableCharacteristic alloc]
                                   initWithType:[CBUUID UUIDWithString:UUID_GAIA_RESPONSE_ENDPOINT]
                                   properties:CBCharacteristicPropertyRead |
                                              CBCharacteristicPropertyNotify
                                   value:nil
                                   permissions:CBAttributePermissionsReadable];
    self.dataCharacteristic = [[CBMutableCharacteristic alloc]
                               initWithType:[CBUUID UUIDWithString:UUID_GAIA_DATA_ENDPOINT]
                               properties:CBCharacteristicPropertyWriteWithoutResponse |
                                          CBCharacteristicPropertyWrite |
                                          CBCharacteristicPropertyRead |
                                          CBCharacteristicPropertyNotify
                               value:nil
                               permissions:CBAttributePermissionsWriteable |
                                           CBAttributePermissionsReadable];
    self.iaService.characteristics = @[self.commandCharacteristic,
                                       self.responseCharacteristic,
                                       self.dataCharacteristic];
    
    [self.peripheralManager addService:self.iaService];
}

- (void)stopAdvertising {
    NSLog (@"Advertising Stopped");
    [self.peripheralManager stopAdvertising];
}

- (void)startAdvertising {
    NSLog (@"Request Advertising to Start");
    if (self.peripheralManager && self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self.peripheralManager
         startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey:@[self.iaService.UUID],
                             CBAdvertisementDataLocalNameKey:PERIPHERAL_NAME }];
    }
}

- (BOOL)ready {
    return (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn);
}

#pragma mark CBPeripheralManagers delegate methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheralManager.state) {
        case CBPeripheralManagerStatePoweredOn:
            if (self.pendingInit) {
                NSLog (@"CB Powered ON");
                [self.peripheralManager stopAdvertising];
                [self.peripheralManager removeAllServices];
                [self setupIAService];
                self.pendingInit = NO;
            }
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"Bluetooth is turned off");
            break;
        case CBPeripheralManagerStateResetting:
            NSLog(@"System service resetting");
            break;
        case CBPeripheralManagerStateUnauthorized:
            NSLog(@"We have not been unauthorized with permission");
            break;
        case CBPeripheralManagerStateUnknown:
            NSLog(@"Current state unknown");
            break;
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"The platform doesn't support Bluetooth LE");
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    if (error) {
        NSLog(@"Error publishing service: %@ %@", service.UUID, [error localizedDescription]);
    } else {
        NSLog(@"Added the service %@ to the peripheral with success", service.UUID);
        
        if ([self.iaService isEqual:service]) {
            [self startAdvertising];
        }
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
    if (error) {
        NSLog(@"didStartAdvertisingError=%@", error);
    } else {
        NSLog(@"Advertising Started");
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request {
    if ([request.characteristic isEqual:self.responseCharacteristic]) {
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
    
    NSLog(@"Received read request from %@ for characteristic %@", request.central, request.characteristic);
    NSLog(@"Descriptors: %@", request.characteristic.descriptors);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
  didReceiveWriteRequests:(NSArray *)requests {
    for (CBATTRequest *per in requests) {
        NSLog(@"Write Request %@ value: %@", per.characteristic.UUID, per.characteristic.value);
        
        if ([per.characteristic.UUID.UUIDString isEqualToString:self.dataCharacteristic.UUID.UUIDString]) {
            QTIRWCPServer *server = [self.rwcpServers objectForKey:per.central.identifier.UUIDString];
            
            [server handleMessage:per.value];
        } else if ([per.characteristic.UUID.UUIDString isEqualToString:self.commandCharacteristic.UUID.UUIDString]) {
            [_delegate gaiaCommandReceived:per.value];
        }
        
        [self.peripheralManager respondToRequest:requests.firstObject withResult:CBATTErrorSuccess];
     };
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Central subscribed to characteristic %@", characteristic);

    QTIRWCPServer *server = [self.rwcpServers objectForKey:central.identifier.UUIDString];
    
    if (!server) {
        server = [[QTIRWCPServer alloc] init];
        server.delegate = self;
        server.central = central;
        [self.rwcpServers setObject:server forKey:central.identifier.UUIDString];
    }
    
    [self.subscribedCentrals
     setObject:central
     forKey:central.identifier.UUIDString];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"Central subscribed to characteristic %@", characteristic);
    [self.subscribedCentrals
     removeObjectForKey:central.identifier.UUIDString];
}

#pragma mark Public features
- (void)sendGaiaResponse:(NSData *)data {
    if (![self.peripheralManager
          updateValue:data
          forCharacteristic:self.responseCharacteristic
          onSubscribedCentrals:self.subscribedCentrals.allValues]) {
        NSLog(@"Failed to send response %@", data);
    }    
}

#pragma mark Remote features
- (void)rwcpServerStateChange:(CBCentral *)central state:(QTIRWCPServerState)state {
    // Let the app know about the state change
    NSLog(@"RWCP State change: %ld", (long)state);
}

- (void)rwcpServerSendResponse:(CBCentral *)central sequence:(uint8_t)sequence command:(uint8_t)command {
    if (![self.peripheralManager
          updateValue:[NSData dataWithBytes:&command length:sizeof(command)]
          forCharacteristic:self.dataCharacteristic
          onSubscribedCentrals:nil]) {
        self.failedCommand = [NSData dataWithBytes:&command length:sizeof(command)];
        NSLog(@"Failed to send command %d %d", sequence, command);
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    if (![self.peripheralManager
          updateValue:self.failedCommand
          forCharacteristic:self.dataCharacteristic
          onSubscribedCentrals:nil]) {
        NSLog(@"Double fail to send command");
    }
}

- (void)rwcpDataPacketRecieved:(CBCentral *)central data:(NSData *)data {
    if (_delegate && [_delegate respondsToSelector:@selector(gaiaDataReceived:)]) {
        [_delegate gaiaDataReceived:data];
    }
}

@end
