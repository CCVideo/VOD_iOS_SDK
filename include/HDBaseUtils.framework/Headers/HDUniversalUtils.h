//
//  HDUniversalUtils.h
//  HDBaseUtils
//
//  Created by zwl on 2020/3/24.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HDUniversalUtils : NSObject

#pragma mark - Public Func
///获取系统版本
+(NSString *)HD_GetSystemVersion;

///获取设备型号
+(NSString *)HD_GetDeviceName;

#pragma mark - NSURL

+ (NSString *)HD_stringUrlEncode:(NSString *)string;
+ (NSString *)HD_stringUrlDecode:(NSString *)string;

/**
 *  从 urlString 解析url参数到 NSDictionary
 *  如 http://123.com/a/b/c.txt?v1=k1&v2=k3&v3=k3 解析的结果为：
 *   {
 *       "v1":"k1，
 *       "v2":"k3",
 *       "v3":"k3"，
 *    }
 *
 *  注意：该函数对字典里的value做了url解码。
 *
 *  @param urlString 字符串 url
 *
 *  @return url参数 字典
 */
+ (NSDictionary *)HD_urlQueryDictionaryWithURLString:(NSString *)urlString;
+ (NSDictionary *)HD_urlQueryDictionaryWithUrl:(NSURL *)url;

+ (NSData *)HD_encrypt:(NSData *)data key:(NSString *)key;
+ (NSData *)HD_decrypt:(NSData *)data key:(NSString *)key;

+ (UInt64)HD_htonll:(UInt64)n;
+ (UInt64)HD_ntohll:(UInt64)n;

+ (u_char *)HD_memcpyFrom:(const u_char *)src to:(u_char *)dst length:(size_t)len;

//字节数换算
//返回换算大小
+ (float)HD_calculateSizeWithBytes:(long long)bytes;
//返回换算单位
+ (NSString *)HD_calculateBytes:(long long)bytes;


/*!
 @method
 @abstract 创建设备唯一标识
 
 @return 操作结果
 */
+ (NSString *)uniqueMark;
/*!
 @method
 @abstract 删除创建的设备唯一标识
 */
+ (void)deleteUniqueMark;

/// 域名解析ip地址
/// @param hostName 待解析的域名
+ (NSString *)HD_getIPWithHostName:(const NSString*)hostName;

@end

