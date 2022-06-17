//
//  KSDefaultType.h
//  FastPair
//
//  Created by kiss on 2019/8/5.
//  Copyright © 2019 KSB. All rights reserved.
//

#ifndef KSDefaultType_h
#define KSDefaultType_h

typedef NS_ENUM(NSUInteger, KSEdgeInsetsStyle) {
    LZHEdgeInsetsStyleTop, // image在上，label在下
    LZHEdgeInsetsStyleLeft, // image在左，label在右
    LZHEdgeInsetsStyleBottom, // image在下，label在上
    LZHEdgeInsetsStyleRight // image在右，label在左
};

//首页四个
typedef NS_ENUM(NSUInteger, KSTitleViewStyle) {
    KSKeyConfigStyle,
    KSGeneralSetStyle, // 
    KSEQGainStyle, //
    KSFirmwareUpdateStyle //
};

//未打开蓝牙弹出框
typedef enum {
    CurrentImageTypeEnumOne=0,//0
    CurrentImageTypeEnumTwo=1,//1
}CurrentImageType;

//三击
typedef NS_ENUM(NSUInteger, KSClickThreeStyle) {
    KSClickThreeLeftStyle,
    KSClickThreeRightStyle //
};
typedef NS_ENUM(NSUInteger, KsGetMessageCommand){
    KsGetCommand_Battery    = 0x01,
    KsGetCommand_Volume   = 0x02,
    KsSetCommand_Volume   = 0x03,
    KsGetCommand_VoiceTip = 0x07,
    KsGetCommand_EQ = 0xa1,
    KsGetCommand_Key   = 0x0a,
    KsSetCommand_DFU = 0xa3,
    KsGetCommand_BatteryManager = 0xa4,
    KsGetCommand_BaseInfo   = 0xa6,
    KsGetCommand_Version   = 0xa7,
    KsGetCommand_TouchSwitch   = 0xaa
};
typedef enum : NSUInteger{
    KSEqTopTitleStyle,
    KSEqBottomTitleStyle
}EQTitleStyle;

#endif /* KSDefaultType_h */
