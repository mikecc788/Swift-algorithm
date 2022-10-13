//
//  CircleThumbView.h
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ThumbViewDelegate <NSObject>

- (void)chosedResponseIndex:(NSInteger)index;

@end
@interface CircleThumbView : UIView

- (void)creatThumbViewWithThumbArr:(NSArray *)thumbArr;

/// 代理
@property (nonatomic, weak) id <ThumbViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
