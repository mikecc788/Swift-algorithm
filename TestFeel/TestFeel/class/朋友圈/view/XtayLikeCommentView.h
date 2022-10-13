//
//  XtayLikeCommentView.h
//  FriendCircleDemo
//
//  Created by admin on 2021/1/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XtayLikeCommentDelegate <NSObject>

- (void)dianZanClick;

- (void)cancelDianZanClick;

- (void)huiFuClick;

@end

@interface XtayLikeCommentView : UIView

/// 代理
@property (nonatomic, weak) id <XtayLikeCommentDelegate> delegate;

/// 点赞按钮的选中状态
@property (nonatomic, assign) BOOL haveDianZaned;

@end

NS_ASSUME_NONNULL_END
