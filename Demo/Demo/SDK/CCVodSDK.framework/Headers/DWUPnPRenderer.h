//
//  DWUPnPRenderer.h
//  Demo
//
//  Created by zwl on 2019/7/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DWUPnPResponseDelegate.h"

@class DWUPnPDevice;

/// 此类为控制类，负责发送事件给设备。
@interface DWUPnPRenderer : NSObject

/**
 *  @brief 设备model
 */
@property(nonatomic,strong)DWUPnPDevice * model;

/**
 *  @brief 代理
 */
@property(nonatomic,strong)id <DWUPnPResponseDelegate> delegate;

/*!
 * @method
 * @abstract 初始化
 * @discussion 初始化
 * @param model 搜索得到的UPnPModel
 * @result DWUPnPRenderer对象
 */
-(instancetype)initWithModel:(DWUPnPDevice *)model;

/*!
 * @method
 * @abstract 获取播放进度,可通过协议回调使用
 * @discussion 获取播放进度,可通过协议回调使用
 */
-(void)getPositionInfo;

/*!
 * @method
 * @abstract 获取播放状态,可通过协议回调使用
 * @discussion 获取播放状态,可通过协议回调使用
 */
-(void)getTransportInfo;

/*!
 * @method
 * @abstract 获取音频,可通过协议回调使用
 * @discussion 获取音频,可通过协议回调使用
 */
-(void)getVolume;

/*!
 * @method
 * @abstract 设置投屏地址
 * @discussion 设置投屏地址
 * @param urlStr 视频url
 */
-(void)setAVTransportURL:(NSString *)urlStr;

/*!
 * @method
 * @abstract 设置下一个播放地址
 * @discussion 设置下一个播放地址
 * @param urlStr 下一个视频url
 */
-(void)setNextAVTransportURI:(NSString *)urlStr;

/*!
 * @method
 * @abstract 播放
 * @discussion 播放
 */
-(void)play;

/*!
 * @method
 * @abstract 暂停
 * @discussion 暂停
 */
-(void)pause;

/*!
 * @method
 * @abstract 结束
 * @discussion 结束
 */
-(void)stop;

/*!
 * @method
 * @abstract 下一个
 * @discussion 下一个
 */
-(void)next;

/*!
 * @method
 * @abstract 前一个
 * @discussion 前一个
 */
-(void)previous;

/*!
 * @method
 * @abstract 跳转进度
 * @discussion 跳转进度
 * @param relTime 进度时间(单位秒)
 */
-(void)seek:(float)relTime;

/*!
 * @method
 * @abstract 跳转至特定进度或视频
 * @discussion 跳转至特定进度或视频
 * @param target 目标值，可以是 00:02:21 格式的进度或者整数的 TRACK_NR
 * @param unit REL_TIME（跳转到某个进度）或 TRACK_NR（跳转到某个视频）
 */
-(void)seekToTarget:(NSString *)target Unit:(NSString *)unit;

/*!
 * @method
 * @abstract 设置音频值
 * @discussion 设置音频值
 * @param value 值，整数
 */
-(void)setVolumeWith:(NSString *)value;

@end

