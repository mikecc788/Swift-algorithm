//
//  DMEQViewController.h
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "RootViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol DMEQViewControllerDelegate <NSObject>
-(void)sendCustomArr:(NSArray*)eqArr;
@end
@interface DMEQViewController : RootViewController
@property(nonatomic,strong)NSString *eqValue;
@property(nonatomic,assign)id <DMEQViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
