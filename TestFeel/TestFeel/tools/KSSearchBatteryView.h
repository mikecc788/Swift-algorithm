//
//  KSSearchBatteryView.h
//  FastPair
//
//  Created by kiss on 2020/5/8.
//  Copyright © 2020 KSB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSSearchBatteryView : UIView
-(instancetype)initWithFrame:(CGRect)frame;
/** 线宽 */
@property (nonatomic, assign) CGFloat lineW;
@property(nonatomic,strong)UIView *batteryV;
-(void)createBattery:(float)num;
@end

NS_ASSUME_NONNULL_END
