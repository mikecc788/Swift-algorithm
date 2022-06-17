//
//  DMChoiceDeviceCell.m
//  DMSound
//
//  Created by kiss on 2020/5/29.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMChoiceDeviceCell.h"

@interface DMChoiceDeviceCell()
@property(nonatomic,strong)UIImageView *bgImage;
@property (strong, nonatomic) UILabel *titleLab;
@property(nonatomic,strong)UIImageView *earImage;

@end

@implementation DMChoiceDeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        UIView *bgView = [[UIView alloc]init];
        [self.contentView addSubview:bgView];
        
        if (!_bgImage) {
            _bgImage = [[UIImageView alloc]init];
            [self.contentView addSubview:_bgImage];
        }
        
        if (!_earImage) {
            _earImage = [[UIImageView alloc]init];
            [self.contentView addSubview:_earImage];
        }
        
        if (!_titleLab) {
            _titleLab = [[UILabel alloc]init];
            _titleLab.textAlignment = NSTextAlignmentLeft;
            _titleLab.font = [UIFont systemFontOfSize:16];
            _titleLab.textColor = [UIColor colorWithHexString:@"#BBBBBB"];
            [self.contentView addSubview:_titleLab];
        }
        
        [_titleLab sizeToFit];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.mas_equalTo(self.contentView.mas_left).offset(33);
            make.size.mas_equalTo(CGSizeMake(247, 220));
        }];
        
        [_bgImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(bgView);
        }];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bgView.mas_left).offset(23);
            make.top.mas_equalTo(bgView.mas_top).offset(30);
        }];
        
        [_earImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLab.mas_bottom).offset(30);
            make.left.mas_equalTo(bgView.mas_left).offset(31);
            make.size.mas_equalTo(CGSizeMake(157, 104));
        }];
    }
    return self;
}
-(void)setTitleName:(NSString *)title earName:(NSString *)earName bgName:(NSString *)bgName{
    _titleLab.text = title;
    _bgImage.image = [UIImage imageNamed:bgName];
    _earImage.image = [UIImage imageNamed:earName];
}
@end
