//
//  DWDownloadSessionManager.h
//  DWDownloadManagerDemo
//
//  Created by luyang on 17/4/19.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDownloadModel.h"



// 下载代理
@protocol DWDownloadDelegate <NSObject>

// 更新下载进度
- (void)downloadModel:(DWDownloadModel *)downloadModel didUpdateProgress:(DWDownloadProgress *)progress;

// 更新下载状态
- (void)downloadModel:(DWDownloadModel *)downloadModel didChangeState:(DWDownloadState)state filePath:(NSString *)filePath error:(NSError *)error;

@end

/**
 *  下载管理类 封装NSURLSessionDownloadTask
 */
@interface DWDownloadSessionManager : NSObject<NSURLSessionDownloadDelegate>

// 下载代理
@property (nonatomic,weak) id<DWDownloadDelegate> delegate;

// 等待中的模型 只读
@property (nonatomic, strong,readonly) NSMutableArray *waitingDownloadModels;

// 下载中的模型 只读
@property (nonatomic, strong,readonly) NSMutableArray *downloadingModels;

/*
 * maxDownloadCount resumeDownloadFIFO起作用的前提是设置 isBatchDownload =NO
 * 设置maxDownloadCount 是为了处理 譬如网络不好的时候 设置一次只下载一个视频 而不是必须要求有多个视频并发下载
 * 注意 最大下载数的概念 是少于或等于
 */

// 最大下载数
@property (nonatomic, assign) NSInteger maxDownloadCount;

// 等待下载队列 先进先出 默认YES， 当NO时，先进后出
@property (nonatomic, assign) BOOL resumeDownloadFIFO;

// 全部并发 默认YES, 当YES时，忽略maxDownloadCount 
@property (nonatomic, assign) BOOL isBatchDownload;

// 后台session configure
@property (nonatomic, strong) NSString *backgroundConfigure;
@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)();

// 后台下载完成后调用 返回文件保存路径filePath
@property (nonatomic, copy) NSString *(^backgroundSessionDownloadCompleteBlock)(NSString *downloadURL);
//是否允许使用移动流量 YES支持 NO不支持 默认支持
@property (nonatomic,assign)BOOL allowsCellular;

// 单例
+ (DWDownloadSessionManager *)manager;

// 配置后台session
- (void)configureBackroundSession;

// 获取正在下载模型
- (DWDownloadModel *)downLoadingModelForURLString:(NSString *)URLString;

// 获取后台运行task
- (NSURLSessionDownloadTask *)backgroundSessionTasksWithDownloadModel:(DWDownloadModel *)downloadModel;

// 是否已经下载
- (BOOL)isDownloadCompletedWithDownloadModel:(DWDownloadModel *)downloadModel;

// 取消所有完成或失败后台task
- (void)cancleAllBackgroundSessionTasks;

// 开始下载
- (DWDownloadModel *)startDownloadURLString:(NSString *)URLString toDestinationPath:(NSString *)destinationPath progress:(DWDownloadProgressBlock)progress state:(DWDownloadStateBlock)state;

// 开始下载 
- (void)startWithDownloadModel:(DWDownloadModel *)downloadModel;

// 开始下载
- (void)startWithDownloadModel:(DWDownloadModel *)downloadModel progress:(DWDownloadProgressBlock)progress state:(DWDownloadStateBlock)state;

// 恢复下载（除非确定对这个model进行了suspend，否则使用start）
- (void)resumeWithDownloadModel:(DWDownloadModel *)downloadModel;

// 暂停下载
- (void)suspendWithDownloadModel:(DWDownloadModel *)downloadModel;

// 取消下载 YES清除已下载的数据 NO不清除
- (void)cancleWithDownloadModel:(DWDownloadModel *)downloadModel isClear:(BOOL )isClear;

// 删除下载文件 
- (void)deleteFileWithDownloadModel:(DWDownloadModel *)downloadModel;

// 删除下载文件 downloadDirectory:对应的文件路径videoPath
- (void)deleteAllFileWithDownloadDirectory:(NSString *)downloadDirectory;

//根据路径获取resumeData path:传原先的下载URL字符串
- (NSData *)resumeDataFromFileWithFilePath:(NSString *)path;

//根据新的URL生成新的resumeData resumeData:原先下载的data urlString:新的下载URL字符串
- (NSData *)newResumeDataFromOldResumeData:(NSData *)resumeData withURLString:(NSString *)urlString;

@end
