//
//  FriendCircleViewCell.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "FriendCircleViewCell.h"
#import <Masonry.h>
#import "XtayCircleContentView.h"
#import "XtayCircleImageView.h"
#import "XtayCaculateHeightTool.h"
#import "CircleThumbView.h"
#import "XtayCircleCommentView.h"
#import "XtayLikeCommentView.h"
@interface FriendCircleViewCell()<XtayOpenCloseButtonResDelegate,XtayLookImagesDelegate,ThumbViewDelegate,XtayCommentViewDelegate,XtayLikeCommentDelegate>
/// headimg
@property (nonatomic, strong) UIImageView *headImageView;
/// nameLabel
@property (nonatomic, strong) UILabel *nameLabel;
/// contentLabelView
@property (nonatomic, strong) XtayCircleContentView *contentLabelView;
/// imageView
@property (nonatomic, strong) XtayCircleImageView *circleImageView;
/// timeLabel
@property (nonatomic, strong) UILabel *timeLabel;
/// moreButton
@property (nonatomic, strong) UIButton *moreButton;
/// thumbView
@property (nonatomic, strong) CircleThumbView *thumbView;
/// commentView
@property (nonatomic, strong) XtayCircleCommentView *commentView;
/// likeCommentView
@property (nonatomic, strong) XtayLikeCommentView *likeCommentView;

@end

@implementation FriendCircleViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customUI];
        [self basicSettingsFrame];
    }
    return self;
}
- (void)customUI {
    self.headImageView = [[UIImageView alloc] init];
    _headImageView.image = [UIImage imageNamed:@""];
    [self.contentView addSubview:_headImageView];
    
    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = XTAY_FONT_WEIGHT(16, 0.3);
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLabel];
                            
    self.contentLabelView = [[XtayCircleContentView alloc] init];
    _contentLabelView.delegate = self;
    [self.contentView addSubview:_contentLabelView];
    
    self.circleImageView = [[XtayCircleImageView alloc] init];
    _circleImageView.delegate = self;
    [self.contentView addSubview:_circleImageView];
    
    self.timeLabel = [[UILabel alloc] init];
    _timeLabel.textColor = [UIColor lightGrayColor];
    _timeLabel.font = XTAY_FONT_WEIGHT(12, 0);
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_timeLabel];
                            
    self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"gengduo"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreHandleClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_moreButton];
    
    self.likeCommentView = [[XtayLikeCommentView alloc] init];
    _likeCommentView.delegate = self;
    [self.contentView addSubview:_likeCommentView];
    
    self.thumbView = [[CircleThumbView alloc] init];
    self.thumbView.delegate = self;
    [self.contentView addSubview:_thumbView];

    self.commentView = [[XtayCircleCommentView alloc] init];
    self.commentView.delegate = self;
    [self.contentView addSubview:_commentView];
}
- (void)basicSettingsFrame {
    XTAY_WEAK_SELF
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(weakSelf.contentView).offset(10);
        make.width.height.mas_equalTo(AVATAR_W_H);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.headImageView.mas_right).offset(10);
        make.top.equalTo(weakSelf.headImageView.mas_top);
        make.height.mas_equalTo(30);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    LogMethod();
//    self.presenter = [[CirclePhotoPresenter alloc] initWithView:self];
}

