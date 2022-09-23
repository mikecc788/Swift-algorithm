//
//  LoginProtocol.h
//  TestFeel
//
//  Created by app on 2022/9/23.
//

#import <Foundation/Foundation.h>

@protocol LoginProtocol <NSObject>
-(void)loginSuccess:(id)model;
-(void)loginFail:(NSInteger) errorCode errorMessage:(NSString *)errorMessage;
@end
