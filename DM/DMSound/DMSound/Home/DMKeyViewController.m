//
//  DMKeyViewController.m
//  DMSound
//
//  Created by kiss on 2020/5/27.
//  Copyright © 2020 kiss. All rights reserved.
//

#import "DMKeyViewController.h"
#import "DMGoBackButton.h"
#import "DMKeyPopView.h"
#import "DMKeyViewCell.h"
#import "DMKeyButton.h"

#import "CLDataConver.h"
@interface DMKeyViewController ()<UITableViewDelegate,UITableViewDataSource,DMKeyViewCellDelegate,DMKeyPopViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray *titleArr;
@property(nonatomic,strong)NSIndexPath *currentIndex;
@property(nonatomic,strong)NSMutableArray *nameArr;
@end

@implementation DMKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = Gloabal_bg;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetKeyNotifi:) name:DMSetkeyResetNotification object:nil];
    
    self.nameArr = [[NSMutableArray alloc]init];
    for (int i =0 ;i<4;i++) {
        NSString *name;
        if (i>1) {
            name = [NSObject getKeyWithStr:[self.keyStr substringWithRange:NSMakeRange(16+i*4, 4)]];
        }else{
           name = [NSObject getKeyWithStr:[self.keyStr substringWithRange:NSMakeRange(8+i*4, 4)]];
        }
        [self.nameArr addObject:name];
       }
    NSLog(@"name==%@ key=%@",self.nameArr,self.keyStr);
    CGFloat offY = 170 ;
    self.titleArr = @[NSLocalizedString(@"連按兩次", nil),NSLocalizedString(@"連按三次", nil)];
    UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0 , SCREEN_WIDTH, SCREEN_HEIGHT ) style:UITableViewStylePlain];
    tableView.delegate =self;
    tableView.dataSource=self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
