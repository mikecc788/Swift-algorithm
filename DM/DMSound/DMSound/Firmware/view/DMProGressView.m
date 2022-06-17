//
//  DMProGressView.m
//  DMSound
//
//  Created by kiss on 2020/6/15.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMProGressView.h"
@interface DMProGressView(){
    UIView *viewTop;
    UIView *viewBottom;
}

@end

@implementation DMProGressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self buildUI];
        
    }
    return self;
}

- (void)buildUI
{
    
    viewBottom = [[UIView alloc]initWithFrame:self.bounds];
    viewBottom.backgroundColor = [UIColor colorFromHexStr:@"#2B2D34"];
    viewBottom.layer.cornerRadius = 5;
    viewBottom.layer.masksToBounds = YES;
    [self addSubview:viewBottom];
    
    
    viewTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, viewBottom.frame.size.height)];
    viewTop.backgroundColor = [UIColor whiteColor];
    viewTop.layer.cornerRadius = 5;
    viewTop.layer.masksToBounds = YES;
    [viewBottom addSubview:viewTop];
    
}


-(void)setTime:(float)time
{
    _time = time;
}
-(void)setProgressValue:(float)progressValue
{
    if (!_time) {
        _time = 1.0f;
    }
    _progressValue = progressValue;
//    [UIView animateWithDuration:_time animations:^{
//
//    }];
    viewTop.frame = CGRectMake(viewTop.frame.origin.x,viewTop.frame.origin.y, viewBottom.frame.size.width*progressValue, viewTop.frame.size.height);
}


-(void)setBottomColor:(UIColor *)bottomColor
{
    _bottomColor = bottomColor;
    viewBottom.backgroundColor = bottomColor;
}

-(void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    viewTop.backgroundColor = progressColor;
}

@end
