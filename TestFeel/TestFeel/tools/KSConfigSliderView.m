//
//  KSConfigSliderView.m
//  FastPair
//
//  Created by cl on 2019/7/29.
//  Copyright © 2019 KSB. All rights reserved.
//

#import "KSConfigSliderView.h"
#import "UIColor+Extension.h"
#import "UIView+Extension.h"
#define SelectColor [UIColor colorWithHexString:@"#2D2D2D"]
#define NomaleColor [UIColor colorWithHexString:@"#999999"]
@interface KSConfigSliderView()
@property (nonatomic, strong) UIView                           *slideLightView;
@property (nonatomic, strong) NSMutableArray<UIButton *>        *labels;
@property (nonatomic, strong) NSMutableArray<NSString *>       *titles;
@property (nonatomic, assign) NSInteger                        tabIndex;
@property (nonatomic, assign) CGFloat                          itemWidth;
@property(nonatomic,assign)CGFloat buttonWidth;

@end

@implementation KSConfigSliderView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _labels = [NSMutableArray array];
        _titles = [NSMutableArray array];
  
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if(_titles.count == 0) {
        return;
    }
    
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        [subView removeFromSuperview];
    }];
    [_labels removeAllObjects];
    
    CGFloat itemWidth = _itemWidth = self.width/_titles.count;
    [_titles enumerateObjectsUsingBlock:^(NSString * title, NSUInteger idx, BOOL *stop) {
        UIButton *label = [[UIButton alloc]init];
//        label.text = title;
        [label setTitle:title forState:(UIControlStateNormal)];
//        label.textColor = NomaleColor;
        [label setTitleColor:NomaleColor forState:(UIControlStateNormal)];
        if (idx == 0) {
            [label setImage:[UIImage imageNamed:@"组 19-1"] forState:(UIControlStateNormal)];
        }else{
            [label setImage:[UIImage imageNamed:@"组 19"] forState:(UIControlStateNormal)];
        }
        label.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
//        label.textAlignment = NSTextAlignmentCenter;
        label.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        int titleFont;
        
        titleFont = 22;
//            label.font = ArialBoldFont(22);
        label.titleLabel.font = [UIFont systemFontOfSize:22];
        
        label.tag = idx;
        label.userInteractionEnabled = YES;
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapAction:)]];
        [self.labels addObject:label];
        [self addSubview:label];
        label.frame = CGRectMake(idx*itemWidth, 0, itemWidth, self.bounds.size.height);
         NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:titleFont],};
        CGSize titleSize = [label.titleLabel.text sizeWithAttributes:attributes];
        
        
        self.buttonWidth = titleSize.width + 10 + label.imageView.width;
        NSLog(@"titleSize==%f",self.buttonWidth);
//        CGSize textSize = [label.text boundingRectWithSize:CGSizeMake(itemWidth, self.bounds.size.height) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;;
//        [label setFrame:CGRectMake(idx*itemWidth, 0, textSize.width, textSize.height)];

        
        if(idx != self.titles.count - 1) {
            UIView *spliteLine = [[UIView alloc] initWithFrame:CGRectMake((idx+1)*itemWidth - 0.25f, 12.5f, 0.5f, self.bounds.size.height - 25.0f)];
            spliteLine.backgroundColor = [UIColor clearColor];
            spliteLine.layer.zPosition = 10;
            [self addSubview:spliteLine];
        }
    }];
//    _labels[_tabIndex].textColor = SelectColor;
    [_labels[_tabIndex] setTitleColor:SelectColor forState:(UIControlStateNormal)];
    
    
    _slideLightView = [[UIView alloc] init];
    _slideLightView.backgroundColor = [UIColor orangeColor];
    //之前居中的x位置 _tabIndex * itemWidth + itemWidth*0.5
    _slideLightView.frame = CGRectMake(_tabIndex * itemWidth + self.buttonWidth*0.5, self.bounds.size.height, 6, 6);
    _slideLightView.layer.cornerRadius = 3;
    _slideLightView.layer.masksToBounds = YES;
    [self addSubview:_slideLightView];
}

- (void)setLabels:(NSArray<NSString *> *)titles tabIndex:(NSInteger)tabIndex {
    [_titles removeAllObjects];
    [_titles addObjectsFromArray:titles];
    _tabIndex = tabIndex;
}

- (void)onTapAction:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    if(_delegate) {
        CGRect frame = self.slideLightView.frame;
//        frame.origin.x = self.itemWidth * index + self.itemWidth *0.5;
        frame.origin.x = self.itemWidth * index + self.buttonWidth *0.5;
        
        [UIView animateWithDuration:0.50
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
//                            CGRect frame = self.slideLightView.frame;
//                             frame.origin.x = self.itemWidth * index + self.itemWidth *0.5;
//                             frame.size.width = 60;
//                             frame.size.height = 10;
//                             [self.slideLightView setFrame:frame];
                             
                             [self.slideLightView setFrame:frame];
                             [self.labels enumerateObjectsUsingBlock:^(UIButton *label, NSUInteger idx, BOOL *stop) {
//                                 label.textColor = index == idx ? SelectColor : NomaleColor;
//
                                 if (index == idx) {
                                     [label setTitleColor:SelectColor forState:(UIControlStateNormal)];
                                 }else{
                                     [label setTitleColor:NomaleColor forState:(UIControlStateNormal)];
                                 }
                             }];
                         } completion:^(BOOL finished) {
                             
                             [self.delegate onTabTapAction:index];
                         }];
        
    }
}



@end
