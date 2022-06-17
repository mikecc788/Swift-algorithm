//
//  DMEqCustomController.m
//  DMSound
//
//  Created by kiss on 2020/6/2.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMEqCustomController.h"
#import "DMGoBackButton.h"
#import "KSEqSlider.h"
#import "KSColorBgButton.h"

@interface DMEqCustomController ()<KSEqSliderDelegate>
@property(nonatomic,strong)NSString *eqValue;
@property(nonatomic,strong)KSEqSlider *slider;
@property(nonatomic,strong)NSMutableArray *values;
@property(nonatomic,strong)UIView *sliderView;
@property(nonatomic,strong)NSMutableDictionary *dic;
@property(nonatomic,strong)NSMutableArray *sumEqArr;
@end
#define leftDistance 40
#define sliderWidth 5
#define sliderYHeight 20
@implementation DMEqCustomController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arrCustom = @[@(0), @(0), @(0), @(0), @(0) ,@(0), @(0), @(0), @(0), @(0)];
    NSArray *popArr = @[@(0),@(2),@(0),@(1),@(0),@(0),@(0),@(1),@(1),@(2)];
    NSArray *vocalArr = @[@(0),@(0),@(0),@(0),@(2),@(6),@(4),@(1),@(0),@(0)];
    NSArray *classicArr =@[@(0),@(0),@(0),@(-1),@(0),@(0),@(1),@(1),@(2),@(3)];
    NSArray *bassBoosterArr =@[@(0),@(3),@(0),@(2),@(1),@(0),@(0),@(0),@(0),@(0)];
    NSArray *trebleReducerArr =@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(-1),@(-2),@(-3)];
    NSArray *rockArr =@[@(5),@(4),@(3),@(2),@(1),@(0),@(1),@(2),@(3),@(4)];
    NSArray *jazzArr =@[@(1),@(2),@(2),@(3),@(-2),@(-1),@(0),@(1),@(2),@(3)];
    NSArray *hipHopArr =@[@(5),@(5),@(4),@(3),@(0),@(1),@(2),@(3),@(4),@(5)];
    self.sumEqArr = [NSMutableArray array];
    [self.sumEqArr addObjectsFromArray:@[arrCustom,popArr,vocalArr,classicArr,bassBoosterArr,trebleReducerArr,rockArr,jazzArr,hipHopArr]];
    
    NSLog(@"点击了第%ld个进来的",self.selectItem);
    NSArray *titleArr = @[NSLocalizedString(@"自訂", nil),NSLocalizedString(@"流行", nil) ,NSLocalizedString(@"聲樂",nil),NSLocalizedString(@"古典",nil),NSLocalizedString(@"重低音",nil),NSLocalizedString(@"弱高音",nil),NSLocalizedString(@"搖滾",nil),NSLocalizedString(@"爵士",nil),NSLocalizedString(@"嘻哈",nil)];
    
    self.dic = [[NSMutableDictionary alloc]init];
    self.view.backgroundColor = Gloabal_bg;
    self.eqValue = @"070101020100FFFFFEFE";
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, 40, 100, BackHeight)];
    [back setMutableTitleWithString:titleArr[self.selectItem] textFont:[UIFont systemFontOfSize:33.33]];
    [self.view addSubview:back];
    self.values = [[NSMutableArray alloc]init];
