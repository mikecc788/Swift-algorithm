//
//  DMAboutViewController.m
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMAboutViewController.h"
#import "DMGoBackButton.h"
#import "DMAboutViewCell.h"
#import "DMWebViewController.h"
#import "DMPrivacyViewController.h"

@interface DMAboutViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray *titleArr;
@property(nonatomic,strong)NSString *appVersion;
@end

@implementation DMAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = Gloabal_bg;
    UIImageView *bgImg = [[UIImageView alloc]initWithFrame:self.view.bounds];
    bgImg.image = [UIImage imageNamed:@"info_bg"];
    [self.view addSubview:bgImg];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    self.titleArr = @[NSLocalizedString(@"App版本", nil),NSLocalizedString(@"意見反饋", nil),NSLocalizedString(@"隱私協議", nil),NSLocalizedString(@"DM官方網站", nil)];
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, 40, 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"關於", nil) textFont:[UIFont systemFontOfSize:34]];
    [self.view addSubview:back];
    
    CGFloat distancBottom = 90;
    CGFloat tableH = 380;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(27, SCREEN_HEIGHT-distancBottom -tableH, SCREEN_WIDTH-27*2, tableH) style:UITableViewStylePlain];
     [tableView registerClass:[DMAboutViewCell class] forCellReuseIdentifier:kCellIdentifier_DMAboutViewCell];
    tableView.layer.cornerRadius = 22;
    tableView.layer.masksToBounds = YES;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-27*2, 90)];
    tableView.backgroundColor = [UIColor colorFromHexStr:@"#2F2F2F"];
    [tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView = tableView;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-distancBottom -tableH - 35, 70, 70)];
//    img.y = SCREEN_HEIGHT-distancBottom -tableH - 35;
    img.centerX = self.view.centerX;
    img.image = [UIImage imageNamed:@"组 1"];
    [self.view addSubview:img];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DMAboutViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_DMAboutViewCell forIndexPath:indexPath];
    cell.nameL.text = self.titleArr[indexPath.row];
    [cell setHiddenWithRow:indexPath.row andDetail:self.appVersion];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        NSURL *url = [NSURL URLWithString:@"mailto:cs@dm-sounds.com"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }else if (indexPath.row == 2){
        DMPrivacyViewController *privacy = [DMPrivacyViewController new];
        [self.navigationController pushViewController:privacy animated:YES];

    }else if (indexPath.row == 3){
        [self.navigationController pushViewController:[DMWebViewController new] animated:YES];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

@end
