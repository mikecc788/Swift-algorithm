//
//  ViewController.m
//  TestFeel
//
//  Created by app on 2022/3/7.
//

#import "ViewController.h"
#import "ZFProgressView.h"
#import <Masonry.h>
#import "ZSPickView.h"
#import "BRPickerView.h"
#import "KSConfigSliderView.h"
#import "LFSBottomActionSheet.h"
#import "CircleViewController.h"
#import "NSObject+Extension.h"
#import "KSBatteryView.h"
#import "KSSearchBatteryView.h"
#import "UIButton+Alignment.h"
#import "UIButton+AttStrAlignment.h"
#import "HYRadix.h"
#import "LFSPopTextView.h"
#import "LFSDeviceInfo.h"
#import "MBProgressHUD+Extension.h"
#import "KSAlertTool.h"
#import "UIView+Extension.h"
#import "SecondViewController.h"
#import "TopTipsView.h"
#import "MBProgressHUD.h"
#import "LFSFitSmartPopView.h"
@interface ViewController ()<LFSBottomActionSheetDelegate>
@property (nonatomic,strong) ZFProgressView *progress;
@property NSUInteger count;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign)NSInteger second;
@property (nonatomic,assign)NSInteger minute;
@property (nonatomic,strong) NSTimer *countTimer;
@property(nonatomic,strong)UILabel *label;

@property(nonatomic,strong)NSArray *arr1;
@property(nonatomic,strong)NSArray *arr2;
@property(nonatomic,strong)NSArray *arr3;
@property(nonatomic,strong)NSMutableArray *pickArr;
@property(nonatomic,strong)NSString *firstStr;
@property(nonatomic,strong)KSConfigSliderView *slideBar;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property(nonatomic,strong)KSBatteryView *batteryV;
@property(nonatomic,strong)NSArray *infoArr;
@property (weak, nonatomic) IBOutlet UIButton *lineBtn;
@end

@implementation ViewController

