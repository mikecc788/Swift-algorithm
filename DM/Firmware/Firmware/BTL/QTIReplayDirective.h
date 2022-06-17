//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QTIReplayDirectiveType) {
    QTIReplayDirectiveTypeConnect,
    QTIReplayDirectiveTypeDataIn,
    QTIReplayDirectiveTypeDataOut,
    QTIReplayDirectiveTypeDisconnect,
    QTIReplayDirectiveTypeError,
    QTIReplayDirectiveTypeTimeout
};

@interface QTIReplayDirective : NSObject

+ (NSString *)displayName:(QTIReplayDirectiveType)type;
+ (QTIReplayDirectiveType)typeFromString:(NSString *)directive;

@end
