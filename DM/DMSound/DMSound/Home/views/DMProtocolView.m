//
//  DMProtocolView.m
//  DMSound
//
//  Created by kiss on 2020/5/28.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMProtocolView.h"

@interface DMProtocolView()
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UITextView *textView;
@property(nonatomic,strong)UIButton *agreeBtn;
@end

@implementation DMProtocolView

-(instancetype)initWithFrame:(CGRect)frame content:(NSString*)content{
    if (self = [super initWithFrame:frame]) {
        UIImageView *topImg = [[UIImageView alloc]init];
        topImg.image = [UIImage imageNamed:@"图层 17"];
        [self addSubview:topImg];
        [topImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(180);
        }];
        
        CGFloat topY = iPhoneX ? 79:59;
        _titleL = [[UILabel alloc] init];
        _titleL.textColor = [UIColor whiteColor];
        _titleL.font = [UIFont systemFontOfSize:24];
        _titleL.textAlignment = 0;
        _titleL.text = NSLocalizedString(@"隱私協議",nil);
        [self addSubview:_titleL];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top).offset(topY);
        }];
        [_titleL sizeToFit];
        if (_textView == nil) {
            _textView = [[UITextView alloc] init];
            _textView.scrollEnabled = YES;
            _textView.showsHorizontalScrollIndicator = NO;
            _textView.showsVerticalScrollIndicator = NO;
            _textView.textColor = [UIColor colorFromHexStr:@"#BDBDBD"];
            _textView.font = [UIFont systemFontOfSize:16];
            _textView.editable = NO;
            _textView.backgroundColor = [UIColor clearColor];
            [self addSubview:_textView];
            
        }
        _textView.text = content;
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.titleL.mas_bottom).offset(20);
            make.bottom.equalTo(self.mas_bottom).offset(-90);
            make.width.mas_equalTo(SCREEN_WIDTH - 27*2);
        }];
        _agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreeBtn setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
        [_agreeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_agreeBtn setTitleColor:[UIColor colorFromHexStr:@"#D0D0D0"] forState:UIControlStateNormal];
        [_agreeBtn setBackgroundImage:[UIImage imageNamed:@"agree_bg"] forState:(UIControlStateNormal)];
        [_agreeBtn addTarget:self action:@selector(dismissAlertView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_agreeBtn];
        [_agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self.mas_bottom).offset(-30);
            make.size.mas_equalTo(CGSizeMake(140, 42));
        }];
    }
    return self;
}
-(IBAction)dismissAlertView:(UIButton*)sender{
    if (self.dismissAlertView) {
        self.dismissAlertView();
    }
}
@end
