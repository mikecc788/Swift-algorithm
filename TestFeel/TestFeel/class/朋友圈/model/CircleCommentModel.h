//
//  CircleCommentModel.h
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CircleCommentModel : NSObject
+(CircleCommentModel *)obtainModelWithCircleDict:(NSDictionary *)circleDic;

/// from
@property (nonatomic, copy) NSString *from;
/// to
@property (nonatomic, copy) NSString *to;
/// cont
@property (nonatomic, copy) NSString *cont;
@end

NS_ASSUME_NONNULL_END
