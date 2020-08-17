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
typedef void (^DWDownloadStateBlock)(DWDownloadModel *downloadModel, NSError *error);


///下载模型
@interface DWDownloadModel : NSObject

/**
 *  @brief 下载地址
 */
@property(nonatomic, strong, readonly)NSString * downloadURL;

/**
 *  @brief 文件名
 */
@property(nonatomic, strong, readonly)NSString * fileName;

/**
 *  @brief 存储路径
 */
@property(nonatomic, strong, readonly)NSString * filePath;

/**
 *  @brief 下载状态
 */
@property(nonatomic, assign, readonly)DWDownloadState state;

/**
 *  @brief 文件类型，1 视频 2 音频
 */
@property(nonatomic, strong, readonly)NSString * mediaType;

/**
 *  @brief 文件后缀名
 */
@property(nonatomic ,strong, readonly)NSString * mimeType;

/**
 *  @brief 清晰度
 */
@property(nonatomic, strong, readonly)NSString * quality;

/**
 *  @brief 清晰度描述
 */
@property(nonatomic, strong, readonly)NSString * desp;

/**
 *  @brief VR视频
 */
@property(nonatomic, assign, readonly)BOOL vrMode;

/**
 *  @brief resumeData
 */
@property(nonatomic, strong, readonly)NSData * resumeData;

/**
 *  @brief userId
 */
@property(nonatomic, strong, readonly)NSString * userId;

/**
 *  @brief 视频id
 */
@property(nonatomic, strong, readonly)NSString * videoId;

/**
 *  @brief 跑马灯数据
 */
@property(nonatomic, strong, readonly)NSString * marqueeStr;

/**
 *  @brief 自定义字段，根据自己需求适当添加，比如添加媒体图片，标题等
 */
@property(nonatomic, strong)NSDictionary * othersInfo;

/**
 *  @brief 解压状态，非点播业务不需要关注此值。0 未解压，1 解压中，2 解压完成，3 解压失败
 */
@property(nonatomic, assign)NSInteger decompressionState;

/**
 *  @brief 下载进度
 */
@property(nonatomic, strong ,readonly)DWDownloadProgress *progress;

/**
 *  @brief 下载进度更新block
 */
@property(nonatomic, copy)DWDownloadProgressBlock progressBlock;

/**
 *  @brief 下载状态更新block
 */
@property(nonatomic, copy)DWDownloadStateBlock stateBlock;

@end

///下载进度
@interface DWDownloadProgress : NSObject

/**
 *  @brief 续传大小
 */
@property(nonatomic, assign, readonly)int64_t resumeBytesWritten;

/**
 *  @brief 每次写入的数量
 */
@property(nonatomic, assign, readonly)int64_t bytesWritten;

/**
 *  @brief 已下载的数量
 */
@property(nonatomic, assign, readonly)int64_t totalBytesWritten;

/**
 *  @brief 文件的总大小
 */
@property(nonatomic, assign, readonly)int64_t totalBytesExpectedToWrite;

/**
 *  @brief 下载进度
 */
@property(nonatomic, assign, readonly)float progress;

/**
 *  @brief 下载速度
 */
@property(nonatomic, assign, readonly)float speed;

/**
 *  @brief 下载剩余时间
 */
@property(nonatomic, assign, readonly)int remainingTime;

@end
