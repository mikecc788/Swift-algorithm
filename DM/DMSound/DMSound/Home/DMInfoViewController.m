//
//  DMInfoViewController.m
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMInfoViewController.h"
#import "DMGoBackButton.h"
#import "DMInfoViewCell.h"
#import "HYRadix.h"
@interface DMInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,assign)int leftVersion;
@property(nonatomic,assign)int rightVersion;
@end

@implementation DMInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexStr:@"#111217"];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
     [tableView registerClass:[DMInfoViewCell class] forCellReuseIdentifier:kCellIdentifier_DMInfoViewCell];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor colorFromHexStr:@"#111217"];
    [tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.tableHeaderView = [self setHeaderView];
    self.tableView = tableView;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    
    NSString *rightVersion  = [self.versionInfo substringWithRange:NSMakeRange(self.versionInfo.length-2, 2)];
    NSString *leftVersion = [self.versionInfo substringWithRange:NSMakeRange(self.versionInfo.length-6, 2)];
   
    self.leftVersion = [[HYRadix hy_convertToDecimalFromHexadecimal:leftVersion] intValue];
    self.rightVersion = [[HYRadix hy_convertToDecimalFromHexadecimal:rightVersion] intValue];
//    NSLog(@" left=%d r2=%d", self.leftVersion,self.rightVersion);
//    [self test];
    NSLog(@"商%d 余数%d",self.leftVersion /10,self.leftVersion%10);
    
    UIImageView *bgImg = [[UIImageView alloc]initWithFrame:tableView.bounds];
    bgImg.image = [UIImage imageNamed:@"scan_bg"];
    [self.tableView addSubview:bgImg];
    
}
-(UIView*)setHeaderView{
    UIView * headerView;
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,  140)];
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, 10, 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"耳機資料", nil) textFont:[UIFont systemFontOfSize:34]];//耳機資料
    [headerView addSubview:back];
    return headerView;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     DMInfoViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:kCellIdentifier_DMInfoViewCell forIndexPath:indexPath];
    if (indexPath.row == 0) {
        [cell setLeftName:NSLocalizedString(@"版本",nil)];
//        double newleftV = (self.leftVersion + 10) / 10 ;
//        double newRightV = (self.rightVersion + 10) / 10;
        NSString *str = [NSString stringWithFormat:@"%@:1.%d.%d  %@:1.%d.%d",NSLocalizedString(@"左", nil),self.leftVersion/10,self.leftVersion%10,NSLocalizedString(@"右", nil),self.rightVersion/10,self.rightVersion%10];
        [cell setRightName:str];
    }else{
        [cell setLeftName:NSLocalizedString(@"提示音语言",nil)];
        [cell setRightName:NSLocalizedString(@"英语",nil)];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
-(void)test{
    UIView *midV = [[UIView alloc]init];
    midV.backgroundColor = [UIColor lightGrayColor];
    midV.layer.cornerRadius = 7.0;
    midV.layer.masksToBounds = YES;
    [self.view addSubview:midV];
    [midV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-27*2, 383));
    }];
    
    UILabel *versionL = [[UILabel alloc]init];
    versionL.textColor = [UIColor colorWithHexString:@"#2D2D2D"];
    versionL.font = [UIFont systemFontOfSize:16];
    versionL.numberOfLines = 0;
    versionL.text = NSLocalizedString(@"固件版本", nil);
    [midV addSubview:versionL];
    [versionL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(midV.mas_top).offset(80);
        make.left.equalTo(midV.mas_left).offset(50);
    }];
    [versionL sizeToFit];
    
    UILabel *versionD = [[UILabel alloc]init];
    versionD.textColor = [UIColor colorWithHexString:@"#2D2D2D"];
    versionD.font = [UIFont systemFontOfSize:16];
    versionD.numberOfLines = 0;
    versionD.text = NSLocalizedString(@"左:1.01 右:1.02", nil);
    [midV addSubview:versionD];
    [versionD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(versionL.mas_centerY);
        make.left.equalTo(midV.mas_left).offset(170);
    }];
    [versionD sizeToFit];
    
    UILabel *productL = [[UILabel alloc]init];
    productL.textColor = [UIColor colorWithHexString:@"#2D2D2D"];
    productL.font = [UIFont systemFontOfSize:16];
    productL.numberOfLines = 0;
    productL.text = NSLocalizedString(@"生产序号", nil);
    [midV addSubview:productL];
    [productL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(versionL.mas_top).offset(80);
        make.left.equalTo(midV.mas_left).offset(50);
    }];
    [productL sizeToFit];
    
    UILabel *productD = [[UILabel alloc]init];
    productD.textColor = [UIColor colorWithHexString:@"#2D2D2D"];
    productD.font = [UIFont systemFontOfSize:16];
    productD.numberOfLines = 0;
    productD.text = NSLocalizedString(@"202005001", nil);
    [midV addSubview:productD];
    [productD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(productL.mas_centerY);
        make.left.equalTo(midV.mas_left).offset(170);
    }];
    [productD sizeToFit];
    
    UILabel *tipL = [[UILabel alloc]init];
    tipL.textColor = [UIColor colorWithHexString:@"#2D2D2D"];
    tipL.font = [UIFont systemFontOfSize:16];
    tipL.numberOfLines = 0;
    tipL.text = NSLocalizedString(@"提示音语言", nil);
    [midV addSubview:tipL];
    [tipL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productL.mas_top).offset(80);
        make.left.equalTo(midV.mas_left).offset(50);
    }];
    [tipL sizeToFit];
    
    UILabel *tipD = [[UILabel alloc]init];
    tipD.textColor = [UIColor colorWithHexString:@"#2D2D2D"];
    tipD.font = [UIFont systemFontOfSize:16];
    tipD.numberOfLines = 0;
    tipD.text = NSLocalizedString(@"英语", nil);
    [midV addSubview:tipD];
    [tipD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tipL.mas_centerY);
        make.left.equalTo(midV.mas_left).offset(170);
    }];
    [tipD sizeToFit];
}

@end
