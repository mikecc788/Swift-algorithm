//
//  XtayCircleContentView.m
//  FriendCircleDemo
//
//  Created by admin on 2021/1/15.
//

#import "XtayCircleContentView.h"
#import "XtayCaculateHeightTool.h"
#import <Masonry.h>

@interface XtayCircleContentView ()

/// contentLabel
@property (nonatomic, strong) UILabel *contentLabel;
/// openBtn
@property (nonatomic, strong) UIButton *openButton;

@end

@implementation XtayCircleContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customContentView];
    }
    return self;
}

- (void)customContentView {
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.textColor = [UIColor blackColor];
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.font = XTAY_FONT_WEIGHT(15, 0);
    self.contentLabel.numberOfLines = 0;
    [self addSubview:_contentLabel];
    
    self.openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_openButton setTitle:@"展开▼" forState:UIControlStateNormal];
    [_openButton setTitle:@"收起▲" forState:UIControlStateSelected];
    [_openButton setBackgroundColor:UIColor.whiteColor];
    [_openButton setTitleColor:XTAY_MAIN_COLOR forState:UIControlStateNormal];
    _openButton.titleLabel.font = XTAY_FONT_WEIGHT(15, 0);
    [_openButton addTarget:self action:@selector(openOrCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_openButton];
}

- (void)openOrCloseClick {
    self.openButton.selected = !self.openButton.selected;
    if ([self.delegate respondsToSelector:@selector(openOrCloseBtnCallBackStatus:)]) {
        [self.delegate openOrCloseBtnCallBackStatus:self.openButton.selected];
    }
}

- (void)giveContentString:(NSString *)contentString openCloseBtnSelected:(BOOL)isSelected isShowBtn:(BOOL)isShowBtn {
    self.contentLabel.text = contentString;
    self.openButton.hidden = !isShowBtn;
    self.openButton.selected = isSelected;
    XTAY_WEAK_SELF
    if (isShowBtn) {
        [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf.mas_bottom).offset(-20);
        }];
        [_openButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(20);
            make.right.bottom.equalTo(weakSelf);
        }];
    } else {
        [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(weakSelf);
            make.bottom.equalTo(weakSelf.mas_bottom).offset(-0);
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
