//
//  XtayCaculateHeightTool.m
//  FriendCircleDemo
//
//  Created by admin on 2021/1/16.
//

#import "XtayCaculateHeightTool.h"
#import "CircleCommentModel.h"


@implementation XtayCaculateHeightTool

+ (float)caculateRealHeightWithText:(NSString *)text realWidth:(float)width textFont:(UIFont *)font {
    if ([text isEqualToString:@""] || text.length <= 0 || !text) {
        return 0;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 1.5;
    return [text boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil].size.height;
}

+ (float)caculateContentHeightWithText:(NSString *)text realWidth:(float)width textFont:(UIFont *)font isOpen:(BOOL)isOpen {
    float h = [self caculateRealHeightWithText:text realWidth:width textFont:font];
    if (!isOpen) {
        return h > CONTENT_SHOW_MAXH ? (CONTENT_SHOW_MAXH + 20) : h;
    }
    return h;
}

+ (float)caculateImagesHeightWithImgsCount:(NSInteger)imgsCount realWidth:(float)width {
    if (imgsCount == 0) {
        return 0;
    }
    // 每个小图/缩略图的宽高
    CGFloat everyh_w = (width - 2*5)/3;
    NSInteger count = imgsCount / 3;
    if (imgsCount % 3 != 0) {
        count += 1;
    }
    return everyh_w*count + (count - 1)*5;
}

+ (float)caculateThumbHeightWithThumbList:(NSArray *)thumbArr realWidth:(float)width textFont:(UIFont *)font {
    NSString *str = @"";
    for (NSString *tempStr in thumbArr) {
        if ([str isEqualToString:@""]) {
            str = tempStr;
        } else {
            str = [NSString stringWithFormat:@"%@,%@", str, tempStr];
        }
    }
    return [self caculateRealHeightWithText:str realWidth:width textFont:font];
}

+ (float)caculateCommentHeightWithCommentArray:(NSArray *)commentArray realWidth:(float)width textFont:(UIFont *)font {
    CGFloat commentH = 0.f;
    for (CircleCommentModel *commentModel in commentArray) {
        NSString *toStr = @"";
        if (![commentModel.to isEqualToString:@""]) {
            toStr = [NSString stringWithFormat:@"回复%@", commentModel.to];
        }
        NSString *str = [NSString stringWithFormat:@"%@%@:%@", commentModel.from, toStr, commentModel.cont];
        CGFloat everyH = [self caculateRealHeightWithText:str realWidth:width textFont:font];
        commentH += everyH;
    }
    return commentH;
}

@end

