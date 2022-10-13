//
//  CircleFriendViewController.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "CircleFriendViewController.h"
#import "IQKeyboardManager.h"
@interface CircleFriendViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CircleFriendViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"列表";
    self.tabBarController.tabBar.hidden = YES;
    self.presenter = [[CircleFriendPresenter alloc] initWithView: self.tableView];
    self.presenter.viewController = self;
   
}



@end
