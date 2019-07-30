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

 /**
 此类为控制类，负责发送事件给设备。
 */
@interface DWUPnPRenderer : NSObject

//设备model
@property(nonatomic,strong)DWUPnPDevice * model;

@property(nonatomic,strong)id <DWUPnPResponseDelegate> delegate;

/**
 初始化
 @param model 搜索得到的UPnPModel
 @return self
 */
-(instancetype)initWithModel:(DWUPnPDevice *)model;

/**
 获取播放进度,可通过协议回调使用
 */
-(void)getPositionInfo;

/**
 获取播放状态,可通过协议回调使用
 */
-(void)getTransportInfo;

/**
 获取音频,可通过协议回调使用
 */
-(void)getVolume;

/**
 设置投屏地址
 @param urlStr 视频url
 */
-(void)setAVTransportURL:(NSString *)urlStr;

/**
 设置下一个播放地址
 @param urlStr 下一个视频url
 */
-(void)setNextAVTransportURI:(NSString *)urlStr;

/**
 播放
 */
-(void)play;

/**
 暂停
 */
-(void)pause;

/**
 结束
 */
-(void)stop;

/**
 下一个
 */
-(void)next;

/**
 前一个
 */
-(void)previous;

/**
 跳转进度
 @param relTime 进度时间(单位秒)
 */
-(void)seek:(float)relTime;

/**
 跳转至特定进度或视频
 @param target 目标值，可以是 00:02:21 格式的进度或者整数的 TRACK_NR。
 @param unit   REL_TIME（跳转到某个进度）或 TRACK_NR（跳转到某个视频）。
 */
-(void)seekToTarget:(NSString *)target Unit:(NSString *)unit;

/**
 设置音频值
 @param value 值，整数
 */
-(void)setVolumeWith:(NSString *)value;


@end

