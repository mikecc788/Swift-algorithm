//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>
#import "QTIDataProvider.h"
#import "QTIAccessory.h"

@interface QTIClassicDataProvider : QTIDataProvider

@property (nonatomic) QTIAccessory *accessory;

- (id)initWithAccessory:(QTIAccessory *)accessory delegate:(nullable id <QTIDataProviderDelegate>)delegate;

@end
