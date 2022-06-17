//
//  LFSBottomActionSheet.m
//  FeelLife
//
//  Created by app on 2022/3/10.
//

#import "LFSBottomActionSheet.h"
#import "Masonry.h"
#define kKeyWindow [[[UIApplication sharedApplication] windows] objectAtIndex:0]
@implementation LFSBottomActionSheet

-(instancetype)initwithArray:(NSArray *)array{
    if (self == [super init]){
        self.frame = kKeyWindow.bounds;
        self.dataCount = array;
        CGRect frame = self.frame;
        
        self.backgroundColor = [UIColor clearColor];
        self.bgBlackView  = [[UIView alloc]initWithFrame:frame];
        self.bgBlackView .backgroundColor = [UIColor blackColor];
        self.bgBlackView .alpha = 0.7;
        self.actionSheetTable.frame = CGRectMake(0,kKeyWindow.bounds.size.height,self.frame.size.width, 0);
        [self.actionSheetTable reloadData];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideActionSheet)];
        [self.bgBlackView  addGestureRecognizer:tap];
        self.contentColor = [UIColor whiteColor];
        self.contentFont = [UIFont systemFontOfSize:16];
        self.contentHeight = 54.0f;
        self.cancleColor = [UIColor grayColor];
    }
    return  self;
}


#pragma mark -tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  self.contentHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _dataCount.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        static NSString *identifier = @"LFSBottomActionSheetCell";
        LFSBottomActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell){
            cell = [[LFSBottomActionSheetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.actionsheet.text = _dataCount[indexPath.row];
            
            cell.actionsheet.textColor = self.contentColor;
            
            //去除底部横线
//            if (indexPath.row != [_dataCount count]-1)
//            {
//                UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,self.contentHeight-0.5,[UIScreen mainScreen].bounds.size.width, 0.5)];
//                lineView.backgroundColor = [UIColor lightGrayColor];
//                [cell.contentView addSubview:lineView];
//                
//            }
            
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,self.contentHeight-0.5,[UIScreen mainScreen].bounds.size.width, 0.5)];
            lineView.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:lineView];

        }
        return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (0 == indexPath.section) {
        
        if (self.delegate &&[self.delegate respondsToSelector:@selector(selectIndex:selectTitle:)])
        {
            [self.delegate selectIndex:indexPath.row selectTitle:self.dataCount[indexPath.row]];
        }
    }
    [self hideActionSheet];
}

-(UITableView*)actionSheetTable
{
    if (!_actionSheetTable)
    {
        _actionSheetTable= [[UITableView alloc]initWithFrame:CGRectZero];
        _actionSheetTable.delegate = self;
        _actionSheetTable.dataSource =self;
        _actionSheetTable.scrollEnabled = NO;
        _actionSheetTable.backgroundColor = Gloabal_bg;
        _actionSheetTable.tableFooterView = [self setFooter];
        [_actionSheetTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    
    return _actionSheetTable;
}

-(UIView*)setFooter{
    UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 54+20)];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 54)];
    [btn setTitleColor:self.cancleColor forState:(UIControlStateNormal)];
    [btn setTitle:@"取消" forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(cancel) forControlEvents:(UIControlEventTouchUpInside)];
    [bottom addSubview:btn];
    return bottom;
}
-(void)cancel{
    [self hideActionSheet];
}
-(void)showActionSheet{
 
    CGFloat y = kKeyWindow.bounds.size.height;
    [self addSubview: self.bgBlackView];
    [self addSubview:self.actionSheetTable];
    [kKeyWindow addSubview:self];
    CGFloat tableY = [self.dataCount count]* self.contentHeight +self.contentHeight+ 20;
    [UIView animateWithDuration:0.13 animations:^{
        
        self.actionSheetTable.backgroundColor = Gloabal_bg;
        
      self.actionSheetTable.frame = CGRectMake(0,y-tableY,self.frame.size.width,tableY);
       
   } completion:^(BOOL finished) {

   }];
}
-(void)hideActionSheet
{
    CGFloat y = kKeyWindow.bounds.size.height;
    
    [UIView animateWithDuration:0.13 animations:^{
        
        self.actionSheetTable.frame = CGRectMake(0,y,self.frame.size.width, 0);
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}


@end

@implementation LFSBottomActionSheetCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        self.actionsheet = [[UILabel alloc]init];
      
        self.actionsheet.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.actionsheet];
        [self.actionsheet mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(30);
        }];
    }
    return self;
}
@end
