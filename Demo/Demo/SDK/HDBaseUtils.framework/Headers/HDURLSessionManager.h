//
//  HDURLSessionSessionManager.h
//  HDURLSession
//
//  Created by zwl on 2020/3/23.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HDURLSessionManagerDelegate <NSObject>

@optional
//上传，下载通用方法
-(void)HDURLSessionTask:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

///上传进度回调
-(void)HDURLSessionTask:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

//下载方法回调
///恢复下载
-(void)HDURLSessionDownloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes;

///下载进度监听
-(void)HDURLSessionDownloadTask:(NSURLSessionDownloadTask *)downloadTask    didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
      totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

///下载完成
-(void)HDURLSessionDownloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;

@end

@interface HDURLSessionManager : NSObject

+(HDURLSessionManager *)sharedManager;

///上传任务初始化

/// 初始化上传任务
/// @param urlString 上传地址
/// @param params 上传参数
/// @param filePath 本地文件路径
-(NSURLSessionUploadTask *)getUploadTaskWithUrl:(NSString *)urlString
                                         Params:(NSDictionary *)params
                                       FilePath:(NSString *)filePath;

/// 初始化上传任务
/// @param request 上传任务
/// @param filePath 本地文件路径
-(NSURLSessionUploadTask *)getUploadTaskWithRequest:(NSURLRequest *)request
                                           FilePath:(NSString *)filePath;

/// 获取当前所有上传任务
-(NSArray <NSURLSessionUploadTask *> *)getAllUploadTasks;

//下载任务初始化

/// 初始化下载任务
/// @param urlString 下载地址
/// @param params 下载参数
-(NSURLSessionDownloadTask *)getDownloadTaskWithUrl:(NSString *)urlString
                                             Params:(NSDictionary *)params;

/// 初始化下载任务
/// @param request 下载任务
-(NSURLSessionDownloadTask *)getDownloadTaskWithRequest:(NSURLRequest *)request;

/// 通过resumeData初始化下载任务
/// @param resumeData 续传数据
-(NSURLSessionDownloadTask *)getDownloadTaskWithResumeData:(NSData *)resumeData;

-(NSArray <NSURLSessionDownloadTask *> *)getAllDownloadTasks;

/// 开始任务
/// @param task 具体任务
-(BOOL)resumeTask:(NSURLSessionTask *)task;

/// 暂停任务
/// @param task 具体任务
-(BOOL)suspendTask:(NSURLSessionTask *)task;

/// 代理回调
@property(nonatomic,weak) id <HDURLSessionManagerDelegate> delegate;

@end
