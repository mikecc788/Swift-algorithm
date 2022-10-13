//
//  CircleFriendPresenter.h
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import <Foundation/Foundation.h>
#import "CirclePresenterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CircleFriendPresenter : NSObject<UITableViewDataSource, UITableViewDelegate,CirclePresenterProtocol>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
- (instancetype)initWithView:(UITableView *)view;
@property(nonatomic,weak)UIViewController *viewController;
@end

NS_ASSUME_NONNULL_END
