//
//  XtayCircleRecommendView.m
//  FriendCircleDemo
//
//  Created by admin on 2021/1/15.
//

#define TV_TAG 1000

#import "XtayCircleCommentView.h"
#import "XtayCaculateHeightTool.h"
#import "CircleCommentModel.h"

@interface XtayCircleCommentView () <UITextViewDelegate>

@end

@implementation XtayCircleCommentView

- (void)creatCommentViewWithCommentArr:(NSArray *)commentArr withWidth:(float)width {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat commentH = 0.f;
    for (NSInteger i = 0; i<commentArr.count; i++) {
        CircleCommentModel *commentModel = commentArr[i];
        NSString *toStr = @"";
        if (![commentModel.to isEqualToString:@""]) {
            toStr = [NSString stringWithFormat:@"回复%@", commentModel.to];
        }
        NSString *str = [NSString stringWithFormat:@"%@%@:%@", commentModel.from, toStr, commentModel.cont];
        CGFloat everyH = [XtayCaculateHeightTool caculateRealHeightWithText:str realWidth:width textFont:XTAY_FONT_WEIGHT(15, 0)];
        // 计算出每一个cell的高度
        UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(0, commentH, width, everyH)];
        tv.scrollEnabled = NO;
        tv.editable = NO;
        tv.delegate = self;
        tv.tag = TV_TAG + i;
        [self addSubview:tv];
        commentH += everyH;
        // 处理数据
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.lineSpacing = 1.0;
        NSMutableAttributedString *maStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:XTAY_FONT_WEIGHT(15, 0), NSParagraphStyleAttributeName:paragraphStyle.copy}];
        tv.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        NSRange fromRange = [str rangeOfString:commentModel.from];
        NSRange toRange = [str rangeOfString:commentModel.to];
        NSString *valueFromString = [[NSString stringWithFormat:@"from://%@", commentModel.from] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSString *valueToString = [[NSString stringWithFormat:@"to://%@", commentModel.to] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [maStr addAttribute:NSLinkAttributeName value:valueFromString range:fromRange];
        [maStr addAttribute:NSLinkAttributeName value:valueToString range:toRange];

        tv.attributedText = maStr;
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSInteger index = textView.tag - TV_TAG;
    if ([URL.scheme containsString:@"from"]) {
        if ([self.delegate respondsToSelector:@selector(chosedCommentFromIndex:)]) {
            [self.delegate chosedCommentFromIndex:index];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(chosedCommentToIndex:)]) {
            [self.delegate chosedCommentToIndex:index];
        }
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
