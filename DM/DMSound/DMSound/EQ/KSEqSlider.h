//
//  KSEqSlider.h
//  FastPair
//
//  Created by kiss on 2019/10/25.
//  Copyright © 2019 KSB. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KSEqSlider;
@class KSColorBgButton;
NS_ASSUME_NONNULL_BEGIN
@protocol KSEqSliderDelegate <NSObject>

@optional

- (void)beginSwip;
- (void)endSwipValue:(CGFloat)value Tag:(NSInteger)tag;
- (void)currentValueOfSlider:(KSEqSlider *)slider;
@end


@interface KSEqSlider : UISlider
@property (nonatomic,assign) BOOL isShowTitle;
@property(nonatomic, strong) UILabel *sliderValueLabel;//滑块下面的值
@property (nonatomic,assign) EQTitleStyle titleStyle;
@property(nonatomic,strong)KSColorBgButton *btn;
@property(nonatomic,assign)int sliderValue;

@property (nonatomic, unsafe_unretained)id<KSEqSliderDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
