//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import "QTIReplayDirective.h"

@implementation QTIReplayDirective

+ (NSString *)displayName:(QTIReplayDirectiveType)type {
    return [[QTIReplayDirective typeDisplayNames] objectForKey:@(type)];
}

+ (NSDictionary *)typeDisplayNames {
    return @{@(QTIReplayDirectiveTypeConnect) : @"O",
             @(QTIReplayDirectiveTypeDataIn) : @"<",
             @(QTIReplayDirectiveTypeDataOut) : @">",
             @(QTIReplayDirectiveTypeDisconnect) : @"X",
             @(QTIReplayDirectiveTypeError) : @"E",
             @(QTIReplayDirectiveTypeTimeout) : @"T"};
}

+ (QTIReplayDirectiveType)typeFromString:(NSString *)directive {
    NSDictionary *types = @{@"O" : @(QTIReplayDirectiveTypeConnect),
                            @"<" : @(QTIReplayDirectiveTypeDataIn),
                            @">" : @(QTIReplayDirectiveTypeDataOut),
                            @"X" : @(QTIReplayDirectiveTypeDisconnect),
                            @"E" : @(QTIReplayDirectiveTypeError),
                            @"T" : @(QTIReplayDirectiveTypeTimeout)};
    NSNumber *value = [types objectForKey:directive];
    
    return (QTIReplayDirectiveType)value.unsignedIntegerValue;
}

@end
