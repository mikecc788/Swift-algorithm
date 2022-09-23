//
//  TopTipsView.m
//  TestFeel
//
//  Created by app on 2022/8/20.
//

#import "TopTipsView.h"
#import "UIView+Extension.h"

@interface TopTipsView ()
@property (nonatomic, strong)UILabel *messageL;
@end
@implementation TopTipsView
+(TopTipsView *)sharedView{
    static TopTipsView *pv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pv = [[TopTipsView alloc]init];
    });
    return pv;
}
- (instancetype)init {
    if ([super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50);
        self.backgroundColor = [UIColor clearColor];
        [[self lastWidow] addSubview:self];
        [self addSubview:self.messageL];
    }
    return self;
}
- (UILabel *)messageL {
    if (!_messageL) {
        _messageL = [[UILabel alloc]init];
        _messageL.backgroundColor = [UIColor blackColor];
        _messageL.alpha = 0.7;
        _messageL.layer.cornerRadius = 5;
        _messageL.layer.masksToBounds = YES;
        _messageL.textColor = [UIColor whiteColor];
        _messageL.textAlignment = NSTextAlignmentCenter;
        _messageL.numberOfLines = 0;
        _messageL.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _messageL;
}
+ (void)showPromptWithMessage:(NSString *)message {
    [[self sharedView] showMessage:message];
}
- (void)showMessage:(NSString *)message{
    self.hidden = NO;
    self.messageL.text = message;
    CGFloat maxWidth = SCREEN_WIDTH - 60;
    CGSize size = [self.messageL sizeThatFits:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)];
    if (size.width + 20 > maxWidth) {
        size = [self.messageL sizeThatFits:CGSizeMake(maxWidth - 20, CGFLOAT_MAX)];
        self.messageL.frame = CGRectMake((SCREEN_WIDTH - maxWidth) / 2, (self.height - (size.height + 20)) / 2, maxWidth, size.height + 20);
    }else {
        self.messageL.frame = CGRectMake((SCREEN_WIDTH - (size.width + 20)) / 2, (self.height - (size.height + 20)) / 2, size.width + 20, size.height + 20);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1 animations:^{
            self.hidden = YES;
        }];
    });
    
}
#pragma mark - 获取最上层window
- (UIWindow *)lastWidow{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] && CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds)) {
            return window;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

