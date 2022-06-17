//
//  AppDelegate.m
//  DMSound
//
//  Created by kiss on 2020/5/26.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "AppDelegate.h"
#import "DMSearchViewController.h"
#import "DMMyDeviceController.h"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryAmbient error:nil];
    [session setActive:YES error:nil];
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    //iOS9以上加上这句
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor =[UIColor whiteColor];
    if (![NSObject isEmptyArr:[DMAppUserSetting shareInstance].addressArr]) {//不存在设备
        DMSearchViewController*search = [DMSearchViewController new];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:search];
        self.window.rootViewController = nav;
    } else {
        DMMyDeviceController *device = [DMMyDeviceController new];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:device];
        self.window.rootViewController = nav;
    }
    [self.window makeKeyAndVisible];
    return YES;
}



#pragma mark - UISceneSession lifecycle


@end
