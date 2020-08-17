//
//  DWScreeningBgView.m
//  Demo
//
//  Created by zwl on 2019/7/10.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWScreeningBgView.h"
#import "DWPlayerFuncBgView.h"

@interface DWScreeningBgView () <DWUPnPResponseDelegate,DWUPnPSubscriptionDelegate>

@property(nonatomic,assign)UIEdgeInsets areaInsets;

@property(nonatomic,assign)BOOL isFull;//是否全屏
@property(nonatomic,assign)BOOL isPlaying;//是否正在播放
@property(nonatomic,copy)NSString * volume;//当前音量
@property(nonatomic,assign)CGFloat duration;//视频时长
@property(nonatomic,strong)NSTimer * scheduleTimer;

@property(nonatomic,strong)DWUPnPRenderer * renderer;//投屏的控制器
@property(nonatomic,strong)DWUPnPSubscription * subscription;//投屏订阅器

//UI
@property(nonatomic,strong)UIImageView * topBgImageView;

//top
@property(nonatomic,strong)DWPlayerFuncBgView * topFuncBgView;
@property(nonatomic,strong)UIButton * backButton;//返回按钮
@property(nonatomic,strong)UILabel * titleLabel;//视频标题

//bottom
@property(nonatomic,strong)DWPlayerFuncBgView * bottomFuncBgView;
@property(nonatomic,strong)UIButton * playOrPauseButton;//开始/暂停
@property(nonatomic,strong)UILabel * currentLabel;//当前时间
@property(nonatomic,strong)UILabel * lineLabel;// /!!
@property(nonatomic,strong)UILabel * totalLabel;//总时间
@property(nonatomic,strong)UISlider * slider;//进度条,
@property(nonatomic,strong)UIButton * rotateScreenButton;//横竖屏切换

@property(nonatomic,strong)UIButton * addSound;//增加音量
@property(nonatomic,strong)UIButton * subSound;//减少音量

@property(nonatomic,strong)UILabel * statusLabel;//投屏状态
@property(nonatomic,strong)UIView * screeningFailedBgView; //投屏失败


@end

@implementation DWScreeningBgView

static CGFloat topFuncBgHeight = 39;
static CGFloat bottomFuncBgHeight = 39;

-(instancetype)initWithDevice:(DWUPnPDevice *)device AndPlayUrl:(NSString *)playUrl
{
    if (self == [super init]) {

        self.duration = 0;
        self.seekTime = 0;
        self.backgroundColor = [UIColor blackColor];
        self.isPlaying = NO;
        
        self.renderer = [[DWUPnPRenderer alloc]initWithModel:device];
        self.renderer.delegate = self;
        [self.renderer setAVTransportURL:playUrl];
        
        self.subscription = [[DWUPnPSubscription alloc]initWithModel:device];
        self.subscription.delegate = self;
        [self.subscription startSubscribe];
        
        [self initUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
        
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    NSLog(@"DWScreeningBgView dealloc");
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = title;
}

#pragma mark - private
//播放
-(void)play
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isPlaying) {
            return;
        }
        self.isPlaying = YES;
        
        [self showAlert:@"正在投屏播放中" WithFailed:NO];
        
        self.playOrPauseButton.selected = YES;
        
        [self.renderer play];
        
        [self startScheduleTimer];

    });
}

//暂停
-(void)pause
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isPlaying) {
            return;
        }
        self.isPlaying = NO;
        
        [self showAlert:@"已暂停" WithFailed:NO];
        
        self.playOrPauseButton.selected = NO;
        
        [self.renderer pause];
        
        [self stopScheduleTimer];
    });
}

//开启定时器
-(void)startScheduleTimer
{
    [self stopScheduleTimer];
    
    self.scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scheduleTimerAction) userInfo:nil repeats:YES];
}

//结束定时器
-(void)stopScheduleTimer
{
    if (self.scheduleTimer) {
        [self.scheduleTimer invalidate];
        self.scheduleTimer = nil;
    }
}

