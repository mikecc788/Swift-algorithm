//
//  DMNoFoundView.h
//  DMSound
//
//  Created by kiss on 2020/6/9.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ReconnectBlock)(void);
@interface DMNoFoundView : UIView
@property(nonatomic,copy)ReconnectBlock reconectBlock;
@end

NS_ASSUME_NONNULL_END
