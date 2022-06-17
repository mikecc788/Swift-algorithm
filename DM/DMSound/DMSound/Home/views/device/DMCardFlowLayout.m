//
//  DMCardFlowLayout.m
//  DMSound
//
//  Created by kiss on 2020/6/3.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMCardFlowLayout.h"
#define LineSpacing 50
@interface DMCardFlowLayout()

@end

@implementation DMCardFlowLayout
- (instancetype)init {
    if (self = [super init]) {
        self.minimumLineSpacing = LineSpacing;
        //设置内边距
           CGFloat insert =(self.collectionView.frame.size.width-self.itemSize.width)/2;
        self.sectionInset = UIEdgeInsetsMake(0, insert, 0, insert);
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;//速率
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //水平方向
    }
    return self;
}

/**
  * 用来做布局的初始化操作（不建议在init方法中进行布局的初始化操作）
 */
//- (void)prepareLayout {
//    [super prepareLayout];
//
//}

/**
   * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
   * 一旦重新刷新布局，就会重新调用下面的方法：
   * 1.prepareLayout
   * 2.layoutAttributesForElementsInRect:方法
  */
 - (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
 {
    return YES;
}


/**
* 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
* 这个方法的返回值决定了rect范围内所有元素的排布（frame）
 */
//需要在viewController中使用上ZWLineLayout这个类后才能重写这个方法！！

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    
    NSArray *original = [super layoutAttributesForElementsInRect:rect];
    NSArray *array = [[NSArray alloc] initWithArray:original copyItems:YES];
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes * attributes in array) {
        //判断相交
        if (CGRectIntersectsRect(visibleRect, rect)) {
        //当前视图中心点 距离item中心点距离
       CGFloat  distance  =  CGRectGetMidX(self.collectionView.bounds) - attributes.center.x;
        CGFloat  normalizedDistance = distance / 260;
            if (ABS(distance) < 210) {
                //放大倍数
                CGFloat zoom = 1 + 0.2 * (1 - ABS(normalizedDistance));
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1);
                attributes.zIndex = 1;
            }
        }
    }
    
    return array;
}

/**
   * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
  proposedContentOffset这个是最终的 偏移量的值 但是实际的情况还是要根据返回值来定
 velocity  是滚动速率  有个x和y 如果x有值 说明x上有速度
 *  如果y有值 说明y上又速度 还可以通过x或者y的正负来判断是左还是右（上还是下滑动）  有时候会有用
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    /**/
     CGFloat  offSetAdjustment = MAXFLOAT;
      //预期停止水平中心点
    CGFloat horizotalCenter = proposedContentOffset.x + self.collectionView.bounds.size.width / 2;
    
       //预期滚动停止时的屏幕区域
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    //找出最接近中心点的item
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes * attributes in array) {
        CGFloat currentCenterX = attributes.center.x;
        if (ABS(currentCenterX - horizotalCenter) < ABS(offSetAdjustment)) {
            offSetAdjustment = currentCenterX - horizotalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offSetAdjustment, proposedContentOffset.y);
    
}

@end
