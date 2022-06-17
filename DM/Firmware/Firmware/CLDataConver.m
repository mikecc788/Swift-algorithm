//
//  CLDataConver.m
//  FastPair
//
//  Created by kiss on 2020/5/7.
//  Copyright © 2020 KSB. All rights reserved.
//

#import "CLDataConver.h"

@implementation CLDataConver
//将Data类型转为String类型并返回
+(NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}
+(int)toCurrentStr:(NSString*)str{
    if ([str isEqualToString:NSLocalizedString(@"上一曲", nil)]) {
        return 8 ;
    }else if ([str isEqualToString:NSLocalizedString(@"下一曲", nil)]) {
        return 4 ;
    }else if ([str isEqualToString:NSLocalizedString(@"音量+", nil)]) {
        return 16 ;
    }else if ([str isEqualToString:NSLocalizedString(@"音量-", nil)]) {
        return 32 ;
    }else if ([str containsString:NSLocalizedString(@"Siri", nil)]) {
        return 256 ;
    }
    else{
        return 1;
    }
}
+(NSString*)toCurrentTemp:(int)str{
    if (str == 8 ) {
        return  NSLocalizedString(@"上一曲", nil);
    }else if (str == 4) {
        return NSLocalizedString(@"下一曲", nil);
    }else if (str == 16) {
        return NSLocalizedString(@"音量+", nil);
    }else if (str == 32) {
        return NSLocalizedString(@"音量-", nil);
    }else if (str == 256){
        return NSLocalizedString(@"Siri", nil);
    }
    else{
        return NSLocalizedString(@"播放/暂停", nil);
    }
}


-(void)sendData:(Byte)_flag byteType:(Byte) _type byteSubType:(Byte)_subType dataContent:(NSData*)_content {
    if (_content==nil) {
        _content= [[NSData alloc]init];
    }
    NSUInteger size=_content.length;
    Byte byteSize[4] = {};
    byteSize[0] =  (Byte) ((size>>24) & 0xFF);
    byteSize[1] =  (Byte) ((size>>16) & 0xFF);
    byteSize[2] =  (Byte) ((size>>8) & 0xFF);
    byteSize[3] =  (Byte) (size & 0xFF);
    //    byteSize[0] = (Byte) (size & 0xFF);
    //    byteSize[1] =  (Byte) ((size>>8) & 0xFF);
    //    byteSize[2] =  (Byte) ((size>>16) & 0xFF);
    //    byteSize[3] = (Byte) ((size>>24) & 0xFF);
    Byte head[]={_flag,_type,_subType};
    NSMutableData *md=[[NSMutableData alloc] init];
    [md appendBytes:head length:2];
    [md appendBytes:byteSize length:1];
    [md appendData:_content];
}
//将String类型转为Data类型并返回
+(NSData*)dataWithHexstring:(NSString *)hexstring{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for(idx = 0; idx + 2 <= hexstring.length; idx += 2){
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
+(NSString *)to10:(NSString *)num{
    NSString *result = [NSString stringWithFormat:@"%ld", strtoul([num UTF8String],0,16)];
    return result;
}
@end
