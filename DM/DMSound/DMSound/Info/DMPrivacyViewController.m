
//
//  DMPrivacyViewController.m
//  DMSound
//
//  Created by kiss on 2020/6/20.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMPrivacyViewController.h"
#import <WebKit/WebKit.h>
#import "DMPrivacyInfoView.h"
#import "DMGoBackButton.h"
@interface DMPrivacyViewController ()
@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) UIView *topView;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation DMPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = Gloabal_bg;
    NSString *fileName;
       if ([CurrentLanguage isEqualToString:@"en"]) {
           fileName = @"policyEng";
       }else{
           fileName = @"policy";
       }
    NSString *noteVideoPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString *content = [[NSString alloc] initWithContentsOfFile:noteVideoPath encoding:NSUTF8StringEncoding error:nil];
    
   DMPrivacyInfoView *protocolV = [[DMPrivacyInfoView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH , SCREEN_HEIGHT -0) content:content];
    [self.view addSubview:protocolV];
    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SafeAreaTopHeight)];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topView];
    
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, statusBar, 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"隱私協議", nil) textFont:[UIFont systemFontOfSize:30]];
    [self.topView addSubview:back];
}
-(IBAction)goBack:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
