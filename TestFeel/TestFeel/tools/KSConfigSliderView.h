//
//  KSConfigSliderView.h
//  FastPair
//
//  Created by cl on 2019/7/29.
//  Copyright © 2019 KSB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OnTabTapActionDelegate

@required
- (void)onTabTapAction:(NSInteger)index;
@end

@interface KSConfigSliderView : UIView
@property (nonatomic, weak) id <OnTabTapActionDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setLabels:(NSArray<NSString *> *)titles tabIndex:(NSInteger)tabIndex;

@end

NS_ASSUME_NONNULL_END
