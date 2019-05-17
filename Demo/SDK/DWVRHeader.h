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
-(void) texture:(UIImage*)image;
@end

@protocol YUV420PTextureCallback <NSObject>
@required
-(void) texture:(DWVideoFrame*)frame;
@end


@protocol IMDDestroyable <NSObject>
-(void) destroy;
@end

@protocol IMDImageProvider <NSObject>
@required
-(void) onProvideImage:(id<TextureCallback>)callback;
@end

@protocol IMDYUV420PProvider <NSObject>
@required
-(void) onProvideBuffer:(id<YUV420PTextureCallback>)callback;
@end

#pragma mark DWVideoFrameAdapter
@interface DWVideoFrameAdapter : NSObject<IMDYUV420PProvider,DWVideoFrameCallback>

@end

@interface DWIJKAdapter : DWVideoFrameAdapter

+ (DWVideoFrameAdapter*) wrap:(id)ijk_sdl_view;

@end

@interface DWSizeContext : NSObject
- (void)updateTextureWidth:(float)width height:(float) height;
- (void)updateViewportWidth:(float)width height:(float) height;
- (float)getTextureRatioValue;
- (float)getViewportRatioValue;
@end

#endif /* DWVRHeader_h */
