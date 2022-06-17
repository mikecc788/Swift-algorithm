//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//

#import "QTIAccessoryManager.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface QTIAccessoryManager () <QTIAccessoryDelegate>

@end

@implementation QTIAccessoryManager

+ (QTIAccessoryManager *)sharedInstance {
    static dispatch_once_t pred;
    static QTIAccessoryManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[QTIAccessoryManager alloc] init];
        
    });
    
    return shared;
}

- (id)init {
    if (self = [super init]) {
        _accessories = [NSMutableSet set];
        _delegates = [NSMutableSet set];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(disconnectedEvent:)
         name:EAAccessoryDidDisconnectNotification
         object:nil];
        
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    }
    
    return self;
}

- (void)addDelegate:(id<QTIAccessoryManagerDelegate>)newDelegate {
    [_delegates addObject:newDelegate];
}

- (void)removeDelegate:(id<QTIAccessoryManagerDelegate>)newDelegate {
    [_delegates removeObject:newDelegate];
}

- (void)scanAndConnect:(NSString *)protocol {
    _protocol = protocol;
    [_accessories removeAllObjects];

    EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];

    [manager registerForLocalNotifications];

    for (EAAccessory *accessory in [manager connectedAccessories]) {
        QTIAccessory *qtiAccessory = [[QTIAccessory alloc]
                                      initWithDelegate:self
                                      accessory:accessory
                                      protocol:protocol];
        [_accessories addObject:qtiAccessory];
        
        [qtiAccessory connect];
    }
}

- (void)scan:(NSString *)protocol {
    _protocol = protocol;
    [_accessories removeAllObjects];
    
    EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];
    
    [manager registerForLocalNotifications];
    
    for (EAAccessory *accessory in [manager connectedAccessories]) {
        QTIAccessory *qtiAccessory = [[QTIAccessory alloc]
                                      initWithDelegate:self
                                      accessory:accessory
                                      protocol:protocol];
        [_accessories addObject:qtiAccessory];
        
        [self.delegates enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didFindQTIAccessory:)]) {
                [obj didFindQTIAccessory:accessory.connectionID];
            }
        }];
    }
}

- (void)connect:(NSUInteger)connectionId {
    QTIAccessory *accessory = [self getAccessory:connectionId];
    
    if (accessory) {
        [accessory connect];
    }
}

- (void)disconnect:(NSUInteger)connectionId {
    QTIAccessory *accessory = [self getAccessory:connectionId];
    
    if (accessory) {
        [_accessories removeObject:accessory];
        [accessory disconnect];
    }
}

- (int)writeData:(NSUInteger)connectionId data:(NSData *)data {
    QTIAccessory *accessory = [self getAccessory:connectionId];
    
    if (accessory) {
        [accessory writeData:data];
    }
    
    return -1;
}

- (QTIAccessory *)getAccessory:(NSUInteger)accessoryId {
    for (QTIAccessory *accessory in _accessories) {
        if (accessory.connectionId == accessoryId) {
            return accessory;
        }
    }
    
    return nil;
}

#pragma mark Private methods
- (void)disconnectedEvent:(NSNotification *)notification {
    if (notification.userInfo) {
        EAAccessory *accessory = [notification.userInfo objectForKey:EAAccessoryKey];
        
        if (accessory) {
            QTIAccessory *qtiAccessory = [self getAccessory:accessory.connectionID];
            
            if (qtiAccessory) {
                NSUInteger accessoryId = qtiAccessory.connectionId;
                
                [_accessories removeObject:qtiAccessory];
                
                [self.delegates enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    if ([obj respondsToSelector:@selector(didDisconnectQTIAccessory:)]) {
                        [obj didDisconnectQTIAccessory:accessoryId];
                    }
                }];
            }
        }
    }
}

#pragma mark QTIAccessoryDelegate methods
- (void)didConnectAccessory:(QTIAccessory *)accessory {
    [self.delegates enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didConnectQTIAccessory:)]) {
            [obj didConnectQTIAccessory:accessory.connectionId];
        }
    }];
}

- (void)didDisconnectAccessory:(QTIAccessory *)accessory {
    NSUInteger accessoryId = accessory.connectionId;
    
    [_accessories removeObject:accessory];
    
    [self.delegates enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didDisconnectQTIAccessory:)]) {
            [obj didDisconnectQTIAccessory:accessoryId];
        }
    }];
}

- (void)dataAvailable:(NSData *)data {
    [self.delegates enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj respondsToSelector:@selector(dataAvailable:)]) {
            [obj dataAvailable:data];
        }
    }];
}

@end