- (IBAction)slider:(UISlider *)sender {
    [self.batteryV setBatteryNum:sender.value];
    float value = 30.0 * sender.value /100.0;
    NSLog(@"value==%.0f",value);
}
-(IBAction)click3:(UIButton*)sender{
//    [TopTipsView showPromptWithMessage:@"测试一下"];
    
    
    NSArray *arr1 = @[NSLocalizedString(@"取消",nil),NSLocalizedString(@"确认",nil)];
    LFSFitSmartPopView * pop = [[LFSFitSmartPopView alloc]initWithFrame:kKeyWindow.frame title:@"自定义训练次数" btnArray:arr1 num:10];
    hq_weak(pop)
    
    pop.clickPopView = ^(LFSFitSmartPopView * _Nonnull alertView, NSInteger buttonIndex,int num) {
        hq_strong(pop)
        if (buttonIndex == 0) {
            [pop close];
        }else{
            [pop close];
        }
    };

    [kKeyWindow addSubview:pop];

//    Byte byteArray[] = {0xE3, 0x28,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x66,0x00,0x00,0x00,0x00,0x4F};
//    NSData *infoData = [NSData dataWithBytes:&byteArray length:sizeof(byteArray)];
//    self.infoArr = [self convertDataToLongArrayWithData:infoData];
//    NSLog(@"data1===%@ arr1=%p",self.infoArr[1],self.infoArr);
//
//    [MBProgressHUD showToast:@"连接异常" ToView:self.view];
    

//    data===18 arr=0x600002366550
    // data1===28 arr1=0x600002340630
}
-(IBAction)click2:(UIButton*)sender{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
//    LFSPopTextView *view = [[LFSPopTextView alloc]initWithTitle:@"修改名称" message:@""];
//    __weak typeof(LFSPopTextView) *weakPopUpView = view;
//    view.clickBackgroundHide = YES;
//    view.messageColor = [UIColor colorWithRed:92/255.0 green:92/255.0 blue:92/255.0 alpha:1];
//    view.titleSpace = 20.f;
//    view.messageSpace = 25.f;
//    view.titleFont = [UIFont systemFontOfSize:18];
//    view.titleColor = [UIColor blackColor];
//    [view addCustomTextFieldForPlaceholder:@"自定义输入框1" maxInputCharacter:30 text:@"" secureEntry:NO];
//    [view addCustomButton:@"取消" buttonTextColor:[UIColor purpleColor] clickBlock:^(UIButton * btn) {
//        NSLog(@"%ld",btn.tag);
//
//    }];
//    [view addCustomButton:@"确定" buttonTextColor:[UIColor purpleColor] clickBlock:^(UIButton * btn) {
//
//        UITextField *file = view.textFieldsArray.firstObject;
//
//        NSLog(@"%@",file.text);
//
//    }];
//    [view showPopView];
    
}
-(void)popText{
    UIButton *searchBtn = [[UIButton alloc]init];
    [searchBtn setTitle:@"点击2" forState:(UIControlStateNormal)];
    searchBtn.backgroundColor = [UIColor whiteColor];
    [searchBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [searchBtn addTarget:self action:@selector(click2:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(124);
        make.top.equalTo(self.view.mas_top).offset(180);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(100);
    }];
}
-(void)bottomSheet{
    UIButton *searchBtn = [[UIButton alloc]init];
    [searchBtn setTitle:@"顶部弹出" forState:(UIControlStateNormal)];
    searchBtn.backgroundColor = [UIColor whiteColor];
    [searchBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [searchBtn addTarget:self action:@selector(click3:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(124);
        make.top.equalTo(self.view.mas_top).offset(220);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(100);
    }];
    
    
    UILabel *historyL = [[UILabel alloc]init];
   
//    historyL.backgroundColor = [UIColor blueColor];
    [historyL sizeToFit];
    NSArray *arrr = @[@"22",@"333",@"3456"];
    historyL.text = [arrr componentsJoinedByString:@",  "];
    
    [self.view addSubview:historyL];
    [historyL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.top.equalTo(searchBtn.mas_bottom).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        
    }];
    
}
- (UIViewController*)currentViewController{
    UIView *tmpSupView = self.view.superview;
    UIResponder* nextResponder = [tmpSupView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        return (UIViewController*)nextResponder;
    }
    else{
        return [tmpSupView currentViewController];
    }
}
//返回数组
-(NSArray *)convertDataToLongArrayWithData:(NSData *)data{
    
    NSString *str = [self hexadecimalString:data];
    int longnum = (int)[str length];
    NSMutableArray *tempArray = [NSMutableArray array];
    for(int i=0; i<longnum; i++) {
        if (i%2 == 0) {
            NSString *longStr = [str substringWithRange:NSMakeRange(i, 2)];
            [tempArray addObject:longStr];
        }
    }
    return tempArray;
}
//将Data类型转为String类型并返回
-(NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}
- (IBAction)clickAnimate:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        NSLog(@"isSelected");
        [UIView animateWithDuration:0.3 animations:^{
//            sender.transform = CGAffineTransformMakeRotation(M_PI);
            
            [sender setImage:[UIImage imageNamed:@"向下12"] forState:(UIControlStateNormal)];
        }];
       
    }else{
        NSLog(@"isCancel");
        [UIView animateWithDuration:0.3 animations:^{
            [sender setImage:[UIImage imageNamed:@"向上"] forState:(UIControlStateNormal)];
//            sender.transform = CGAffineTransformMakeRotation(0);
        }];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    NSString *str22 = @"01a42e5d";
    NSLog(@"str22===%@",[str22 stringByReplacingCharactersInRange:NSMakeRange(2, 2) withString:@"12"]);
    
    [self.lineBtn setTitle:@"1212312\nqsdda" forState:(UIControlStateNormal)];
    self.lineBtn.titleLabel.lineBreakMode = 0;
    
    NSString *straaa = [NSObject timestampToDate:[HYRadix hy_convertToDecimalFromHexadecimal:@"6310607f"]];
    NSLog(@"%@",straaa);
    
    NSString *aaaa= @"01263e01124201a42e5d";
    NSLog(@"====%d  %@",3/2,[aaaa substringWithRange:NSMakeRange(10, 4)]);
    Byte byteArray[] = {0xE2, 0x18,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x66,0x00,0x00,0x00,0x00,0x4F};
    NSData *infoData = [NSData dataWithBytes:&byteArray length:sizeof(byteArray)];
    self.infoArr = [self convertDataToLongArrayWithData:infoData];
    
    NSLog(@"data===%@ arr=%p",self.infoArr[1],self.infoArr);
    
    
    
    NSString *aaatr = @"ab550172010002000000";
    NSString *bstr = [HYRadix hy_convertToDecimalFromHexadecimal:[aaatr substringWithRange:NSMakeRange(12,2)]];
    NSLog(@"bstr=%@",bstr);
    
    NSString *tempHigh = [HYRadix hy_convertToDecimalFromHexadecimal:@"016d"];
    NSLog(@"tem=%@",tempHigh);
    
    NSString *temStr =  [NSString stringWithFormat:@"体温:%@",[NSObject getTempValue:tempHigh]];
    NSLog(@"temStr=%@",temStr);

    BOOL isShow = [[UIView getCurrentVC] isMemberOfClass:[SecondViewController class]];
    
    NSLog(@"old===%@",[LFSAppUserSetting shareInstance].resultArr);
    
    NSMutableArray *arr1 = [[LFSAppUserSetting shareInstance].resultArr mutableCopy];
    
    NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:@[@"12323",@"bbbbbb",@"ccccccc"]];
    
    [arr1 addObjectsFromArray:arr];
    
    [[LFSAppUserSetting shareInstance] setResultArr:arr1];
    
    NSLog(@"%d",isShow);
