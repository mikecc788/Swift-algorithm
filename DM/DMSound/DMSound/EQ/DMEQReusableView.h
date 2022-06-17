//
//  DMEQReusableView.h
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMEQReusableViewDelegate <NSObject>

// 点击的按钮
-(void)clickCustomBtn;
//点击背景框
-(void)clickImageBg;
@end

NS_ASSUME_NONNULL_BEGIN
#define kCellIdentifier_DMEQReusableView @"DMEQReusableView"

@interface DMEQReusableView : UICollectionReusableView
@property(nonatomic,assign)id<DMEQReusableViewDelegate> delegate;
@property(nonatomic,strong)UIImageView *headerImg;
@end

NS_ASSUME_NONNULL_END
