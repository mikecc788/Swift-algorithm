//
//  CLDownLoadManager.h
//  TestFeel
//
//  Created by app on 2022/10/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLDownLoadManager : NSObject
+ (instancetype)sharedManager;
/** 下载图片 */
- (void)downLoadImageWithURLString:(NSString *)urlString complectionBlock:(void(^)(UIImage *,NSError *))complectionBlock;
/** 取消所有的任务下载 */
- (void)cancelAllDownLoading;
/** recover 所有下载任务 */
- (void)recoverAllDownLoadOperations;
@end

NS_ASSUME_NONNULL_END
