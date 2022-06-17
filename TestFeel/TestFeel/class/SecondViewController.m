//
//  SecondViewController.m
//  TestFeel
//
//  Created by app on 2022/3/11.
//

#import "SecondViewController.h"
#import "CircleViewController.h"
#import "LFSLineChartVC.h"
@interface SecondViewController ()
@property(nonatomic, strong) NSArray *dataSourceArray;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSLog(@"===%@",[LFSAppUserSetting shareInstance].resultArr);
    self.dataSourceArray = @[@"China", @"Unit Kingdom",@"America"];
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
    cell.textLabel.text = [NSString stringWithFormat:@"测试%ld",indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        [self.navigationController pushViewController:[LFSLineChartVC new] animated:YES];
    }else{
        [self.navigationController pushViewController:[CircleViewController new] animated:YES];
    }
    
}
@end
