//
//  DWVRHeader.h
//  DWVRLibrary
//
//  Created by ashqal on 16/6/20.
//  Copyright © 2016年 asha. All rights reserved.
//

#ifndef DWVRHeader_h
#define DWVRHeader_h


#define DWVR_RAW_NAME @ "vrlibraw.bundle"
#define DWVR_RAW_PATH [[[NSBundle bundleForClass: [self class]] resourcePath] stringByAppendingPathComponent: DWVR_RAW_NAME]
#define DWVR_RAW [NSBundle bundleWithPath: DWVR_RAW_PATH]
#define MULTI_SCREEN_SIZE 2

#import <UIKit/UIKit.h>
#import "DWExt.h"

@protocol TextureCallback <NSObject>
@required
/** 纹理回调
 @param image 图片
 */
-(void)texture:(UIImage*)image;
@end

@protocol YUV420PTextureCallback <NSObject>
@required
/** 纹理回调
 @param frame 视频帧
 */
-(void)texture:(DWVideoFrame*)frame;
@end


@protocol IMDDestroyable <NSObject>
/** 销毁
 */
-(void)destroy;
@end

@protocol IMDImageProvider <NSObject>
@required
/** 设置图片回调
 @param callback TextureCallback回调
 */
-(void)onProvideImage:(id<TextureCallback>)callback;
@end

@protocol IMDYUV420PProvider <NSObject>
@required
/** 设置数据回调
 @param callback YUV420PTextureCallback回调
 */
-(void) onProvideBuffer:(id<YUV420PTextureCallback>)callback;
@end

#pragma mark DWVideoFrameAdapter
@interface DWVideoFrameAdapter : NSObject<IMDYUV420PProvider,DWVideoFrameCallback>

@end

@interface DWIJKAdapter : DWVideoFrameAdapter

/*!
 * @method
 * @abstract 设置ijkView
 * @discussion 设置ijkView
 * @param ijk_sdl_view view对象
 * @result DWVideoFrameAdapter对象
 */
+(DWVideoFrameAdapter*)wrap:(id)ijk_sdl_view;

@end

@interface DWSizeContext : NSObject

/*!
 * @method
 * @abstract 更新纹理宽高
 * @discussion 更新纹理宽高
 * @param width 宽
 * @param height 高
 */
-(void)updateTextureWidth:(float)width height:(float) height;

/*!
 * @method
 * @abstract 更新viewport
 * @discussion 更新viewport
 * @param width 宽
 * @param height 高
 */
-(void)updateViewportWidth:(float)width height:(float) height;

/*!
 * @method
 * @abstract 获取Texture比例
 * @discussion 获取Texture比例
 * @result Texture比例
 */
-(float)getTextureRatioValue;

/*!
 * @method
 * @abstract 获取viewport比例
 * @discussion 获取viewport比例
 * @result viewport比例
 */
-(float)getViewportRatioValue;

@end

#endif /* DWVRHeader_h */
