//
//  ZSPickView.h
//  ZSPickView
//
//  Created by Tony on 16/8/19.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^BRCancelBlock)(void);

@interface ZSPickView : UIView
//pickview无关联的组数
@property(nonatomic,strong)NSArray * _Nullable componentArr;
-(instancetype)initWithComponentArr:(NSArray *)Arr;
/** 取消选择的回调 */
@property (nullable, nonatomic, copy) BRCancelBlock cancelBlock;

//确认回调block
@property(nonatomic,copy)void(^ _Nullable sureBlock)(NSArray *);
@end
