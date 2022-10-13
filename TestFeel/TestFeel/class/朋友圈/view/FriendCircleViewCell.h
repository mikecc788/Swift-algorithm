//
//  FriendCircleViewCell.h
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import <UIKit/UIKit.h>
#import "CirclePhotoPresenter.h"
#import "CircleDetailInfo.h"
#import "FriendClickCellProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FriendCircleViewCell : UITableViewCell<TextPresenterProtocol,FriendClickCellProtocol>
@property(nonatomic,strong)CirclePhotoPresenter *presenter;
@property (nonatomic, strong) CircleDetailInfo *model;
@property (nonatomic, weak) id <FriendClickCellProtocol> cellDelegate;
@end

NS_ASSUME_NONNULL_END
