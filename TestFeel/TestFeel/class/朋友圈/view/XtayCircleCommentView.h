//
//  XtayCircleRecommendView.h
//  FriendCircleDemo
//
//  Created by admin on 2021/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XtayCommentViewDelegate <NSObject>

/// 选择了回复的人
/// @param index 索引值
- (void)chosedCommentFromIndex:(NSInteger)index;

/// 选择了被回复的人
/// @param index 索引值
- (void)chosedCommentToIndex:(NSInteger)index;

@end

@interface XtayCircleCommentView : UIView

- (void)creatCommentViewWithCommentArr:(NSArray *)commentArr withWidth:(float)width;

/// 代理
@property (nonatomic, weak) id <XtayCommentViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
