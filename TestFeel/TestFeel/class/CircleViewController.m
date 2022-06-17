//
//  CircleViewController.m
//  TestFeel
//
//  Created by app on 2022/3/11.
//

#import "CircleViewController.h"
#import "HYRadix.h"
#import "NSObject+Extension.h"
#define KSTitleButton_Margin 0   // 行_列间距
#define Top_Margin 160
@interface CircleViewController ()
// 行
@property(nonatomic,assign)NSInteger linkNumber ;
// 列
@property(nonatomic,assign)NSInteger columnsNumber ;
@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation CircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.columnsNumber = 3;
    self.linkNumber = 8;
    NSArray *arr =@[@"00a1017c01b22a011401b101dd3f00002d04",@"394f0000003c740000c9d20000d90a1d3a00",@"00b5014202683800a800d2016350000001b9",@"01e600000000000000000000000000000000"];
    
    NSString *str =[arr componentsJoinedByString:@""];
   
    NSString * dataStr = [str stringByReplacingCharactersInRange:NSMakeRange(42,30) withString:@""] ;
    NSString *sub = [str substringWithRange:NSMakeRange(42, 30)];
    NSLog(@"leng=%lu str==%@",(unsigned long)dataStr.length,dataStr);
    NSLog(@"strleng=%lu oldStr==%@",(unsigned long)str.length,str);
    NSLog(@"sublen=%ld,subStr=%@",sub.length,sub);

    self.dataArr = [NSMutableArray arrayWithArray:arr];
    if (self.dataArr.count>0) {
        
        CGFloat topW = SCREEN_WIDTH - 20*2;
        CGFloat btnX = 0;
        CGFloat btnY = 0;
        NSArray *leftTitle = @[@"FEV1(L)",@"FVC(L)",@"MVV(L/min)",@"FEF50(L/s)",@"FEF75(L/s)",@"VC(L)",@"PEF(L/min)",@"FEV1/FVC"];
        
        for (int i =0; i<8; i++) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0+30*i + Top_Margin, topW*0.25, 30)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.text = leftTitle[i];
            [self.view addSubview:label];
        }
        
        CGFloat labelH = 30;
        for (int i =0; i<24; i++) {
/**
 00a1017c01b22a011401b101dd3f00002d04394f0000003c740000c9d20000d90a1d3a0000b5014202683800a800d2016350000001b901e600000000000000000000000000000000
 */
            
            //先拿出PEF值 ev1/fvc 44位开始
            btnX =  (i % self.columnsNumber) * (topW*0.25);
            btnY =  (i / self.columnsNumber) * labelH;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(btnX + topW*0.25, btnY + Top_Margin, topW*0.25, 30)];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.adjustsFontSizeToFitWidth=YES;
            /** */
            if (i<18) {
                if (i%3==0) {
                    label.text = [NSObject getActualValue:[dataStr substringWithRange:NSMakeRange(4*i+2*(i/3), 4)]];
                    
                }else if (i%3==1){
                    label.text =[NSString stringWithFormat:@"%@ ~ %@",[NSObject getActualValue:[dataStr substringWithRange:NSMakeRange(i*4+2*(i/3), 4)]],[NSObject getActualValue:[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 4)]]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@%@",[HYRadix hy_convertToDecimalFromHexadecimal:[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 2)]],@"%"];
                }
            }else if(i>=18 && i<21){
                if (i%3==0){
                    label.text = [NSObject getActualValue:[sub substringWithRange:NSMakeRange(0, 8)]];
//                    [NSString stringWithFormat:@"%@",[sub substringWithRange:NSMakeRange(0, 8)]];
                }else if (i%3==1){
                    label.text = [NSString stringWithFormat:@"%@ ~ %@",[NSObject getActualValue:[sub substringWithRange:NSMakeRange(8, 8)]],[NSObject getActualValue:[sub substringWithRange:NSMakeRange(8*2,8)]]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@%@",[HYRadix hy_convertToDecimalFromHexadecimal:[sub substringWithRange:NSMakeRange(8*3, 2)]],@"%"];
                }
            }else{
                if (i%3==0 || i%3==1){
                    label.text = @"--";
                }else{
                    label.text = [NSString stringWithFormat:@"%@%@",[HYRadix hy_convertToDecimalFromHexadecimal:[sub substringWithRange:NSMakeRange(8*3+2, 2)]],@"%"];
                }
            }
            
            /**
            if (i<3) {
                if (i%3==0) {

                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange(0, 4)]];
                }else if (i%3==1){
                    label.text = [NSString stringWithFormat:@"%@ ~ %@",[dataStr substringWithRange:NSMakeRange(i*4, 4)],[dataStr substringWithRange:NSMakeRange((i+1)*4, 4)]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange((i+1)*4+2*i/3, 2)]];
                }
            }else if(i>2 && i<6){
                if (i%3==0) {
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange(i*4+2, 4)]];
                }else if (i%3==1){
                    label.text = [NSString stringWithFormat:@"%@ ~ %@",[dataStr substringWithRange:NSMakeRange(i*4+2, 4)],[dataStr substringWithRange:NSMakeRange((i+1)*4+2, 4)]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 2)]];
                }
            }
            else if(i>5 && i<9){
                if (i%3==0) {
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange(4*i+2*(i/3), 4)]];
                }else if (i%3==1){
                    label.text = [NSString stringWithFormat:@"%@ ~ %@",[dataStr substringWithRange:NSMakeRange(4*i+2*(i/3), 4)],[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 4)]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 2)]];
                }
            } else if(i>8 && i<12){
                if (i%3==0) {
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange(4*i+2*(i/3), 4)]];
                }else if (i%3==1){
                    label.text = [NSString stringWithFormat:@"%@ ~ %@",[dataStr substringWithRange:NSMakeRange(i*4+2*(i/3), 4)],[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 4)]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 2)]];
                }
            }else if(i>11 && i<15){
                if (i%3==0) {
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange(4*i+2*(i/3), 4)]];
                }else if (i%3==1){
                    label.text = [NSString stringWithFormat:@"%@ ~ %@",[dataStr substringWithRange:NSMakeRange(i*4+2*(i/3), 4)],[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 4)]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 2)]];
                }
            }else if(i>14 && i<18){
                if (i%3==0) {
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange(4*i+2*(i/3), 4)]];
                }else if (i%3==1){
                    label.text = [NSString stringWithFormat:@"%@ ~ %@",[dataStr substringWithRange:NSMakeRange(i*4+2*(i/3), 4)],[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 4)]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 2)]];
                }
            }else if(i>17 && i<21){
                if (i%3==0) {
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange(4*i+2*(i/3), 4)]];
                }else if (i%3==1){
                    label.text = [NSString stringWithFormat:@"%@ ~ %@",[dataStr substringWithRange:NSMakeRange((i+1)*4+2, 4)],[dataStr substringWithRange:NSMakeRange((i+1)*4+2, 4)]];
                }else{
                    label.text = [NSString stringWithFormat:@"%@",[dataStr substringWithRange:NSMakeRange((i+1)*4+2*(i/3), 2)]];
                }
            }
             */
            
            
//            if (btnX == 0) {
//                label.text = leftTitle[i/4];
//            }else if(i<3){
//                int a  = (i % self.columnsNumber);
//                if (i==3) {
//                    label.text = [arr[0] substringWithRange:NSMakeRange(0+i*4-4, 2)];
//                }else{
//                    label.text = [arr[0] substringWithRange:NSMakeRange(i*4-4, 4)];
//                }
//            }
            
            [self.view addSubview:label];
        }
    }
    
}


@end
