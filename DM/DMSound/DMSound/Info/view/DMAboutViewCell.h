//
//  DMAboutViewCell.h
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMBaseViewCell.h"

NS_ASSUME_NONNULL_BEGIN
#define kCellIdentifier_DMAboutViewCell @"DMAboutViewCell"

@interface DMAboutViewCell : DMBaseViewCell
@property (strong, nonatomic) UILabel *nameL;
@property (strong, nonatomic) UILabel *detailL;
-(void)setHiddenWithRow:(NSInteger)row andDetail:(NSString*)detailT;
@end

NS_ASSUME_NONNULL_END
