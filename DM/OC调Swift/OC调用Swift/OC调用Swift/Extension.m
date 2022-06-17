//
//  Extension.m
//  OC调用Swift
//
//  Created by kiss on 2020/7/7.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "Extension.h"

@implementation Extension
-(void)initWithData:(NSData*)data offset:(int)offset bigEndian:(BOOL)isBig{
    isBig = YES;
    if (offset + 2 <= data.length) {
        if(isBig) {
//            data[offset] << 8
           
            unsigned char *header = (unsigned char *)[data bytes];
            
//            self = (UInt16(data[offset]) << 8) + UInt16(data[offset + 1])
        } else {
            
        }
    }
}
@end
