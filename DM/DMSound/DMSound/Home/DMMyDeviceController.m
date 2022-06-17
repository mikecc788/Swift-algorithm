//
//  DMMyDeviceController.m
//  DMSound
//
//  Created by kiss on 2020/5/29.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMMyDeviceController.h"
#import "DMDeviceCollectionCell.h"
#import "DMDeviceViewFlowLayout.h"
#import "DMHomeViewController.h"
#import "DMCardView.h"
#import "CLBLEManager.h"
#import "CLDataConver.h"
#import "DMCardFlowLayout.h"
#import "CustomFlowLayout.h"
#import "DMScanViewController.h"
#import "DMSearchViewController.h"
#import "LYEmptyViewHeader.h"
@interface DMMyDeviceController ()<UICollectionViewDelegate,UICollectionViewDataSource,DMDeviceCollectionCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic,strong)CLBLEManager *bleManager;

@property (nonatomic,strong)CustomFlowLayout * layout;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,assign)NSInteger currentRow;

@property(nonatomic,strong)UIButton *connectBtn;
/**
 选中的当前下标
 */
@property (nonatomic, strong) NSIndexPath * currentIndexPath;
@end

@implementation DMMyDeviceController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexStr:@"#111217"];
    
    self.dataArr = [[NSMutableArray alloc]init];
    [self.dataArr addObjectsFromArray:[DMAppUserSetting shareInstance].addressArr];
    self.currentRow = 0;
    UILabel *titleL = [[UILabel alloc]init];
    titleL.textAlignment = NSTextAlignmentRight;
    titleL.font = [UIFont systemFontOfSize:33];
    titleL.textColor = [UIColor colorWithHexString:@"#E4E4E4"];
    titleL.text = NSLocalizedString(@"我的耳机", nil);
    [self.view addSubview:titleL];
    [titleL sizeToFit];
    CGFloat topY = iPhoneX ? 63:43;
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(42);
        make.top.equalTo(self.view.mas_top).offset(topY);
    }];

//    DMCardView *cardView = [[DMCardView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 280)];
//    [self.view addSubview:cardView];
    
    [self setupCollect];
    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    connectBtn.backgroundColor = [UIColor colorFromHexStr:@"#414145"];
    connectBtn.layer.cornerRadius = 21;
    [connectBtn addTarget:self action:@selector(connectClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [connectBtn setTitle:NSLocalizedString(@"连接", nil) forState:(UIControlStateNormal)];
    [connectBtn setTitleColor:[UIColor colorFromHexStr:@"#D0D0D0"] forState:(UIControlStateNormal)];
    connectBtn.layer.masksToBounds = YES;
    [self.view addSubview:connectBtn];
    self.connectBtn = connectBtn;
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-KScaleHeight(100));
        make.size.mas_equalTo(CGSizeMake(202, 42));
    }];
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setImage:[UIImage imageNamed:@"新设备"] forState:(UIControlStateNormal)];
    [addBtn addTarget:self action:@selector(addDevice:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-33);
        make.bottom.equalTo(self.view.mas_bottom).offset(-32);
        make.size.mas_equalTo(CGSizeMake(37, 37));
    }];
    
    self.collectionView.ly_emptyView = [LYEmptyView emptyViewWithImageStr:@"place_non" titleStr:nil detailStr:NSLocalizedString(@"你还没有添加耳机\n 点击右下角\"+\"添加耳机", nil)];
}


//MARK-:Click Method
-(IBAction)addDevice:(UIButton*)sender{
    DMSearchViewController *scan = [[DMSearchViewController alloc]init];
    [self.navigationController pushViewController:scan animated:YES];
}
-(IBAction)connectClick:(UIButton*)sender{
    DMHomeViewController *home = [[DMHomeViewController alloc]init];
    NSLog(@"===%ld",self.currentRow);
//    [self adjustEarWithRow:self.currentRow];
//    home.bleManager = self.bleManager;
    if ([NSObject isSimuLator]) {
        NSArray *arr1 = @[@"003333333333",@"003333333333"];
        [home.macArr addObjectsFromArray:arr1];
    }else{
       home.macArr = self.dataArr[self.currentRow];
    }
    [self.navigationController pushViewController:home animated:YES];
}
-(void)setupCollect{
//    DMCardFlowLayout *layout = [[DMCardFlowLayout alloc] init];
//    layout.itemSize = CGSizeMake(240, 260);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, KScaleHeight(155), SCREEN_WIDTH , 280) collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
//    self.collectionView.pagingEnabled = true; //影响滑动
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[DMDeviceCollectionCell class] forCellWithReuseIdentifier:kCellIdentifier_DMDeviceCollectionCell];
    self.collectionView.showsHorizontalScrollIndicator = false;
    [self.view addSubview:self.collectionView];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([NSObject isSimuLator]) {
        return 2;
    }
    return [DMAppUserSetting shareInstance].addressArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DMDeviceCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_DMDeviceCollectionCell forIndexPath:indexPath];
    cell.titleL.text = @"BE3000AI";
    cell.delegate = self;
    cell.deleteBtn.hidden = YES;
    UILongPressGestureRecognizer* longgs=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpress:)];
    [cell addGestureRecognizer:longgs];
    longgs.minimumPressDuration=1.0;//定义长按识别时长
    longgs.view.tag=indexPath.row;//将手势和cell的序号绑定
    
