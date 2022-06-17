//
//  ViewController.h
//  OC调用Swift
//
//  Created by kiss on 2020/7/7.
//  Copyright © 2020 kiss. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(uint8_t, GaiaDevicePluginFeatureID){
    GaiaDevicePluginFeatureID_basic = 0x00,
    GaiaDevicePluginFeatureID_earbud = 0x01,
    GaiaDevicePluginFeatureID_noiseCancellation = 0x02,
    GaiaDevicePluginFeatureID_voiceAssistant = 0x03,
    GaiaDevicePluginFeatureID_debug = 0x04,
    GaiaDevicePluginFeatureID_upgrade = 0x06,
    GaiaDevicePluginFeatureID_unknown = 0x7f
};


@interface ViewController : UIViewController

@property (nonatomic,assign) GaiaDevicePluginFeatureID featureID;

@end

