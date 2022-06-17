//
//  DMEQViewController.m
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMEQViewController.h"
#import "DMEqCollectionViewCell.h"
#import "DMEQReusableView.h"
#import "DMEqCustomController.h"

@interface DMEQViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,DMEQReusableViewDelegate,DMEqCollectionDelegate,DMEQSliderViewDelegate>
@property (strong , nonatomic)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *titleArr;
@property(nonatomic,strong)NSArray *textArr;
@property (assign, nonatomic) NSIndexPath *selectedIndexPath;//单选，当前选中的行
@property(nonatomic,strong)DMEQReusableView *headerView;
@property(nonatomic,strong)NSArray *popArr;
@property(nonatomic,strong)NSArray *vocalArr;
@property(nonatomic,strong)NSArray *classicArr;
@property(nonatomic,strong)NSArray *bassBoosterArr;
@property(nonatomic,strong)NSArray *trebleReducerArr;
@property(nonatomic,strong)NSArray *rockArr;
@property(nonatomic,strong)NSArray *jazzArr;
@property(nonatomic,strong)NSArray *hipHopArr;
@property(nonatomic,strong)NSMutableArray *sumArr;
@property(nonatomic,assign)BOOL isFirst;
@end

@implementation DMEQViewController
-(void)viewWillAppear:(BOOL)animated{
    //sumArr eq滑动改变
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirst = NO;
    [self setupColl];
    self.titleArr = @[@"POP",@"Vocal",@"Classic",@"Bass Booster",@"Treble Reducer",@"Rock",@"Jazz",@"Hip Hop"];
    self.textArr = @[ NSLocalizedString(@"流行", nil) ,NSLocalizedString(@"聲樂",nil),NSLocalizedString(@"古典",nil),NSLocalizedString(@"重低音",nil),NSLocalizedString(@"弱高音",nil),NSLocalizedString(@"搖滾",nil),NSLocalizedString(@"爵士",nil),NSLocalizedString(@"嘻哈",nil)];
    self.popArr =[DMAppUserSetting shareInstance].customPopArr.count>0 ?[DMAppUserSetting shareInstance].customPopArr: @[@(0),@(2),@(0),@(1),@(0),@(0),@(0),@(1),@(1),@(2)];
    self.vocalArr =[DMAppUserSetting shareInstance].customVocalArr.count>0 ?[DMAppUserSetting shareInstance].customVocalArr: @[@(0),@(0),@(0),@(0),@(2),@(6),@(4),@(1),@(0),@(0)];
    self.classicArr =[DMAppUserSetting shareInstance].customClassicArr.count>0 ?[DMAppUserSetting shareInstance].customClassicArr:@[@(0),@(0),@(0),@(-1),@(0),@(0),@(1),@(1),@(2),@(3)];
    self.bassBoosterArr =[DMAppUserSetting shareInstance].customBassBoosterArr.count>0 ?[DMAppUserSetting shareInstance].customBassBoosterArr:@[@(0),@(3),@(0),@(2),@(1),@(0),@(0),@(0),@(0),@(0)];
    self.trebleReducerArr =[DMAppUserSetting shareInstance].customTrebleReducerArr.count>0 ?[DMAppUserSetting shareInstance].customTrebleReducerArr:@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(-1),@(-2),@(-3)];
    self.rockArr =[DMAppUserSetting shareInstance].customRockArr.count>0 ?[DMAppUserSetting shareInstance].customRockArr:@[@(5),@(4),@(3),@(2),@(1),@(0),@(1),@(2),@(3),@(4)];
    self.jazzArr =[DMAppUserSetting shareInstance].customJazzArr.count>0 ?[DMAppUserSetting shareInstance].customJazzArr:@[@(1),@(2),@(2),@(3),@(-2),@(-1),@(0),@(1),@(2),@(3)];
    self.hipHopArr =[DMAppUserSetting shareInstance].customHipHopArr.count>0 ?[DMAppUserSetting shareInstance].customHipHopArr:@[@(5),@(5),@(4),@(3),@(0),@(1),@(2),@(3),@(4),@(5)];
    self.sumArr = [NSMutableArray array];
    [self.sumArr addObjectsFromArray:@[self.popArr,self.vocalArr,self.classicArr,self.bassBoosterArr,self.trebleReducerArr,self.rockArr,self.jazzArr,self.hipHopArr]];
    if (![DMAppUserSetting shareInstance].selectTag) {
        NSLog(@"第一次进来");
        self.isFirst = YES;
//        [DMAppUserSetting shareInstance].selectTag = -1;
    }
}
-(void)setupColl{
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
;
//    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, SafeAreaTopHeight, 0);
    _collectionView.showsVerticalScrollIndicator = NO;        //注册
     self.collectionView.backgroundColor = Gloabal_bg;
    
    [_collectionView registerClass:[DMEQReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCellIdentifier_DMEQReusableView];
    
    [_collectionView registerClass:[DMEqCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier_DMEqCollectionViewCell];
    

    [self.view addSubview:_collectionView];
   
}
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 8;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DMEqCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_DMEqCollectionViewCell forIndexPath:indexPath];
    cell.gridImageView.image = [UIImage imageNamed: self.titleArr[indexPath.item]];
    cell.delegate = self;
    cell.gridLabel.tag = indexPath.row+1;
    [cell.gridLabel setTitle:self.textArr[indexPath.item] forState:(UIControlStateNormal)];
    if ([DMAppUserSetting shareInstance].selectTag == indexPath.row +1) {
        NSLog(@"===%ld",[DMAppUserSetting shareInstance].selectTag);
        [cell selectItem];
        self.selectedIndexPath = indexPath;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [DMAppUserSetting shareInstance].selectTag = indexPath.row+1;
    self.headerView.headerImg.hidden = YES;
    DMEqCollectionViewCell *cell =(DMEqCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell selectItem];
    DMEqCollectionViewCell *selectCell =(DMEqCollectionViewCell*)[collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [selectCell isCancelSelect];
    self.selectedIndexPath = indexPath;
    NSLog(@"current=%@ lastText=%@",cell.gridLabel.titleLabel.text,selectCell.gridLabel.titleLabel.text);
    if ([cell.gridLabel.titleLabel.text isEqualToString:selectCell.gridLabel.titleLabel.text]) {
        [selectCell selectItem];
    }
    if ([self.delegate respondsToSelector:@selector(sendCustomArr:)]) {
        [self.delegate sendCustomArr:self.sumArr[indexPath.item]];
    }

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH )/2, 100);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader){
        if (indexPath.section == 0) {
            DMEQReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCellIdentifier_DMEQReusableView forIndexPath:indexPath];
            headerView.delegate = self;
            if (self.isFirst) {
                headerView.headerImg.hidden = NO;
                self.isFirst = NO;
                [DMAppUserSetting shareInstance].selectTag = EQHeaderSelectTag;
                //第一次进来重设EQ
                [[NSNotificationCenter defaultCenter] postNotificationName:DMSetEQResetNotification object:nil userInfo:nil];
            }
            self.headerView = headerView;
            reusableview = headerView;
        }
    }
    
    return reusableview;
}
#pragma mark - head宽高

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section  {
    return CGSizeMake(SCREEN_WIDTH, 180);  //推荐适合的宽高
}
#pragma mark - <UICollectionViewDelegateFlowLayout>
#pragma mark - X间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return  0;
}
#pragma mark - Y间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return  0;
    
}
//MARK:头部点击
-(void)clickCustomBtn{
    LogMethod();
    [DMAppUserSetting shareInstance].selectTag = EQHeaderSelectTag;
    self.headerView.headerImg.hidden = NO;
    DMEqCollectionViewCell *cell =(DMEqCollectionViewCell*) [self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [cell isCancelSelect];
    DMEqCustomController *custom = [[DMEqCustomController alloc]init];
    custom.selectItem = 0;
    [self.navigationController pushViewController:custom animated:YES];
}
-(void)clickImageBg{
    [DMAppUserSetting shareInstance].selectTag = EQHeaderSelectTag;
    self.headerView.headerImg.hidden = NO;
    DMEqCollectionViewCell *cell =(DMEqCollectionViewCell*) [self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [cell isCancelSelect];
    if ([DMAppUserSetting shareInstance].customEqFirst.count>0) {
        if ([self.delegate respondsToSelector:@selector(sendCustomArr:)]) {
            [self.delegate sendCustomArr:[DMAppUserSetting shareInstance].customEqFirst];
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:DMSetEQResetNotification object:nil userInfo:nil];
    }
}
//MARK:点击其他八个文字进入
-(void)didClickEqTag:(NSInteger)tag cell:(DMEqCollectionViewCell * _Nonnull)cell{
     [DMAppUserSetting shareInstance].selectTag = tag;
    NSIndexPath *index = [self.collectionView indexPathForCell:cell];
    
    self.headerView.headerImg.hidden = YES;
    [cell selectItem];
    DMEqCollectionViewCell *selectCell =(DMEqCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [selectCell isCancelSelect];
    self.selectedIndexPath = index;
    NSLog(@"didClickEq =%@ lastText=%@",cell.gridLabel.titleLabel.text,selectCell.gridLabel.titleLabel.text);
    if ([cell.gridLabel.titleLabel.text isEqualToString:selectCell.gridLabel.titleLabel.text]) {
        [selectCell selectItem];
    }
    if ([self.delegate respondsToSelector:@selector(sendCustomArr:)]) {
        [self.delegate sendCustomArr:self.sumArr[index.item]];
    }
    
    DMEqCustomController *custom = [[DMEqCustomController alloc]init];
    custom.currentArr = self.sumArr[index.item];
    custom.delegate = self;
    custom.selectItem = tag;
    [self.navigationController pushViewController:custom animated:YES];
}
//MARK:更新sum数组的值 滑动的时候
-(void)updateSumArr:(NSInteger)currentItem{
    NSLog(@"updateSumArr 第%ld个",currentItem);
    switch (currentItem) {
    case 1:{
        [self.sumArr replaceObjectAtIndex:currentItem -1 withObject:[DMAppUserSetting shareInstance].customPopArr];
    }break;
    case 2:{
        [self.sumArr replaceObjectAtIndex:currentItem -1 withObject:[DMAppUserSetting shareInstance].customVocalArr];
    }break;
    case 3:{
        [self.sumArr replaceObjectAtIndex:currentItem -1 withObject:[DMAppUserSetting shareInstance].customClassicArr];
    }break;
    case 4:{
        [self.sumArr replaceObjectAtIndex:currentItem -1 withObject:[DMAppUserSetting shareInstance].customBassBoosterArr];
        
    }break;
    case 5:{
        [self.sumArr replaceObjectAtIndex:currentItem -1 withObject:[DMAppUserSetting shareInstance].customTrebleReducerArr];
    }break;
    case 6:{
     
        [self.sumArr replaceObjectAtIndex:currentItem -1 withObject:[DMAppUserSetting shareInstance].customRockArr];
    }break;
    case 7:{
        [self.sumArr replaceObjectAtIndex:currentItem -1 withObject:[DMAppUserSetting shareInstance].customJazzArr];
    }break;
    case 8:{
        [self.sumArr replaceObjectAtIndex:currentItem -1 withObject:[DMAppUserSetting shareInstance].customHipHopArr];
    }break;
        default:
            break;
    }
}

@end
