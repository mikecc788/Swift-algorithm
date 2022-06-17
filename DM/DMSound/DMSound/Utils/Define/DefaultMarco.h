//
//  DefaultMarco.h
//  FastPair
//
//  Created by cl on 2019/7/24.
//  Copyright © 2019 KSB. All rights reserved.
//

#ifndef DefaultMarco_h
#define DefaultMarco_h
//const

#define LogMethod() NSLog(@"%s", __func__)

//版本号
#define kVersion_FastPair [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define kVersionBuild_FastPair [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]


//size
#define iPhoneX (SCREEN_HEIGHT >= 812 && SCREEN_WIDTH >= 375)
#define titleVHeight 240
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kMaxX(X) CGRectGetMaxX(X)
#define kMaxY(Y) CGRectGetMaxY(Y)
#define statusBar [[UIApplication sharedApplication] statusBarFrame].size.height

#define SafeAreaTopHeight ((SCREEN_HEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"] ? 88 : 64)
#define SafeAreaBottomHeight ((SCREEN_HEIGHT >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"]  ? 30 : 0)

#define kKeyWindow [[[UIApplication sharedApplication] windows] objectAtIndex:0]

//适配ui 375的图
#define KScaleWidth(width) ((width)*(SCREEN_WIDTH/375.f))
#define KScaleHeight(height) ((height)*(SCREEN_HEIGHT/667.f))
#define CurrentLanguage [[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject] substringToIndex:2]
//按键页面的一些尺寸
#define keyPaddingRightWidth 65
#define Key_width 100 //左边按键宽
#define keyPaddingImage 15

#define EQHeaderSelectTag 9
//字体
#define CHINESE_FONT_NAME  @"Heiti SC"
#define CHINESE_SYSTEM(x) [UIFont fontWithName:CHINESE_FONT_NAME size:x]


#define SHCNFont(a) [UIFont fontWithName:@"SourceHanSansCN-Normal" size:a];

#define SHCNBoldFont(a) [UIFont fontWithName:@"SourceHanSansCN-Bold" size:a];
#define ArialBoldFont(a) [UIFont fontWithName:@"Arial-BoldMT" size:a]

//slider高度
#define EQSliderHeight 350
#define BackHeight 42
//color
#define kColorMakeWithRGB(x,y,z,a) [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:a]

#define Gloabal_bg [UIColor colorFromHexStr:@"#111217"]


#define SmallFileName @"qunxiang_OTA_SMALL_File_20200611"

#define BigFileName @"qunxiang_OTA_BIG_File_20200611"
#ifndef hq_weak
#if DEBUG
#if __has_feature(objc_arc)
#define hq_weak(object) __weak __typeof(object) weak##_##object = object;
#else
#define hq_weak(object) __block __typeof(object) weak##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define hq_weak(object) __weak __typeof(object) weak##_##object = object;
#else
#define hq_weak(object) __block __typeof(object) weak##_##object = object;
#endif
#endif
#endif

#ifndef hq_strong
#if DEBUG
#if __has_feature(objc_arc)
#define hq_strong(object) __typeof(object) object = weak##_##object;
#else
#define hq_strong(object) __typeof(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define hq_strong(object) __typeof(object) object = weak##_##object;
#else
#define hq_strong(object) __typeof(object) object = block##_##object;
#endif
#endif
#endif

#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"[%s:%d行] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else

#define NSLog(FORMAT, ...) nil

#endif


#endif /* DefaultMarco_h */
