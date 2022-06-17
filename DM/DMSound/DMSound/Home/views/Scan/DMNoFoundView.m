//
//  DMNoFoundView.m
//  DMSound
//
//  Created by kiss on 2020/6/9.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMNoFoundView.h"
#define Left_Distance 54

@implementation DMNoFoundView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *img = [[UIImageView alloc]init];
        img.image = [UIImage imageNamed:@"scan_bg"];
        [self addSubview:img];
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(6);
            make.top.equalTo(self.mas_top).offset(0);
            make.right.equalTo(self.mas_right).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(31);
        }];
        
        UILabel *tipL = [[UILabel alloc]init];
        tipL.text =  NSLocalizedString(@"没发现耳机,请确保左右耳机…", nil) ;
        tipL.numberOfLines = 0;
        tipL.textColor = [UIColor colorWithHexString:@"#DFDFDF"];
        tipL.font = [UIFont boldSystemFontOfSize:20];
        [self addSubview:tipL];
        [tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(Left_Distance+10);
            make.top.equalTo(self.mas_top).offset(KScaleHeight(200));
            make.right.equalTo(self.mas_right).offset(-Left_Distance);
        }];
        [tipL sizeToFit];
        CGFloat tipHeight = [self textHeight:tipL.text];
        NSString *content = NSLocalizedString(@"1)保持开机\n2)与手机保持50cm范围内\n3)已配对", nil);
        UILabel *contentL = [[UILabel alloc]init];
        contentL.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
        contentL.font = [UIFont systemFontOfSize:16];
        contentL.numberOfLines = 0;
        contentL.text = content;
        [self addSubview:contentL];
        NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
        [attDic setValue:[UIFont systemFontOfSize:16] forKey:NSFontAttributeName];      // 字体大小
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:contentL.text attributes:attDic];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 8;                                            // 设置行之间的间距
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range: NSMakeRange(0, contentL.text.length)];
        CGFloat contentH = [attStr boundingRectWithSize:CGSizeMake(self.width -Left_Distance * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        contentL.attributedText = attStr;
               
        [contentL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(Left_Distance);
            make.right.equalTo(self.mas_right).offset(-Left_Distance);
             make.top.equalTo(tipL.mas_bottom).offset(30);
//            make.height.mas_equalTo(contentH);
        }];
        
        [contentL sizeToFit];
        
        UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        connectBtn.backgroundColor = [UIColor colorFromHexStr:@"#414145"];
        connectBtn.layer.cornerRadius = 21;
        [connectBtn addTarget:self action:@selector(searchClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [connectBtn setTitle:NSLocalizedString(@"重新搜索", nil) forState:(UIControlStateNormal)];
        [connectBtn setTitleColor:[UIColor colorFromHexStr:@"#D0D0D0"] forState:(UIControlStateNormal)];
        connectBtn.layer.masksToBounds = YES;
        [self addSubview:connectBtn];
        [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self.mas_bottom).offset(-KScaleHeight(160));
            make.size.mas_equalTo(CGSizeMake(150, 42));
        }];
        
        
    }
    return self;
}
-(IBAction)searchClick:(UIButton*)sender{
    if (_reconectBlock) {
        self.reconectBlock();
    }
}
-(CGFloat)textHeight:(NSString *)str{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
//Attribute传和label设定的一样
    NSDictionary * attributes = @{
                                  NSFontAttributeName:[UIFont systemFontOfSize:14.f],
                                  NSParagraphStyleAttributeName: paragraphStyle
                                  };
//这里的size，width传label的宽，高默认都传MAXFLOAT
    CGSize textRect = CGSizeMake(self.width - 250, MAXFLOAT);
    CGFloat textHeight = [str boundingRectWithSize: textRect
                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        attributes:attributes
                                           context:nil].size.height;
    return textHeight;
}
@end