//    NSLog(@"data=%@",self.dataArr);
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"indexPathItem=%ld",(long)indexPath.item);
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
     
     DMDeviceCollectionCell *cell =(DMDeviceCollectionCell*) [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    if ([touches anyObject].view != cell.deleteBtn){
        cell.deleteBtn.hidden = YES;
    }
    
}

//MARK:-click method
-(void)didClickDeletePer:(DMDeviceCollectionCell *)cell{
    NSIndexPath *index = [self.collectionView indexPathForCell:cell];
    NSLog(@"delete%ld个",index.item);
    [self.dataArr removeObjectAtIndex:index.item];
    [[DMAppUserSetting shareInstance] setAddressArr:self.dataArr];
    if ([DMAppUserSetting shareInstance].addressArr.count<=0) {
        self.connectBtn.hidden = YES;
    }
    [self.collectionView reloadData];
}
//MARK:-longPress
-(IBAction)longpress:(UILongPressGestureRecognizer*)ges{
    if(ges.state==UIGestureRecognizerStateBegan){
        CGPoint point = [ges locationInView:_collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        //当没有点击到cell的时候不进行处理
        if (indexPath == nil) {
            return;
        }
        self.currentIndexPath = indexPath;
        DMDeviceCollectionCell *cell =(DMDeviceCollectionCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell == nil) {
            [self.collectionView layoutIfNeeded];//如果 cell 不是 visible 的 或者 indexPath 超过有效范围，就返回 nil。 性能上会有所牺牲
            cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        }
        cell.deleteBtn.hidden = NO;
        NSLog(@"%@",NSStringFromCGRect(cell.deleteBtn.frame));
//         [self.view bringSubviewToFront:cell.deleteBtn];
    }
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
//    //计算中心位置
//      double ceterX = scrollView.contentOffset.x + scrollView.frame.size.width * 0.5;
//      int currentPage = floor(ceterX / 240.0);
////      NSLog(@"currentPage=%d x=%f",currentPage,scrollView.contentOffset.x);
//
//    if (currentPage > 2) {
//        [scrollView setContentOffset:CGPointMake(-87+2*240, 0) animated:YES];
//    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
   
     DMDeviceCollectionCell *cell =(DMDeviceCollectionCell*) [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    cell.deleteBtn.hidden = YES;

//    LogMethod();
//    double ceterX = scrollView.contentOffset.x + scrollView.frame.size.width * 0.5;
//    int currentPage = floor(ceterX / 240.0);
////    NSLog(@"currentPage=%d x=%f width=%f",currentPage,scrollView.contentOffset.x,scrollView.size.width);
//    [scrollView setContentOffset:CGPointMake(-87+currentPage*240+currentPage*10, 0) animated:YES];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 将collectionView在控制器view的中心点转化成collectionView上的坐标
    CGPoint pInView = [self.view convertPoint:self.collectionView.center toView:self.collectionView];
    // 获取这一点的indexPath
    NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pInView];
    // 赋值给记录当前坐标的变量
//    self.currentIndexPath = indexPathNow;
    self.currentRow = indexPathNow.item;
    NSLog(@"currentRow==%ld",self.currentRow);
}

-(CustomFlowLayout *)layout{
    if(!_layout){
        _layout=[[CustomFlowLayout alloc] init];
        _layout.itemSize=CGSizeMake(240, 260);
        _layout.minimumLineSpacing = 10;
    }
    return _layout;
}
@end
