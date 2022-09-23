//
//  LFSFitSmartPopView.h
//  FeelLife
//
//  Created by app on 2022/8/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFSFitSmartPopView : UIView

-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title btnArray:(NSArray *)btnArr num:(int)num;
@property (nonatomic, copy) void(^clickPopView)(LFSFitSmartPopView *alertView, NSInteger buttonIndex,int times);
- (void)close;
@end

NS_ASSUME_NONNULL_END
