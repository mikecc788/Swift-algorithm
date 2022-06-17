//
// Copyright 2017 Qualcomm Technologies International, Ltd.
//
#import <Foundation/Foundation.h>
#import "QTIAccessory.h"

/**
 Delegate methods for QTIAccessories
 Optional methods for handling EASessions
 */
@protocol QTIAccessoryManagerDelegate;

/// @brief Manage accessories and their sessions
@interface QTIAccessoryManager : NSObject

/// @brief Delegates
@property (nonatomic) NSString * _Nullable protocol;

/// @brief Delegates
@property (nonatomic) NSMutableSet * _Nonnull delegates;

/// @brief Current accessories. Contains EAAccessories
@property (nonatomic) NSMutableSet * _Nullable accessories;


/**
 Add a delegate callback method

 @param newDelegate The new object conforming to the delegate
 */
- (void)addDelegate:(nullable id <QTIAccessoryManagerDelegate>)newDelegate;


/**
 Remove a delegate method

 @param newDelegate The new object conforming to the delegate
 */
- (void)removeDelegate:(nullable id <QTIAccessoryManagerDelegate>)newDelegate;

/**
 @brief Find an EAAccessory and create a EASession with
 
 Your app must have an entry in the Info.plist
 "Supported external accessory protocols" > com.qualcomm.ivor

 @param protocol String to find the accessory
 */
- (void)scanAndConnect:(NSString * _Nullable)protocol;

- (void)scan:(NSString * _Nullable)protocol;

/**
 Connect from an accessory, close all the streams
 
 @param connectionId The connection to disconnect from
 */
- (void)connect:(NSUInteger)connectionId;

/**
 Disconnect from an accessory, close all the streams

 @param connectionId The connection to disconnect from
 */
- (void)disconnect:(NSUInteger)connectionId;

- (QTIAccessory *_Nullable)getAccessory:(NSUInteger)accessoryId;

/**
 Write data to an accessory

 @param connectionId The connection to write to
 @param data The data to write
 @return Bytes writen or -1 for write failure
 */
- (int)writeData:(NSUInteger)connectionId data:(NSData *_Nonnull)data;

/*!
 @brief The singleton instance
 @return id - The id of the singleton object.
 */
+ (QTIAccessoryManager *_Nonnull)sharedInstance;

@end

@protocol QTIAccessoryManagerDelegate <NSObject>

@optional

/// @brief An accessory was found maching the protocol
- (void)didFindQTIAccessory:(NSUInteger)connectionId;

/// @brief an new connection with id is available
- (void)didConnectQTIAccessory:(NSUInteger)connectionId;

/// @brief an new connection with id is available
- (void)didDisconnectQTIAccessory:(NSUInteger)connectionId;

/// @brief an new connection with id is available
- (void)dataAvailable:(NSUInteger)connectionId data:(NSData *_Nonnull)data;

@end