- (void)setModel:(CircleDetailInfo *)model {
    if (model) {
        _model = model;
        self.headImageView.image = [UIImage imageNamed:_model.avata];
        self.nameLabel.text = _model.name;
        [self handleTimeView];
        [self handleContentView];
        [self handleImagesView];
        [self handleThumbView];
        [self handleCommentView];
    }
}
- (void)handleCommentView {
    [_commentView creatCommentViewWithCommentArr:_model.comment withWidth:SCREEN_WIDTH-30-AVATAR_W_H];
    CGFloat commentH = [XtayCaculateHeightTool caculateCommentHeightWithCommentArray:_model.comment realWidth:SCREEN_WIDTH-30-AVATAR_W_H textFont:XTAY_FONT_WEIGHT(15, 0)];
    XTAY_WEAK_SELF
    if (commentH == 0) {
        [_commentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.thumbView.mas_bottom).offset(0);
            make.height.mas_equalTo(commentH);
        }];
    } else {
        [_commentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.nameLabel.mas_left);
            make.right.equalTo(weakSelf.contentLabelView.mas_right);
            make.top.equalTo(weakSelf.thumbView.mas_bottom).offset(5);
            make.height.mas_equalTo(commentH);
        }];
    }
}
- (void)handleContentView {
    CGFloat contentH = [XtayCaculateHeightTool caculateContentHeightWithText:_model.content realWidth:SCREEN_WIDTH-30-AVATAR_W_H textFont:XTAY_FONT_WEIGHT(15, 0) isOpen:_model.isOpen];
    BOOL isShow = NO;
    if (contentH >= CONTENT_SHOW_MAXH) {
        isShow = YES;
    }
    [self.contentLabelView giveContentString:_model.content openCloseBtnSelected:_model.isOpen isShowBtn:isShow];
    XTAY_WEAK_SELF
    if (contentH == 0) {
        [_contentLabelView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(0);
            make.right.equalTo(weakSelf.contentView).offset(-10);
            make.height.mas_equalTo(contentH);
        }];
    } else {
        [_contentLabelView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(5);
            make.left.equalTo(weakSelf.nameLabel.mas_left);
            make.right.equalTo(weakSelf.contentView).offset(-10);
            make.height.mas_equalTo(contentH);
        }];
    }
}
- (void)handleThumbView {
    XTAY_WEAK_SELF
    [_thumbView creatThumbViewWithThumbArr:_model.thumb];
    CGFloat thumbH = [XtayCaculateHeightTool caculateThumbHeightWithThumbList:_model.thumb realWidth:SCREEN_WIDTH-30-AVATAR_W_H textFont:XTAY_FONT_WEIGHT(15, 0)];
    if (thumbH == 0) {
        [_thumbView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.nameLabel.mas_left);
            make.right.equalTo(weakSelf.contentLabelView.mas_right);
            make.top.equalTo(weakSelf.timeLabel.mas_bottom).offset(0);
            make.height.mas_equalTo(thumbH);
        }];
    } else {
        [_thumbView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.nameLabel.mas_left);
            make.right.equalTo(weakSelf.contentLabelView.mas_right);
            make.top.equalTo(weakSelf.timeLabel.mas_bottom).offset(5);
            make.height.mas_equalTo(thumbH);
        }];
    }
}
- (void)handleImagesView {
    [_circleImageView creatImageViewWithImages:_model.images withWidth:SCREEN_WIDTH-30-AVATAR_W_H];
    XTAY_WEAK_SELF
    CGFloat imageViewH = [XtayCaculateHeightTool caculateImagesHeightWithImgsCount:_model.images.count realWidth:SCREEN_WIDTH-30-AVATAR_W_H];
    if (imageViewH == 0) {
        [self.circleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.contentLabelView.mas_bottom).offset(0);
            make.height.mas_equalTo(imageViewH);
        }];
    } else {
        [self.circleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.contentLabelView.mas_bottom).offset(5);
            make.left.equalTo(weakSelf.nameLabel.mas_left);
            make.right.equalTo(weakSelf.contentLabelView.mas_right);
            make.height.mas_equalTo(imageViewH);
        }];
    }
}
- (void)handleTimeView {
    self.timeLabel.text = _model.time;
    self.likeCommentView.hidden = !_model.isMoreViewShow;
    self.likeCommentView.haveDianZaned = _model.hasLiked;
    XTAY_WEAK_SELF
    [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.circleImageView.mas_bottom).offset(5);
        make.left.equalTo(weakSelf.nameLabel.mas_left);
        make.height.mas_equalTo(20);
    }];
    [_moreButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.timeLabel.mas_top).offset(0);
        make.right.equalTo(weakSelf.contentLabelView.mas_right);
        make.height.mas_equalTo(weakSelf.timeLabel.mas_height);
        make.width.mas_equalTo(40);
    }];
    
    [_likeCommentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.moreButton.mas_left).offset(-5);
        make.centerY.equalTo(weakSelf.moreButton.mas_centerY);
        make.width.mas_equalTo(115);
        make.height.mas_equalTo(30);
    }];
}

- (void)moreHandleClick {
    if ([self.cellDelegate respondsToSelector:@selector(moreButtonCallBackCell:)]) {
        [self.cellDelegate moreButtonCallBackCell:self];
    }
}
-(void)openOrCloseBtnCallBackStatus:(BOOL)isOpen{
    if ([self.cellDelegate respondsToSelector:@selector(openOrCloseBtnResponseWithCurrentStatus:cell:)]) {
        [self.cellDelegate openOrCloseBtnResponseWithCurrentStatus:isOpen cell:self];
    }
}
//点击图片浏览器
- (void)lookImageWithIndex:(NSInteger)index {
    if ([self.cellDelegate respondsToSelector:@selector(lookCellImagesWithIndex:cell:)]) {
        [self.cellDelegate lookCellImagesWithIndex:index cell:self];
    }
}
//点赞和回复
-(void)huiFuClick{
    if ([self.cellDelegate respondsToSelector:@selector(moreBtnSubViewHuiFuResCell:)]) {
        [self.cellDelegate moreBtnSubViewHuiFuResCell:self];
    }
}
@end
