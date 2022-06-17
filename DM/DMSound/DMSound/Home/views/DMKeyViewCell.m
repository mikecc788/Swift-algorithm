//
//  DMKeyViewCell.m
//  DMSound
//
//  Created by kiss on 2020/5/28.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMKeyViewCell.h"
#import "DMKeyButton.h"
@interface DMKeyViewCell()
@property(nonatomic,strong)DMKeyButton *tipBtn;
@property (strong, nonatomic) UILabel *titleL;
@end

@implementation DMKeyViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *midV = [[UIView alloc]init];
        midV.backgroundColor = [UIColor colorFromHexStr:@"#242528"];
        midV.layer.cornerRadius = 10;
        midV.layer.masksToBounds = YES;
        [self.contentView addSubview:midV];
        [midV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(33);
            make.right.equalTo(self.contentView.mas_right).offset(-27);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(self.contentView);
        }];
        
        if (!_titleL) {
            _titleL = [[UILabel alloc]init];
            _titleL.textAlignment = NSTextAlignmentLeft;
            _titleL.font = [UIFont systemFontOfSize:16];
            _titleL.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
            [midV addSubview:_titleL];
            }
         if (!self.tipBtn) {
            _tipBtn = [[DMKeyButton alloc]init];
             [_tipBtn setImage:[UIImage imageNamed:@"arrow_up"] forState:(UIControlStateNormal)];
             [_tipBtn addTarget:self action:@selector(btnClick:) forControlEvents:(UIControlEventTouchUpInside)];
             _tipBtn.titleLabel.textAlignment = UIControlContentVerticalAlignmentCenter;
             _tipBtn.titleLabel.font = [UIFont systemFontOfSize:13.3];
             
            [_tipBtn setTitleColor:[UIColor colorWithHexString:@"#DFDFDF"] forState:(UIControlStateNormal)];
            [midV addSubview:_tipBtn];
            }
        CGFloat width = keyPaddingRightWidth + 100 -Key_width;

        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(midV.mas_left).offset(20);
            make.centerY.equalTo(midV.mas_centerY);
        }];
        
        [_titleL sizeToFit];
        
        [_tipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(midV.mas_right).offset(-23);
            make.centerY.equalTo(midV.mas_centerY);
        }];
        [_tipBtn sizeToFit];
    }
    return self;
}
-(void)leftName:(NSString *)name{
    _titleL.text = name;
}
-(IBAction)btnClick:(DMKeyButton*)sender{
    LogMethod();
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidClick:)]) {
        [self.delegate cellDidClick:self];
    }
}
-(void)setKeyName:(NSString *)name{
    [_tipBtn setTitle:name forState:(UIControlStateNormal)];
    [_tipBtn sizeToFit];
}
@end
