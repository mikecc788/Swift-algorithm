//
//  DMCardCollectionCell.m
//  DMSound
//
//  Created by kiss on 2020/6/3.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMCardCollectionCell.h"
#define JGRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define JGRandomColor   JGRGBColor(arc4random_uniform(255),arc4random_uniform(255),arc4random_uniform(255))

@interface DMCardCollectionCell()
@property(nonatomic,strong)UIImageView *earImg;
@end

@implementation DMCardCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
//        self.backgroundColor = JGRandomColor;
        self.layer.cornerRadius = 23;
        self.layer.masksToBounds = YES;
        if (!_bgImg) {
              _bgImg = [[UIImageView alloc]init];
//           _bgImg.image = [UIImage imageNamed:@"device_img"];
              [self addSubview:_bgImg];
          }
                    
        if (!_earImg) {
              _earImg = [[UIImageView alloc]init];
              [self addSubview:_earImg];
          }

        
        _titleL = [[UILabel alloc] initWithFrame:self.bounds];
        _titleL.textColor = [UIColor colorFromHexStr:@"#DFDFDF"];
        _titleL.font = [UIFont systemFontOfSize:20];
        _titleL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleL];
        
        [_bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
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
        
        
    }
    return self;
}
-(void)setTitleName:(NSString *)title earName:(NSString *)earName bgName:(NSString *)bgName{
    _titleL.text = title;
    
    if (bgName.length == 0) {
         _bgImg.backgroundColor = [UIColor colorFromHexStr:@"#292A2F"];
    }else{
        _bgImg.image = [UIImage imageNamed:bgName];
    }
    _earImg.image = [UIImage imageNamed:earName];
}
@end
