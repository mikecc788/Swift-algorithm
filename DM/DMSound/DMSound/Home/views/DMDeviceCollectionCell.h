//
//  DMDeviceCollectionCell.h
//  DMSound
//
//  Created by kiss on 2020/5/29.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define kCellIdentifier_DMDeviceCollectionCell  @"DMDeviceCollectionCell"
@class DMDeviceCollectionCell;
@protocol DMDeviceCollectionCellDelegate <NSObject>
- (void)didClickDeletePer:(DMDeviceCollectionCell*)cell;
@end


@interface DMDeviceCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleL;
@property(nonatomic,strong)UIImageView *bgImg;
@property (nonatomic, strong) UIButton *deleteBtn;
@property(nonatomic,assign)id <DMDeviceCollectionCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
