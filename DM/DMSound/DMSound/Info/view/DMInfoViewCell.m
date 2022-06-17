//
//  DMInfoViewCell.m
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMInfoViewCell.h"

@interface DMInfoViewCell()
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UILabel *nameL;

@end

@implementation DMInfoViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_nameL) {
            _nameL  = [[UILabel alloc]init];
            _nameL.textAlignment = NSTextAlignmentLeft;
            _nameL.font = [UIFont systemFontOfSize:16];
            _nameL.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
            [self.contentView addSubview:_nameL];
            [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(45);
                make.centerY.equalTo(self.mas_centerY).offset(10);
            }];
            [_nameL sizeToFit];
        }
        
        if (!_titleL) {
            _titleL = [[UILabel alloc]init];
            _titleL.textAlignment = NSTextAlignmentLeft;
            _titleL.font = [UIFont systemFontOfSize:16];
            _titleL.numberOfLines = 0;
            _titleL.textColor = [UIColor colorWithHexString:@"#DFDFDF"];
            [self.contentView addSubview:_titleL];
        }
        
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(190);
            make.centerY.equalTo(self.nameL);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(200);
        }];
        
        UIImageView *line = [[UIImageView alloc]init];
        line.backgroundColor = [UIColor colorFromHexStr:@"#3A3C41"];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}
-(void)setLeftName:(NSString *)name{
    _nameL.text = name;
}
-(void)setRightName:(NSString *)name{
    _titleL.text= name;
}
@end
