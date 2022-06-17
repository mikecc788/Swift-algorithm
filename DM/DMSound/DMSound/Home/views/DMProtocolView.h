//
//  DMProtocolView.h
//  DMSound
//
//  Created by kiss on 2020/5/28.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface DMProtocolView : UIView
-(instancetype)initWithFrame:(CGRect)frame content:(NSString*)content;
@property (nonatomic,copy)void (^dismissAlertView)(void);
@end

NS_ASSUME_NONNULL_END
