#import <Foundation/Foundation.h>

typedef void (^DWHTTPRequestDrmProgressBlock)(NSData *data, NSInteger totalBytesReceived, NSInteger totalBytesExpectedToReceive);
typedef void (^DWErrorBlock)(NSError *error);
typedef void (^DWHTTPRequestReceiveResponseBlock)(NSHTTPURLResponse *response);
typedef void (^DWHTTPRequestDownloadProgressBlock)(NSInteger bytesWritten, NSInteger totalBytesReceived, NSInteger totalBytesExpectedToReceive);
typedef void (^DWHTTPRequestUploadProgressBlock)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);
typedef void (^DWHTTPRequestFinishLoadingBlock)(NSHTTPURLResponse *response, NSData *responseBody);
typedef void (^DWHTTPRequestFinishLoadingStringBlock)(NSHTTPURLResponse *response, NSString *responseBodyString);

@interface DWHTTPRequest : NSObject <NSURLConnectionDataDelegate,NSURLSessionTaskDelegate,NSURLSessionDelegate>{
    NSURLSession *inProcessSession;
}

# pragma mark - http request
@property (strong, nonatomic)NSURL *url;
@property (copy, nonatomic)NSString *HTTPMethod;
@property (strong, nonatomic, readonly)NSDictionary *requestHeaders;
@property (strong, nonatomic)NSData *requestBody;
@property (assign, nonatomic)NSTimeInterval timeoutSeconds;

# pragma mark - http response
@property (strong, nonatomic, readonly)NSHTTPURLResponse *response;
@property (assign, nonatomic)NSStringEncoding forcedResponseEncoding;

@property (strong, nonatomic, readonly)NSData *responseBody;
@property (copy, nonatomic, readonly)NSString *responseBodyString;


/**
 *  若设置为YES，则在 -connection:didReceiveData: 中不会copy接受的数据。
 *  默认为NO，若使用 -startAsynchronousWithDestinationFilePath:，则接收到的数据会被写入文件，否则追加到buffer。
 */
@property (assign, nonatomic)BOOL unCopyResponseBody;
@property (copy)DWHTTPRequestDrmProgressBlock drmProgressBlock;
@property (copy)DWHTTPRequestReceiveResponseBlock receiveReponseBlock;
@property (copy)DWHTTPRequestDownloadProgressBlock downoadProgressBlock;
@property (copy)DWHTTPRequestUploadProgressBlock uploadProgressBlock;

/**
 非点播产品线，只需关心这3个回调即可！！！
 */
//网络请求完成回调
@property (copy)DWHTTPRequestFinishLoadingBlock finishLoadingBlock;
//网络请求完成回调
@property (copy)DWHTTPRequestFinishLoadingStringBlock finishLoadingStringBlock;
//网络请求失败回调
@property (copy)DWErrorBlock errorBlock; 

/**
 *  通过 NSURL 初始化 DWHTTPRequest，设置默认请求超时时间：10秒。
 *
 *  @param url 用户传来的NSURL
 *
 *  @return 返回 DWHTTPRequest
 */
+ (DWHTTPRequest *)requestWithURL:(NSURL *)url;

/**
 *  通过字符串url初始化 DWHTTPRequest，设置默认请求超时时间：10秒。
 *
 *  @param urlString 字符串url
 *
 *  @return 返回 DWHTTPRequest
 */
+ (DWHTTPRequest *)requestWithURLString:(NSString *)urlString;

/**
 *  发起同步HTTP请求
 *
 *  @param error 错误信息
 *
 *  @return HTTP响应体
 */
- (NSData *)startSynchronousWithError:(NSError **)error;

/**
 *  发起异步HTTP请求 
 */
- (void)startAsynchronous;



/**
 *  结束本次HTTP请求
 */
- (void)finish;

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)name;


@end
