//
//  CLDownLoadManager.m
//  TestFeel
//
//  Created by app on 2022/10/9.
//

#import "CLDownLoadManager.h"
/** 最大下载并发数 */
#define kMaxConcurrentOperationCount 5

@interface CLDownLoadManager()
/** 下载任务队列管理 */
@property (nonatomic,strong) NSOperationQueue *queue;
/** 网络下载器 */
@property (nonatomic,strong) NSURLSession *session;

@end
@implementation CLDownLoadManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static CLDownLoadManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[CLDownLoadManager alloc] init];
        /** 内存管理 */
//        instance.cacheManager = [[RLCacheManager alloc] init];
        /** 下载任务队列 */
        instance.queue = [[NSOperationQueue alloc] init];
        instance.queue.maxConcurrentOperationCount = kMaxConcurrentOperationCount;
        /** 下载管理器 */
        instance.session = [NSURLSession sharedSession];
        
        /** 当前正在下载的任务 */
//        instance.downloadingOperations = [NSMutableArray array];
    });
    
    return instance;
}
-(void)downLoadImageWithURLString:(NSString *)urlString complectionBlock:(void (^)(UIImage * _Nonnull, NSError * _Nonnull))complectionBlock{
    NSAssert(urlString && complectionBlock, @"参数错误!");
    
}
@end