//    NSString *userInfo = @"e6440019a032030101640000000055000000008f";
//
//
//    NSString *str1111 = [userInfo stringByReplacingCharactersInRange:NSMakeRange(4, 8) withString:@"12345678"];
//
//    NSString *str2222 = [str1111 stringByReplacingCharactersInRange:NSMakeRange(28, 2) withString:@"66"];
    
//    NSMutableArray *characterArray = [NSMutableArray array];
//        NSRange range = NSMakeRange(0, 2);
//    for(int i = 0; i < userInfo.length; i += range.length){
//            range.location = i;
//            NSString *character = [userInfo substringWithRange:range];
//            [characterArray addObject:character];
//    }
//
//    NSLog(@"====%@",characterArray);
//
//    NSString *sex = [userInfo substringWithRange:NSMakeRange(4, 2)];
//
//    NSString *age = [userInfo substringWithRange:NSMakeRange(6, 2)];
//    //计算已雾化值 定量值-当前已雾化
//    NSString *height = [userInfo substringWithRange:NSMakeRange(8, 2)];
//    NSString *weight = [userInfo substringWithRange:NSMakeRange(10, 2)];
//
//    NSLog(@"%@%@%@%@",sex,age,height,weight);
    
    
//    NSString *message = [NSString stringWithFormat:@"%@ 30%@,%@",NSLocalizedString(@"Headset power below", nil), @"%",NSLocalizedString(@"Please charge.", nil)];
//
//    [KSAlertTool alertOk:NSLocalizedString(@"Got it", nil)  mesasge:message confirmHandler:^(UIAlertAction * action) {
//        [self.navigationController popViewControllerAnimated:YES];
//    } viewController:self];
    
    NSLog(@"%@",[LFSDeviceInfo getDeviceDesignation:@"AirRigh01"]);
    
    
    self.currentTime = 320.000;
    int totalNum = 320;
    if (self.currentTime == totalNum) {
        NSLog(@"00000");
    }
    
    NSString *str =  [@"12345" substringToIndex:2];
    NSLog(@"%@",str);
    
    NSLog(@"%@",[NSObject getMinuteTime:@"69"]);
    
    
    NSLog(@"%@",[NSObject getSecondByMinute:@"1.02"]);
    NSMutableArray *a1 = [[NSMutableArray alloc]initWithObjects:@"1",@"2", nil];
    NSLog(@"===%@",[a1 class]);
    NSLog(@"===%@",[[a1 copy] class]);
    
    [self popText];
    
    [self bottomSheet];
    
    NSString *rate = [HYRadix hy_convertToHexadecimalFromDecimal:@"10"];
    NSLog(@"%@",rate);
    
    NSLog(@"%.0f",30.0*55/100.0);
    
    
    KSBatteryView *batteryV= [[KSBatteryView alloc]initWithFrame:CGRectMake(40,  150, SCREEN_WIDTH-80, 44) num:20];
    self.batteryV = batteryV;
    [self.view addSubview:batteryV];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[path lastObject] stringByAppendingPathComponent:@"atom.txt"];
    
    NSArray *path1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath1 = [[path1 lastObject] stringByAppendingPathComponent:@"atom2.txt"];
    NSLog(@"%@===%@",filePath,filePath1);
    self.currentTime += 200;
    NSLog(@"%@",[NSObject getCurrentTimes]);
    NSLog(@"=%d==%d==%d ----> %d %f %f",4%4,3%4,7%4,3/3, self.currentTime/600,5.2/3.2);
    
    Byte cmds[] = {0x30,0x04};
