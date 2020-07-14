//
//  DWBigDataReportManager.h
//  SDK
//
//  Created by zwl on 2020/6/17.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWBigDataReportManager : NSObject

/// 发送播放统计
/// @param userid CC用户id
/// @param roleId 角色id，用户自行传入
/// @param code 播放事件 200成功，400播放接口失败，401CDN资源失败
/// @param vid 视频id
/// @param cdn cdn域名
/// @param retry 接口重试次数
/// @param data 接口返回数据，json串
/// @param et 接口耗时
+(void)reportPlayActionWithUserid:(NSString *)userid
                           RoleId:(NSString *)roleId
                             Code:(NSString *)code
                              Vid:(NSString *)vid
                              Cdn:(NSString *)cdn
                            Retry:(NSInteger)retry
                      RequestData:(NSString *)data
                               Et:(NSInteger)et;


/// 发送心跳统计
/// @param userid CC用户id
/// @param roleId 角色id，用户自行传入
/// @param vid 视频id
/// @param heartinter 心跳间隔 单位：秒
/// @param blockduration 本次心跳周期内的卡顿时长:毫秒
/// @param blocktimes 本次心跳周期内的卡顿次数
/// @param num 心跳累计次数
/// @param playerstatus 播放状态，0未播放 1播放中
+(void)reportHeartActionWithUserid:(NSString *)userid
                            RoleId:(NSString *)roleId
                               Vid:(NSString *)vid
                        Heartinter:(NSInteger)heartinter
                     Blockduration:(NSInteger)blockduration
                        Blocktimes:(NSInteger)blocktimes
                               Num:(NSInteger)num
                      Playerstatus:(BOOL)playerstatus;

@end
