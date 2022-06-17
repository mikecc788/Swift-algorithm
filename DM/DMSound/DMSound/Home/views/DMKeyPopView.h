//
//  DMKeyPopView.h
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DMKeyPopView;
@protocol DMKeyPopViewDelegate<NSObject>

-(void)kPromptView:(DMKeyPopView *)promptView cellStr:(NSString *)cellStr;


@end

@interface DMKeyPopView : UIView
@property(nonatomic,copy)NSString * title;
@property(nonatomic,strong)NSArray * cellArr;
@property(nonatomic,weak)id<DMKeyPopViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title cellArray:(NSArray *)cellArr;
-(void)close;
@end

NS_ASSUME_NONNULL_END
