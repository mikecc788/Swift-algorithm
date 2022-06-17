//
//  DMUpdateAlert.h
//  DMSound
//
//  Created by kiss on 2020/5/26.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DMUpdateAlertDelegate <NSObject>

// 点击的按钮
-(void)clickUpdateNow;

@end

@interface DMUpdateAlert : UIView
-(instancetype)initWithFrame:(CGRect)frame content:(NSString*)content  currentV:(int)currentV;

@property(nonatomic,assign)id<DMUpdateAlertDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
