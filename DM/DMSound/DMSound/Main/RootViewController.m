//
//  RootViewController.m
//  FastPair
//
//  Created by cl on 2019/7/24.
//  Copyright © 2019 KSB. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)changeLanguage{
    if ([self isViewLoaded] && self.view.window == nil) {
        for (UIView *v in self.view.subviews) {
            [v removeFromSuperview];
        }
        self.view = nil;
    }
}

- (void)dealloc{
    
    NSLog(@"++++++++++_%@_dealloc+++++++",[super class]);
    
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
