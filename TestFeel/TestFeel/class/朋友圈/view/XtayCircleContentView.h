//
//  XtayCircleContentView.h
//  FriendCircleDemo
//
//  Created by admin on 2021/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XtayOpenCloseButtonResDelegate <NSObject>

- (void)openOrCloseBtnCallBackStatus:(BOOL)isOpen;

@end

@interface XtayCircleContentView : UIView

- (void)giveContentString:(NSString *)contentString openCloseBtnSelected:(BOOL)isSelected isShowBtn:(BOOL)isShowBtn;

/// 代理
@property (nonatomic, weak) id <XtayOpenCloseButtonResDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
