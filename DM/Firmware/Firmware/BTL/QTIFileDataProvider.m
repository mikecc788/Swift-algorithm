//
// Copyright © 2018 Qualcomm Technologies International, Ltd.
//

#import "QTIFileDataProvider.h"
#import "QTIReplayDirective.h"

#define QTIReplayDefaultErrorDomain  @"com.qualcomm.com"
#define QTIReplayAdvanceTimer        (0.005)

@interface QTIFileDataProvider ()

@property (nonatomic) NSURL *fileName;
@property (nonatomic) NSMutableArray *expectingData;
@property (nonatomic) NSMutableArray *arrivingData;
@property (nonatomic) NSMutableArray *fileContents;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) Boolean waitingForData;

@end

@implementation QTIFileDataProvider

- (id)initWithFileName:(NSURL * _Nonnull)fileName delegate:(nullable id <QTIDataProviderDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        _fileName = fileName;
        _expectingData = [NSMutableArray array];
        _arrivingData = [NSMutableArray array];
        _waitingForData = false;
    }
    
    return self;
}

- (void)enableReplay {
    NSError *error;
    NSString *string = [NSString stringWithContentsOfURL:_fileName
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
    
    if (error) {
        [self.delegate onError:error];
    } else {
        _fileContents = [NSMutableArray array];
        [_fileContents addObjectsFromArray:[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    }

    while (_fileContents.count > 0) {
        if (!_waitingForData) {
            
            if ([self readReplay]) {
                if (_arrivingData.count == 0 && _expectingData.count > 0)
                    _waitingForData = true;
            } else {
                _waitingForData = false;
            }
        }
        
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, QTIReplayAdvanceTimer, false);
    }
}

- (void)write:(NSData *)data {
    [_arrivingData addObject:data];

    _waitingForData = false;

    if (_expectingData.count == 0) {
        return;
    }

    NSString *value = [_expectingData firstObject];
    
    if (value) {
        NSString *match = [self hexStringFromData:data];

        if (![match isEqualToString:[value uppercaseString]]) {
            [self.delegate onError:[NSError errorWithDomain:QTIReplayDefaultErrorDomain
                                                       code:0
                                                   userInfo:@{@"name" : [NSString stringWithFormat:@"Non matching write: %@", value]}]];
        }
    }
    
    [_expectingData removeObjectAtIndex:0];
    [_arrivingData removeObjectAtIndex:0];
}

- (NSString *)nextReplayItem {
    if (_fileContents.count == 0) return nil;
    
    NSString *value = [_fileContents firstObject];
    
    if (value.length < 1) false;

    NSString *directive = [value substringToIndex:1];
    
    if (directive.length > 0) {
        if ([QTIReplayDirective typeFromString:directive] == QTIReplayDirectiveTypeDataOut) {
            return [value substringFromIndex:1];
        }
    }
    
    return nil;
}

- (Boolean)readReplay {
    if (_fileContents.count == 0) return false;
    
    NSString *value = [_fileContents firstObject];
    QTIReplayDirectiveType type = QTIReplayDirectiveTypeError;
    
    [_fileContents removeObjectAtIndex:0];
    
    if (value.length < 1) false;

    NSString *directive = [value substringToIndex:1];
    
    if (directive.length > 0) {
        type = [QTIReplayDirective typeFromString:directive];

        NSString *string = [value substringFromIndex:1];
        
        switch (type) {
            case QTIReplayDirectiveTypeConnect:
                [self.delegate didConnect];
                break;
            case QTIReplayDirectiveTypeDataIn:
                [self.delegate dataAvailable:[self dataFromHexString:string]];
                break;
            case QTIReplayDirectiveTypeDataOut:
                break;
            case QTIReplayDirectiveTypeDisconnect:
                [self.delegate didDisconnect];
                break;
            case QTIReplayDirectiveTypeError: {
                // Convert the string into an error
                NSArray *array = [string componentsSeparatedByString:@":"];
                
                if (array.count == 3) {
                    NSInteger code = ((NSString *)array[1]).intValue;
                    
                    [self.delegate
                     onError:[NSError errorWithDomain:array[0]
                                                 code:code
                                             userInfo:@{@"name":array[2]}]];
                }
                break;
            }
            case QTIReplayDirectiveTypeTimeout: {
                int delay = string.intValue;
                
                sleep(delay);
                break;
            }
        }
    }

    // If response expected then wait
    NSString *response = [self nextReplayItem];
    
    if (response) [_expectingData addObject:response];
    
    if (response && _arrivingData.count > 0) {
        // If I already have data in _arrivingData then check with that and clear the waiting flag
        // This can happen if the delegate responds before the replay instruction has finished.
        NSData *data = [_arrivingData firstObject];
        
        if (value) {
            NSString *match = [self hexStringFromData:data];
            
            if (![match isEqualToString:[response uppercaseString]]) {
                [self.delegate onError:[NSError errorWithDomain:QTIReplayDefaultErrorDomain
                                                           code:0
                                                       userInfo:@{@"name" : [NSString stringWithFormat:@"Non matching write: %@", value]}]];
            }
        }
        
        [_arrivingData removeObjectAtIndex:0];
        [_expectingData removeObjectAtIndex:0];        
        response = nil;
    }
    
    if (response) {
        [self.delegate dataExpected];
    }

    return (response != nil);
}
    
- (NSData *)dataFromHexString:(NSString *)string {
    string = [string lowercaseString];
    
    NSMutableData *data = [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = (int) string.length;
    
    while (i < length - 1) {
        char c = [string characterAtIndex:i++];
        
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    return data;
}
    
- (NSString *)hexStringFromData:(NSData *)data {
    if (data == nil) return nil;
    
    const unsigned char *bytes = [data bytes];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(data.length*2)];
    
    for (int loop = 0; loop < (data.length); loop++) {
        [hexString appendFormat:@"%02X", *bytes];
        bytes++;
    }
    
    return hexString;
}

@end
