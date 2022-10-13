//
//  CLPhoto.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "CLPhoto.h"

@interface CLPhoto()
@property (nonatomic, strong) UIImage *image;
@end

@implementation CLPhoto
+(CLPhoto *)photoWithImage:(UIImage *)image{
    return [[CLPhoto alloc] initWithImage:image];
}

-(instancetype)initWithImage:(UIImage *)image{
    if ((self = [super init])) {
        self.image = image;
        [self setup];
    }
    return self;
}
-(void)setup{
    
}
@end
