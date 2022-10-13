//
//  XtayCaculateHeightTool.h
//  FriendCircleDemo
//
//  Created by admin on 2021/1/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XtayCaculateHeightTool : NSObject

/// 计算一段文字的实际高度
/// @param text 文字
/// @param width 实际宽度
/// @param font 字体大小
+ (float)caculateRealHeightWithText:(NSString *)text realWidth:(float)width textFont:(UIFont *)font;

/// 计算内容的高度
/// @param text 内容
/// @param width 宽度
/// @param font 字体大小
/// @param isOpen 是否展开状态
+ (float)caculateContentHeightWithText:(NSString *)text realWidth:(float)width textFont:(UIFont *)font isOpen:(BOOL)isOpen;

/// 计算图片视图的高度
/// @param imgsCount 图片数量
/// @param width 宽度
+ (float)caculateImagesHeightWithImgsCount:(NSInteger)imgsCount realWidth:(float)width;

/// 计算点赞视图的高度
/// @param thumbArr 点赞数组
/// @param width 点赞视图宽度
/// @param font 点赞字体大小
+ (float)caculateThumbHeightWithThumbList:(NSArray *)thumbArr realWidth:(float)width textFont:(UIFont *)font;

/// 计算评论回复内容的高度
/// @param commentArray 评论回复数组
/// @param width 规定宽度
/// @param font 评论回复字体大小
+ (float)caculateCommentHeightWithCommentArray:(NSArray *)commentArray realWidth:(float)width textFont:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
