//
//  Presenter.m
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import "Presenter.h"

@implementation Presenter
/**
 初始化函数
 */
- (instancetype)initWithView:(id)view{
    
    if (self = [super init]) {
        _view = view;
    }
    return self;
}
/**
 * 绑定视图
 * @param view 要绑定的视图
 */
- (void) attachView:(id)view {
    _view = view;
}


/**
 解绑视图
 */
- (void)detachView{
    _view = nil;
}
@end
