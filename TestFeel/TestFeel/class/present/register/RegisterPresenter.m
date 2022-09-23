//
//  RegisterPresenter.m
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import "RegisterPresenter.h"
#import "RegisterProtocol.h"
@implementation RegisterPresenter
-(void)test1{
    NSLog(@"test1");
    if ( [_view respondsToSelector:@selector(registerSuccess)]) {
        [_view registerSuccess];
    }
}
@end
