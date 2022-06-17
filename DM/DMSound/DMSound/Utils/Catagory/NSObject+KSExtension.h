//
//  NSObject+KSExtension.h
//  FastPair
//
//  Created by kiss on 2019/8/13.
//  Copyright © 2019 KSB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KSExtension)
+(BOOL)isBleToothOutput;
+(BOOL)isConnectOutput;
-(int)getBaseKey:(NSString*)keyStr;
+ (NSString *)iphoneType;
-(NSString*)getKeyWithStr:(NSString*)str;
+(NSString *)getCurrentTimestamp;
+ (BOOL)isBlankString:(NSString *)aStr;
+ (NSString *)getHexByDecimal:(NSInteger)decimal;
+(NSString *)to16:(int)num;
+ (BOOL)isEmptyDic:(NSDictionary *)aDic;
+(BOOL)isEmptyArr:(NSMutableArray *)arr;
-(BOOL)isSimuLator;
+(NSString*)compareInt:(NSInteger)left right:(NSInteger)right;
@end

NS_ASSUME_NONNULL_END
