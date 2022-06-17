//
//  KSBatteryView.h
//  FastPair
//
//  Created by cl on 2019/7/26.
//  Copyright © 2019 KSB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSBatteryView : UIView
-(instancetype)initWithFrame:(CGRect)frame num:(NSInteger)num;

-(void)setBatteryNum:(float)num;


@end

NS_ASSUME_NONNULL_END
