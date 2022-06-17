//
//  DMSuccessView.h
//  Interview
//
//  Created by kiss on 2020/6/18.
//  Copyright © 2020 cl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMSuccessView : UIView
@property (nonatomic, copy) void(^onButtonTouchUpSuccess)(DMSuccessView *successView);
@end

NS_ASSUME_NONNULL_END
