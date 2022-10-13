//
//  CirclePresenterProtocol.h
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@protocol CirclePresenterProtocol <NSObject>
- (void)setView:(NSObject *)view;
- (void)setViewController:(UIViewController *)viewController;

@optional
- (void)present;
- (void)presentWithModel:(id)model viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
