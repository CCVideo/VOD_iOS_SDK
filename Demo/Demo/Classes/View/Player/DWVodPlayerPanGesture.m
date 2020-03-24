//
//  DWVodPlayerPanGesture.m
//  BrightnessVolumeView
//
//  Created by zwl on 2020/3/11.
//  Copyright © 2020 admin. All rights reserved.
//

#import "DWVodPlayerPanGesture.h"
#import "DWPlayerTimeSilder.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BrightnessView.h"

@interface DWVodPlayerPanGesture ()

@property(nonatomic,assign)DWVodPlayerPanGestureStatus status;

@property(nonatomic,weak)UIView * fatherView;

//手势落点
@property(nonatomic,assign)CGPoint location;
@property(nonatomic,strong)DWPlayerTimeSilder * timeSilder;

@property(nonatomic,assign)CGFloat lastProgress;

@property(nonatomic,strong)UISlider * volumeSlider;
@property(nonatomic,assign)CGFloat lastVolume;
@property(nonatomic,assign)CGFloat lastBrightness;

@end

@implementation DWVodPlayerPanGesture

-(instancetype)initWithFatherView:(UIView *)fatherView
{
    self = [super init];
    if (self) {
        
        self.fatherView = fatherView;
        self.canResponse = YES;
        
        [self addTarget:self action:@selector(handlePan)];
        [self.fatherView addGestureRecognizer:self];
        
        self.status = DWVodPlayerPanGestureStatusNone;
                
        [BrightnessView sharedBrightnessView];
    }
    return self;
}

-(void)setDuration:(CGFloat)duration
{
    _duration = duration;
    
    self.timeSilder.duration = duration;
}

-(void)handlePan
{
    //外部是否禁用手势
    if (!self.canResponse) {
        return;
    }
    
    //只在横屏状态下，相应手势
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    if (!(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        return;
    }
    
    //这个用于判断落点是在左边还是右边，判断音量 or 亮度
    CGPoint position = [self translationInView:self.view];
    CGFloat absX = fabs(position.x);
    CGFloat absY = fabs(position.y);
    
    switch (self.state) {
        case UIGestureRecognizerStateBegan:
            {
                self.location = [self locationInView:self.view];
                self.lastProgress = self.progress;
                
                if (absX > absY) {
                    //左右滑动
                    if (position.x < 0) {
                        //向左滑动
                        self.status = DWVodPlayerPanGestureStatusRewind;
                    }else{
                        //向右滑动
                        self.status = DWVodPlayerPanGestureStatusFast;
                    }
                    
                    if (self.duration == 0) {
                        return;
                    }
                    
                    self.timeSilder.hidden = NO;
                    self.timeSilder.progress = self.lastProgress;

                } else{
                    //上下滑动
                    if (self.location.x <= CGRectGetWidth(self.view.frame) * 0.5) {
                        //亮度
                        self.status = DWVodPlayerPanGestureStatusBrightness;
                        self.lastBrightness = [UIScreen mainScreen].brightness;
                    }else{
                        //音量
                        self.status = DWVodPlayerPanGestureStatusVolume;
                        self.lastVolume = [self getCurrentVolume];
                    }
                    
                }
                    
//                NSLog(@"status %ld",self.status);
            }
            break;
        case UIGestureRecognizerStateChanged:
            {
                [self gestureChange:position];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            {
                [self gestureEnd];
            }
            break;
        default:
            break;
    }
}

//修改亮度/音量
-(void)gestureChange:(CGPoint)position
{
    switch (self.status) {
        case DWVodPlayerPanGestureStatusVolume:
            {
                float volumeDelta = position.y / (self.fatherView.bounds.size.height) * 0.5;
                float newVolume = self.lastVolume - volumeDelta;
                if (newVolume > 1) {
                    newVolume = 1;
                }else if (newVolume < 0){
                    newVolume = 0;
                }
                [self.volumeSlider setValue:newVolume animated:NO];
            }
            break;
        case DWVodPlayerPanGestureStatusBrightness:
            {
                float volumeDelta = position.y / (self.fatherView.bounds.size.height) * 0.5;
                float newVolume = self.lastBrightness - volumeDelta;
                [[UIScreen mainScreen] setBrightness:newVolume];

            }
            break;
        case DWVodPlayerPanGestureStatusRewind:
        case DWVodPlayerPanGestureStatusFast:
            {
//                CGPoint location = [self locationInView:self.view];

                CGFloat w = self.fatherView.frame.size.width - self.location.x;
//                CGFloat offset = position.x - location.x;
                
                CGFloat progress = position.x / w + self.lastProgress;
                
                self.timeSilder.progress = progress;
                
                if (self.timeSilder.progress > 1) {
                    self.timeSilder.progress = 1;
                }
            
            }
            break;
        default:
            break;
    }
}

//快进快退
-(void)gestureEnd
{
    if (self.status == DWVodPlayerPanGestureStatusFast || self.status == DWVodPlayerPanGestureStatusRewind) {
        if ([self.vodPanDelegate respondsToSelector:@selector(playerPanHandleEnd:)]) {
            [self.vodPanDelegate playerPanHandleEnd:self.timeSilder.progress];
        }
    }
    self.timeSilder.hidden = YES;
}

//获取当前音量
-(CGFloat)getCurrentVolume
{
    if (_volumeSlider) {
        return _volumeSlider.value;
    }
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeSlider = (UISlider*)view;
            break;
        }
    }
    
    // 解决初始状态下获取不到系统音量
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat systemVolume = audioSession.outputVolume;
    
    return systemVolume;
}

-(DWPlayerTimeSilder *)timeSilder
{
    if (!_timeSilder) {
        _timeSilder = [[DWPlayerTimeSilder alloc]init];
        _timeSilder.hidden = YES;
        [self.fatherView addSubview:_timeSilder];
        [_timeSilder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(self.fatherView.frame.size.height / 3.0));
            make.width.equalTo(@150);
            make.centerX.equalTo(self.fatherView);
            make.height.equalTo(@(12 + 8 + 4));
        }];
    }
    return _timeSilder;
}

@end
