//
//  DMFailUpdateView.m
//  Interview
//
//  Created by kiss on 2020/6/18.
//  Copyright © 2020 cl. All rights reserved.
//

#import "DMFailUpdateView.h"

@implementation DMFailUpdateView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *bgImg = [[UIImageView alloc]init];
        bgImg.image = [UIImage imageNamed:@"失败"];
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
        rightL.text = NSLocalizedString(@"升级失败", nil);
        [self addSubview:rightL];
        
        [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bgImg.mas_bottom).offset(20);
            make.centerX.equalTo(self);
        }];
        [rightL sizeToFit];
        
        UILabel *contentL = [[UILabel alloc]init];
        contentL.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
        contentL.font = [UIFont systemFontOfSize:16];
        contentL.numberOfLines = 0;
        contentL.text = NSLocalizedString(@"·與手機保持50cm範圍內\n\n·與手機已配對\n\n·保持開機", nil) ;
        [self addSubview:contentL];
        NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
        [attDic setValue:[UIFont systemFontOfSize:16]forKey:NSFontAttributeName];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:contentL.text attributes:attDic];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4;
        // 设置行之间的间距
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range: NSMakeRange(0, contentL.text.length)];
        CGFloat contentH = [attStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 90-70, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        
        contentL.attributedText = attStr;
        
        [contentL mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.mas_left).offset(90);
        make.right.equalTo(self.mas_right).offset(-70);
         make.top.equalTo(rightL.mas_bottom).offset(15);
            }];
        
        [contentL sizeToFit];
        
        UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        connectBtn.backgroundColor = [UIColor colorFromHexStr:@"#414145"];
        connectBtn.layer.cornerRadius = 20;
        [connectBtn addTarget:self action:@selector(retryClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [connectBtn setTitle:NSLocalizedString(@"重试", nil) forState:(UIControlStateNormal)];
        [connectBtn setTitleColor:[UIColor colorFromHexStr:@"#D0D0D0"] forState:(UIControlStateNormal)];
        connectBtn.layer.masksToBounds = YES;
        [self addSubview:connectBtn];
        [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(contentL.mas_bottom).offset(30);
            make.size.mas_equalTo(CGSizeMake(150, 42));
        }];
        
    }
    return self;
}
-(IBAction)retryClick:(UIButton*)sender{
    if (self.onButtonTouchUpFail) {
        self.onButtonTouchUpFail(self);
    }
}
@end
