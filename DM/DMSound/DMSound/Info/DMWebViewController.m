//
//  DMWebViewController.m
//  DMSound
//
//  Created by kiss on 2020/6/1.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMWebViewController.h"
#import <WebKit/WebKit.h>
#import "DMGoBackButton.h"
#import "MBProgressHUD+Extension.h"
@interface DMWebViewController ()<WKNavigationDelegate>
@property(nonatomic,strong)WKWebView *webView;
@property (strong, nonatomic) UIView *topView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation DMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SafeAreaTopHeight)];
    self.topView.backgroundColor = Gloabal_bg;
    [self.view addSubview:self.topView];
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, statusBar, 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"DM", nil) textFont:[UIFont systemFontOfSize:34]];
    [self.topView addSubview:back];
    
//    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)];
    WKWebViewConfiguration *webConfiguration = [WKWebViewConfiguration new];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT -SafeAreaTopHeight) configuration:webConfiguration];
    _webView.navigationDelegate = self;

//    [_webView addObserver:self
//    forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
//    options:0 context:nil];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.dm-sounds.com"]]];
    self.view.backgroundColor = Gloabal_bg;
    [_webView setAllowsBackForwardNavigationGestures:true];
    [self.view addSubview:self.webView];
    
    [MBProgressHUD showMessage: NSLocalizedString(@"正在加载", nil)  ToView:self.view];
    
//    [self setupProgressView];
}
//开始加载
-(void)webView:(WKWebView *)webView
 didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让进度条显示
    NSLog(@"didStartProvisionalNavigation");
    self.progressView.hidden = NO;
}
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
}
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"44444当Web视图开始接收Web内容时调用");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"didFinishNavigation");
}
//kvo 监听进度
//-(void)observeValueForKeyPath:(NSString *)keyPath
//      ofObject:(id)object
//      change:(NSDictionary<NSKeyValueChangeKey,id> *)change
//      context:(void *)context{
//
// if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
//  && object == self.webView) {
//  [self.progressView setAlpha:1.0f];
//  BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
//  [self.progressView setProgress:self.webView.estimatedProgress
//        animated:animated];
//
//  if (self.webView.estimatedProgress >= 1.0f) {
//   [UIView animateWithDuration:0.3f
//         delay:0.3f
//        options:UIViewAnimationOptionCurveEaseOut
//        animations:^{
//         [self.progressView setAlpha:0.0f];
//        }
//        completion:^(BOOL finished) {
//         [self.progressView setProgress:0.0f animated:NO];
//        }];
//  }
// }else{
//  [super observeValueForKeyPath:keyPath
//        ofObject:object
//        change:change
//        context:context];
// }
//}
//
//-(void)dealloc{
//    [self.webView removeObserver:self
//      forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
//}
- (void)setupProgressView{
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, 5);
    
    [progressView setTrackTintColor:Gloabal_bg];
    progressView.progressTintColor = [UIColor greenColor];
    [self.view addSubview:progressView];
    
    _progressView = progressView;
}
@end
