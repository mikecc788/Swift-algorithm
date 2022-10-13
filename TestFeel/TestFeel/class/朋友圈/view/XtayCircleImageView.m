//
//  XtayCircleImageView.m
//  FriendCircleDemo
//
//  Created by admin on 2021/1/15.
//

#define XTAY_IMAGES_TAG    4000

#import "XtayCircleImageView.h"

@implementation XtayCircleImageView

- (void)creatImageViewWithImages:(NSArray *)imageArray withWidth:(float)width {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat everyh_w = (width - 2*5)/3;
    for (NSInteger i = 0; i<imageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageArray[i]]];
        imageView.frame = CGRectMake((everyh_w+5)*(i%3), (everyh_w+5)*(i/3), everyh_w, everyh_w);
        imageView.tag = XTAY_IMAGES_TAG + i;
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapGesture:)];
        [imageView addGestureRecognizer:tap];
    }
}

- (void)imgTapGesture:(UITapGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag - XTAY_IMAGES_TAG;
    if ([self.delegate respondsToSelector:@selector(lookImageWithIndex:)]) {
        [self.delegate lookImageWithIndex:index];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
