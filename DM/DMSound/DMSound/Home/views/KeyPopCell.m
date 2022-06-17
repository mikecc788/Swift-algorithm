//
//  KeyPopCell.m
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "KeyPopCell.h"

@interface KeyPopCell()

@end

@implementation KeyPopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor colorFromHexStr:@"#242529"];
        
        if (!_titleLab) {
            _titleLab = [[UILabel alloc]init];
            _titleLab.textAlignment = NSTextAlignmentLeft;
            _titleLab.font = CHINESE_SYSTEM(15);
            _titleLab.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
            [self.contentView addSubview:_titleLab];
        }
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(70);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(130);
        }];
       
        if (!_selectBtn) {
            _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _selectBtn.hidden = YES;
            [_selectBtn setImage:[UIImage imageNamed:@"select"] forState:(UIControlStateNormal)];
            [self.contentView addSubview:_selectBtn];
        }
        
        [_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.right.equalTo(self.contentView.mas_right).offset(-100);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        
    }
    return self;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(cellDidClick:selectRowStr:)]) {
        [self.delegate cellDidClick:self selectRowStr:self.titleLab.text];
    }
}
@end
