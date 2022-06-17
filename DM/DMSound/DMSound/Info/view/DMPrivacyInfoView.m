//
//  DMPrivacyInfoView.m
//  DMSound
//
//  Created by kiss on 2020/6/20.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMPrivacyInfoView.h"

@interface DMPrivacyInfoView()
@property (nonatomic, strong) UITextView *textView;
@end



@implementation DMPrivacyInfoView

-(instancetype)initWithFrame:(CGRect)frame content:(NSString*)content{
    if (self = [super initWithFrame:frame]) {
        UIImageView *topImg = [[UIImageView alloc]init];
        topImg.image = [UIImage imageNamed:@"图层 17"];
        [self addSubview:topImg];
        [topImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(180);
        }];
        
        if (_textView == nil) {
            _textView = [[UITextView alloc] init];
            _textView.scrollEnabled = YES;
            _textView.showsHorizontalScrollIndicator = NO;
            _textView.showsVerticalScrollIndicator = NO;
            _textView.textColor = [UIColor colorFromHexStr:@"#BDBDBD"];
            _textView.font = [UIFont systemFontOfSize:14];
            _textView.editable = NO;
            _textView.backgroundColor = [UIColor clearColor];
            [self addSubview:_textView];
            
        }
        _textView.text = content;
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top).offset(SafeAreaTopHeight);
            make.bottom.equalTo(self.mas_bottom).offset(0);
            make.width.mas_equalTo(SCREEN_WIDTH - 27*2);
        }];
        
    }
    return self;
}

@end
