//
//  DMDeviceCollectionCell.m
//  DMSound
//
//  Created by kiss on 2020/5/29.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMDeviceCollectionCell.h"

@interface DMDeviceCollectionCell()
@property(nonatomic,strong)UIImageView *earImg;

@end

@implementation DMDeviceCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor  = [UIColor colorFromHexStr:@"#292A2F"];
        self.layer.cornerRadius = 20;
//        self.layer.masksToBounds = YES;
        
        if (!_earImg) {
               _earImg = [[UIImageView alloc]init];
            _earImg.image = [UIImage imageNamed:@"collection_ear"];
               [self addSubview:_earImg];
           }
               
        _titleL = [[UILabel alloc] initWithFrame:self.bounds];
        _titleL.textColor = [UIColor colorFromHexStr:@"#DFDFDF"];
        _titleL.font = [UIFont systemFontOfSize:20];
        _titleL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleL];
        
        
        
        
        [_earImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(50);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(167, 111));
        }];
        
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-50);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        [_titleL sizeToFit];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(-3);
            make.right.equalTo(self.mas_right).offset(3);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(20);
        }];
       
    }
    return self;
}
- (UIButton *)deleteBtn
{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"delete_btn"] forState:(UIControlStateNormal)];
        [_deleteBtn addTarget:self action:@selector(deleteEar:) forControlEvents:(UIControlEventTouchUpInside)];
        _deleteBtn.hidden = YES;
        [self addSubview:_deleteBtn];
//        [self bringSubviewToFront:_deleteBtn];
    }
    return _deleteBtn;
}
-(IBAction)deleteEar:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(didClickDeletePer:)]) {
        [self.delegate didClickDeletePer:self];
    }
}
@end
