//
//  FriendCommentInputView.m
//  TestFeel
//
//  Created by app on 2022/9/30.
//

#import "FriendCommentInputView.h"
#import <Masonry.h>

@interface FriendCommentInputView()
/// 输入框
@property (nonatomic, strong) UITextField *inputTF;
/// 发送按钮
@property (nonatomic, strong) UIButton *sendButton;
@end

@implementation FriendCommentInputView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self creatView];
    }
    return self;
}
- (void)creatView {
    self.inputTF = [[UITextField alloc] init];
    _inputTF.borderStyle = UITextBorderStyleRoundedRect;
    _inputTF.textAlignment = NSTextAlignmentLeft;
    _inputTF.font = XTAY_FONT_WEIGHT(15, 0);
    _inputTF.textColor = [UIColor blackColor];
    [self addSubview:_inputTF];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setBackgroundColor:XTAY_MAIN_COLOR];
    _sendButton.titleLabel.font = XTAY_FONT_WEIGHT(15, 0);
    [_sendButton addTarget:self action:@selector(sendInputedContent) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendButton];
    
    XTAY_WEAK_SELF
    [self.inputTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(weakSelf).offset(10);
        make.bottom.equalTo(weakSelf).offset(-10);
        make.right.equalTo(weakSelf).offset(-80);
    }];
    
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(10);
        make.bottom.right.equalTo(weakSelf).offset(-10);
        make.width.mas_equalTo(60);
    }];
}
- (void)sendInputedContent {
    if ([self.delegate respondsToSelector:@selector(finishedInputWithSendContent:)]) {
        [self.delegate finishedInputWithSendContent:self.inputTF.text];
    }
}
- (void)setPlaceHolder:(NSString *)placeHolder {
    if (placeHolder) {
        _placeHolder = placeHolder;
        self.inputTF.placeholder = _placeHolder;
    }
}
- (void)beginShowInputView {
    self.inputTF.text = @"";
    self.inputTF.placeholder = _placeHolder;
    [self.inputTF becomeFirstResponder];
}
- (void)beginHiddenInputView {
    [self.inputTF resignFirstResponder];
}
@end
