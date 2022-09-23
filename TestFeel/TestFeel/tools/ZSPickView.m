//
//  ZSPickView.m
//  ZSPickView
//
//  Created by Tony on 16/8/19.
//  Copyright © 2016年 Tony. All rights reserved.
//  如果有更好的改进想法,请告诉我tonyshanm,如果喜欢给个star也是可以滴
//

#import "ZSPickView.h"
#import "UIColor+Extension.h"
@interface ZSPickView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic,strong)UIPickerView *pickview;
@property(nonatomic,strong)NSArray *oneArr;
@property(nonatomic,strong)NSArray *twoArr;
@property(nonatomic,strong)NSArray *threeArr;
@property(nonatomic,assign)NSInteger isNum;
@property(nonatomic,strong)UIBarButtonItem *cancelBtn;
@property(nonatomic,strong)UIBarButtonItem *sureBtn;
@property(nonatomic,strong)NSArray *sureArr;
@property(nonatomic,strong)NSString *oneStr;
@property(nonatomic,strong)NSString *twoStr;
@property(nonatomic,strong)NSString *threeStr;
@property(nonatomic,assign)BOOL isrelation;
// 蒙层视图
@property (nonatomic, strong) UIView *maskView;
//// 标题栏背景视图
//@property (nonatomic, strong) UIView *titleBarView;
//// 左边取消按钮
//@property (nonatomic, strong) UIButton *cancelBtn;
//// 右边确定按钮
//@property (nonatomic, strong) UIButton *doneBtn;
//// 中间标题
//@property (nonatomic, strong) UILabel *titleLabel;

@end
@implementation ZSPickView
#define screenH [UIScreen mainScreen].bounds.size.height
#define screenW [UIScreen mainScreen].bounds.size.width
#define kKeyWindow [[[UIApplication sharedApplication] windows] objectAtIndex:0]
-(instancetype)initWithComponentArr:(NSArray *)Arr{
    self = [super init];
    if (self) {
        self.componentArr = Arr;
        [self setupUI];
    }
    return self;
}

#pragma mark - 蒙层视图
//- (UIView *)maskView {
//    if (!_maskView) {
//        _maskView = [[UIView alloc]initWithFrame:kKeyWindow.bounds];
//        _maskView.backgroundColor = [UIColor blackColor];
//        _maskView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapMaskView:)];
//        [_maskView addGestureRecognizer:myTap];
//    }
//    return _maskView;
//}
#pragma mark - 点击蒙层视图事件
- (void)didTapMaskView:(UITapGestureRecognizer *)sender {
    [self removePickerFromView:nil];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}


-(UIPickerView *)pickview{
    if (_pickview == nil) {
        _pickview = [[UIPickerView alloc]init];
        _pickview.delegate = self;
        _pickview.dataSource = self;
        _pickview.frame = CGRectMake(0, screenH - 216, screenW, 216);
        _pickview.backgroundColor = [UIColor colorFromHexStr:@"#854794"];
    }
    return _pickview;
}

-(void)setComponentArr:(NSArray *)componentArr{
    _componentArr = componentArr;
    for (int i=0; i<componentArr.count; i++) {
        id sub = componentArr[i];
        if ([sub isKindOfClass:[NSArray class]]) {
            self.isNum = componentArr.count;
            if (i == 0) {
                self.oneArr = sub;
            }
            if (i == 1) {
                self.twoArr = sub;
            }
            if (i == 2) {
                self.threeArr = sub;
            }
        }else{
            self.oneArr = componentArr;
        }
    }
    [self.pickview reloadAllComponents];
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (self.isNum) {
        return self.isNum;
    }else{
        return 1;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.isNum) {
        if (component == 0) {
            return self.oneArr.count;
        }
        if (component == 1) {
            return self.twoArr.count;
        }
        if (component == 2) {
            return self.threeArr.count;
        }
    }else{
        return self.oneArr.count;
    }
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (self.isNum) {
        if (component == 0) {
            
            return [NSString stringWithFormat:@"%@       .",self.oneArr[row]];
             
        }
        if (component == 1) {
            return [NSString stringWithFormat:@"%@",self.twoArr[row]];
        }
        if (component == 2) {
            return [NSString stringWithFormat:@"%@",self.threeArr[row]];
        }
    }else{
        return [NSString stringWithFormat:@"%@",self.oneArr[row]];
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (self.isNum) {
        if (component == 0) {
            self.oneStr = self.oneArr[row];
        }
        if (component == 1) {
            self.twoStr = self.twoArr[row];
        }
        if (component == 2) {
            self.threeStr = self.threeArr[row];
        }
    }else{
        self.oneStr = self.oneArr[row];
    }
}

-(void)setupUI{
    
    _maskView = [[UIView alloc]initWithFrame:kKeyWindow.bounds];
    _maskView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.6];
    _maskView.userInteractionEnabled = YES;
    UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapMaskView:)];
    [_maskView addGestureRecognizer:myTap];
    
    CGFloat y = kKeyWindow.bounds.size.height;
    
//    self.frame = CGRectMake(0, 0, screenW, screenH);
    self.frame = kKeyWindow.bounds;
    [self addSubview:_maskView];
    [self addSubview:self.pickview];
    [kKeyWindow addSubview:self];
    
//    _pickview.frame = CGRectMake(0, screenH - 216.0/667.0*screenH, screenW, 216.0/667.0*screenH);
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, screenH - 260, screenW, 44.0)];
    toolbar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *defalutItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    toolbar.items = @[self.cancelBtn,defalutItem,self.sureBtn];
    [self addSubview:toolbar];
}

-(void)cancelClick{
//    [self removeFromSuperview];
    [self removePickerFromView:nil];
}
#pragma mark - 移除视图方法
- (void)removePickerFromView:(UIView *)view{
    if (view) {
        [self removeFromSuperview];
    }else {
        // 关闭动画
        [UIView animateWithDuration:0.2 animations:^{
//            CGFloat alertViewHeight = self.alertView.bounds.size.height;
//            CGRect rect = self.alertView.frame;
//            rect.origin.y += alertViewHeight;
//            self.alertView.frame = rect;
//            if (!self.pickerStyle.hiddenMaskView) {
//                self.maskView.alpha = 0;
//            }
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}
-(void)sureClick{
    if (self.sureBlock) {
        self.sureBlock(self.sureArr.copy);
    }
    [self removeFromSuperview];
}


-(NSArray *)sureArr{
    if (_sureArr == nil) {
        _sureArr = [NSArray array];
        if (self.oneStr == nil) {
            self.oneStr = self.oneArr[0];
        }
        if (self.twoStr == nil) {
            self.twoStr = self.twoArr[0];
        }
        if (self.threeStr == nil) {
            self.threeStr = self.threeArr[0];
        }
        if (self.isNum == 1) {
            _sureArr = @[self.oneStr];
        }
        if (self.isNum == 2) {
            _sureArr = @[self.oneStr,self.twoStr];
        }
        if (self.isNum == 3) {
            _sureArr = @[self.oneStr,self.twoStr,self.threeStr];
        }
    }
    return _sureArr;
}



-(UIBarButtonItem *)cancelBtn{
    if (_cancelBtn == nil) {
        _cancelBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClick)];
    }
    return _cancelBtn;
}

-(UIBarButtonItem *)sureBtn{
    if (_sureBtn == nil) {
        _sureBtn = [[UIBarButtonItem alloc]initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(sureClick)];
    }
    return _sureBtn;
}

@end
