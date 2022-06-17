//
//  ViewController.m
//  OC调用Swift
//
//  Created by kiss on 2020/7/7.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "ViewController.h"
#import "Uint16+Byteorder.swift"


@interface ViewController (){
    UInt16 vendorID;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * str = @"0aa6000000000000000000000000000000000000000000599db5680000260b01";
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = <0aa60000 00000000 00000000 00000000 00000000 00000059 9db56800 00260b01>;
    NSLog(@"%s", data.bytes);
    
    UInt16 result = [self unsignedDataTointWithData:data Location:0 Offset:2];
//    11000001100001
    NSLog(@"result=%d",result);
    int number = result & 0x000f;
    
}

// 转为本地大小端模式 返回Unsigned类型的数据
-(unsigned int)unsignedDataTointWithData:(NSData *)data Location:(NSInteger)location Offset:(NSInteger)offset {
    unsigned int value=0;
    NSData *intdata= [data subdataWithRange:NSMakeRange(location, offset)];
    
    if (offset==2) {
        value=CFSwapInt16BigToHost(*(int*)([intdata bytes]));
    }
    else if (offset==4) {
        value = CFSwapInt32BigToHost(*(int*)([intdata bytes]));
    }
    else if (offset==1) {
        unsigned char *bs = (unsigned char *)[[data subdataWithRange:NSMakeRange(location, 1) ] bytes];
        value = *bs;
    }
    return value;
}
// 转为本地大小端模式 返回Signed类型的数据
-(signed int)signedDataTointWithData:(NSData *)data Location:(NSInteger)location Offset:(NSInteger)offset {
    signed int value=0;
    NSData *intdata= [data subdataWithRange:NSMakeRange(location, offset)];
    if (offset==2) {
        value=CFSwapInt16BigToHost(*(int*)([intdata bytes]));
    }
    else if (offset==4) {
        value = CFSwapInt32BigToHost(*(int*)([intdata bytes]));
    }
    else if (offset==1) {
        signed char *bs = (signed char *)[[data subdataWithRange:NSMakeRange(location, 1) ] bytes];
        value = *bs;
    }
    return value;
}
@end
