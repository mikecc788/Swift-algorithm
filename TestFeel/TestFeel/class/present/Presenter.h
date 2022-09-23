//
//  Presenter.h
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Presenter : NSObject{
    //MVP中负责更新的视图
    __weak id _view;
}

/**
 初始化函数

 @param view 要绑定的视图
 */
- (instancetype) initWithView:(id)view;

/**
 * 绑定视图
 * @param view 要绑定的视图
 */
- (void) attachView:(id)view ;

/**
 解绑视图
 */
- (void)detachView;

@end

NS_ASSUME_NONNULL_END
