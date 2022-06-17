//
//  DMSuccessView.m
//  Interview
//
//  Created by kiss on 2020/6/18.
//  Copyright © 2020 cl. All rights reserved.
//

#import "DMSuccessView.h"

@implementation DMSuccessView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *bgImg = [[UIImageView alloc]init];
        bgImg.image = [UIImage imageNamed:@"成功"];
        [self addSubview:bgImg];
        [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(10);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(51, 51));
        }];
        UILabel *rightL = [[UILabel alloc]init];
        rightL.textAlignment = NSTextAlignmentCenter;
        rightL.textColor = [UIColor colorWithHexString:@"#DFDFDF"];
        rightL.font = [UIFont systemFontOfSize:16];
        rightL.text = NSLocalizedString(@"升级成功", nil);
        [self addSubview:rightL];
        
        [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bgImg.mas_bottom).offset(20);
            make.centerX.equalTo(self);
        }];
        [rightL sizeToFit];
        
        UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        connectBtn.backgroundColor = [UIColor colorFromHexStr:@"#414145"];
        connectBtn.layer.cornerRadius = 20;
        [connectBtn addTarget:self action:@selector(connectClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [connectBtn setTitle:NSLocalizedString(@"完成", nil) forState:(UIControlStateNormal)];
        [connectBtn setTitleColor:[UIColor colorFromHexStr:@"#D0D0D0"] forState:(UIControlStateNormal)];
        connectBtn.layer.masksToBounds = YES;
        [self addSubview:connectBtn];
        [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(rightL.mas_bottom).offset(60);
            make.size.mas_equalTo(CGSizeMake(160, 42));
        }];
    }
    return self;
}
-(IBAction)connectClick:(UIButton*)sender{
    if (self.onButtonTouchUpSuccess) {
        self.onButtonTouchUpSuccess(self);
    }
}
@end
