//
//  DMEqCustomController.h
//  DMSound
//
//  Created by kiss on 2020/6/2.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "RootViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol DMEQSliderViewDelegate <NSObject>
//滑动的时候数组Arr也改变了
-(void)updateSumArr:(NSInteger)currentItem;
@end

@interface DMEqCustomController : RootViewController
@property(nonatomic,strong)NSArray *currentArr;
//哪个item点击进来的
@property(nonatomic,assign)NSInteger selectItem;
@property(nonatomic,assign)id<DMEQSliderViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
