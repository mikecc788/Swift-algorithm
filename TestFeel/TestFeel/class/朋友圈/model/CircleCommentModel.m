//
//  CircleCommentModel.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "CircleCommentModel.h"

@implementation CircleCommentModel
+ (CircleCommentModel *)obtainModelWithCircleDict:(NSDictionary *)circleDic {
    return [[self alloc] initWithCircleDict:circleDic];
}

- (CircleCommentModel *)initWithCircleDict:(NSDictionary *)circleDic {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:circleDic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}
@end
