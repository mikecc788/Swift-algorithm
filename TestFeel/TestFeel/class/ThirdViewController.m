//
//  ThirdViewController.m
//  TestFeel
//
//  Created by app on 2022/9/8.
//

#import "ThirdViewController.h"
#import "LFSPresenter.h"
#import "LoginProtocol.h"
#import "LoginPresenter.h"
#import "RegisterViewController.h"
@interface ThirdViewController ()<LoginProtocol>{
    UIButton * loginBtn;
    UIButton *registerBtn;
    UITextField *userNameTF;
    UITextField *pwdTF;
    LoginPresenter *_loginPresenter;
}
@property (strong, nonatomic) LFSPresenter *presenter;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupData];
}
-(void)setupData{
    /**===测试数据====**/
    userNameTF.text = @"chenggong";
    pwdTF.text = @"123456";
    /**===测试数据====**/
    _loginPresenter = [[LoginPresenter alloc]initWithView:self];
    _loginPresenter.loginDelegate = self;
}
//UI 初始化布局
-(void)setupUI{
    UILabel* userNameLb = [[UILabel alloc]initWithFrame:CGRectMake(50, 200, 80, 36)];
    userNameLb.text = @"用户名：";
    userNameLb.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:userNameLb];
    userNameTF = [[UITextField alloc]initWithFrame:CGRectMake(130, 200, 160, 36)];
    userNameTF.placeholder = @"请输入用户名";
    [self.view addSubview:userNameTF];
    UILabel *pwdLb = [[UILabel alloc]initWithFrame:CGRectMake(50, 255, 80, 36)];
    pwdLb.text = @"密码：";
    pwdLb.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:pwdLb];
    pwdTF = [[UITextField alloc]initWithFrame:CGRectMake(130, 255, 160, 36)];
    pwdTF.placeholder = @"请输入密码";
    pwdTF.secureTextEntry = YES;
    [self.view addSubview:pwdTF];

    loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.backgroundColor = [UIColor blueColor];
    loginBtn.frame = CGRectMake(110, 300, 50, 36);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];

    [loginBtn addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];

    registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(210, 300, 50, 36);
    registerBtn.backgroundColor = [UIColor blueColor];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:registerBtn];
}
-(IBAction)registerClick:(id)sender{
    [self.navigationController pushViewController:[RegisterViewController new] animated:YES];
}
-(void)loginClick:(id)sender{
    if (!userNameTF.text) {
        //
        NSLog(@"用户名不能为空！");
        return;
    }
    if (!pwdTF.text) {
        NSLog(@"密码不能为空！");
        return;
    }
    [_loginPresenter loginWithUserName:userNameTF.text password:pwdTF.text];
}
-(void)loginSuccess:(id)model{
    NSLog(@"登录成功！");
}
-(void)loginFail:(NSInteger)errorCode errorMessage:(NSString *)errorMessage{
    //登录失败，提示失败原因
    NSLog(@"登录失败！");

}
@end
