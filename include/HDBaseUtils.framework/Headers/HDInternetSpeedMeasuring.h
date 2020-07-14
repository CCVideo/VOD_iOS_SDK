//
//  InternetSpeedMeasuring.h
//  HDBaseUtils
//
//  Created by zwl on 2020/5/11.
//  Copyright © 2020 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class HDInternetSpeedMeasuring;

@protocol HDInternetSpeedMeasuringDelegate <NSObject>

@optional

/// 网络测速回调，当error存在时，bytes为-1。
/// @param speedMeasuring 对象
/// @param bytes 字节数
/// @param error 错误信息
-(void)HD_InternetSpeedMeasuring:(HDInternetSpeedMeasuring *)speedMeasuring Bytes:(long long)bytes Error:(NSError *)error;

@end

@interface HDInternetSpeedMeasuring : NSObject

/// 测速间隔单位秒,调用start前设置有效。默认3秒
@property(nonatomic,assign)CGFloat spaceTime;

/// 代理
@property(nonatomic,weak) id <HDInternetSpeedMeasuringDelegate> delegate;

/// 开始测速
-(void)start;

/// 停止测速
-(void)stop;

@end
