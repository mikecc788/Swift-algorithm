//
//  LFSPopTextView.h
//  TestFeel
//
//  Created by app on 2022/3/30.
//

#import <UIKit/UIKit.h>

typedef void(^ClickBlock)(UIButton * btn);

NS_ASSUME_NONNULL_BEGIN

@interface LFSPopTextView : UIView
//点击背景隐形部分时候隐藏弹框 默认是NO
@property (nonatomic, assign) BOOL clickBackgroundHide;
//用来获取输入框内容
@property (nonatomic, strong, readonly) NSArray * textFieldsArray;
/**
 标题字体大小 默认18
 */
@property (nonatomic, strong) UIFont * titleFont;
/**
 标题字体颜色 默认黑色
 */
@property (nonatomic, strong) UIColor * titleColor;
/**
 title距离下方控件的空隙
 */
@property (nonatomic, assign) CGFloat titleSpace;
/**
 message距离下方控件的空隙
 */
@property (nonatomic, assign) CGFloat messageSpace;
/**
 消息字体大小 默认15
 */
@property (nonatomic, strong) UIFont * messageFont;
/**
 消息字体颜色  默认黑色
 */
@property (nonatomic, strong) UIColor * messageColor;
/**
 按钮字体颜色 默认15
 */
@property (nonatomic, strong) UIFont * buttonFont;
/**
 输入框的颜色 默认15
 */
@property (nonatomic, strong) UIFont * textFieldFont;
/**
 输入框字体颜色 默认黑色
 */
@property (nonatomic, strong) UIColor * textFieldColor;

/**
 分割线的颜色 默认 lightGray
 */
@property (nonatomic, strong) UIColor * lineColor;
#pragma mark - Method
/**
 初始化方法  顶部title 跟描述内容

 @param title 标题
 @param message 描述
 @return self
 */
- (instancetype) initWithTitle:(NSString *)title message:(NSString *)message;

- (void)addCustomTextFieldForPlaceholder:(NSString *)placeholder maxInputCharacter:(int)maxValue text:(NSString *)text secureEntry:(BOOL)secureEntry;
/**
 呈现在window
 */
- (void)showPopView;
- (void)addCustomButton:(NSString *)title buttonTextColor:(UIColor *)color clickBlock:(ClickBlock)block;
@end

NS_ASSUME_NONNULL_END
