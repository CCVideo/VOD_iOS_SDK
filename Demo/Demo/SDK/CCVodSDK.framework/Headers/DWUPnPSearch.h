//
//  DWUPnPSearch.h
//  Demo
//
//  Created by zwl on 2019/7/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DWUPnPDevice;
@protocol DWUPnPSearchDelegate <NSObject>

/** 搜索结果
 @param devices 设备数组
 */
-(void)upnpSearchChangeWithResults:(NSArray <DWUPnPDevice *>*)devices;

@optional
/** 搜索失败
 @param error 错误信息
 */
-(void)upnpSearchErrorWithError:(NSError *)error;

@end

@interface DWUPnPSearch : NSObject

/**
 *  @brief 代理
 */
@property (nonatomic, weak) id<DWUPnPSearchDelegate>delegate;

/*!
 * @method
 * @abstract 开始搜索设备
 * @discussion 开始搜索设备
 */
-(void)start;

/*!
 * @method
 * @abstract 重新搜索设备
 * @discussion 重新搜索设备
 */
-(void)refresh;

/*!
 * @method
 * @abstract 销毁对象
 * @discussion 销毁对象
 */
-(void)destroy;

@end

NS_ASSUME_NONNULL_END
