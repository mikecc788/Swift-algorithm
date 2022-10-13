//
//  FriendCommentInputView.h
//  TestFeel
//
//  Created by app on 2022/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CommentInputContentFinishedProtocol <NSObject>

- (void)finishedInputWithSendContent:(NSString *)content;

@end

@interface FriendCommentInputView : UIView
/// 代理
@property (nonatomic, weak) id <CommentInputContentFinishedProtocol> delegate;

- (void)beginShowInputView;

- (void)beginHiddenInputView;

/// placeHolder
@property (nonatomic, strong) NSString *placeHolder;
@end

NS_ASSUME_NONNULL_END
