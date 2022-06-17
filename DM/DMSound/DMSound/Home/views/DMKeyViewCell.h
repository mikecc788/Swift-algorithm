//
//  DMKeyViewCell.h
//  DMSound
//
//  Created by kiss on 2020/5/28.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMKeyViewCell;

@protocol DMKeyViewCellDelegate <NSObject>
- (void)cellDidClick:(DMKeyViewCell *_Nonnull)cell;
@end

NS_ASSUME_NONNULL_BEGIN
#define kCellIdentifier_DMKeyViewCell @"DMKeyViewCell"
@interface DMKeyViewCell : UITableViewCell
-(void)leftName:(NSString*)name;
@property (nonatomic,weak)id<DMKeyViewCellDelegate>delegate;
-(void)setKeyName:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