//    NSLog(@"currentArr=%@",self.currentArr);
    if (self.selectItem >0) {
        [self.values addObjectsFromArray:self.currentArr];
    }else{
        if ([DMAppUserSetting shareInstance].customEqFirst.count>0){
            [self.values addObjectsFromArray:[DMAppUserSetting shareInstance].customEqFirst];
        }else{
            NSArray *arr = @[@(0), @(0), @(0), @(0), @(0) ,@(0), @(0), @(0), @(0), @(0)];
            [self.values addObjectsFromArray:arr];
        }
    }
    
    UIButton *rsetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rsetButton addTarget:self action:@selector(resetClick:) forControlEvents:UIControlEventTouchUpInside];
    [rsetButton setTitle:NSLocalizedString(@"重設", nil) forState:UIControlStateNormal];
    rsetButton.backgroundColor = [UIColor colorFromHexStr:@"#242528"];
    [rsetButton setTitleColor:[UIColor colorFromHexStr:@"#A2A2A2"] forState:UIControlStateNormal];
    [rsetButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    rsetButton.titleLabel.numberOfLines = 0;
    rsetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rsetButton.layer setCornerRadius:10];
    [self.view addSubview:rsetButton];
    [rsetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-20);
       make.top.equalTo(back.mas_bottom).offset(50);
       make.size.mas_equalTo(CGSizeMake(90, 50));
    }];
    [self setupSlider];
    [self leftLable];
}
-(void)setupSlider{
    [self removeSlider];
    UIView *sliderBgV = [[UIView alloc]initWithFrame:CGRectMake(40, KScaleHeight(200) , SCREEN_WIDTH, EQSliderHeight+30)];
    [self.view addSubview:sliderBgV];
//    sliderBgV.backgroundColor = [UIColor redColor];
    self.sliderView = sliderBgV;
    CGFloat width = (SCREEN_WIDTH - leftDistance*2) /9;
    
    for (int i =0; i<self.values.count; i++){
        CGFloat sliderH = EQSliderHeight;
        CGFloat sliderW = sliderWidth;
        CGFloat sliderX = width *i + 8;
        CGFloat sliderY = sliderYHeight;
        self.slider = [[KSEqSlider alloc] init];
        self.slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
        CGFloat value = [self.values[i] intValue];
        self.slider.isShowTitle = YES;
        self.slider.titleStyle = KSEqTopTitleStyle;
        self.slider.value = value;
        self.slider.tag = i;
        self.slider.delegate = self;
        [self.slider setSliderValue:value];
        [sliderBgV addSubview:self.slider];
         self.slider.frame = CGRectMake(sliderX, sliderY, sliderW, sliderH);
        [self.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
}
-(void)leftLable{
     CGFloat labelY = KScaleHeight(200) + sliderYHeight;
    CGFloat interval =  (EQSliderHeight - 10)/ 2;
    NSArray *textArr = @[@"7db",@"0db",@"-7db"];
    for (int i =0;i < 3; i++) {
         UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, labelY + interval*i-2, 24, 10)];
         label.text = textArr[i];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor colorFromHexStr:@"#A1A1A1"];
        [self.view addSubview:label];
    }
    
    CGFloat topH = kMaxY(self.sliderView.frame)+15;
    NSMutableArray *xArray = [NSMutableArray arrayWithObjects:@"40",@"80",@"125",@"250",@"500", @"1K",@"2K",@"4K",@"8K",@"16K",nil];
    CGFloat h = (SCREEN_WIDTH - leftDistance*2  -sliderWidth*0.5) / (xArray.count -1);
    for (int i = 0; i < xArray.count; i++) {
        UILabel *label = [UILabel new];
        label.text = xArray[i];
        [self.view addSubview:label];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"#DFDFDF"];
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake( leftDistance + i * h +5 , topH + 15, 40, 20);
        [label sizeToFit];
    }
    
}
-(void)resetSliderWith:(NSArray*)arr{
    [self removeSlider];
    UIView *sliderBgV = [[UIView alloc]initWithFrame:CGRectMake(40, KScaleHeight(200) , SCREEN_WIDTH, EQSliderHeight+30)];
    [self.view addSubview:sliderBgV];
    self.sliderView = sliderBgV;
    
    CGFloat width = (SCREEN_WIDTH - leftDistance*2) /9;
    [self.values addObjectsFromArray:arr];
    for (int i =0; i<arr.count; i++){
    CGFloat sliderH = EQSliderHeight;
    CGFloat sliderW = sliderWidth;
    CGFloat sliderX = width *i + 8;
    CGFloat sliderY = sliderYHeight;
    self.slider = [[KSEqSlider alloc] init];
    self.slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    CGFloat value = [arr[i] intValue];
    self.slider.isShowTitle = YES;
    self.slider.titleStyle = KSEqTopTitleStyle;
    self.slider.value = value;
    self.slider.tag = i;
    self.slider.delegate = self;
    [self.slider setSliderValue:value];
       [self.sliderView addSubview:self.slider];
    self.slider.frame = CGRectMake(sliderX, sliderY, sliderW, sliderH);
    [self.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
}
-(void)sliderValueChange:(KSEqSlider *)slider{
//    NSLog(@"sliderValueChange=%f",slider.value);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.00 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImageView *slideImage = (UIImageView *)[slider.subviews lastObject];
        if ([[slider.subviews lastObject] isKindOfClass:[UIImageView class]]) {
            NSLog(@"最后一个是imageV");
            for (UIView *sub in slider.subviews) {
                if ([sub isKindOfClass:[KSColorBgButton class]]) {
                    [slider insertSubview:sub aboveSubview:slider.subviews.lastObject];
                }
            }
            [slider.btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(slideImage).offset(45);
            }];
        }
    });
}
//MARK:-SliderDelegate
-(void)beginSwip{
    NSLog(@"beginSwip");
}

