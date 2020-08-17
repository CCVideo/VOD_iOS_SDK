//
//  DWDownloadSessionManager.h
//  Demo
//
//  Created by zwl on 2019/2/25.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDownloadModel.h"

#import <HDBaseUtils/HDURLSessionManager.h>

@class DWVodVideoModel;

// 下载代理
@protocol DWDownloadSessionDelegate <NSObject>

@optional
/** 更新下载进度回调
 @param downloadModel 自身对象
 @param progress 下载进度
 */
-(void)downloadModel:(DWDownloadModel *)downloadModel didUpdateProgress:(DWDownloadProgress *)progress;

/** 更新下载状态/出现error时回调
 @param downloadModel 自身对象
 @param error 错误信息
 */
-(void)downloadModel:(DWDownloadModel *)downloadModel error:(NSError *)error;

/** 后台下载完成时回调
 */
-(void)downloadBackgroundSessionCompletion;

@end

@interface DWDownloadSessionManager : NSObject

/**
 *  @brief 下载任务队列
 */
@property(nonatomic,strong,readonly)NSArray <DWDownloadModel *> * downloadModelList;

/**
 *  @brief 代理
 */
@property(nonatomic,weak)id<DWDownloadSessionDelegate> delegate;

/**
  注意：修改下载设置后，对已经存在的下载任务可能无效，请清空下载任务之后修改设置
 */

/**
 *  @brief 是否允许使用移动流量 YES支持 NO不支持 默认支持
 */
@property(nonatomic,assign)BOOL allowsCellular;

/**
 *  @brief 全部并发，默认YES, 当YES时，忽略maxDownloadCount
 */
@property(nonatomic,assign)BOOL isBatchDownload;

/**
 *  @brief 允许同时下载的最大并发数,默认为1，最大为4
 */
@property(nonatomic,assign)NSInteger maxDownloadCount;

/**
 *  @brief 等待下载队列 先进先出 默认YES，当NO时，先进后出
 */
@property(nonatomic,assign)BOOL resumeDownloadFIFO;

/*!
 * @method
 * @abstract 初始化DWDownloadSessionManager
 * @discussion 初始化DWDownloadSessionManager
 * @result DWDownloadSessionManager对象
 */
+(DWDownloadSessionManager *)manager;

/*!
 * @method
 * @abstract 初始化DWDownloadModel
 * @discussion 初始化DWDownloadModel
 * @param videoMdoel 点播视频model，非空
 * @param quality 媒体品质，非空
 * @param othersInfo 自定义字段，可为空
 * @result 创建成功返回DWDownloadModel对象，如果失败，返回nil
 */
+(DWDownloadModel *)createDownloadModel:(DWVodVideoModel *)videoMdoel Quality:(NSString *)quality AndOthersInfo:(NSDictionary *)othersInfo;

/*!
 * @method
 * @abstract 开始下载任务
 * @discussion 开始下载任务
 * @param downloadModel DWDownloadModel对象
 */
-(void)startWithDownloadModel:(DWDownloadModel *)downloadModel;

/*!
 * @method
 * @abstract 开始下载任务
 * @discussion 所有回调均已回到主线程中
 * @param downloadModel DWDownloadModel对象
 * @param progress 下载进度回调
 * @param state 下载状态变动回调
 */
-(void)startWithDownloadModel:(DWDownloadModel *)downloadModel progress:(DWDownloadProgressBlock)progress state:(DWDownloadStateBlock)state;

/*!
 * @method
 * @abstract 暂停下载任务
 * @discussion 暂停下载任务
 * @param downloadModel DWDownloadModel对象
*/
-(void)suspendWithDownloadModel:(DWDownloadModel *)downloadModel;

/*!
 * @method
 * @abstract 恢复下载任务
 * @discussion 恢复下载任务
 * @param downloadModel DWDownloadModel对象
 */
-(void)resumeWithDownloadModel:(DWDownloadModel *)downloadModel;

