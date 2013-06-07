//
//  RequestHelper.h
//  TiantianCab
//
//  Created by Johnil on 13-5-17.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestHelper : NSObject

+ (RequestHelper *)defaultHelper;
- (void)requestPOSTAPI:(NSString *)api postData:(NSDictionary *)datas success:(void (^)(id result))success failed:(void (^)(id result, NSError *error))failed;
- (void)requestGETAPI:(NSString *)api postData:(NSDictionary *)datas success:(void (^)(id result))success failed:(void (^)(id result, NSError *error))failed;

@end
