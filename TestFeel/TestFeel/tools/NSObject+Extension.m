//
//  NSObject+Extension.m
//  FeelLife
//
//  Created by app on 2022/3/4.
//

#import "NSObject+Extension.h"
#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>
#import "HYRadix.h"

@implementation NSObject (Extension)



+ (NSString *)iphoneType {
    
    //    需要导入头文件：#import <sys/utsname.h>

    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";//国行、日版、港行
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";//港行、国行
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";//美版、台版
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";//美版、台版
    
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone 8";//国行(A1863)、日行(A1906)
    
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone 8";//美版(Global/A1905)
    
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";//国行(A1864)、日行(A1898)
    
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";//美版(Global/A1897)
    
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhone X";//国行(A1865)、日行(A1902)
    
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhone X";//美版(Global/A1901)
    
    if ([platform isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
    
}

+(BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}
-(BOOL)isSimuLator{
    if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        //模拟器
        return YES;
    }else{
        //真机
        return NO;
    }
}
// 获取当前时间戳
+(NSString *)getCurrentTimestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970];// *1000 是精确到毫秒(13位),不乘就是精确到秒(10位)
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}
+(NSString *)getCurrentTotalVap:(NSString *)str{
    NSString *str1 = [HYRadix hy_convertToDecimalFromHexadecimal:str];
    int a = [str1 intValue];
   
    NSString *target = [NSString stringWithFormat:@"%d:%d%d",a / 1000,a / 100 % 10,a / 10 % 10];
//    NSArray  *array =[str1 componentsSeparatedByString:@""];
//    NSLog(@"个数=%lu arr=%@",(unsigned long)array.count,array);
    return  target;
}

+(NSString *)getCurrentSubVap:(NSString *)str{
    int a = [str intValue];
    NSString *target = [NSString stringWithFormat:@"%d:%d%d",a / 1000,a / 100 % 10,a / 10 % 10];
    return  target;
}
//计算雾化返回值
+(int)getSubNum:(NSString *)first second:(NSString*)second{
    
    return [[HYRadix hy_convertToDecimalFromHexadecimal:first] intValue] -  [[HYRadix hy_convertToDecimalFromHexadecimal:second] intValue];
    
}
+(NSString *)getStateTitle:(NSString *)str{
    NSString *target;
    if ([str isEqualToString:@"01"]) {
        target = @"暂停";
    }else if ([str isEqualToString:@"00"]) {
        target = @"开始";
    }else if ([str isEqualToString:@"02"]) {
        target = @"继续";
    }else if ([str isEqualToString:@"03"]) {
        target = @"开始";
    }
    
    return  target;
}

+(NSString *)deviceType:(NSString *)type{
    NSString *target;
    if ([type isEqualToString:@"AirRight01"]) {
        target = @"Air Right";
    }else if ([type isEqualToString:@"00"]) {
        target = @"A8B呼吸天使";
    }else if ([type isEqualToString:@"02"]) {
        target = @"A15";
    }else if ([type isEqualToString:@"03"]) {
        target = @"Air Fit";
    }else if ([type isEqualToString:@"00"]) {
        target = @"Air Mask D3";
    }else if ([type isEqualToString:@"02"]) {
        target = @"Air pro 4";
    }else if ([type isEqualToString:@"03"]) {
        target = @"Air Fit";
    }else{
        target = @"Air pro 4";
    }
    return  target;
}

+ (NSDictionary*)parseJSONStringToNSDictionary:(NSString*)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:&err];
    if(err){
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
    return responseJSON;

}

// 读取本地JSON文件
+ (NSDictionary *)readLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

+ (NSString*)getActualValue:(NSString *)str{
    NSString *target;
    target = [HYRadix hy_convertToDecimalFromHexadecimal:[NSString stringWithFormat:@"%@",str]];
    float num =  [target floatValue]/100;
//    NSLog(@"num=%.2f",num);
    target = [NSString stringWithFormat:@"%.2f",num];
    return target;
}
+(NSString*)getCurrentTimes{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    [formatter setDateFormat:@"HH:mm YYYY/MM/dd"];

    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring

    NSString *currentTimeString = [formatter stringFromDate:datenow];

//    NSLog(@"currentTimeString =  %@",currentTimeString);

    return currentTimeString;
}
+(NSString*)getCurrentSecondTime:(NSString*)str{
    NSString *target;
    int miu =  [str intValue]/60;
    int sec = [str intValue]%60;
    target = [NSString stringWithFormat:@"%d:%d s",miu,sec];
    return target;
    
}

+(NSString*)getMinuteTime:(NSString*)sec{
    NSString *target;
    
    int a  = [sec intValue] /60;
    int b = [sec intValue] % 60;
    if (b < 10) {
        target = [NSString stringWithFormat:@"%d.0%d",a,b];
    }else{
        target = [NSString stringWithFormat:@"%d.%d",a,b];
    }
    return  target;
}
//时间戳转时间
- (NSString *)timestampToDate:(NSString *)timeStamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

     [formatter setDateStyle:NSDateFormatterMediumStyle];

     [formatter setTimeStyle:NSDateFormatterShortStyle];

     [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // （@"YYYY-MM-dd hh:mm:ss"）
    
    NSString *arg = timeStamp;
    if (![timeStamp isKindOfClass:[NSString class]]) {
        arg = [NSString stringWithFormat:@"%@", timeStamp];
    }
    NSTimeInterval time = [arg doubleValue];
    
    NSDate *confromTimesp =  [NSDate dateWithTimeIntervalSince1970:time];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
}
//// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
//- (NSString *)getDateStringWithTimeStr:(NSString *)str{
//    NSTimeInterval time=[str doubleValue]/1000;//传入的时间戳str如果是精确到毫秒的记得要/1000
//    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
//    //设定时间格式,这里可以设置成自己需要的格式
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SS"];
//    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
//    return currentDateStr;
//}

+(NSString*)getSecondByMinute:(NSString*)min{
    NSString *target;
    
    NSArray *arr = [min componentsSeparatedByString:@"."];
    
  
    
    int a =  [arr.firstObject intValue]*60+ [[arr lastObject] intValue];
    
    target = [NSString stringWithFormat:@"%d",a];
    
    return  target;
}


+ (NSString*)getTempValue:(NSString *)str{
    NSString *target;
    float num =  [str floatValue]/10;
    target = [NSString stringWithFormat:@"%.1f",num];
    return target;
}


@end