//    int b = (0x30 & 0xFF00) >> 8 ;
//    NSLog(@"b==%d",b);
    Byte b = cmds[0x00];
    Byte array[8] = {0};
    for (int i = 7; i >= 0; i--) {
        array[i] = (Byte)(b & 1);
        b = (Byte) (b >> 1);
    }//array 为8位bit的数组
    NSLog(@"0 = %hhu, 1 = %hhu",array[0],array[1]);
    int aa = 2;
    Byte b2 = aa >> 8 ;
    NSLog(@"=========%d",b2);
    
    int ab = 144;
    Byte b3 = ab &0xff;
    NSLog(@"=========%d",b3);
    
    Byte byte3[4] = {0};
    byte3[0] = 0x30;
    byte3[1] = 0x05;
    
    int d = (byte3[0] & 0xf0) >> 8;
    char e = (byte3[0] >> 8) & 0xff;
//    int f = (byte3[1] & 0x0fff) >> 8;
    NSLog(@"d==%d e===%c",d,e);
    
    _slideBar = [[KSConfigSliderView alloc]initWithFrame:CGRectMake(38 + 10, 100, 200, 40)];
    [_slideBar setLabels:@[NSLocalizedString(@"左", nil)] tabIndex:0];
    
    [self.view addSubview:_slideBar];
    self.pickArr = [[NSMutableArray alloc]init];
    self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeHeadle) userInfo:nil repeats:YES];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(200, 100, 100, 40)];
    label1.text = [NSObject getCurrentSecondTime:@"30"];
    [self.view addSubview:label1];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 40)];
    label.text = [NSString stringWithFormat:@"%ld:%ld",self.minute,self.second];
    self.label = label;
    [self.view addSubview:label];
    [self setBtn2];
    UIButton *searchBtn = [[UIButton alloc]init];
    [searchBtn setTitle:@"00:00" forState:(UIControlStateNormal)];
    searchBtn.backgroundColor = [UIColor whiteColor];
    [searchBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [searchBtn addTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(24);
        make.bottom.equalTo(self.view.mas_bottom).offset(-140);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(100);
    }];
    
    _progress = [[ZFProgressView alloc] initWithFrame:CGRectMake(50, 450, 100, 100) style:ZFProgressViewStyleImageSegment withImage:[UIImage imageNamed:@"1.jpg"]];
    [self.view addSubview:_progress];
    [_progress setProgressStrokeColor:[UIColor redColor]];
    [_progress setBackgroundStrokeColor:[UIColor lightGrayColor]];
    _progress.timeDuration = 10;
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
}
-(void)setBtn2{
    UIButton *searchBtn = [[UIButton alloc]init];
    [searchBtn setTitle:@"点击1" forState:(UIControlStateNormal)];
    searchBtn.backgroundColor = [UIColor whiteColor];
    [searchBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [searchBtn addTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(124);
        make.top.equalTo(self.view.mas_top).offset(140);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(100);
    }];
}
-(IBAction)click1:(UIButton*)sender{
//    [self.navigationController pushViewController:[CircleViewController new] animated:YES];
//    
//    return;
    
    NSArray *array = @[@"0755-83775665",@"4000681396"];
    LFSBottomActionSheet *actionsheet = [[LFSBottomActionSheet alloc]initwithArray:array];
    actionsheet.delegate = self;
    actionsheet.viewTitle = @"客服热线";
    actionsheet.contentColor = [UIColor whiteColor];
    actionsheet.contentFont = [UIFont systemFontOfSize:16];
    actionsheet.cancleColor = [UIColor whiteColor];
    [actionsheet showActionSheet];
}

