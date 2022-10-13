//
//  FriendClickCellProtocol.h
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import <Foundation/Foundation.h>
@class FriendCircleViewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol FriendClickCellProtocol <NSObject>
/// 展开收缩按钮的回调方法
/// @param isOpen 当前状态是开还是关
/// @param cell 自身
- (void)openOrCloseBtnResponseWithCurrentStatus:(BOOL)isOpen cell:(FriendCircleViewCell *)cell;

/// 查看图片
/// @param index 点击的当前索引值
/// @param cell 自身
- (void)lookCellImagesWithIndex:(NSInteger)index cell:(FriendCircleViewCell *)cell;

/// 点击点赞的人的回调
/// @param index 当前排序索引值
/// @param cell 自身
- (void)clickThumbViewListWithIndex:(NSInteger)index cell:(FriendCircleViewCell *)cell;

/// 点击评论视图的回复者方法
/// @param index 第几条数据
/// @param cell 自身
- (void)clickCommentListViewFromManIndex:(NSInteger)index cell:(FriendCircleViewCell *)cell;

/// 点击评论视图的被回复对象方法
/// @param index 第几条数据
/// @param cell 自身
- (void)clickCommentListViewToManIndex:(NSInteger)index cell:(FriendCircleViewCell *)cell;

/// 更多按钮的回调事件
/// @param cell 自身
- (void)moreButtonCallBackCell:(FriendCircleViewCell *)cell;

/// 点赞按钮点击事件回调
/// @param cell 自身
- (void)moreBtnSubViewDianZanResCell:(FriendCircleViewCell *)cell;

/// 取消点赞按钮点击事件回调
/// @param cell 自身
- (void)moreBtnSubViewCancelDianZanResCell:(FriendCircleViewCell *)cell;

/// 回复按钮点击事件回调
/// @param cell 自身
- (void)moreBtnSubViewHuiFuResCell:(FriendCircleViewCell *)cell;
@end

NS_ASSUME_NONNULL_END
