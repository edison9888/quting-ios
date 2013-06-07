//
//  AppUtil.h
//  TiantianCab
//
//  Created by Johnil on 13-5-17.
//  Copyright (c) 2013年 Johnil. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    m_none = -1,
    m_error,
    m_success
} MessageType;

@interface AppUtil : NSObject

+ (BOOL)isNetworkReachable;
+ (BOOL)isValidatePhoneNumber:(NSString *)number;
+ (void)warning:(NSString *)message withType:(MessageType)type;

@end
