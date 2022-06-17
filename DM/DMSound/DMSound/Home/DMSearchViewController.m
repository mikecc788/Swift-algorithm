//
//  DMSearchViewController.m
//  DMSound
//
//  Created by kiss on 2020/5/28.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMSearchViewController.h"
#import "DMProtocolView.h"
#import "KSAlertTool.h"
#import "CLDataConver.h"
#import "DMChoiceDeviceCell.h"
#import "DMMyDeviceController.h"
#import "DMDeviceCollectionCell.h"
#import "DMCardFlowLayout.h"
#import "DMCardCollectionCell.h"
#import "CustomFlowLayout.h"
#import "DMScanViewController.h"
@interface DMSearchViewController ()<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)NSMutableArray *dataArr;

@property (nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic,strong)CustomFlowLayout *layout;

@end


@implementation DMSearchViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    NSString *fileName;
    if ([CurrentLanguage isEqualToString:@"en"]) {
        fileName = @"policyEng";
    }else{
        fileName = @"policy";
    }
    
    NSString *noteVideoPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
       NSString *content = [[NSString alloc] initWithContentsOfFile:noteVideoPath encoding:NSUTF8StringEncoding error:nil];
    if (![DMAppUserSetting shareInstance].isShowAlert){
       DMProtocolView *protocolV = [[DMProtocolView alloc]initWithFrame:self.view.bounds content:content];
       [self.view addSubview:protocolV];
       __weak typeof(protocolV)  weakP = protocolV;
       protocolV.dismissAlertView = ^{
           NSLog(@"点击了同意");
           [DMAppUserSetting shareInstance].isShowAlert = YES;
           [weakP  removeFromSuperview];
           if (self.dataArr.count<=0) {
               [self loadData];
           }
//           if (!self.myTableView) {
//               [self setupTable];
//           }
           if (!self.collectionView) {
               [self setHeaderView];
               [self setupCollect];
           }
       };
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}
-(void)setupCollect{
//    DMCardFlowLayout *layout = [[DMCardFlowLayout alloc] init];
//    layout.itemSize = CGSizeMake(260, 284);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT -300)*0.5, SCREEN_WIDTH , 300) collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[DMCardCollectionCell class] forCellWithReuseIdentifier:kCellIdentifier_DMCardCollectionCell];
    self.collectionView.showsHorizontalScrollIndicator = false;
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.view.backgroundColor = [UIColor colorFromHexStr:@"#111217"];
//    [self setupUI];
   if ([DMAppUserSetting shareInstance].isShowAlert){
       [self loadData];
//       [self setupTable];
       [self setHeaderView];
       [self setupCollect];
   }
}

-(void)loadData{
    NSArray *arr1 = @[@"BE3000AI",@"BE3000AI"];
   NSArray *arr2 = @[@"图层 4 拷贝 2",@"WechatIMG23"];
   NSArray *arr3 = @[@"device_bg",@"圆角矩形 936 拷贝"];
   self.dataArr = [[NSMutableArray alloc]init];
   [self.dataArr addObject:arr1];
   [self.dataArr addObject:arr2];
   [self.dataArr addObject:arr3];
}
-(void)setupTable{
    self.myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.myTableView registerClass:[DMChoiceDeviceCell class] forCellReuseIdentifier:kCellIdentifier_DMChoiceDeviceCell];
    self.myTableView.backgroundColor =[UIColor colorWithHexString:@"#111217"];
    
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
//    self.myTableView.backgroundView = [UIColor clearColor];
//    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, HSTitilesViewY, 0);
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableView.tableHeaderView = [self setHeaderView];
    [self.view addSubview:self.myTableView];
    
    UIImageView *img = [[UIImageView alloc]init];
    img.image = [UIImage imageNamed:@"DM GROUP"];
    [self.view addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.top.equalTo(self.view.mas_top).offset(220);
        make.size.mas_equalTo(CGSizeMake(50, 354));
    }];
}
-(UIView*)setHeaderView{
    UIView * headerView;
       headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,  KScaleHeight(100))];
    [self.view addSubview:headerView];
    UILabel *headL = [[UILabel alloc]init];
    headL.text = NSLocalizedString(@"选择您的装置", nil);
    headL.textAlignment = NSTextAlignmentCenter;
    headL.font = [UIFont fontWithName:@"ArialMT" size:33];
    headL.textColor = [UIColor colorWithHexString:@"#E4E4E4"];
    [headerView addSubview:headL];
    
    [headL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_top).offset(KScaleHeight(60));
        make.left.equalTo(headerView.mas_left).offset(42);
    }];
    [headerView sizeToFit];
    return headerView;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DMCardCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_DMCardCollectionCell forIndexPath:indexPath];
//    if (indexPath.item == 0) {
//        cell.backgroundColor = [UIColor colorFromHexStr:@"#292A2F"];
//    }else{
//        cell.backgroundColor = [UIColor colorFromHexStr:@"#311A4E"];
//    }
    [cell setTitleName:(self.dataArr[0])[indexPath.item] earName:(self.dataArr[1])[indexPath.item] bgName:self.dataArr[2][indexPath.item]];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *arr = @[@"0001",@"0002"];
    DMScanViewController *scan = [[DMScanViewController alloc]init];
    scan.productCode = arr[indexPath.item];
    [self.navigationController pushViewController:scan animated:YES];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DMChoiceDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_DMChoiceDeviceCell forIndexPath:indexPath];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;// cell点击变灰
    
    [cell setTitleName:(self.dataArr[0])[indexPath.row] earName:(self.dataArr[1])[indexPath.row] bgName:self.dataArr[2][indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath=%ld",indexPath.row);
    DMMyDeviceController *device = [[DMMyDeviceController alloc]init];
    [self.navigationController pushViewController:device animated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 270;
}


#pragma mark -
#pragma mark setter and getter
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(CustomFlowLayout *)layout{
    if(!_layout){
        _layout=[[CustomFlowLayout alloc] init];
        _layout.itemSize=CGSizeMake(260, 284);
        _layout.minimumLineSpacing = 0;
    }
    return _layout;
}
@end
