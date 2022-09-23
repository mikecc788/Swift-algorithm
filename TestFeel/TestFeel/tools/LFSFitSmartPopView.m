//
//  LFSFitSmartPopView.m
//  FeelLife
//
//  Created by app on 2022/8/25.
//

#import "LFSFitSmartPopView.h"
#define KSDefaultButtonHeight 50
#define kWTAlertViewCornerRadius 9
@interface LFSFitSmartPopView()
@property(nonatomic,strong) UIView * promptView;
@property(nonatomic,assign)int midNum;
@property(nonatomic,strong)UIButton *stateBtn;
@end

@implementation LFSFitSmartPopView

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title btnArray:(NSArray *)btnArr num:(int)num{
    if (self =[super initWithFrame:frame]) {
        self.midNum = num;
        self.backgroundColor = [[UIColor blackColor ]colorWithAlphaComponent:0.4];
        UIView * promptView = [UIView new];
        promptView.layer.cornerRadius = kWTAlertViewCornerRadius;
        promptView.backgroundColor = [UIColor whiteColor];
        promptView.layer.masksToBounds = YES;
        [self addSubview:promptView];
        self.promptView = promptView;
        
        
        [promptView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(42);
            make.right.equalTo(self.mas_right).offset(-37);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(121+KSDefaultButtonHeight);
        }];
        
        
        UILabel *tipL = [[UILabel alloc]init];
        tipL.text = title;
        tipL.textColor = [UIColor colorWithHexString:@"#282828"];
        tipL.font = [UIFont systemFontOfSize:16];
        [self.promptView addSubview:tipL];
        [tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.promptView.mas_centerX).offset(10);
            make.top.equalTo(promptView.mas_top).offset(31);
            make.height.mas_equalTo(16);
        }];
        [tipL sizeToFit];
        
        
        CGFloat bWidth = (self.width - 42 -37) / 3;
        for (int i=0; i<3; i++) {
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [closeButton addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [closeButton setTag:i];
            
            if (i == 0) {
                [closeButton setTitle:@"+" forState:UIControlStateNormal];
            }else if (i == 1){
                self.stateBtn = closeButton;
                [closeButton setTitle:[NSString stringWithFormat:@"%d",self.midNum] forState:UIControlStateNormal];
            }else{
                [closeButton setTitle:@"-" forState:UIControlStateNormal];
            }
            
            [closeButton setTitleColor:[UIColor colorFromHexStr:@"#010101"] forState:UIControlStateNormal];
            
            [closeButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
            closeButton.titleLabel.numberOfLines = 0;
            closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            
            [self.promptView addSubview:closeButton];
            
            [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.promptView.mas_left).offset( i*bWidth);
                make.top.equalTo(tipL.mas_bottom).offset(20);
                make.size.mas_equalTo(CGSizeMake(bWidth, KSDefaultButtonHeight));
            }];
            
            
        }
        
        CGFloat buttonWidth = (self.width - 42 -37) / btnArr.count;
        for (int i=0; i<btnArr.count; i++) {
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [closeButton addTarget:self action:@selector(dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [closeButton setTag:i];
            
            [closeButton setTitle:[btnArr objectAtIndex:i] forState:UIControlStateNormal];
            if (i == 1) {
                [closeButton setTitleColor:[UIColor colorFromHexStr:@"#010101"] forState:UIControlStateNormal];
                
            }else{
                [closeButton setTitleColor:[UIColor colorFromHexStr:@"#A0A0A0"] forState:UIControlStateNormal];
            }
            [closeButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
            closeButton.titleLabel.numberOfLines = 0;
            closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [closeButton.layer setCornerRadius:kWTAlertViewCornerRadius];
            [self.promptView addSubview:closeButton];
            
            [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.promptView.mas_left).offset( i*buttonWidth);
                make.top.equalTo(self.promptView.mas_bottom).offset(-KSDefaultButtonHeight);
                make.size.mas_equalTo(CGSizeMake(buttonWidth, KSDefaultButtonHeight));
            }];
            
            
        }
        
        UIView *lineV = [[UIView alloc]init];
        lineV.backgroundColor = [UIColor colorFromHexStr:@"#ECECEC"];
        [self.promptView addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.promptView.mas_left).offset(0);
            make.right.equalTo(self.promptView.mas_right).offset(0);
            make.top.equalTo(self.promptView.mas_bottom).offset(-KSDefaultButtonHeight);
            make.height.mas_equalTo(1);
        }];
        
        UIView *verL = [[UIView alloc]init];
        verL.backgroundColor = [UIColor colorFromHexStr:@"#ECECEC"];
        [self.promptView addSubview:verL];
        [verL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.promptView.mas_centerX);
            make.top.equalTo(self.promptView.mas_bottom).offset(-KSDefaultButtonHeight);
            make.size.mas_equalTo(CGSizeMake(1, KSDefaultButtonHeight));
            
        }];
        
        
    }
    return self;
}
-(IBAction)touchUpInside:(UIButton*)sender{
    if (sender.tag == 0) {
        self.midNum += 5;
        if (self.midNum>=95) {
            self.midNum = 95;
        }
        [self.stateBtn setTitle:[NSString stringWithFormat:@"%d",self.midNum] forState:UIControlStateNormal];
    }else if(sender.tag == 1){
        NSLog(@"1");
    }else{
        self.midNum -= 5;
        if (self.midNum<=5) {
            self.midNum = 5;
        }
        [self.stateBtn setTitle:[NSString stringWithFormat:@"%d",self.midNum] forState:UIControlStateNormal];
    }
}
-(IBAction)dialogButtonTouchUpInside:(UIButton*)sender{
    if (self.clickPopView) {
        self.clickPopView(self, sender.tag,self.midNum);
    }
}
// 点击提示框视图以外的其他地方时隐藏弹框
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [[touches anyObject] locationInView:self];
    point = [self.promptView.layer convertPoint:point fromLayer:self.layer];
    if (![self.promptView.layer containsPoint:point]) {
        self.hidden = YES;
    }
}
- (void)close{
    CATransform3D currentTransform = self.promptView.layer.transform;
    self.promptView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.promptView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.promptView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}
@end
