//
//  DMChoiceDeviceCell.h
//  DMSound
//
//  Created by kiss on 2020/5/29.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define kCellIdentifier_DMChoiceDeviceCell @"DMChoiceDeviceCell"
@interface DMChoiceDeviceCell : UITableViewCell
-(void)setTitleName:(NSString*)title earName:(NSString*)earName bgName:(NSString*)bgName;
@end

NS_ASSUME_NONNULL_END
