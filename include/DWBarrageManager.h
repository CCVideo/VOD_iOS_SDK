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
//收到弹幕响应回调
-(void)getBarrageManager:(DWBarrageManager *)barrageManager BarrageList:(NSArray <DWBarrageModel *> *)barrageList WithError:(NSError *)error;
//发送弹幕回调
-(void)sendBarrageManager:(DWBarrageManager *)barrageManager BarrageModel:(DWBarrageModel *)sendBarrageModel WithError:(NSError *)error;

@end

///弹幕管理类，负责发送弹幕以及接收弹幕。
@interface DWBarrageManager : NSObject

///视频id
@property(nonatomic,copy)NSString * videoId;

///代理
@property(nonatomic,weak)id <DWBarrageManagerDelegate> delegate;

/// 设置当前播放时间
/// @param time 当前播放时间
-(void)associationWithTimeDidChange:(float)time;

/// 发送弹幕
/// @param barrageModel 弹幕模型
-(void)sendBarrageWithBarrageModel:(DWBarrageModel *)barrageModel;

/// 销毁进行中的请求，只对获取弹幕请求有效，发送弹幕的请求不会被销毁。
- (void)cancelRequest;


@end
