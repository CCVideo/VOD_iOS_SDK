#import <Foundation/Foundation.h>

@interface DWLog : NSObject

/*!
 * @method
 * @abstract 开启或关闭打印HTTP通信日志功能
 * @discussion 开启或关闭打印HTTP通信日志功能
 * @param on YES，则开启，NO则关闭。
 */
+(void)setIsDebugHttpLog:(BOOL)on;

/*!
 * @method
 * @abstract 查看是否开启打印HTTP通信日志功能
 * @discussion 查看是否开启打印HTTP通信日志功能
 * @result 开启返回YES，否则返回NO
 */
+(BOOL)isDebugHttpLog;

@end
