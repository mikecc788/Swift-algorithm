//
//  DMBLEInstruction.h
//  DMSound
//
//  Created by kiss on 2020/6/3.
//  Copyright © 2020 kiss. All rights reserved.
//

#ifndef DMBLEInstruction_h
#define DMBLEInstruction_h

#define ksBatteryPower                  @"0001"   //获取电池电量
#define ksAcquireVolume                 @"0002"   //获取音量
#define ksSetVolume                     @"0003"   //设置音量
#define ksSetVoiceSwitch                @"0004"   //设置语音提示开关
#define ksAcquireVoiceSwitch            @"0005"   //获取语音提示开关
#define ksSetVoiceLanguage              @"0006"   //设置语音提示语言
#define ksAcquisitionVoiceLanguage      @"0007"   //获取语音提示语言
#define ksSetName                       @"0008"   //设置名称
#define ksGetKeyFunction                @"000a"   //获取按键功能
#define ksSetKeyFunction                @"0009"   //设置按键功能
#define ksGetEqInfo                     @"00a1"   //获取设置EQ
#define ksSetEq                         @"00a2"   //设置EQ
#define ksEnterDFUMode                  @"00a3"   //开始进入DFU模式
#define ksGetBatteryManager             @"00a4"     //获取电池管理状态
#define ksSetBatteryManager             @"00a5"     //设置电池管理状态
#define ksGetMacAddress                 @"00a6"     //获取左右耳mac地址
#define ksGetFirmVersion                @"00a7"     //获取固件版本号
#define ksGetTouchSwitch                @"00aa"     //获取触摸按键开关状态


#define PLAY_PAUSE          @"0001"//播放暂停
#define ANSER_HANGUP        0x0002//接听挂断
#define AV_FORWARD          @"0004"//下一曲
#define AV_BACKWARD         @"0008"//上一曲
#define AV_VOLUME_UP        @"0010"//音量加
#define AV_VOLUME_DOWN      @"0020"//音量减
#define REJECT_CALL         0x0040//拒接来电
#define HANDSET_PAIRING     0x0080//进入配对模式
#define START_SIRI          0x0100//开启Siri

//转成二进制的
#define Play_pause @"00000001"
#define Av_Forward @"00000100"
#define AV_BackWard @"00001000"
#define Av_VolumeUp @"00010000"
#define Av_VolumeDown @"00100000"
#define Start_Siri @"100000000"

#endif /* DMBLEInstruction_h */
