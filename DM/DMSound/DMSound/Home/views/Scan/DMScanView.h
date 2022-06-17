//
//  DMScanView.h
//  DMSound
//
//  Created by kiss on 2020/6/9.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DMScanViewDelegate <NSObject>

-(void)animationDidStop;

@end

@interface DMScanView : UIView
@property(nonatomic,assign)id <DMScanViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
