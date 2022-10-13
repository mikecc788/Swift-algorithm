//
//  CirclePhotoPresenter.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "CirclePhotoPresenter.h"

@implementation CirclePhotoPresenter
- (instancetype)initWithView:(UIView<TextPresenterProtocol> *)view{
    if (self = [self init]) {
        self.view = view;
    }

    return self;
}
-(void)presentWithModel:(CircleDetailInfo *)model viewController:(UIViewController *)viewController{
    self.detailInfo = model;
    self.viewController = viewController;
    [self present];
}
-(void)present{
    LogMethod();
}

@end
