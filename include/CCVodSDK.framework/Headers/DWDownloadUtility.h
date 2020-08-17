//
//  DWDownloadUtility.h
//  DWDownloadManagerDemo
//
//  Created by luyang on 17/4/18.
//  
//

#import <Foundation/Foundation.h>

///下载工具类
@interface DWDownloadUtility : NSObject

/*!
 * @method
 * @abstract 返回文件大小
 * @discussion 返回文件大小
 * @param contentLength 文件大小
 * @result 文件大小
 */
+(float)calculateFileSizeInUnit:(unsigned long long)contentLength;

/*!
 * @method
 * @abstract 返回文件大小的单位
 * @discussion 返回文件大小的单位
 * @param contentLength 文件大小
 * @result 文件大小单位
 */
+(NSString *)calculateUnit:(unsigned long long)contentLength;

@end
