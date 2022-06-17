//
//  DMFailUpdateView.h
//  Interview
//
//  Created by kiss on 2020/6/18.
//  Copyright © 2020 cl. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMFailUpdateView : UIView
@property (nonatomic, copy) void(^onButtonTouchUpFail)(DMFailUpdateView *failView);
@end

NS_ASSUME_NONNULL_END
