//
//  NetworkManager.m
//  TestFeel
//
//  Created by app on 2022/9/27.
//

#import "NetworkManager.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#define HOST @"http://www.apitesting.dev/"
#define ENABLE_SSL 1
#define PROTOCOL (ENABLE_SSL ? @"https://" : @"http://")
#define PORT @"80"
#define BASE_URL [NSString stringWithFormat:@"%@%@:%@", PROTOCOL, HOST, PORT]

static const int port = 80;

@interface NetworkManager()
@property (nonatomic, strong) AFHTTPSessionManager *networkingManager;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property(nonatomic,strong)NSString *appID;
@end
#pragma mark -
#pragma mark Constructors

static NetworkManager *sharedManager = nil;

@implementation NetworkManager
+ (NetworkManager*)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^
    {
        sharedManager = [[NetworkManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if ((self = [super init])) {
        self.appID = @"1";
    }
    return self;
}

- (void)test {
    NSLog(@"Testing out the networking singleton for appID: %@, HOST: %@, and PORT: %d", self.appID, HOST, port);
}
- (AFHTTPSessionManager*)getNetworkingManagerWithToken:(NSString*)token {
    if (self.networkingManager == nil) {
        self.networkingManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        if (token != nil && [token length] > 0) {
            NSString *headerToken = [NSString stringWithFormat:@"%@ %@", @"JWT", token];
            [self.networkingManager.requestSerializer setValue:headerToken forHTTPHeaderField:@"Authorization"];
            // Example - [networkingManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        self.networkingManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.networkingManager.responseSerializer.acceptableContentTypes = [self.networkingManager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html", @"application/json", @"text/json"]];
        self.networkingManager.securityPolicy = [self getSecurityPolicy];
    }
    return self.networkingManager;
}
- (id)getSecurityPolicy {
    return [AFSecurityPolicy defaultPolicy];
    /* Example - AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [policy setAllowInvalidCertificates:YES];
    [policy setValidatesDomainName:NO];
    return policy; */
}
- (NSString*)getError:(NSError*)error {
    if (error != nil) {
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary class]] && [responseObject objectForKey:@"message"] != nil && [[responseObject objectForKey:@"message"] length] > 0) {
            return [responseObject objectForKey:@"message"];
        }
    }
    return @"Server Error. Please try again later";
}
- (void)showProgressHUD {
    [self hideProgressHUD];
    self.progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
    [self.progressHUD removeFromSuperViewOnHide];
    self.progressHUD.bezelView.color = [UIColor colorWithWhite:0.0 alpha:1.0];
    self.progressHUD.contentColor = [UIColor whiteColor];
}

- (void)hideProgressHUD {
    if (self.progressHUD != nil) {
        [self.progressHUD hideAnimated:YES];
        [self.progressHUD removeFromSuperview];
        self.progressHUD = nil;
    }
}
- (void)tokenCheckWithSuccess:(NetworkManagerSuccess)success failure:(NetworkManagerFailure)failure {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"token"];
    if (token == nil || [token length] == 0) {
        if (failure != nil) {
            failure(@"Invalid Token", -1);
        }
        return;
    }
    [self showProgressHUD];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [[self getNetworkingManagerWithToken:token] GET:@"/checktoken" parameters:params headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self hideProgressHUD];
        if (success != nil) {
            success(responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self hideProgressHUD];
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            failure(errorMessage, ((NSHTTPURLResponse*)operation.response).statusCode);
        }
    }];
    
}

- (void)authenticateWithEmail:(NSString*)email password:(NSString*)password success:(NetworkManagerSuccess)success failure:(NetworkManagerFailure)failure {
    if (email != nil && [email length] > 0 && password != nil && [password length] > 0) {
        [self showProgressHUD];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:email forKey:@"email"];
        [params setObject:password forKey:@"password"];
        [[self getNetworkingManagerWithToken:nil] POST:@"/authenticate" parameters:params headers:nil progress:nil  success:^(NSURLSessionTask *task, id responseObject) {
            [self hideProgressHUD];
            if (success != nil) {
                success(responseObject);
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            [self hideProgressHUD];
            NSString *errorMessage = [self getError:error];
            if (failure != nil) {
                failure(errorMessage, ((NSHTTPURLResponse*)operation.response).statusCode);
            }
        }];
    } else {
        if (failure != nil) {
            failure(@"Email and Password Required", -1);
        }
    }
}

@end
