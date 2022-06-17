//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import "QTIDataProvider.h"
#import "QTIL2CAPChannel.h"

API_AVAILABLE(ios(11), macosx(10.13))
@interface QTIL2CAPDataProvider : QTIDataProvider

@property (nonatomic) QTIL2CAPChannel *channel;

- (id)initWithChannel:(QTIL2CAPChannel *)channel delegate:(nullable id <QTIDataProviderDelegate>)delegate;
- (void)connect;

@end
