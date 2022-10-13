//
//  ImageCacheController.m
//  TestFeel
//
//  Created by app on 2022/10/9.
//

#import "ImageCacheController.h"

static NSUInteger downloadIndex = 0;

@interface ImageCacheController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property(nonatomic,strong)NSArray<NSString *> *downloadStrings;
@end

@implementation ImageCacheController

- (void)viewDidLoad {
    [super viewDidLoad];
    _downloadStrings = @[
                         @"https://img.iplaysoft.com/wp-content/uploads/2019/free-images/free_stock_photo_2x.jpg!0x0.webp",
                         @"http://img.daimg.com/uploads/allimg/220430/3-220430155613.jpg",
                         @"http://img.daimg.com/uploads/allimg/220406/3-2204062156010-L.jpg",
                         @"http://img.daimg.com/uploads/allimg/220406/3-2204061434500-L.jpg",
                         @"http://img.daimg.com/uploads/allimg/220405/3-220405160F10-L.jpg",
                         @"http://pic.tesetu.com/2017/0426/30/15.jpg",
                         @"http://img.daimg.com/uploads/allimg/220324/3-2203241HA40-L.jpg",
                         @"http://img.daimg.com/uploads/allimg/211113/3-2111131I6140-L.jpg",
                         @"http://img.daimg.com/uploads/allimg/211117/3-21111G054080-L.jpg"
                         ];
}


- (IBAction)downLoadImage:(UIButton *)sender {
    if (downloadIndex == _downloadStrings.count) {
        NSLog(@"%@",@"数组内图片下载完毕!");
        return;
    }
}

@end
