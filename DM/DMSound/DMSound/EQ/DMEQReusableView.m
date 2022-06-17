//
//  DMEQReusableView.m
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMEQReusableView.h"
#import "DMGoBackButton.h"
#import "DMKeyButton.h"
@interface DMEQReusableView()

@property (strong, nonatomic) UIImageView *bgImg;
@end

@implementation DMEQReusableView
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpUI];
    }
    return self;
}
-(void)setUpUI{
    
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, 10, 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"音效模式", nil) textFont:[UIFont systemFontOfSize:33.33]];
    [self addSubview:back];
    
    
    if (!_bgImg) {
        _bgImg = [[UIImageView alloc] init];
        _bgImg.image = [UIImage imageNamed:@"组 10"];
        _bgImg.contentMode = UIViewContentModeScaleToFill;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        [_bgImg addGestureRecognizer:tapGesture];
        _bgImg.userInteractionEnabled = YES;
        [self addSubview:_bgImg];
    }

    if (!_headerImg) {
        _headerImg = [[UIImageView alloc] init];
        _headerImg.image = [UIImage imageNamed:@"header_select"];
        if ([DMAppUserSetting shareInstance].selectTag == EQHeaderSelectTag) {//头部选择定为9
            _headerImg.hidden = NO;
        }else{
            _headerImg.hidden = YES;
        }
//        _headerImg.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_headerImg];
    }
    DMKeyButton *custom = [[DMKeyButton alloc]init];
    [custom setTitle:NSLocalizedString(@"自訂", nil)  forState:(UIControlStateNormal)];
    custom.titleLabel.font = [UIFont systemFontOfSize:20];
    [custom setTitleColor:[UIColor colorFromHexStr:@"#E6E6E6"] forState:(UIControlStateNormal)];
    [custom addTarget:self action:@selector(customClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [custom setImage:[UIImage imageNamed:@"arrow"] forState:(UIControlStateNormal)];
    [self addSubview:custom];
    [_bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).offset(-22);
        make.left.equalTo(self.mas_left).offset(22);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
//        make.height.mas_equalTo(71);
    }];
    [_headerImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.bgImg);
    }];
    [custom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bgImg);
//        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [custom sizeToFit];
}
-(IBAction)customClick:(DMKeyButton*)sender{
//    LogMethod();
    if ([self.delegate respondsToSelector:@selector(clickCustomBtn)]) {
        [self.delegate clickCustomBtn];
    }
}
-(void)clickImage{
//    LogMethod();
    if ([self.delegate respondsToSelector:@selector(clickImageBg)]) {
        [self.delegate clickImageBg];
    }
}
@end
