//
//  KSTitleButton.h
//  FastPair
//
//  Created by cl on 2019/7/24.
//  Copyright © 2019 KSB. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol KSTitleButtonDelegate <NSObject>

// 点击的按钮
-(void)clickBtnIndex:(KSTitleViewStyle)style Title:(NSString *_Nonnull)title;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KSTitleButton : UIView
-(instancetype)initWithFrame:(CGRect)frame TitleArr:(NSArray*)titleArr LineNumber:(NSInteger)linkNumber ColumnsNumber:(NSInteger)columnsNumber EdgeInsetsStyle:(KSEdgeInsetsStyle)style ImageTitleSpace:(CGFloat)space isUpdate:(BOOL)update isFemale:(BOOL)isH12;
@property(nonatomic,assign)id<KSTitleButtonDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
