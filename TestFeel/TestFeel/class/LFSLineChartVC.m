//
//  LFSLineChartVC.m
//  TestFeel
//
//  Created by app on 2022/4/1.
//

#import "LFSLineChartVC.h"
#import "PNChart.h"

@implementation LFSLineChartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 135.0, SCREEN_WIDTH, 200.0)];
//    [lineChart setXLabels:@[@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5"]];
//    lineChart.backgroundColor = [UIColor redColor]; //背景颜色
    lineChart.yGridLinesColor = [UIColor redColor];
    
    [lineChart setXLabels:@[@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5"]];

    // Line Chart No.1
    NSArray * data01Array = @[@60.1, @160.1, @126.4, @262.2, @186.2,@60.1, @160.1, @126.4, @262.2, @186.2,@60.1, @160.1, @126.4, @262.2, @186.2,@60.1, @160.1, @126.4, @262.2, @186.2];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = PNFreshGreen;
    data01.itemCount = lineChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    lineChart.showCoordinateAxis = YES;//显示坐标轴
    lineChart.chartData = @[data01];
    [lineChart.chartData enumerateObjectsUsingBlock:^(PNLineChartData *obj, NSUInteger idx, BOOL *stop) {
        obj.pointLabelColor = [UIColor redColor];
    }];
    lineChart.showSmoothLines = YES;
    lineChart.showYGridLines = YES;
    [lineChart strokeChart];
    [self.view addSubview:lineChart];
}

@end
