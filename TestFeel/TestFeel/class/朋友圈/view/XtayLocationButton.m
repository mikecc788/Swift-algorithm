//
//  XtayLocationButton.m
//  FriendCircleDemo
//
//  Created by admin on 2021/1/18.
//

#import "XtayLocationButton.h"

@implementation XtayLocationButton

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.imageView.image) {
        return;
    }
    [self.titleLabel sizeToFit];
    CGRect titleFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    CGFloat spacing = 0;
    if (self.locationBtnType == ButtonType_Image_Tope || self.locationBtnType == ButtonType_Image_Bottom) {
        spacing = (self.frame.size.height - titleFrame.size.height - imageFrame.size.height - 5) / 2;
    } else {
        spacing = (self.frame.size.width - titleFrame.size.width - imageFrame.size.width - 5) / 2;
    }
    switch (self.locationBtnType) {
        case ButtonType_Image_Tope:
        {
            self.imageView.center = CGPointMake(self.frame.size.width / 2, spacing + imageFrame.size.height / 2);
            self.titleLabel.center = CGPointMake(self.frame.size.width / 2, CGRectGetMaxY(self.imageView.frame) + titleFrame.size.height / 2 + 5);
        }
            break;
        case ButtonType_Image_Bottom:
        {
            self.titleLabel.center = CGPointMake(self.frame.size.width / 2, spacing + titleFrame.size.height / 2);
            self.imageView.center = CGPointMake(self.frame.size.width / 2, CGRectGetMaxY(self.titleLabel.frame) + imageFrame.size.height / 2 + 5);
        }
            break;
        case ButtonType_Image_Left:
        {
            self.imageView.center = CGPointMake(spacing + imageFrame.size.width / 2, self.frame.size.height / 2);
            self.titleLabel.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) + 5 + titleFrame.size.width / 2, self.frame.size.height / 2);
        }
            break;
        case ButtonType_Image_Right:
        {
            self.titleLabel.center = CGPointMake(spacing + titleFrame.size.width / 2, self.frame.size.height / 2);
            self.imageView.center = CGPointMake(CGRectGetMaxX(self.titleLabel.frame) + 5 + imageFrame.size.width / 2, self.frame.size.height / 2);
        }
            break;
        default:
            break;
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