//    tableView.backgroundView.backgroundColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    [tableView registerClass:[DMKeyViewCell class] forCellReuseIdentifier:kCellIdentifier_DMKeyViewCell];
    tableView.tableHeaderView = [self setheaderView];
    UIImageView *bgImg = [[UIImageView alloc]initWithFrame:tableView.bounds];
    bgImg.image = [UIImage imageNamed:@"scan_bg"];
    [tableView addSubview:bgImg];
}
-(UIView*)setheaderView{
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, KScaleHeight(150))];
    DMGoBackButton *back = [[DMGoBackButton alloc]initWithFrame:CGRectMake(10, 10, 100, BackHeight)];
    [back setMutableTitleWithString:NSLocalizedString(@"按鍵設定", nil) textFont:[UIFont systemFontOfSize:30]];
    [headerV addSubview:back];
    
    UIButton *rsetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rsetButton addTarget:self action:@selector(resetClick:) forControlEvents:UIControlEventTouchUpInside];
    [rsetButton setTitle:NSLocalizedString(@"重設", nil) forState:UIControlStateNormal];
    rsetButton.backgroundColor = [UIColor colorFromHexStr:@"#242528"];
    [rsetButton setTitleColor:[UIColor colorFromHexStr:@"#A2A2A2"] forState:UIControlStateNormal];
    [rsetButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    rsetButton.titleLabel.numberOfLines = 0;
    rsetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rsetButton.layer setCornerRadius:10];
    [headerV addSubview:rsetButton];
    [rsetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerV.mas_right).offset(-20);
        make.bottom.equalTo(headerV.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(90, 50));
    }];
    
    return headerV;
}
-(IBAction)resetClick:(UIButton*)sender{
//    LogMethod();
    if ([self.delegate respondsToSelector:@selector(clickResetKeyBtn)]) {
        [self.delegate clickResetKeyBtn];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DMKeyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_DMKeyViewCell forIndexPath:indexPath];
    cell.delegate = self;
    [cell leftName:self.titleArr[indexPath.row]];
    [cell setKeyName:self.nameArr[indexPath.row + indexPath.section *2]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DMKeyViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = Gloabal_bg;
//    cell.contentView.backgroundColor = Gloabal_bg;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return [self setTitleName:NSLocalizedString(@"左耳機", nil) imageName:@"L"];
        
    }else{
        return [self setTitleName:NSLocalizedString(@"右耳機", nil) imageName:@"R"];
    }
}
-(UIView*)setTitleName:(NSString*)name imageName:(NSString*)img{
    UIView *nameView=[[UIView alloc]init];
    nameView.backgroundColor = [UIColor clearColor];
    //将分组的名字nameLabel添加到nameview上
    DMKeyButton *nameBtn=[[DMKeyButton alloc]init];
    [nameBtn setTitle:name forState:(UIControlStateNormal)];
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [nameBtn setImage:[UIImage imageNamed:img] forState:(UIControlStateNormal)];
    [nameBtn setTitleColor:[UIColor colorFromHexStr:@"#D0D0D0"] forState:(UIControlStateNormal)];
    [nameView addSubview:nameBtn];
    [nameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       make.leading.equalTo(nameView.mas_leading).offset(40);
       make.top.equalTo(nameView.mas_top).offset(20);
       make.height.mas_equalTo(40);
    }];
    [nameBtn sizeToFit];
    return nameView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
    
}
//设置headerView高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}
-(void)cellDidClick:(DMKeyViewCell *)cell{
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    self.currentIndex = index;
    NSLog(@"section=%ld row==%ld",index.section,index.row);
    NSArray * array = @[NSLocalizedString(@"播放/暂停", nil) ,NSLocalizedString(@"音量+", nil),NSLocalizedString(@"音量-", nil),NSLocalizedString(@"下一曲", nil),NSLocalizedString(@"上一曲", nil),NSLocalizedString(@"Siri", nil)];
    DMKeyPopView * kproptView = [[DMKeyPopView alloc]initWithFrame:kKeyWindow.frame title: self.nameArr[index.row + index.section*2]  cellArray:array];
    NSLog(@"==%@",self.nameArr[index.row + index.section*2]);
    kproptView.delegate = self;
    [kKeyWindow addSubview:kproptView];
}
//MARK:-NSNotification Method
-(void)resetKeyNotifi:(NSNotification*)notice{
    NSLog(@"刷新table了"); //backward 上一曲 0008  0004+0002=0006 0020+0080 =00a0
    [self.nameArr removeAllObjects];
    char send[18] = {0x00,0x09,0x00,0x03,0x00,0x06,0x00,0x08,0x01,0x40,0x00,0x03,0x00,0xa0,0x00,0x10,0x01,0x40};
    NSData *sendData = [NSData dataWithBytes:send length:18];
    for (int i =0 ;i<4;i++) {
     NSString *name;
     if (i>1) {
         name = [NSObject getKeyWithStr:[[CLDataConver hexadecimalString:sendData] substringWithRange:NSMakeRange(16+i*4, 4)]];
     }else{
        name = [NSObject getKeyWithStr:[[CLDataConver hexadecimalString:sendData] substringWithRange:NSMakeRange(8+i*4, 4)]];
     }
     [self.nameArr addObject:name];
    }
    [self.tableView reloadData];
}
//MARK:-DMKeyPopViewDelegate
-(void)kPromptView:(DMKeyPopView *)promptView cellStr:(NSString *)cellStr{
    [promptView close];
    [self.nameArr replaceObjectAtIndex:self.currentIndex.row + self.currentIndex.section*2 withObject:cellStr];
    [self.tableView reloadData];
    NSLog(@"selectName=%@ %@",cellStr,self.nameArr);
    if ([self.delegate respondsToSelector:@selector(clickSelectRow:selectName:)]) {
        [self.delegate clickSelectRow:self.currentIndex.row + self.currentIndex.section*2 selectName:cellStr];
    }
    
}
-(void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:DMSetkeyResetNotification object:nil];
}
@end