- (void)endSwipValue:(CGFloat)value Tag:(NSInteger)tag{
    
    [self.values replaceObjectAtIndex:tag withObject:@(roundf(value))];
    NSLog(@"endSwipValue=%@",self.values);
    
    NSString *key = [NSString stringWithFormat:@"%ld",tag];
    [self.dic setValue:self.values forKey:key];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:DMSendSliderNotification object:self.dic userInfo:nil];
    [self.dic removeAllObjects];
    
    switch (self.selectItem) {
        case 0:{
            [[DMAppUserSetting shareInstance] setCustomEqFirst:self.values];
        }break;
        case 1:{
            [[DMAppUserSetting shareInstance] setCustomPopArr:self.values];
        }break;
        case 2:{
            [[DMAppUserSetting shareInstance] setCustomVocalArr:self.values];
        }break;
        case 3:{
            [[DMAppUserSetting shareInstance] setCustomClassicArr:self.values];
        }break;
        case 4:{
            [[DMAppUserSetting shareInstance] setCustomBassBoosterArr:self.values];
            
        }break;
        case 5:{
            [[DMAppUserSetting shareInstance] setCustomTrebleReducerArr:self.values];
        }break;
        case 6:{
            [[DMAppUserSetting shareInstance] setCustomRockArr:self.values];
        }break;
        case 7:{
            [[DMAppUserSetting shareInstance] setCustomJazzArr:self.values];
        }break;
        case 8:{
            [[DMAppUserSetting shareInstance] setCustomHipHopArr:self.values];
        }break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(updateSumArr:)]) {
           [self.delegate updateSumArr:self.selectItem];
       }
}
-(void)removeSlider{
    [self.sliderView removeFromSuperview];
    for (UIView *sub in self.view.subviews) {
        if ([sub isKindOfClass:[KSEqSlider class]]) {
            [sub removeFromSuperview];
        }
    }
}
//MARK: Click Method
-(IBAction)resetClick:(UIButton*)sender{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //自定义的reset和其他几个reset不一样
    NSString *key = [NSString stringWithFormat:@"%ld",self.selectItem];
    [self.dic setValue:self.sumEqArr[self.selectItem] forKey:key];
    [center postNotificationName:DMSetEQResetNotification object:self.dic userInfo:nil];
    [self.values removeAllObjects];
    switch (self.selectItem) {
        case 0:{
            [[DMAppUserSetting shareInstance] setCustomEqFirst:self.sumEqArr[0]];
        }break;
        case 1:{
            [[DMAppUserSetting shareInstance] setCustomPopArr:self.sumEqArr[1]];
        }break;
        case 2:{
            [[DMAppUserSetting shareInstance] setCustomVocalArr:self.sumEqArr[2]];
        }break;
        case 3:{
            [[DMAppUserSetting shareInstance] setCustomClassicArr:self.sumEqArr[3]];
        }break;
        case 4:{
            [[DMAppUserSetting shareInstance] setCustomBassBoosterArr:self.sumEqArr[4]];
            
        }break;
        case 5:{
            [[DMAppUserSetting shareInstance] setCustomTrebleReducerArr:self.sumEqArr[5]];
        }break;
        case 6:{
            [[DMAppUserSetting shareInstance] setCustomRockArr:self.sumEqArr[6]];
        }break;
        case 7:{
            [[DMAppUserSetting shareInstance] setCustomJazzArr:self.sumEqArr[7]];
        }break;
        case 8:{
            [[DMAppUserSetting shareInstance] setCustomHipHopArr:self.sumEqArr[8]];
        }break;
        default:
            break;
    }
    [self resetSliderWith:self.sumEqArr[self.selectItem]];
    
    if ([self.delegate respondsToSelector:@selector(updateSumArr:)]) {
        [self.delegate updateSumArr:self.selectItem];
    }
}

@end
