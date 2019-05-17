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
- (void) asVideo:(AVPlayerItem*)playerItem;
- (void) asVideoWithDataAdatper:(id<DWVideoDataAdapter>)adapter;
- (void) asVideoWithYUV420PProvider:(id<IMDYUV420PProvider>)provider;

- (void) asImage:(id<IMDImageProvider>)data;

- (void) interactiveMode:(DWModeInteractive)interactiveMode;
- (void) displayMode:(DWModeDisplay)displayMode;
- (void) projectionMode:(DWModeProjection)projectionMode;
- (void) pinchEnabled:(bool)pinch;
- (void) setContainer:(UIViewController*)vc;
- (void) setContainer:(UIViewController*)vc view:(UIView*)view;
- (void) setDirectorFactory:(id<DW360DirectorFactory>) directorFactory;
- (DWVRLibrary*) build;
@end

#pragma mark DWVRLibrary
@interface DWVRLibrary : NSObject
+ (DWVRConfiguration*) createConfig;

- (void) switchInteractiveMode;
- (void) switchInteractiveMode:(DWModeInteractive)interactiveMode;
- (DWModeInteractive) getInteractiveMdoe;

- (void) switchDisplayMode:(DWModeDisplay)displayMode;
- (void) switchDisplayMode;
- (DWModeDisplay) getDisplayMdoe;

- (void) switchProjectionMode;
- (void) switchProjectionMode:(DWModeProjection)projectionMode;
- (DWModeProjection) getProjectionMode;
@end
