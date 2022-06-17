//
//  DMKeyPopView.m
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMKeyPopView.h"
#import "KeyPopCell.h"
//一个默认的坐标
#define HHframe  CGRectMake(0, 0, 100, 30)
@interface DMKeyPopView()<UITableViewDelegate,UITableViewDataSource,KeyPopCellDelegate>
@property (assign, nonatomic) NSIndexPath *selectedIndexPath;//单选，当前选中的行
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong) UIView * promptView;
@property(nonatomic,copy)NSString * cellStr;//单元格内容
@end

@implementation DMKeyPopView
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title cellArray:(NSArray *)cellArr{
    if (self =[super initWithFrame:frame]){
        self.cellArr = cellArr;
        self.cellStr=@"";
        self.title=title;
        self.backgroundColor = [[UIColor blackColor ]colorWithAlphaComponent:0.4];
        UIView * promptView = [UIView new];
        promptView.backgroundColor = [UIColor colorFromHexStr:@"#242529"];
        [self addSubview:promptView];
        self.promptView = promptView;
        promptView.layer.cornerRadius = 23;
        promptView.layer.masksToBounds = YES;
        [promptView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(self);
            make.height.mas_equalTo(KScaleHeight(420));
        }];
        
        UITableView * tableView = [[UITableView alloc]initWithFrame:HHframe style:UITableViewStylePlain];
        tableView.delegate =self;
        tableView.dataSource=self;
        tableView.scrollEnabled = NO;
        tableView.backgroundColor = [UIColor colorFromHexStr:@"#242529"];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [promptView addSubview:tableView];
        self.tableView = tableView;
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(promptView.mas_top).offset(20);
            make.left.right.mas_equalTo(promptView);
            make.bottom.mas_equalTo(promptView.mas_bottom).offset(-20);
        }];
        [tableView registerClass:[KeyPopCell class] forCellReuseIdentifier:@"PromptCell"];
        tableView.tableFooterView= [[UIView alloc]initWithFrame:CGRectZero];
        
    }
    return self;
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cellArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KeyPopCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PromptCell"];
    if (!cell) {
        cell = [[KeyPopCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PromptCell"];
        
    }
    
    if ([self.title isEqualToString:self.cellArr[indexPath.row]]) {
        cell.selectBtn.hidden = NO;
        self.selectedIndexPath = indexPath;
         cell.titleLab.textColor = [UIColor colorFromHexStr:@"#DFDFDF"];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate=self;
    cell.titleLab.text=self.cellArr[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return KScaleHeight(60);
}


-(void)cellDidClick:(KeyPopCell *)cell selectRowStr:(NSString *)cellStr{
    self.cellStr=cellStr;
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    cell.accessoryType = UITableViewCellAccessoryNone;
    KeyPopCell *cell1 = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    if (self.selectedIndexPath.row != index.row) {
        cell.titleLab.textColor = [UIColor colorFromHexStr:@"#DFDFDF"];
        cell1.titleLab.textColor = [UIColor colorFromHexStr:@"#A2A2A2"];
        cell.selectBtn.hidden = NO;
        cell1.selectBtn.hidden = YES;
    }else{
        cell1.titleLab.textColor = [UIColor colorFromHexStr:@"#DFDFDF"];
        cell.selectBtn.hidden = YES;
        cell1.selectBtn.hidden = NO;
    }
//    NSLog(@"selectStr=%@ clickrow=%ld lastStr=%@ lastRow=%ld",cellStr,(long)index.row,cell1.titleLab.text,self.selectedIndexPath.row);
    self.selectedIndexPath = index;
    if ([self.delegate respondsToSelector:@selector(kPromptView:cellStr:)]) {
        [self.delegate kPromptView:self cellStr:cellStr];
    }
    
}
// 点击提示框视图以外的其他地方时隐藏弹框
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [[touches anyObject] locationInView:self];
    point = [self.promptView.layer convertPoint:point fromLayer:self.layer];
    if (![self.promptView.layer containsPoint:point]) {
        self.hidden = YES;
    }
}

-(void)close{
    CATransform3D currentTransform = self.promptView.layer.transform;
    self.promptView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.promptView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.promptView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}
@end
