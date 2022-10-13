//
//  SecondViewController.m
//  TestFeel
//
//  Created by app on 2022/3/11.
//

#import "SecondViewController.h"
#import "CircleViewController.h"
#import "LFSLineChartVC.h"
#import "CircleFriendViewController.h"
#import "ProfileViewController.h"
@interface SecondViewController ()
@property(nonatomic, strong) NSArray *dataSourceArray;
@property(nonatomic, strong) NSArray *classArray;
@end

@implementation SecondViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.classArray = @[@"ProfileViewController", @"CircleViewController",@"CircleFriendViewController",@"ImageCacheController"];
    NSLog(@"===%@",[LFSAppUserSetting shareInstance].resultArr);
    self.dataSourceArray = @[@"Profile", @"Circle",@"FriendCircle",@"图片缓存"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ID"];
}

//每个section有多少个row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSourceArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class cls = NSClassFromString(self.classArray[indexPath.row]);
    [self.navigationController pushViewController:[cls new] animated:YES];
//    if (indexPath.row == 0) {
//        [self.navigationController pushViewController:[LFSLineChartVC new] animated:YES];
//    }else if (indexPath.row == 1) {
//        [self.navigationController pushViewController:[CircleFriendViewController new] animated:YES];
//    }else{
//        [self.navigationController pushViewController:[CircleViewController new] animated:YES];
//    }
    
}
@end