//屏幕旋转
-(void)screenRotate:(BOOL)isFull
{
    self.isFull = isFull;
    
    self.rotateScreenButton.hidden = self.isFull;

    if (self.isFull) {
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-18));
        }];
        
        [_screeningFailedBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.centerX.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@161);
        }];
    }else{
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-45));
        }];
        
        [_screeningFailedBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topBgImageView.mas_bottom);
            make.centerX.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@161);
        }];
    }
}

-(void)showAlert:(NSString *)alert WithFailed:(BOOL)isFailed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.hidden = isFailed;
        self.screeningFailedBgView.hidden = !isFailed;
        
        if (isFailed) {
            
        }else{
            self.statusLabel.text = alert;
        }
    });
}

-(void)enterForegroundNotification
{
    //回到前台时，查询一下当前状态
    [self.renderer getTransportInfo];
}

#pragma mark - DWUPnPSubscriptionDelegate
//订阅相关的事件
-(void)upnpSubscriptionTransition
{
    
}

-(void)upnpSubscriptionPlay
{
    [self play];
    
    [self.renderer getPositionInfo];
}

-(void)upnpSubscriptionPause
{
    [self pause];
}

-(void)upnpSubscriptionStop
{
    //结束投屏
    [self.renderer stop];
    
    //结束订阅
    [self.subscription cancelSubscribe];
    
    //结束投屏回调事件
    if ([self.delegate respondsToSelector:@selector(screeningBgViewCloseAction)]) {
        [self.delegate screeningBgViewCloseAction];
    }
}

-(void)upnpSubscriptionWithError:(NSError *)error
{
    [@"订阅失败" showAlert];
}

#pragma mark - DWUPnPResponseDelegate
//设备响应事件
-(void)upnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML
{
    NSLog(@"upnpUndefinedResponse resXML:%@ \npostXML:%@",resXML,postXML);
    if (!resXML) {
        //投屏失败
        [self showAlert:nil WithFailed:YES];
    }
}

// 设置url响应
- (void)upnpSetAVTransportURIResponse
{
    [self play];
    
    [self.renderer getTransportInfo];
    
    [self.renderer getVolume];

}

// 获取播放状态
- (void)upnpGetTransportInfoResponse:(DWUPnPTransportInfo *)info
{
    if ([info.currentTransportState isEqualToString:@"PAUSED_PLAYBACK"] && self.isPlaying) {
        [self pause];
    }
    
    if ([info.currentTransportState isEqualToString:@"PLAYING"] && !self.isPlaying) {
        [self play];
    }
    
    if ([info.currentTransportState isEqualToString:@"STOPPED"]) {
        [self upnpSubscriptionStop];
    }
}

// 获取音频信息
- (void)upnpGetVolumeResponse:(NSString *)volume
{
    self.volume = volume;
}

// 获取播放进度
- (void)upnpGetPositionInfoResponse:(DWUPnPAVPositionInfo *)info
{
    if (!self.volume && self.duration != 0) {
        [self.renderer getVolume];
    }
    
    if (self.duration != 0) {
        //证明设置了拖拽时间
        if (self.seekTime != 0) {
            [self.renderer seek:self.seekTime];
            self.seekTime = 0;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            self.duration = info.trackDuration;
            
            int time = info.absTime;
            self.slider.value = (float)time / self.duration;
            
            self.currentLabel.text = [DWTools formatSecondsToString:time];
            self.totalLabel.text = [DWTools formatSecondsToString:self.duration];
        }
    });
}


// 播放响应
- (void)upnpPlayResponse
{

}

// 暂停响应
- (void)upnpPauseResponse
{

}

// 停止投屏
- (void)upnpStopResponse
{

}

// 跳转响应
- (void)upnpSeekResponse
{

}

// 以前的响应
- (void)upnpPreviousResponse
{

}

// 下一个响应
- (void)upnpNextResponse
{

}

// 设置音量响应
- (void)upnpSetVolumeResponse
{

}

#pragma mark - action
-(void)backButtonAction
{
    if (self.isFull) {
        //转小屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }else{
        [self stopScheduleTimer];
        
        //结束投屏
        [self.renderer stop];
        self.renderer = nil;
        
        //结束订阅
        [self.subscription cancelSubscribe];
        self.subscription = nil;
        
        //结束投屏回调事件
        if ([self.delegate respondsToSelector:@selector(screeningBgViewCloseAction)]) {
            [self.delegate screeningBgViewCloseAction];
        }
    }
}

