//
//  DWBarrageManager.h
//  Demo
//
//  Created by zwl on 2020/6/4.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWBarrageModel.h"
@class DWBarrageManager;

@protocol DWBarrageManagerDelegate <NSObject>

@optional
/** 收到弹幕响应回调
 @param barrageManager 自身对象
 @param barrageList 字幕列表
 @param error 错误信息
 */
-(void)getBarrageManager:(DWBarrageManager *)barrageManager BarrageList:(NSArray <DWBarrageModel *> *)barrageList WithError:(NSError *)error;

/** 发送弹幕回调
 @param barrageManager 自身对象
 @param sendBarrageModel 字幕模型
 @param error 错误信息
 */
-(void)sendBarrageManager:(DWBarrageManager *)barrageManager BarrageModel:(DWBarrageModel *)sendBarrageModel WithError:(NSError *)error;

@end

///弹幕管理类，负责发送弹幕以及接收弹幕。
@interface DWBarrageManager : NSObject

/**
 *  @brief 视频id
 */
@property(nonatomic,copy)NSString * videoId;

/**
 *  @brief 代理
 */
@property(nonatomic,weak)id <DWBarrageManagerDelegate> delegate;

/*!
 * @method
 * @abstract 设置当前播放时间
 * @discussion 设置当前播放时间
 * @param time 当前播放时间
 */
-(void)associationWithTimeDidChange:(float)time;

/*!
 * @method
 * @abstract 发送弹幕
 * @discussion 发送弹幕
 * @param barrageModel 弹幕模型
 */
-(void)sendBarrageWithBarrageModel:(DWBarrageModel *)barrageModel;

/*!
 * @method
 * @abstract 销毁进行中的请求
 * @discussion 只对获取弹幕请求有效，发送弹幕的请求不会被销毁。
 */
-(void)cancelRequest;

@end
