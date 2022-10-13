//
//  CircleDetailInfo.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "CircleDetailInfo.h"

@implementation CircleDetailInfo
+(CircleDetailInfo *)obtainModelWithCircleDict:(NSDictionary *)circleDic{
    return [[self alloc] initWithCircleDict:circleDic];
}
- (CircleDetailInfo *)initWithCircleDict:(NSDictionary *)circleDic {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:circleDic];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
