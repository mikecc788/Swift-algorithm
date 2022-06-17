//
//  DMKeyViewController.h
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "RootViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol DMKeyViewControllerDelegate <NSObject>
-(void)clickResetKeyBtn;
-(void)clickSelectRow:(NSInteger)row selectName:(NSString*_Nonnull)name;
@end

@interface DMKeyViewController : RootViewController
@property(nonatomic,assign)id <DMKeyViewControllerDelegate>delegate;
@property(nonatomic,strong)NSString *keyStr;

@end

NS_ASSUME_NONNULL_END
