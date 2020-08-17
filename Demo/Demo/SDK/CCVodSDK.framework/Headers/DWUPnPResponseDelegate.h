//
//  DWUPnPResponseDelegate.h
//  Demo
//
//  Created by zwl on 2019/7/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWUPnPAVPositionInfo.h"

///响应解析回调协议
@protocol DWUPnPResponseDelegate <NSObject>

@required

/** 设置url响应
 */
-(void)upnpSetAVTransportURIResponse;

/** 获取播放状态
 @param info 返回数据
 */
-(void)upnpGetTransportInfoResponse:(DWUPnPTransportInfo *)info;

@optional

/** 未定义的响应/错误
 @param resXML  响应XML
 @param postXML 请求的动作
 */
-(void)upnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML;

/** 播放响应
 */
-(void)upnpPlayResponse;

/** 暂停响应
 */
-(void)upnpPauseResponse;

/** 停止投屏
 */
-(void)upnpStopResponse;

/** 跳转响应
 */
-(void)upnpSeekResponse;

/** previous响应
 */
-(void)upnpPreviousResponse;

/** next响应
 */
-(void)upnpNextResponse;

/** 设置音量响应
 */
-(void)upnpSetVolumeResponse;

/** 设置下一个url响应
 */
-(void)upnpSetNextAVTransportURIResponse;

/** 获取音量信息
 @param info 音量信息
 */
-(void)upnpGetVolumeResponse:(NSString *)volume;

/** 获取播放进度
 @param info 返回数据
 */
-(void)upnpGetPositionInfoResponse:(DWUPnPAVPositionInfo *)info;

@end
