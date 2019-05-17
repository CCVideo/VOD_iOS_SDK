//
//  DWDownloadModel.h
//  Demo
//
//  Created by luyang on 2017/4/18.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>


// 下载状态
typedef NS_ENUM(NSUInteger, DWDownloadState) {
    DWDownloadStateNone,        // 未下载 或 下载删除了
    DWDownloadStateReadying,    // 等待下载
    DWDownloadStateRunning,     // 正在下载
    DWDownloadStateSuspended,   // 下载暂停
    DWDownloadStateCompleted,   // 下载完成
    DWDownloadStateFailed       // 下载失败
};

@class DWDownloadProgress;
@class DWDownloadModel;

// 进度更新block
typedef void (^DWDownloadProgressBlock)(DWDownloadProgress *progress,DWDownloadModel *downloadModel);
// 状态更新block
typedef void (^DWDownloadStateBlock)(DWDownloadModel *downloadModel,DWDownloadState state,NSString *filePath, NSError *error);



/**
 *  下载模型
 */
@interface DWDownloadModel : NSObject

// >>>>>>>>>>>>>>>>>>>>>>>>>>  download info
// 下载地址
@property (nonatomic, strong, readonly) NSString *downloadURL;
// 文件名 默认nil 则为下载URL中的文件名
@property (nonatomic, strong, readonly) NSString *fileName;
// 缓存文件目录 默认nil 则为manger缓存目录
@property (nonatomic, strong, readonly) NSString *downloadDirectory;
//加密
@property (nonatomic,copy)NSString *responseToken;

//URL失效后的断点续传需要设置这个数据
@property (nonatomic, strong) NSData *resumeData;

/*
 *用户信息
 *视频videoId
 */
@property (nonatomic,copy)NSString *userId;
@property (nonatomic,copy)NSString *key;
@property (nonatomic,copy)NSString *videoId;



// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign, readonly) DWDownloadState state;
// 下载任务
@property (nonatomic, strong, readonly) NSURLSessionTask *task;
// 文件流
@property (nonatomic, strong, readonly) NSOutputStream *stream;
// 下载进度
@property (nonatomic, strong ,readonly) DWDownloadProgress *progress;
// 下载路径 如果设置了downloadDirectory，文件下载完成后会移动到这个目录，否则，在manager默认cache目录里
@property (nonatomic, strong, readonly) NSString *filePath;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  download block
// 下载进度更新block
@property (nonatomic, copy) DWDownloadProgressBlock progressBlock;
// 下载状态更新block
@property (nonatomic, copy) DWDownloadStateBlock stateBlock;

/*
 * @param URLString 下载地址
 * @param  toekn usrId videoId为nil  其中filePath为nil 默认缓存到Document 
 * @param 只适用于 非加密的下载
 */

- (instancetype)initWithURLString:(NSString *)URLString;
/*
 * @param URLString 下载地址
 * @param  toekn usrId videoId为nil  其中filePath为缓存地址 当为nil 默认缓存到cache
 * @param 只适用于 非加密的下载
 */
- (instancetype)initWithURLString:(NSString *)URLString filePath:(NSString *)filePath;

/**
 *  初始化方法
 *
 *  @param URLString 下载地址
 *  @param filePath  缓存地址 当为nil 默认缓存到cache
 *  @param 加密 toekn usrId videoId必须传值 token是解析数据返回的responseToken userId videoId相对应的账号和视频videoId
 *  @param 非加密 toekn usrId videoId 可以为nil
 */
- (instancetype)initWithURLString:(NSString *)URLString filePath:(NSString *)filePath responseToken:(NSString *)token userId:(NSString *)userId videoId:(NSString *)videoId;

@end

/**
 *  下载进度
 */
@interface DWDownloadProgress : NSObject

// 续传大小
@property (nonatomic, assign, readonly) int64_t resumeBytesWritten;
// 这次写入的数量
@property (nonatomic, assign, readonly) int64_t bytesWritten;
// 已下载的数量
@property (nonatomic, assign, readonly) int64_t totalBytesWritten;
// 文件的总大小
@property (nonatomic, assign, readonly) int64_t totalBytesExpectedToWrite;
// 下载进度
@property (nonatomic, assign, readonly) float progress;
// 下载速度
@property (nonatomic, assign, readonly) float speed;
// 下载剩余时间
@property (nonatomic, assign, readonly) int remainingTime;



@end
