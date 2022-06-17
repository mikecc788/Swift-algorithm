//
//  DMAboutViewCell.m
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMAboutViewCell.h"

@interface DMAboutViewCell()
@property(nonatomic,strong)UIImageView *arrowImg;
@end
@implementation DMAboutViewCell
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
                make.centerY.equalTo(self.mas_centerY);
            }];
            [_nameL sizeToFit];
        }
        
        if (!_detailL) {
            _detailL  = [[UILabel alloc]init];
            _detailL.textAlignment = NSTextAlignmentRight;
            _detailL.hidden = YES;
            _detailL.font = [UIFont systemFontOfSize:16];
            _detailL.textColor = [UIColor colorWithHexString:@"#DFDFDF"];
            [self.contentView addSubview:_detailL];
            [_detailL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.contentView.mas_right).offset(-59);
                make.centerY.equalTo(self.mas_centerY);
            }];
            [_detailL sizeToFit];
        }
        
        UIImageView *arrow = [[UIImageView alloc]init];
        arrow.image = [UIImage imageNamed:@"arrow"];
        
        self.arrowImg =arrow;
        [self.contentView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-64);
            make.centerY.equalTo(self.nameL.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(7, 10));
        }];
    }
    return self;
}
-(void)setHiddenWithRow:(NSInteger)row andDetail:(nonnull NSString *)detailT{
    if (row == 0) {
        _detailL.hidden = NO;
        _detailL.text = detailT;
        self.arrowImg.hidden = YES;
    }else{
       _detailL.hidden = YES;
        self.arrowImg.hidden = NO;
    }
}

@end
