//
//  XtayLikeCommentView.m
//  FriendCircleDemo
//
//  Created by admin on 2021/1/18.
//

#import "XtayLikeCommentView.h"
#import "XtayLocationButton.h"
#import <Masonry.h>

@interface XtayLikeCommentView ()

/// bg
@property (nonatomic, strong) UIImageView *bgImageView;
/// dz
@property (nonatomic, strong) XtayLocationButton *dianZanBtn;
/// hf
@property (nonatomic, strong) XtayLocationButton *huiFuBtn;

@end

@implementation XtayLikeCommentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 1.f;
        self.clipsToBounds = YES;
        [self creatView];
    }
    return self;
}

- (void)creatView {
    self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"duihuaqipao"]];
    [self addSubview:_bgImageView];
    
    self.dianZanBtn = [self customButtonNormalTitle:@"点赞" selectedTitle:@"取消" imageName:@"dianzan" selector:@selector(dianZanClick)];
    [self addSubview:_dianZanBtn];
    
    self.huiFuBtn = [self customButtonNormalTitle:@"回复" selectedTitle:@"回复" imageName:@"pinglun" selector:@selector(huiFuBtnClick)];
    [self addSubview:_huiFuBtn];

    XTAY_WEAK_SELF
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [_dianZanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(weakSelf);
        make.left.equalTo(weakSelf.mas_left).offset(5);
    }];
    
    [_huiFuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(weakSelf);
        make.right.equalTo(weakSelf.mas_right).offset(-12);
    }];
}

- (void)dianZanClick {
    if (self.dianZanBtn.selected) {
        if ([self.delegate respondsToSelector:@selector(cancelDianZanClick)]) {
            [self.delegate cancelDianZanClick];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(dianZanClick)]) {
            [self.delegate dianZanClick];
        }
    }
}

- (void)huiFuBtnClick {
    if ([self.delegate respondsToSelector:@selector(huiFuClick)]) {
        [self.delegate huiFuClick];
    }
}

- (void)setHaveDianZaned:(BOOL)haveDianZaned {
    _haveDianZaned = haveDianZaned;
    self.dianZanBtn.selected = _haveDianZaned;
}

- (XtayLocationButton *)customButtonNormalTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle imageName:(NSString *)imageName selector:(SEL)selector {
    XtayLocationButton *button = [XtayLocationButton buttonWithType:UIButtonTypeCustom];
    button.locationBtnType = ButtonType_Image_Left;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:selectedTitle forState:UIControlStateSelected];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    button.titleLabel.font = XTAY_FONT_WEIGHT(13, 0);
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
