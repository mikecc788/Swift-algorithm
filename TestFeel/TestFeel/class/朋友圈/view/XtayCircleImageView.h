//
//  XtayCircleImageView.h
//  FriendCircleDemo
//
//  Created by admin on 2021/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XtayLookImagesDelegate <NSObject>

- (void)lookImageWithIndex:(NSInteger)index;

@end

@interface XtayCircleImageView : UIView

- (void)creatImageViewWithImages:(NSArray *)imageArray withWidth:(float)width;

/// 代理
@property (nonatomic, weak) id <XtayLookImagesDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
