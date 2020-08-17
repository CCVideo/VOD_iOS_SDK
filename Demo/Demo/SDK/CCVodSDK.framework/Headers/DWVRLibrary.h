//
//  DWVRLibrary.h
//  DW360Player4IOS
//
//  Created by ashqal on 16/4/7.
//  Copyright © 2016年 ashqal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "DW360Director.h"
#import "DWVideoDataAdapter.h"
#import "DWExt.h"
#import "DWVRHeader.h"

typedef NS_ENUM(NSInteger, DWModeInteractive) {
    DWModeInteractiveTouch,//触摸
    DWModeInteractiveMotion,//重力感应
    DWModeInteractiveMotionWithTouch,//触摸及重力感应
};

typedef NS_ENUM(NSInteger, DWModeDisplay) {
    DWModeDisplayNormal,//单屏
    DWModeDisplayGlass,//双屏
};

typedef NS_ENUM(NSInteger, DWModeProjection) {
    DWModeProjectionSphere,//球体
    DWModeProjectionDome180,
    DWModeProjectionDome230,
    DWModeProjectionDome180Upper,
    DWModeProjectionDome230Upper,
    DWModeProjectionStereoSphere,
    DWModeProjectionPlaneFit,
    DWModeProjectionPlaneCrop,
    DWModeProjectionPlaneFull,
};

@class DWVRLibrary;
#pragma mark DWVRConfiguration
@interface DWVRConfiguration : NSObject

/*!
 * @method
 * @abstract 设置AVPlayerItem
 * @discussion 设置AVPlayerItem
 * @param playerItem 当前playerItem
 */
-(void)asVideo:(AVPlayerItem*)playerItem;

/*!
 * @method
 * @abstract 设置DWVideoDataAdapter代理
 * @discussion 设置DWVideoDataAdapter代理
 * @param adapter 设置对象
 */
-(void)asVideoWithDataAdatper:(id<DWVideoDataAdapter>)adapter;

/*!
 * @method
 * @abstract 设置IMDYUV420PProvider代理
 * @discussion 设置IMDYUV420PProvider代理
 * @param provider 设置对象
 */
-(void)asVideoWithYUV420PProvider:(id<IMDYUV420PProvider>)provider;

/*!
 * @method
 * @abstract 设置IMDImageProvider代理
 * @discussion 设置IMDImageProvider代理
 * @param data 设置对象
 */
-(void)asImage:(id<IMDImageProvider>)data;

/*!
 * @method
 * @abstract 设置互动模式
 * @discussion 默认DWModeInteractiveTouch
 * @param interactiveMode 互动模式
 */
-(void)interactiveMode:(DWModeInteractive)interactiveMode;

/*!
 * @method
 * @abstract 设置显示模式
 * @discussion 默认DWModeDisplayNormal
 * @param displayMode 显示模式
 */
-(void)displayMode:(DWModeDisplay)displayMode;

/*!
 * @method
 * @abstract 设置投影模式
 * @discussion 设置投影模式
 * @param projectionMode 投影模式
 */
-(void)projectionMode:(DWModeProjection)projectionMode;

/*!
 * @method
 * @abstract 是否允许捏合
 * @discussion 默认NO
 * @param pinch 开启/关闭
 */
-(void)pinchEnabled:(bool)pinch;

/*!
 * @method
 * @abstract 设置控制器
 * @discussion 设置控制器
 * @param vc 控制器
 */
-(void)setContainer:(UIViewController*)vc;

/*!
 * @method
 * @abstract 设置控制器
 * @discussion 设置控制器
 * @param vc 控制器
 * @param view 视图
 */
-(void)setContainer:(UIViewController*)vc view:(UIView*)view;

/*!
 * @method
 * @abstract 设置DW360DirectorFactory代理
 * @discussion 设置DW360DirectorFactory代理
 * @param directorFactory 设置对象
 */
-(void)setDirectorFactory:(id<DW360DirectorFactory>)directorFactory;

/*!
 * @method
 * @abstract 初始化对象
 * @discussion 初始化对象
 * @result DWVRLibrary对象
 */
-(DWVRLibrary*)build;

@end

#pragma mark DWVRLibrary
@interface DWVRLibrary : NSObject

/*!
 * @method
 * @abstract 初始化对象
 * @discussion 初始化对象
 * @result DWVRConfiguration对象
 */
+(DWVRConfiguration*)createConfig;

/*!
 * @method
 * @abstract 切换互动模式
 * @discussion 切换互动模式
 */
-(void)switchInteractiveMode;

/*!
 * @method
 * @abstract 切换指定互动模式
 * @discussion 切换指定互动模式
 * @param interactiveMode 互动模式
 */
-(void)switchInteractiveMode:(DWModeInteractive)interactiveMode;

/*!
 * @method
 * @abstract 获取当前互动模式
 * @discussion 获取当前互动模式
 * @result 当前互动模式
 */
-(DWModeInteractive)getInteractiveMdoe;

/*!
 * @method
 * @abstract 切换指定显示模式
 * @discussion 切换指定显示模式
 * @param displayMode 显示模式
*/
-(void)switchDisplayMode:(DWModeDisplay)displayMode;

/*!
 * @method
 * @abstract 切换显示模式
 * @discussion 切换显示模式
 */
-(void)switchDisplayMode;

/*!
 * @method
 * @abstract 获取当前显示模式
 * @discussion 获取当前显示模式
 * @result 当前显示模式
 */
-(DWModeDisplay)getDisplayMdoe;

/*!
 * @method
 * @abstract 切换投影模式
 * @discussion 切换投影模式
 */
-(void)switchProjectionMode;

/*!
 * @method
 * @abstract 切换指定投影模式
 * @discussion 切换指定投影模式
 * @param projectionMode 投影模式
 */
-(void)switchProjectionMode:(DWModeProjection)projectionMode;

/*!
 * @method
 * @abstract 获取当前投影模式
 * @discussion 获取当前投影模式
 * @result 当前投影模式
 */
-(DWModeProjection)getProjectionMode;

@end
