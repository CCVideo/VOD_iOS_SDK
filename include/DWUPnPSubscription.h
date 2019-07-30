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
///视频传输中
-(void)upnpSubscriptionTransition;

///设备播放投屏
-(void)upnpSubscriptionPlay;

///设备暂停投屏
-(void)upnpSubscriptionPause;

///设备退出投屏
-(void)upnpSubscriptionStop;

///error回调
-(void)upnpSubscriptionWithError:(NSError *)error;

@end


/**
 此类为订阅类，负责监听投屏设备的回调。
 */
@interface DWUPnPSubscription : NSObject

//设备model
@property(nonatomic,strong)DWUPnPDevice *model;

@property(nonatomic,weak)id <DWUPnPSubscriptionDelegate> delegate;

/**
 初始化
 @param model 搜索得到的UPnPModel
 @return self
 */
- (instancetype)initWithModel:(DWUPnPDevice *)model;

/**
 开始订阅
 */
-(void)startSubscribe;

/**
 结束订阅
 */
-(void)cancelSubscribe;


@end

NS_ASSUME_NONNULL_END