-(void)playOrPauseButtonAction
{
    if (self.playOrPauseButton.selected) {
        [self pause];
    }else{
        [self play];
    }
}

-(void)sliderMovingAction
{
    [self stopScheduleTimer];
}

-(void)sliderBeganAction
{
    [self stopScheduleTimer];
}

-(void)sliderEndedAction
{
    if (self.duration <= 0) {
        return;
    }
    CGFloat durationInSeconds = self.duration;
    CGFloat time = durationInSeconds * self.slider.value;
    
    [self.renderer seek:time];
    
    [self startScheduleTimer];
}

-(void)scheduleTimerAction
{
    [self.renderer getPositionInfo];
}

-(void)rotateScreenButtonAction
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
}

-(void)addSoundAction
{
    if (!self.volume) {
        [@"未获取到设备音量" showAlert];
        return;
    }
    
    NSInteger currentVolume = [self.volume integerValue];
    if (currentVolume == 100) {
        [@"当前已最大音量" showAlert];
        return;
    }
    currentVolume += 5;
    if (currentVolume > 100) {
        currentVolume = 100;
    }
    
    self.volume = [NSString stringWithFormat:@"%ld",currentVolume];
    [self.renderer setVolumeWith:self.volume];
}


-(void)subSoundAction
{
    if (!self.volume) {
        [@"未获取到设备音量" showAlert];
        return;
    }
    
    NSInteger currentVolume = [self.volume integerValue];
    if (currentVolume == 0) {
        [@"当前已最小音量" showAlert];
        return;
    }
    currentVolume -= 5;
    if (currentVolume < 0) {
        currentVolume = 0;
    }
    
    self.volume = [NSString stringWithFormat:@"%ld",currentVolume];
    [self.renderer setVolumeWith:self.volume];
}

-(void)closeButtonAction
{
    //结束投屏回调事件
    if ([self.delegate respondsToSelector:@selector(screeningBgViewCloseAction)]) {
        [self.delegate screeningBgViewCloseAction];
    }
}

#pragma mark - init
-(void)initUI
{
    [self addSubview:self.topBgImageView];
    [_topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.centerX.equalTo(self);
        make.width.equalTo(@196);
        make.height.equalTo(@43);
    }];
    
    [self addSubview:self.statusLabel];
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@14);
    }];
    
    [self addSubview:self.screeningFailedBgView];
    self.screeningFailedBgView.hidden = YES;
    [_screeningFailedBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBgImageView.mas_bottom);
        make.centerX.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@161);
    }];
    
    [self initTopFuncView];
    [self initDownFuncView];
    [self initLeftFuncView];
}

-(void)initTopFuncView
{
    [self addSubview:self.topFuncBgView];
    [_topFuncBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(@0);
        make.height.equalTo(@(self.areaInsets.top + topFuncBgHeight));
    }];
    
    [self.topFuncBgView addSubview:self.backButton];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.width.and.height.equalTo(@30);
        make.bottom.equalTo(@(-7));
    }];
    
    [self.topFuncBgView addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backButton.mas_right);
        make.centerY.equalTo(self.backButton);
        make.height.equalTo(@14);
        make.right.equalTo(@(-45));
    }];
}

