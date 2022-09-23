//
//  ErrorMessage.h
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ErrorMessage : NSObject
@property(nonatomic,assign) NSInteger code;
@property(nonatomic,strong) NSString *errorMessage;
@end

NS_ASSUME_NONNULL_END
