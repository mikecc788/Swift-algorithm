//
//  DMEqCollectionViewCell.h
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMEqCollectionViewCell;
@protocol DMEqCollectionDelegate <NSObject>

// 点击的按钮
-(void)didClickEqTag:(NSInteger)tag cell:(DMEqCollectionViewCell*_Nonnull)cell;

@end

NS_ASSUME_NONNULL_BEGIN
#define kCellIdentifier_DMEqCollectionViewCell @"DMEqCollectionViewCell"
@interface DMEqCollectionViewCell : UICollectionViewCell
@property (strong , nonatomic)UIImageView *gridImageView;
@property (strong , nonatomic)UIButton *gridLabel;
@property(nonatomic,strong)UIImageView *itemBg;
@property(nonatomic,strong)UIImageView *markImg;
-(void)selectItem;
-(void)isCancelSelect;
@property(nonatomic,assign)id<DMEqCollectionDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
