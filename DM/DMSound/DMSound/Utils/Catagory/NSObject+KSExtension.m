//
//  NSObject+KSExtension.m
//  FastPair
//
//  Created by kiss on 2019/8/13.
//  Copyright © 2019 KSB. All rights reserved.
//

#import "NSObject+KSExtension.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD+Extension.h"
#import "HYRadix.h"
#import <sys/utsname.h>
#import "CLDataConver.h"
@implementation NSObject (KSExtension)


+(BOOL)isBleToothOutput{
    AVAudioSessionRouteDescription *currentRount = [AVAudioSession sharedInstance].currentRoute;
    AVAudioSessionPortDescription *outputPortDesc = currentRount.outputs[0];
    if([outputPortDesc.portType isEqualToString:@"BluetoothA2DPOutput"]){
//        NSLog(@"当前输出的线路是蓝牙输出，并且已连接");
        return YES;
    }else{
        NSLog(@"当前是spearKer输出");
        [MBProgressHUD showAutoMessage:NSLocalizedString(@"请连接耳机在进行操作", nil)  toView:kKeyWindow];
        return NO;
    }
}

+(BOOL)isConnectOutput{
    AVAudioSessionRouteDescription *currentRount = [AVAudioSession sharedInstance].currentRoute;
    AVAudioSessionPortDescription *outputPortDesc = currentRount.outputs[0];
    if([outputPortDesc.portType isEqualToString:@"BluetoothA2DPOutput"]){
//        NSLog(@"当前输出的线路是蓝牙输出，并且已连接");
        return YES;
    }else{
        return NO;
    }
}

-(int)getBaseKey:(NSString*)keyStr{
    NSArray *keyBaseArr = @[Play_pause,Av_Forward,AV_BackWard,Av_VolumeUp,Av_VolumeDown,Start_Siri];
    
    NSString *leftD = [HYRadix hy_convertToDecimalFromHexadecimal:keyStr];
    int x = 0;
     for (NSString *num in keyBaseArr) {
         NSString *str5 = [HYRadix hy_convertToDecimalFromBinary:num];
         int a1 = [leftD intValue] & [str5 intValue];
//         NSLog(@"a1==%d /n temp=%d \n leftD=%d",a1,[str5 intValue],[leftD intValue]);
         if (a1 > 0) {
             x= a1;
         }
     }
      int base = [leftD  intValue] - x;
    
    return base;
}
-(NSString*)getKeyWithStr:(NSString*)str{
    NSString *tempKey;
    int keyInt = 0 ;
    NSArray * keyArr = @[Play_pause,Av_Forward,AV_BackWard,Av_VolumeUp,Av_VolumeDown,Start_Siri];
        NSString *leftD = [HYRadix hy_convertToDecimalFromHexadecimal:str];
            
      for (NSString *num in keyArr) {
          NSString *numStr = [HYRadix hy_convertToDecimalFromBinary:num];
          int temp = [numStr intValue] & [leftD intValue];
      
          if (temp > 0) {
              keyInt = temp;
          }
      }

    tempKey = [CLDataConver toCurrentTemp:keyInt];
    return tempKey;
}
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

+ (BOOL)isBlankString:(NSString *)aStr {
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

// 获取当前时间戳
+(NSString *)getCurrentTimestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970];// *1000 是精确到毫秒(13位),不乘就是精确到秒(10位)
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

/**
 十进制转换十六进制
 
 @param decimal 十进制数
 @return 十六进制数
 */
+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    char *hexChar = ultostr(decimal, 16);
    NSString *hex = [NSString stringWithUTF8String:hexChar];
    return hex;
}
/**
 无符号长整型转C字符串
 
 @param num 无符号长整型
 @param base 进制 2~36
 @return C字符串
 */
char *ultostr(unsigned long num, unsigned base) {
    static char string[64] = {'\0'};
    size_t max_chars = 64;
    char remainder;
    int sign = 0;
    if (base < 2 || base > 36) {
        return NULL;
    }
    for (max_chars --; max_chars > sign && num != 0; max_chars --) {
        remainder = (char)(num % base);
        if ( remainder <= 9 ) {
            string[max_chars] = remainder + '0';
        } else {
            string[max_chars] = remainder - 10 + 'A';
        }
        num /= base;
    }
    if (max_chars > 0) {
        memset(string, '\0', max_chars + 1);
    }
    return string + max_chars + 1;
}
//转换成十六进制
+ (NSString *)to16:(int)num{
    NSString *result = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",num]];
    if ([result length] < 2) {
        result = [NSString stringWithFormat:@"0%@", result];
    }
    return result;
}

+(BOOL)isEmptyDic:(NSDictionary *)aDic{
    if ([aDic isKindOfClass:[NSNull class]] || [aDic isEqual:[NSNull null]] || [aDic allValues].count<=0) {
         return NO;
    }else{
        return YES;
    }
}
+(BOOL)isEmptyArr:(NSMutableArray *)arr{
    if ([self isSimuLator]) {
        return YES;
    }else{
        if ([arr isKindOfClass:[NSNull class]] || arr.count<=0) {
             return NO;
        }else{
            return YES;
        }
    }
    
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
+(NSString*)compareInt:(NSInteger)left right:(NSInteger)right{
    NSString *result = @"";
    if (left < right) {
        if (left < 30 && right < 30) {
            result = @"LeftRight";
        }else{
            result = @"Left";
        }
        
    }else if (left > right){
        if (left < 30 && right < 30) {
            result = @"LeftRight";
        }else{
            result = @"Right";
        }
    }
    return result;
}
@end