//底部控件
-(void)initDownFuncView
{
    [self addSubview:self.bottomFuncBgView];
    [_bottomFuncBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.left.and.right.equalTo(@0);
        make.height.equalTo(@(bottomFuncBgHeight));
    }];
    
    [self.bottomFuncBgView addSubview:self.playOrPauseButton];
    [_playOrPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(4.5));
        make.width.and.height.equalTo(@30);
        make.left.equalTo(@10);
    }];

    [self.bottomFuncBgView addSubview:self.currentLabel];
    [_currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playOrPauseButton.mas_right).offset(5);
        make.centerY.equalTo(self.playOrPauseButton);
        make.height.equalTo(@(self.currentLabel.frame.size.height));
        make.width.equalTo(@(self.currentLabel.frame.size.width));
    }];
    
    [self.bottomFuncBgView addSubview:self.lineLabel];
    [_lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentLabel.mas_right).offset(2.5);
        make.centerY.equalTo(self.playOrPauseButton);
        make.height.equalTo(@(self.lineLabel.frame.size.height));
        make.width.equalTo(@(self.lineLabel.frame.size.width));
    }];
    
    [self.bottomFuncBgView addSubview:self.totalLabel];
    [_totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lineLabel.mas_right).offset(2.5);
        make.centerY.equalTo(self.playOrPauseButton);
        make.height.equalTo(@(self.totalLabel.frame.size.height));
        make.width.equalTo(@(self.totalLabel.frame.size.width));
    }];
    
    [self.bottomFuncBgView addSubview:self.slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.totalLabel.mas_right).offset(5);
        make.centerY.equalTo(self.playOrPauseButton);
        make.height.equalTo(@30);
        make.right.equalTo(@(-45));
    }];
    
    [self.bottomFuncBgView addSubview:self.rotateScreenButton];
    [_rotateScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-5));
        make.centerY.equalTo(self.playOrPauseButton);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
}

-(void)initLeftFuncView
{
    [self addSubview:self.addSound];
    [_addSound mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-10));
        make.bottom.equalTo(self.mas_centerY).offset(-1);
        make.width.and.height.equalTo(@40);
    }];
    
    [self addSubview:self.subSound];
    [_subSound mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.addSound);
        make.top.equalTo(self.mas_centerY).offset(1);
        make.width.and.height.equalTo(self.addSound);
    }];
}

#pragma mark - lazyLoad
-(UIImageView *)topBgImageView
{
    if (!_topBgImageView) {
        _topBgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_screen_bg@2x"]];
    }
    return _topBgImageView;
}

-(DWPlayerFuncBgView *)topFuncBgView
{
    if (!_topFuncBgView) {
        _topFuncBgView = [[DWPlayerFuncBgView alloc]init];
        _topFuncBgView.isBottom = NO;
    }
    return _topFuncBgView;
}

-(UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"icon_play_return.png"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = TitleFont(14);
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

//底部
-(DWPlayerFuncBgView *)bottomFuncBgView
{
    if (!_bottomFuncBgView) {
        _bottomFuncBgView = [[DWPlayerFuncBgView alloc]init];
        _bottomFuncBgView.isBottom = YES;
    }
    return _bottomFuncBgView;
}

-(UIButton *)playOrPauseButton
{
    if (!_playOrPauseButton) {
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icon_play.png"] forState:UIControlStateNormal];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icon_pause.png"] forState:UIControlStateSelected];
        [_playOrPauseButton addTarget:self action:@selector(playOrPauseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseButton;
}

-(UILabel *)currentLabel
{
    if (!_currentLabel) {
        _currentLabel = [[UILabel alloc]init];
        _currentLabel.font = TitleFont(11);
        _currentLabel.textColor = [UIColor whiteColor];
        _currentLabel.text = @"000:00";
        _currentLabel.textAlignment = NSTextAlignmentCenter;
        [_currentLabel sizeToFit];
        _currentLabel.frame = CGRectMake(0, 0, _currentLabel.frame.size.width, _currentLabel.frame.size.height);
    }
    return _currentLabel;
}

-(UILabel *)lineLabel
{
    if (!_lineLabel) {
        _lineLabel = [[UILabel alloc]init];
        _lineLabel.font = TitleFont(11);
        _lineLabel.textColor = [UIColor whiteColor];
        _lineLabel.textAlignment = NSTextAlignmentCenter;
        _lineLabel.text = @"/";
        [_lineLabel sizeToFit];
        _lineLabel.frame = CGRectMake(0, 0, _lineLabel.frame.size.width, _lineLabel.frame.size.height);
    }
    return _lineLabel;
}

-(UILabel *)totalLabel
{
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc]init];
        _totalLabel.font = TitleFont(11);
        _totalLabel.textColor = [UIColor whiteColor];
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        _totalLabel.text = @"000:00";
        [_totalLabel sizeToFit];
        _totalLabel.frame = CGRectMake(0, 0, _totalLabel.frame.size.width, _totalLabel.frame.size.height);
    }
    return _totalLabel;
}

