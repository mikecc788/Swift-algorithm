//
//  DMInfoViewCell.h
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMBaseViewCell.h"

NS_ASSUME_NONNULL_BEGIN
#define kCellIdentifier_DMInfoViewCell @"DMInfoViewCell"

@interface DMInfoViewCell : DMBaseViewCell
-(void)setLeftName:(NSString*)name;
-(void)setRightName:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
