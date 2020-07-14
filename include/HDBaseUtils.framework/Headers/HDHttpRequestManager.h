//
//  HDHttpRequestManager.h
//  HDBaseUtils
//
//  Created by zwl on 2020/5/6.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DWHTTPRequest;

typedef void(^HDSSuccessBlock)(id responseObject,NSData *responseBody);
typedef void(^HDSFailureBlock)(id responseObject,NSError *error);

@interface HDHttpRequestManager : NSObject

/**
 eg:
 DWHTTPRequest * r = [HDHttpRequestManager GET:@"" Headers:@{} Success:^(id responseObject,                         NSData *responseBody) {
     
                     } Failure:^(id responseObject, NSError *error) {
     
                     }];
 [r startAsynchronous];
 
 */

+(DWHTTPRequest *)GET:(NSString *)URLString
              Headers:(NSDictionary <NSString *, NSString *> *)headers
              Success:(HDSSuccessBlock)success
              Failure:(HDSFailureBlock)failure;

+(DWHTTPRequest *)POST:(NSString *)URLString
               Headers:(NSDictionary <NSString *, NSString *> *)headers
               Success:(HDSSuccessBlock)success
               Failure:(HDSFailureBlock)failure;

@end