-(UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc]init];
        [_slider addTarget:self action:@selector(sliderMovingAction) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderEndedAction) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_slider addTarget:self action:@selector(sliderBeganAction) forControlEvents:UIControlEventTouchDown];
        [_slider setThumbImage:[UIImage imageNamed:@"icon_play_circle.png"] forState:UIControlStateNormal];
        [_slider setMinimumTrackImage:[[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
    }
    return _slider;
}

-(UIButton *)rotateScreenButton
{
    if (!_rotateScreenButton) {
        _rotateScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotateScreenButton setImage:[UIImage imageNamed:@"icon_play_full.png"] forState:UIControlStateNormal];
        [_rotateScreenButton addTarget:self action:@selector(rotateScreenButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotateScreenButton;
}

-(UIButton *)addSound
{
    if (!_addSound) {
        _addSound = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addSound setImage:[UIImage imageNamed:@"icon_sound_add.png"] forState:UIControlStateNormal];
        [_addSound addTarget:self action:@selector(addSoundAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addSound;
}

-(UIButton *)subSound
{
    if (!_subSound) {
        _subSound = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subSound setImage:[UIImage imageNamed:@"icon_sound_sub.png"] forState:UIControlStateNormal];
        [_subSound addTarget:self action:@selector(subSoundAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subSound;
}

-(UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc]init];
        _statusLabel.font = TitleFont(14);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.textColor = [UIColor colorWithRed:232/255.0 green:233/255.0 blue:235/255.0 alpha:1.0];
    }
    return _statusLabel;
}

-(UIView *)screeningFailedBgView
{
    if (!_screeningFailedBgView) {
        _screeningFailedBgView = [[UIView alloc]init];
        _screeningFailedBgView.backgroundColor = [UIColor clearColor];
        
        UILabel * tsLabel = [[UILabel alloc]init];
        tsLabel.text = @"投屏连接失败";
        tsLabel.font = TitleFont(15);
        tsLabel.textColor = [UIColor whiteColor];
        tsLabel.textAlignment = NSTextAlignmentCenter;
        [_screeningFailedBgView addSubview:tsLabel];
        [tsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.height.equalTo(@15);
            make.left.and.right.equalTo(@0);
        }];
        
        UILabel * contentLabel = [[UILabel alloc]init];
        contentLabel.text = @"1、请确保手机与投屏设备连接在同一个WiFi下。\n2、请重新投屏或重启APP再次尝试。";
        contentLabel.font = TitleFont(13);
        contentLabel.textColor = [UIColor colorWithRed:232/255.0 green:233/255.0 blue:235/255.0 alpha:1.0];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.numberOfLines = 0;
        [_screeningFailedBgView addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tsLabel.mas_bottom).offset(14);
            make.left.and.right.equalTo(@0);
            make.height.equalTo(@50);
        }];
        
        UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setTitle:@"关闭投屏" forState:UIControlStateNormal];
        closeButton.titleLabel.font = TitleFont(15);
        [closeButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0] forState:UIControlStateNormal];
        closeButton.layer.cornerRadius = 20;
        closeButton.layer.borderWidth = 1;
        closeButton.layer.borderColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0].CGColor;
        [closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_screeningFailedBgView addSubview:closeButton];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentLabel.mas_bottom).offset(22);
            make.centerX.equalTo(_screeningFailedBgView);
            make.width.equalTo(@115);
            make.height.equalTo(@40);
        }];
    }
    return _screeningFailedBgView;
}

-(UIEdgeInsets)areaInsets
{
    if (@available(iOS 11.0, *)) {
        if (!UIEdgeInsetsEqualToEdgeInsets([[UIApplication sharedApplication] delegate].window.safeAreaInsets, UIEdgeInsetsZero)) {
            return [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
        }
    }
    return UIEdgeInsetsMake(20, 10, 0, 10);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
