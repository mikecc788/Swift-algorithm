//
//  CircleThumbView.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "CircleThumbView.h"
#import <Masonry.h>
#import "XtayCaculateHeightTool.h"
@interface CircleThumbView () <UITextViewDelegate>

/// 点赞的人的tv
@property (nonatomic, strong) UITextView *thumbTextView;

@end

@implementation CircleThumbView
- (instancetype)init{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        [self creatView];
    }
    return self;
}
- (void)creatView {
    self.thumbTextView = [[UITextView alloc] init];
    _thumbTextView.editable = NO;
    _thumbTextView.scrollEnabled = NO;
    _thumbTextView.textColor = [UIColor blackColor];
    _thumbTextView.delegate = self;
    [self addSubview:_thumbTextView];
    [_thumbTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}
- (void)creatThumbViewWithThumbArr:(NSArray *)thumbArr{
    NSString *str = @"";
    for (NSString *tempStr in thumbArr) {
        if ([str isEqualToString:@""]) {
            str = tempStr;
        } else {
            str = [NSString stringWithFormat:@"%@,%@", str, tempStr];
        }
    }
    if ([str isEqualToString:@""]) {
        self.thumbTextView.text = @"";
    } else {
        [self likeListArrAttributedText:[NSString stringWithFormat:@"♡%@", str]];
    }
}
- (void)likeListArrAttributedText:(NSString *)likeStr {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 1.0;
    NSMutableAttributedString *maStr = [[NSMutableAttributedString alloc] initWithString:likeStr attributes:@{NSFontAttributeName:XTAY_FONT_WEIGHT(15, 0), NSParagraphStyleAttributeName:paragraphStyle.copy}];
    _thumbTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    NSArray *sepArr = [likeStr componentsSeparatedByString:@","];
    for (NSInteger i = 0; i<sepArr.count; i++) {
        NSString *tempStr = [sepArr objectAtIndex:i];
        NSRange everyRange = [likeStr rangeOfString:tempStr];
        if (i == 0) {
            everyRange = NSMakeRange(1, tempStr.length-1);
        }
        [maStr addAttribute:NSForegroundColorAttributeName value:XTAY_MAIN_COLOR range:everyRange];
        NSString *valueString = [[NSString stringWithFormat:@"index%ld://%@", i, tempStr] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [maStr addAttribute:NSLinkAttributeName value:valueString range:everyRange];
    }
    self.thumbTextView.attributedText = maStr;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSInteger index = [[[URL.scheme componentsSeparatedByString:@":"] firstObject] stringByReplacingOccurrencesOfString:@"index" withString:@""].integerValue;
    if ([self.delegate respondsToSelector:@selector(chosedResponseIndex:)]) {
        [self.delegate chosedResponseIndex:index];
    }
    return NO;
}
@end
