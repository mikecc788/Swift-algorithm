//
//  NSObject+Extension.h
//  FeelLife
//
//  Created by app on 2022/3/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Extension)
+(int)getSubNum:(NSString *)first second:(NSString*)second;

+ (NSString *)iphoneType;
-(BOOL)isSimuLator;
+(BOOL)isBlankString:(NSString *)aStr;
+(NSString *)getCurrentTimestamp;
+(NSString *)getCurrentTotalVap:(NSString*)str;

+(NSString *)getCurrentSubVap:(NSString *)str;
+(NSString *)getStateTitle:(NSString *)str;
+ (NSString *)deviceType:(NSString*)type;
+ (NSDictionary*)parseJSONStringToNSDictionary:(NSString*)JSONString;
+ (NSDictionary *)readLocalFileWithName:(NSString *)name;

+(NSString*)getActualValue:(NSString *)str;
+(NSString*)getCurrentTimes;
+(NSString*)getCurrentSecondTime:(NSString*)str;

+(NSString*)getMinuteTime:(NSString*)sec;
+(NSString*)getSecondByMinute:(NSString*)min;

+ (NSString*)getTempValue:(NSString *)str;
- (NSString *)timestampToDate:(NSString *)timeStamp;
@end

NS_ASSUME_NONNULL_END
