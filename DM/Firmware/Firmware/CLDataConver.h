//
//  CLDataConver.h
//  FastPair
//
//  Created by kiss on 2020/5/7.
//  Copyright © 2020 KSB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLDataConver : NSObject
+(NSString*)hexadecimalString:(NSData *)data;
+(NSData*)dataWithHexstring:(NSString *)hexstring;
+(int)toCurrentStr:(NSString*)str;
+(NSString*)toCurrentTemp:(int)str;

+(NSString *)to10:(NSString *)num;
@end

NS_ASSUME_NONNULL_END
