//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import "QTIDataProvider.h"

/**
 O Connect
 < Data In
 > Data Out
 { No data in (no response from device)
 X Disconnect
 E Error [Domain:code:message]
 T Timeout
 */
@interface QTIFileDataProvider : QTIDataProvider

- (id)initWithFileName:(NSURL * _Nonnull)fileName delegate:(nullable id <QTIDataProviderDelegate>)delegate;
- (void)enableReplay;

@end
