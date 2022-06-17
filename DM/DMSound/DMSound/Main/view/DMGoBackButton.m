//
//  DMGoBackButton.m
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMGoBackButton.h"

@interface DMGoBackButton()

@end

@implementation DMGoBackButton

//-(instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        
//        
//    }
//    return self;
//}
- (void)setMutableTitleWithString:(NSString *)text textFont:(UIFont *)textFont{
    self.backgroundColor = [UIColor clearColor] ;
        
    // 默认 文字和图片的间距是 0
    _space = 0.0f;
    // 默认的内边距为 8
    _delta = 4;

    [self setTitleColor:[UIColor colorWithHexString:@"#E4E4E4"] forState:(UIControlStateNormal)];
    [self setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    //事件
    [self addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize tempSize = [self sizeForNoticeTitle:text font:textFont];
    [self setTitle:text forState:UIControlStateNormal];
    self.titleLabel.font = textFont;
//    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.imageView.center = self.center;
    CGRect self_Rect = self.frame;
    self_Rect.size.width = tempSize.width + _delta*2 + self_Rect.origin.x + self.imageView.image.size.width+15;
//    self_Rect.origin.x -= (tempSize.width - self.frame.size.width)/2;
    self.frame = self_Rect;
//    NSLog(@"frame=%@ %f",NSStringFromCGRect(self_Rect),self.imageView.image.size.width);
}


- (void)setSpace:(CGFloat)space {
    _space = space;
    
}
- (void)setDelta:(CGFloat)delta {
    
    _delta = delta;
}
-(void)clickBtn:(UIButton *)sender{
    
    if ([self.delegate respondsToSelector:@selector(clickBackBtn)]) {
        [self.delegate clickBackBtn];
    }
    if (self.isScanEnter) {
        NSLog(@"isScanEnter");
    }else{
       [(UINavigationController*) [self currentViewController].navigationController popViewControllerAnimated:YES];
    }
    
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {

    CGFloat imageX = _delta;
    CGFloat imageY = (self.height -20)*0.5;

    CGFloat imageH= 20;
    CGFloat imageW = 10;
    return CGRectMake(imageX, imageY, imageW, imageH);
}
- (CGRect)titleRectForContentRect:(CGRect)contentRect {

    CGFloat titleX;
    CGFloat titleY;

    CGFloat titleW;
    CGFloat titleH;

    titleX = _delta + (CGRectGetHeight(contentRect) - _delta * 2) + _space;
    titleY = _delta;

    titleW = CGRectGetWidth(contentRect) - titleX - _delta;
    titleH = CGRectGetHeight(contentRect) - _delta * 2;

    return CGRectMake(titleX, titleY, titleW, titleH);
}
- (CGSize)sizeForNoticeTitle:(NSString*)text font:(UIFont*)font{
    CGSize maxSize = CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX);
    CGSize textSize = CGSizeZero;
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
           // 多行必需使用NSStringDrawingUsesLineFragmentOrigin
           NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
           NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
           [style setLineBreakMode:NSLineBreakByCharWrapping];
           NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
           CGRect rect = [text boundingRectWithSize:maxSize
                                            options:opts
                                         attributes:attributes
                                            context:nil];
           textSize = rect.size;
       } else{
           textSize = [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
       }
       return textSize;
}
-(void)setIsScanEnter:(BOOL)isScanEnter{
    _isScanEnter = isScanEnter;
}
@end
