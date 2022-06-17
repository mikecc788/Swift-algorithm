//
//  DMCardCollectionCell.h
//  DMSound
//
//  Created by kiss on 2020/6/3.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define kCellIdentifier_DMCardCollectionCell  @"DMCardCollectionCell"
@interface DMCardCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleL;
@property(nonatomic,strong)UIImageView *bgImg;
-(void)setTitleName:(NSString *)title earName:(NSString *)earName bgName:(NSString *)bgName;
@end

NS_ASSUME_NONNULL_END
