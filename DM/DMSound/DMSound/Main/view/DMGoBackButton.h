//
//  DMGoBackButton.h
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMGoBackButtonDelegate <NSObject>

// 点击的按钮
-(void)clickBackBtn;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DMGoBackButton : UIButton
/**
 图片和文字的间距
 */
@property (nonatomic, assign) CGFloat space;

/**
 整个LPButton(包含ImageV and titleV)的内边距
 */
@property (nonatomic, assign) CGFloat delta;
@property(nonatomic,assign)BOOL isScanEnter;//从扫描页面进来的
@property(nonatomic,assign)id<DMGoBackButtonDelegate>delegate;
- (void)setMutableTitleWithString:(NSString *)text textFont:(UIFont *)textFont;
@end

NS_ASSUME_NONNULL_END
