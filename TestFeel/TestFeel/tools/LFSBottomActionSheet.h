//
//  LFSBottomActionSheet.h
//  FeelLife
//
//  Created by app on 2022/3/10.
//

#import <UIKit/UIKit.h>

@class LFSBottomActionSheetCell;
@protocol  LFSBottomActionSheetDelegate<NSObject>
@optional
-(void)selectIndex:(NSInteger)index selectTitle:(NSString*_Nullable)selectTitle;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LFSBottomActionSheet : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSArray *dataCount;

@property (nonatomic,strong)UITableView *actionSheetTable;

@property (nonatomic,strong)UIView *bgBlackView ;

@property (nonatomic,weak)id<LFSBottomActionSheetDelegate>delegate;

/**
 *  自定义高度 颜色等 待完善
 */
@property (nonatomic,strong)UIColor *contentColor;
@property (nonatomic,strong)UIFont  *contentFont;
@property (nonatomic,assign)CGFloat  contentHeight;
@property (nonatomic,strong)UIColor *cancleColor;

//自定义标题 可自行完善
@property (nonatomic,strong)NSString *viewTitle;
@property (nonatomic,strong)UIView *sheetHeadView;


-(instancetype)initwithArray:(NSArray *)array;
//显示
-(void)showActionSheet;
//隐藏
-(void)hideActionSheet;
@end

NS_ASSUME_NONNULL_END


@interface  LFSBottomActionSheetCell: UITableViewCell

@property(nonatomic,strong)UILabel * _Nullable actionsheet;

@end
