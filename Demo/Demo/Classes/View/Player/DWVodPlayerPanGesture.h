//
//  DWVodPlayerPanGesture.h
//  BrightnessVolumeView
//
//  Created by zwl on 2020/3/11.
//  Copyright © 2020 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DWVodPlayerPanGestureStatus) {
    DWVodPlayerPanGestureStatusNone,//无
    DWVodPlayerPanGestureStatusVolume,//音量调节
    DWVodPlayerPanGestureStatusBrightness,//亮度调节
    DWVodPlayerPanGestureStatusFast,//快进
    DWVodPlayerPanGestureStatusRewind //快退
};

@protocol DWVodPlayerPanGestureDelegate <NSObject>

//左右滑动事件结束
-(void)playerPanHandleEnd:(CGFloat)sliderProgress;

@end

@interface DWVodPlayerPanGesture : UIPanGestureRecognizer

-(instancetype)initWithFatherView:(UIView *)fatherView;

@property(nonatomic,assign)CGFloat duration;

@property(nonatomic,assign)CGFloat progress;

@property(nonatomic,assign)BOOL canResponse;

@property(nonatomic,weak) id <DWVodPlayerPanGestureDelegate> vodPanDelegate;

@end

