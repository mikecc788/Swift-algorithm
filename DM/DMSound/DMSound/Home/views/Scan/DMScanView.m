//
//  DMScanView.m
//  DMSound
//
//  Created by kiss on 2020/6/9.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMScanView.h"

@interface DMScanView()<CAAnimationDelegate>

@end

@implementation DMScanView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
         UIImageView *img = [[UIImageView alloc]init];
        img.image = [UIImage imageNamed:@"scan_img"];
        [self addSubview:img];
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        UIImageView *midImg = [[UIImageView alloc]init];
        midImg.image = [UIImage imageNamed:@"logo"];
        [self addSubview:midImg];
        [midImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(53, 48));
        }];
        
        
        CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        animation.fromValue = [NSNumber numberWithFloat:0.f];
        animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
        animation.duration  = 2;
        animation.autoreverses = NO;
        animation.delegate = self;
        animation.fillMode =kCAFillModeForwards;
    //    animation.repeatCount = 2; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
        [img.layer addAnimation:animation forKey:nil];
    }
    return self;
}
- (void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"开始了");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    //方法中的flag参数表明了动画是自然结束还是被打断,比如调用了removeAnimationForKey:方法或removeAnimationForKey方法，flag为NO，如果是正常结束，flag为YES。
    
    if ([self.delegate respondsToSelector:@selector(animationDidStop)]) {
        [self.delegate animationDidStop];
    }
}

@end
