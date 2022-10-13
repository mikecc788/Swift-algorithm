//
//  CircleFriendInfo.m
//  TestFeel
//
//  Created by app on 2022/9/29.
//

#import "CircleFriendInfo.h"
#import "CircleDetailInfo.h"
#import "CircleCommentModel.h"
@implementation CircleFriendInfo
-(instancetype)init{
    if (self = [super init]){
        if (!_mDataMArray) {
            _mDataMArray = [NSMutableArray arrayWithCapacity:0];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"File" ofType:@""];
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            for (NSDictionary *dic in dataArr) {
                CircleDetailInfo *obj = [CircleDetailInfo obtainModelWithCircleDict:dic];
                obj.isOpen = NO;// 默认为闭合状态
                obj.isMoreViewShow = NO;
                NSMutableArray *commentArr = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *commentDic in obj.comment) {
                    CircleCommentModel *commentObj = [CircleCommentModel obtainModelWithCircleDict:commentDic];
                    [commentArr addObject:commentObj];
                }
                obj.comment = commentArr;
                [_mDataMArray addObject:obj];
            }
        }
    }
    return self;
}
@end
