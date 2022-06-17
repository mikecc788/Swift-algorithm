//
//  DMEqCollectionViewCell.m
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMEqCollectionViewCell.h"

@interface DMEqCollectionViewCell()
/* imageView */

/* label */


@end

@implementation DMEqCollectionViewCell
#pragma mark - Intial
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpUI];
        
    }
    return self;
}
- (void)setUpUI{
    self.itemBg = [[UIImageView alloc] init];
    self.itemBg.hidden = YES;
    _itemBg.layer.cornerRadius = 4;
    _itemBg.layer.masksToBounds = YES;
    _itemBg.layer.borderWidth = 1;
    _itemBg.layer.borderColor = [UIColor whiteColor].CGColor;
    [self addSubview:_itemBg];
    
    
    
    _gridImageView = [[UIImageView alloc] init];
//    _gridImageView.contentMode = UIViewContentModeScaleAspectFill;
//    _gridImageView.backgroundColor = red_color;
    [self addSubview:_gridImageView];
    
    self.markImg = [[UIImageView alloc] init];
    self.markImg.hidden = YES;
    _markImg.image = [UIImage imageNamed:@"mark_image"];
    [self addSubview:_markImg];
    
    _gridLabel = [[UIButton alloc] init];
    _gridLabel.titleLabel.font = [UIFont systemFontOfSize:14];
    [_gridLabel addTarget:self action:@selector(btnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [_gridLabel setTitleColor:[UIColor colorFromHexStr:@"#E6E6E6"] forState:(UIControlStateNormal)];
    _gridLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_gridLabel];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_gridImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        [make.top.mas_equalTo(self)setOffset:10];
//        make.size.mas_equalTo(CGSizeMake(150, 80));
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
    }];
    
    [_itemBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gridImageView.mas_left).offset(-1);
        make.top.equalTo(self.gridImageView.mas_top).offset(-1);
        make.right.equalTo(self.gridImageView.mas_right).offset(1);
        make.bottom.equalTo(self.gridImageView.mas_bottom).offset(1);
    }];
    
    [_gridLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        [make.bottom.mas_equalTo(_gridImageView.mas_bottom)setOffset:-5];
    }];
    [self.markImg mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.gridImageView.mas_top).offset(-10);
        make.left.equalTo(self.gridImageView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}
-(void)selectItem{
    self.markImg.hidden = NO;
    self.itemBg.hidden = NO;
}
-(void)isCancelSelect{
    self.markImg.hidden = YES;
    self.itemBg.hidden = YES;
}

-(IBAction)btnClick:(UIButton*)sender{
    if ([self.delegate respondsToSelector:@selector(didClickEqTag:cell:)]) {
        [self.delegate didClickEqTag:sender.tag cell:self];
    }
}
@end
