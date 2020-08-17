//
//  DWUPnPSubscription.h
//  Demo
//
//  Created by zwl on 2019/7/12.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DWUPnPDevice;

NS_ASSUME_NONNULL_BEGIN

@protocol DWUPnPSubscriptionDelegate <NSObject>

@optional
/** 视频传输中
 */
-(void)upnpSubscriptionTransition;

/** 设备播放投屏
 */
-(void)upnpSubscriptionPlay;

/** 设备暂停投屏
 */
-(void)upnpSubscriptionPause;

/** 设备退出投屏
 */
-(void)upnpSubscriptionStop;

/** error回调
 @param error 错误信息
 */
-(void)upnpSubscriptionWithError:(NSError *)error;

@end


// 此类为订阅类，负责监听投屏设备的回调。
@interface DWUPnPSubscription : NSObject

/**
 *  @brief 设备model
 */
@property(nonatomic,strong)DWUPnPDevice *model;

/**
 *  @brief 代理
 */
@property(nonatomic,weak)id <DWUPnPSubscriptionDelegate> delegate;

/**
 * @method
 * @abstract 初始化
 * @discussion 初始化
 * @param model 搜索得到的UPnPModel
 * @return DWUPnPSubscription对象
 */
-(instancetype)initWithModel:(DWUPnPDevice *)model;

/**
 * @method
 * @abstract 开始订阅
 * @discussion 开始订阅
 */
-(void)startSubscribe;

/**
 * @method
 * @abstract 结束订阅
 * @discussion 结束订阅
 */
-(void)cancelSubscribe;


@end

NS_ASSUME_NONNULL_END