/*!
 * @method
 * @abstract 删除下载任务以及本地缓存
 * @discussion 删除下载任务以及本地缓存
 * @param downloadModel DWDownloadModel对象
 */
-(void)deleteWithDownloadModel:(DWDownloadModel *)downloadModel;

/*!
 * @method
 * @abstract 暂停全部任务
 * @discussion 暂停全部任务
 */
-(void)suspendAllDownloadModel;

/*!
 * @method
 * @abstract 删除全部任务
 * @discussion 删除全部任务
 */
-(void)deleteAllDownloadModel;

/*!
 * @method
 * @abstract 获取下载模型
 * @discussion 获取下载模型
 * @param URLString 下载地址
 * @result DWDownloadModel对象
 */
-(DWDownloadModel *)downLoadingModelForURLString:(NSString *)URLString;

/*!
 * @method
 * @abstract 判断当前资源是已在下载队列中
 * @discussion 判断当前资源是已在下载队列中
 * @param videoId 视频id，非空
 * @param quality 媒体品质，非空
 * @result 查询结果
 */
-(BOOL)checkLocalResourceWithVideoId:(NSString *)videoId WithQuality:(NSString *)quality;

/*!
 * @method
 * @abstract 判断downloadModel下载链接是否有效
 * @discussion 下载链接具有时效性，若超时，请调用reStartDownloadUrlWithNewUrlString:AndDownloadModel:方法
 * @param downloadModel DWDownloadModel对象
 * @result 查询结果
 */
-(BOOL)isValidateURLWithDownloadModel:(DWDownloadModel *)downloadModel;

/*!
 * @method
 * @abstract 根据新的下载地址，继续下载此任务
 * @discussion 下载链接超时时，调用此方法继续下载当前任务
 * @param newUrlString 新的下载地址
 * @param downloadModel DWDownloadModel对象
 */
-(void)reStartDownloadUrlWithNewUrlString:(NSString *)newUrlString AndDownloadModel:(DWDownloadModel *)downloadModel;

/*!
 * @method
 * @abstract 事件透传
 * @discussion 获取appdelegate，handleEventsForBackgroundURLSession事件回调
 * @param identifier identifier
 * @param completionHandler completionHandler
 */
-(void)setBackgroundSession:(NSString *)identifier CompletionHandler:(void (^)())completionHandler;

/*!
 * @method
 * @abstract 3.x.x升级4.x.x以上版本所使用的过渡方法
 * @discussion 若从3.x.x版本升级到4.x.x，会出现旧版本下载的音视频文件找不到的情况。
可以通过执行此方法，生成新版SDk的下载任务
 * @param loaclPath 对于已完成的任务，必填。对于未完成的任务，请务必传nil
 * @param downloadUrl 网络下载地址。对于未完成的任务，必填
 * @param mediaType 文件类型，1 视频 2 音频。若不填写，默认视频
 * @param quality 清晰度，若不填写，默认 10
 * @param desp 清晰度描述，若不填写，默认 标清
 * @param vrMode 是否是VR视频。默认 NO
 * @param othersInfo 自定义字段，根据自己需求适当添加，比如添加媒体图片，标题等
 * @param userId 用户ID，选填
 * @param videoId 视频ID，选填
 * @param totalBytesWritten 已下载的数量。对于未完成的任务，必填
 * @param totalBytesExpectedToWrite 文件的总大小。对于未完成的任务，必填
 * @result 若过渡成功，返回DWDownloadModel对象，否则返回nil
 */
-(DWDownloadModel *)migrateDownloadTask:(NSString *)loaclPath
                            DownloadUrl:(NSString *)downloadUrl
                              MediaType:(NSString *)mediaType
                                Quality:(NSString *)quality
                                   Desp:(NSString *)desp
                                 VRMode:(BOOL)vrMode
                             OthersInfo:(NSDictionary *)othersInfo
                                 UserId:(NSString *)userId
                                VideoId:(NSString *)videoId
                      TotalBytesWritten:(int64_t)totalBytesWritten
              TotalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

@end
