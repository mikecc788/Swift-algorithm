//
//  XtayLocationButton.h
//  FriendCircleDemo
//
//  Created by admin on 2021/1/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ButtonType){
    ButtonType_Image_Left = 0,//图片左边 文字右边
    ButtonType_Image_Right = 1,//图片右边 文字左边
    ButtonType_Image_Tope = 2,//图片上边 文字下边
    ButtonType_Image_Bottom = 3,//图片下边 文字上边边
};

@interface XtayLocationButton : UIButton

@property (nonatomic, assign) ButtonType locationBtnType;

@end

NS_ASSUME_NONNULL_END
