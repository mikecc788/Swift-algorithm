//
//  CLPhoto.h
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MWPhotoProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface CLPhoto : NSObject<MWPhotoProtocol>
@property (nonatomic, strong) NSString *caption;
+ (CLPhoto *)photoWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
