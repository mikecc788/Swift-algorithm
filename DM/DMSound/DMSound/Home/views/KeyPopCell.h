//
//  KeyPopCell.h
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class KeyPopCell;
@protocol KeyPopCellDelegate <NSObject>

-(void)cellDidClick:(KeyPopCell *)cell selectRowStr:(NSString *)cellStr ;
@end

@interface KeyPopCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic)  UIButton *selectBtn;

@property(nonatomic,weak)id<KeyPopCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
