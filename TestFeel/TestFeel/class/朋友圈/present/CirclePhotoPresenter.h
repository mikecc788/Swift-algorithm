//
//  CirclePhotoPresenter.h
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import <Foundation/Foundation.h>
#import "CirclePresenterProtocol.h"
#import "CircleDetailInfo.h"
NS_ASSUME_NONNULL_BEGIN
@protocol TextPresenterProtocol

- (void)setText:(NSString *)text;

@end

@interface CirclePhotoPresenter : NSObject<CirclePresenterProtocol>
@property (nonatomic, weak) NSObject<TextPresenterProtocol> *view;
- (instancetype)initWithView:(UIView<CirclePresenterProtocol> *)view;
- (void)presentWithModel:(CircleDetailInfo *)model viewController:(UIViewController *)viewController;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic) CircleDetailInfo *detailInfo;
- (void)present;
@end

NS_ASSUME_NONNULL_END
