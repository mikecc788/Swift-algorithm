//
//  DMCardView.m
//  DMSound
//
//  Created by kiss on 2020/6/3.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMCardView.h"
#import "DMCardFlowLayout.h"
#import "DMCardCollectionCell.h"

@interface DMCardView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;

@end

static NSString * const DMCollectionViewCellId = @"DMCollectionViewCellId";


@implementation DMCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}
- (void)buildUI {
    DMCardFlowLayout *layout = [[DMCardFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(220, 240);

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = true;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[DMCardCollectionCell class] forCellWithReuseIdentifier:DMCollectionViewCellId];
    self.collectionView.showsHorizontalScrollIndicator = false;
    [self addSubview:self.collectionView];
 
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DMCardCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DMCollectionViewCellId forIndexPath:indexPath];
    cell.titleL.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //计算中心位置
      double ceterX = scrollView.contentOffset.x + scrollView.frame.size.width * 0.5;
      int currentPage = floor(ceterX / 240.0);
      NSLog(@"currentPage=%d x=%f",currentPage,scrollView.contentOffset.x);
    if (currentPage > 2) {
        [scrollView setContentOffset:CGPointMake(-87+2*240, 0) animated:YES];
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    LogMethod();
    double ceterX = scrollView.contentOffset.x + scrollView.frame.size.width * 0.5;
    int currentPage = floor(ceterX / 240.0);
    NSLog(@"currentPage=%d x=%f",currentPage,scrollView.contentOffset.x);
    [scrollView setContentOffset:CGPointMake(-87+currentPage*240, 0) animated:YES];
}
@end
