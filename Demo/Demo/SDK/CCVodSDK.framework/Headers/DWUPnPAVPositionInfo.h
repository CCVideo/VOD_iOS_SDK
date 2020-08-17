//
//  DWUPnPTransportInfo.h
//  Demo
//
//  Created by zwl on 2019/7/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWUPnPAVPositionInfo : NSObject

/**
 *  @brief 总时长
 */
@property(nonatomic, assign)float trackDuration;

/**
 *  @brief 当前时长
 */
@property(nonatomic, assign)float absTime;

/**
 *  @brief 与absTime无差别
 */
@property(nonatomic, assign)float relTime;

/*!
 * @method
 * @abstract 设置数组
 * @discussion 设置数组
 * @param array 数组
 */
- (void)setArray:(NSArray *)array;

@end


@interface DWUPnPTransportInfo : NSObject

/**
 *  @brief 当前播放状态
 */
@property(nonatomic, copy)NSString * currentTransportState;

/**
 *  @brief 当前状态
 */
@property(nonatomic, copy)NSString * currentTransportStatus;

/**
 *  @brief 当前速率
 */
@property(nonatomic, copy)NSString * currentSpeed;

/*!
 * @method
 * @abstract 设置数组
 * @discussion 设置数组
 * @param array 数组
 */
- (void)setArray:(NSArray *)array;

@end


@interface NSString(UPnP)

/*!
 * @method
 * @abstract 格式化时间
 * @discussion 返回时间字符串
 * @param timeValue 时间
 * @result 返回值
 */
+(NSString *)stringWithDurationTime:(float)timeValue;

/*!
 * @method
 * @abstract 获取时间
 * @discussion 获取时间
 * @result 返回值
 */
- (float)durationTime;

@end