-(void)timeHeadle{
    self.second--;
    if (self.second==-1) {
        self.second=59;
        self.minute--;
        if (self.minute==-1) {
            self.minute=2;
        }
    }
    
    if  (self.minute < 0 || self.second < 0) {
        self.label.text = @"倒计时结束需要显示的字样";
        [self.timer invalidate];
        self.timer = nil;
    }else{
        self.label.text = [NSString stringWithFormat:@"%ld:%ld",(long)self.minute,(long)self.second];
        
    }
        
    if (self.second==0 && self.minute==0) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
-(void)pick1{
    BRDatePickerView *datePickerView = [[BRDatePickerView alloc]init];
    datePickerView.pickerMode = BRDatePickerModeHMS;
    datePickerView.title = @"雾化总量";
//    datePickerView.selectDate = self.birthtimeSelectDate;
    datePickerView.isAutoSelect = YES;
    datePickerView.resultBlock = ^(NSDate *selectDate, NSString *selectValue) {
        NSLog(@"selet=%@",selectValue);
    };
    
    // 自定义弹框样式
    BRPickerStyle *customStyle = [BRPickerStyle pickerStyleWithThemeColor:[UIColor darkGrayColor]];
    datePickerView.pickerStyle = customStyle;
    
    [datePickerView show];
}
-(IBAction)click:(UIButton*)sender{
    
//    [self pick1];
    
    [self pick2];
}
-(void)pick2{
    ZSPickView *pick = [[ZSPickView alloc]initWithComponentArr:nil];
    pick.componentArr = @[self.arr1,self.arr2,self.arr3];
    [self.pickArr removeAllObjects];
    pick.sureBlock = ^(NSArray *arr){
        for (NSString *str in arr) {
//            NSLog(@"无联动   %@",str);
            [self.pickArr addObject:str];
        }
        self.firstStr = self.pickArr.firstObject;
        [self.pickArr removeObjectAtIndex:0];
        NSString *str = [self.pickArr componentsJoinedByString:@""];
        NSString *target = [NSString stringWithFormat:@"%@:%@",self.firstStr,str];
        NSLog(@"str=%@",target);
    };
    [self.view addSubview:pick];
    
}
//定时更换图片
-(void)changeImage
{
    if (_count >= _progress.timeDuration) {
        [_timer invalidate];
        _timer = nil;
        return;
    }
    _progress.image = (_count % 2) ? [UIImage imageNamed:@"1.jpg"] : [UIImage imageNamed:@"2.jpg"];
    _count ++;
}
-(NSArray *)arr1{
    if (_arr1 == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i=0; i<16; i++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [arr addObject:str];
        }
        _arr1 = arr.copy;
    }
    return _arr1;
}
-(NSArray *)arr2{
    if (_arr2 == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i=0; i<10; i++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [arr addObject:str];
        }
        _arr2 = arr.copy;
    }
    return _arr2;
}
-(NSArray *)arr3{
    if (_arr3 == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i=0; i<10; i++) {
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [arr addObject:str];
        }
        _arr3 = arr.copy;
    }
    return _arr3;
}
@end
