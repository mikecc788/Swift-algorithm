//
//  DMUpdateAlert.m
//  DMSound
//
//  Created by kiss on 2020/5/26.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMUpdateAlert.h"
#define kWTAlertViewCornerRadius 45*0.5

@interface DMUpdateAlert()
@property(nonatomic,strong)UIView *promptView;
@end
@implementation DMUpdateAlert

-(instancetype)initWithFrame:(CGRect)frame content:(NSString *)content currentV:(int)currentV{
    if (self =[super initWithFrame:frame]) {
        double newCurrent = (double)(currentV  + 10) / 10 ;
        self.backgroundColor = [UIColor blackColor];
        UIView * promptView = [UIView new];
        promptView.layer.cornerRadius = 16;
        promptView.backgroundColor = [UIColor colorFromHexStr:@"#242529"];
        promptView.layer.masksToBounds = YES;
        [self addSubview:promptView];
        self.promptView = promptView;
        [promptView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(42);
            make.right.equalTo(self.mas_right).offset(-37);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(110 + 40*6);
        }];
        

        UILabel *tipL = [[UILabel alloc]init];
        tipL.text = [NSString stringWithFormat:@"%@ V1.%d.%d ",NSLocalizedString(@"最新版本", nil),currentV/10,currentV%10] ;
        tipL.numberOfLines = 0;
        tipL.textColor = [UIColor colorWithHexString:@"#DFDFDF"];
        tipL.font = [UIFont boldSystemFontOfSize:24];
        [promptView addSubview:tipL];
        [tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(promptView.mas_left).offset(20);
            make.top.equalTo(promptView.mas_top).offset(100);
            make.width.mas_equalTo(250);
        }];
        [tipL sizeToFit];
        CGFloat  tipLHeight = [self textHeight:tipL.text];
//        NSLog(@"tipLHeight=%f",[self textHeight:tipL.text]);
        UILabel *updateL= [[UILabel alloc]init];
        updateL.text = NSLocalizedString(@"更新内容:", nil);
        updateL.font = [UIFont systemFontOfSize:13];
        updateL.textAlignment = NSTextAlignmentLeft;
        updateL.textColor =  [UIColor colorFromHexStr:@"#A2A2A2"];
        [promptView addSubview:updateL];
        [updateL sizeToFit];
        [updateL mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(promptView.mas_left).offset(30);
           make.top.equalTo(tipL.mas_bottom).offset(10+5);
        }];
        
        
        UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [updateButton addTarget:self action:@selector(updaleClick:) forControlEvents:UIControlEventTouchUpInside];
        [updateButton setTitle:NSLocalizedString(@"立即更新", nil) forState:UIControlStateNormal];
        updateButton.backgroundColor = [UIColor colorFromHexStr:@"#505154"];
        [updateButton setTitleColor:[UIColor colorFromHexStr:@"#D0D0D0"] forState:UIControlStateNormal];
        [updateButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        updateButton.titleLabel.numberOfLines = 0;
        updateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [updateButton.layer setCornerRadius:kWTAlertViewCornerRadius];
        [promptView addSubview:updateButton];
        
        [updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(promptView.mas_centerX);
            make.bottom.equalTo(promptView.mas_bottom).offset(-40);
            make.size.mas_equalTo(CGSizeMake(150, 45));
        }];
        
        UILabel *contentL = [[UILabel alloc]init];
        contentL.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
        contentL.font = [UIFont systemFontOfSize:13];
        contentL.numberOfLines = 0;
        contentL.text = content;
        [promptView addSubview:contentL];
        
        NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
        [attDic setValue:[UIFont systemFontOfSize:13] forKey:NSFontAttributeName];      // 字体大小
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:contentL.text attributes:attDic];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 8;                                            // 设置行之间的间距
        [attStr addAttribute:NSParagraphStyleAttributeName value:style range: NSMakeRange(0, contentL.text.length)];
        CGFloat contentH = [attStr boundingRectWithSize:CGSizeMake(self.width -42 -37- 20-30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        contentL.attributedText = attStr;
               
        [contentL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(promptView.mas_left).offset(30);
            make.right.equalTo(promptView.mas_right).offset(-20);
             make.top.equalTo(updateL.mas_bottom).offset(5);
        }];
        [contentL sizeToFit];
        
        [promptView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(100 + tipLHeight  +contentH + 160);
        }];
        
    }
    return self;
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

- (void)close{
    CATransform3D currentTransform = self.promptView.layer.transform;
    self.promptView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.promptView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.promptView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

-(IBAction)updaleClick:(UIButton*)sender{
    [self close];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickUpdateNow)]) {
        [self.delegate clickUpdateNow];
    }
}
@end
