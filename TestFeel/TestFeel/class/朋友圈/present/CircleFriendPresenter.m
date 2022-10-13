//
//  CircleFriendPresenter.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "CircleFriendPresenter.h"
#import "CircleFriendInfo.h"
#import "FriendCircleViewCell.h"
#import "XtayCaculateHeightTool.h"
#import "TZImagePickerController.h"
#import "CLPhoto.h"
#import "FriendCommentInputView.h"
#define UN_VISIABLE_FRAME   CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 60)
@interface CircleFriendPresenter()<FriendClickCellProtocol,CommentInputContentFinishedProtocol>
@property (nonatomic, strong) NSMutableArray *mDataMArray;
@property(nonatomic,strong)CircleFriendInfo *info;
/// 上一个选择的展开更多cell的索引值
@property (nonatomic, assign) NSInteger lastSelctedIndex;
@property(nonatomic,strong)FriendCommentInputView *commentInputView;
/// 是否需要弹出输入框
@property (nonatomic, assign) BOOL isNeedInput;
@end

@implementation CircleFriendPresenter
-(instancetype)init{
    if (self = [super init]) {
        self.info = [CircleFriendInfo new];
        self.lastSelctedIndex = -1;
    }
    return self;
}
- (instancetype)initWithView:(UITableView *)view{
    if (self = [self init]) {
        self.tableView = view;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self.tableView registerClass:[FriendCircleViewCell class] forCellReuseIdentifier:@"CircleDetailInfoCell"];
        
    }
    
    return self;
}
-(void)setViewController:(UIViewController *)viewController{
    _viewController = viewController;
    [viewController.view addSubview:self.commentInputView];
    // 添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShown:) name:UIKeyboardWillShowNotification object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.info.mDataMArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id post = self.info.mDataMArray[indexPath.row];
    NSString *identifier = [NSString stringWithFormat:@"%@Cell", NSStringFromClass([post class])];
    FriendCircleViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if ([cell respondsToSelector:@selector(presenter)]) {
//        NSObject<CirclePresenterProtocol> *presenter = [cell presenter];
//        [presenter presentWithModel:post viewController:self.viewController];
//    }
    cell.cellDelegate = self;
    [cell setModel:post];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CircleDetailInfo *model = self.info.mDataMArray[indexPath.row];
    CGFloat contentH = [XtayCaculateHeightTool caculateContentHeightWithText:model.content realWidth:SCREEN_WIDTH-30-AVATAR_W_H textFont:XTAY_FONT_WEIGHT(15, 0) isOpen:model.isOpen];
    contentH != 0 ? contentH+=5 : contentH;
    CGFloat imagesH = [XtayCaculateHeightTool caculateImagesHeightWithImgsCount:model.images.count realWidth:SCREEN_WIDTH-30-AVATAR_W_H];
    imagesH != 0 ? imagesH+=5 : imagesH;
    CGFloat commentH = [XtayCaculateHeightTool caculateCommentHeightWithCommentArray:model.comment realWidth:SCREEN_WIDTH-30-AVATAR_W_H textFont:XTAY_FONT_WEIGHT(15, 0)];
    commentH != 0 ? commentH+=5 : commentH;
    CGFloat thumbH = [XtayCaculateHeightTool caculateThumbHeightWithThumbList:model.thumb realWidth:SCREEN_WIDTH-30-AVATAR_W_H textFont:XTAY_FONT_WEIGHT(15, 0)];
    
    return 10+30+10+contentH +imagesH + commentH + thumbH + 25;
}
- (void)openOrCloseBtnResponseWithCurrentStatus:(BOOL)isOpen cell:(nonnull FriendCircleViewCell *)cell {
    [self beginHideCommentInputView];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (_lastSelctedIndex >= 0) {
        [self showOrHideMoreBtnViewWithIndexPath:[NSIndexPath indexPathForRow:_lastSelctedIndex inSection:0] isMoreViewShow:NO];
        self.lastSelctedIndex = -1;
    }
    CircleDetailInfo *obj = [self.info.mDataMArray objectAtIndex:indexPath.row];
    obj.isOpen = isOpen;
    [self.mDataMArray replaceObjectAtIndex:indexPath.row withObject:obj];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)lookCellImagesWithIndex:(NSInteger)index cell:(FriendCircleViewCell *)cell {
    [self beginHideCommentInputView];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (_lastSelctedIndex >= 0) {
        [self showOrHideMoreBtnViewWithIndexPath:[NSIndexPath indexPathForRow:_lastSelctedIndex inSection:0] isMoreViewShow:NO];
        self.lastSelctedIndex = -1;
    }
    CircleDetailInfo *obj = [self.info.mDataMArray objectAtIndex:indexPath.row];
    NSMutableArray *imgsArray = [NSMutableArray arrayWithCapacity:0];
    for (NSString *name in obj.images) {
        CLPhoto *photo = [[CLPhoto alloc] initWithImage:[UIImage imageNamed:name]];
        [imgsArray addObject:photo];
    }
  
}
//评论三个点
-(void)moreButtonCallBackCell:(FriendCircleViewCell *)cell{
    [self beginHideCommentInputView];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CircleDetailInfo *obj = [self.info.mDataMArray objectAtIndex:indexPath.row];
    obj.isMoreViewShow = !obj.isMoreViewShow;
    [self.info.mDataMArray replaceObjectAtIndex:indexPath.row withObject:obj];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)moreBtnSubViewHuiFuResCell:(FriendCircleViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    self.commentInputView.placeHolder = [NSString stringWithFormat:@"回复%@", currentModel.name];
    [self.commentInputView beginShowInputView];
}
- (void)showOrHideMoreBtnViewWithIndexPath:(NSIndexPath *)indexPath isMoreViewShow:(BOOL)isMoreViewShow {
    CircleDetailInfo *obj = [self.info.mDataMArray objectAtIndex:indexPath.row];
    obj.isMoreViewShow = isMoreViewShow;
    [self.mDataMArray replaceObjectAtIndex:indexPath.row withObject:obj];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)beginHideCommentInputView {
    [self.commentInputView beginHiddenInputView];
    XTAY_WEAK_SELF
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.commentInputView.frame = UN_VISIABLE_FRAME;
    }];
}
- (FriendCommentInputView *)commentInputView {
    if (!_commentInputView) {
        _commentInputView = [[FriendCommentInputView alloc] initWithFrame:UN_VISIABLE_FRAME];
        _commentInputView.delegate = self;
    }
    return _commentInputView;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.isNeedInput) {
        [self beginHideCommentInputView];
    }
}
// MARK: - 键盘通知系统事件
- (void)keyBoardWillShown:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    XTAY_WEAK_SELF
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.commentInputView.frame = CGRectMake(0, SCREEN_HEIGHT- XTAY_STATUS_BAR_H - self.viewController.navigationController.navigationBar.frame.size.height-height + SafeAreaBottomHeight, SCREEN_WIDTH, 60);
    } completion:^(BOOL finished) {
        weakSelf.isNeedInput = NO;
    }];
}
@end
