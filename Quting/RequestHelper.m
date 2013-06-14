//
//  RequestHelper.m
//  TiantianCab
//
//  Created by Johnil on 13-5-17.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import "RequestHelper.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "JSONKit.h"
#import "AppUtil.h"
#define SERVER_URL @"http://t.pamakids.com/"

@implementation RequestHelper 

+ (RequestHelper *)defaultHelper{
    static dispatch_once_t  onceToken;
    static RequestHelper * sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[RequestHelper alloc] init];
    });
    return sSharedInstance;
}

- (void)requestAPI:(NSString *)api type:(NSString *)type postData:(NSDictionary *)datas success:(void (^)(id result))success failed:(void (^)(id result, NSError *error))failed{
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSURLRequest *request = [httpClient requestWithMethod:type path:api parameters:datas];
    NSLog(@"request url:%@", [[request URL] absoluteString]);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success) {
            success(JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [AppUtil warning:@"服务器访问失败,请检查网络连接或重试" withType:m_error];
        if (failed) {
            failed(JSON, error);
        }
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
}

- (void)requestPOSTAPI:(NSString *)api postData:(NSDictionary *)datas success:(void (^)(id result))success failed:(void (^)(id result, NSError *error))failed{
    [self requestAPI:api type:@"POST" postData:datas success:success failed:failed];
}

- (void)requestGETAPI:(NSString *)api postData:(NSDictionary *)datas success:(void (^)(id result))success failed:(void (^)(id result, NSError *error))failed{
    [self requestAPI:api type:@"GET" postData:datas success:success failed:failed];
}

- (void)requestDELETEAPI:(NSString *)api postData:(NSDictionary *)datas success:(void (^)(id result))success failed:(void (^)(id result, NSError *error))failed{
    [self requestAPI:api type:@"DELETE" postData:datas success:success failed:failed];
}

@end
