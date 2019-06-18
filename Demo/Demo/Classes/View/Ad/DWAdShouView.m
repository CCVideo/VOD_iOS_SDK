//
//  DWAdShouView.m
//  Demo
//
//  Created by zwl on 2019/4/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWAdShouView.h"

typedef enum : NSUInteger {
    DWAdTypeBeginPicture,
    DWAdTypeBeginVideo,
    DWAdTypePausePicture,
} DWAdShouViewType;

@interface DWAdShouView ()

//广告数据
@property(nonatomic,strong)DWVodAdInfoModel * adInfoModel;
//当前展示的广告素材数据
@property(nonatomic,strong)DWVodAdMaterialModel * adMaterialModel;
//广告倒计时
@property(nonatomic,assign)NSInteger secondsCountTime;
//跳过时间
@property(nonatomic,assign)NSInteger skipTime;
//广告类型
@property(nonatomic,assign)DWAdShouViewType adType;

//片头广告数据
//返回按钮
@property(nonatomic,strong)UIButton * returnButton;
//倒计时label
@property(nonatomic,strong)UILabel * timeLabel;
//定时器
@property(nonatomic,strong)NSTimer * timer;
//关闭广告按钮
@property(nonatomic,strong)UIButton * beginCloseButton;
//了解详情按钮
@property(nonatomic,strong)UIButton * detailButton;
//全屏/非全屏按钮
@property(nonatomic,strong)UIButton * fullButton;

///片头视频广告
@property(nonatomic,strong)AVQueuePlayer * adQueuePlayer;
@property(nonatomic,strong)AVPlayerLayer * playerLayer;
//当前播放广告下标
///片头图片广告
@property(nonatomic,strong)UIImageView * adBeginImageView;

//暂停广告
@property(nonatomic,strong)UIImageView * adPauseImageView;
//关闭按钮
@property(nonatomic,strong)UIButton * pauseCloseButton;

@property(nonatomic,assign)BOOL isFull;

@end

@implementation DWAdShouView

#pragma mark - function
-(void)playAdVideo:(DWVodAdInfoModel *)adInfoModel
{
    if (!adInfoModel) {
        return;
    }

    self.hidden = NO;
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    self.adInfoModel = adInfoModel;
    
    [self clearAllObject];

    //前后台切换通知
    // app回到前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adShouViewWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adShouViewWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

    self.adMaterialModel = [self.adInfoModel.ads firstObject];
    if (self.adInfoModel.type == 1) {
        //片头广告
        if ([[self.adMaterialModel.materialUrl lowercaseString] rangeOfString:@".mp4"].location == NSNotFound) {
            //图片广告
            self.adType = DWAdTypeBeginPicture;
        }else{
            //视频广告
            [self loadAdQueuePlayer];
            self.adType = DWAdTypeBeginVideo;
        }
        
    }else if (self.adInfoModel.type == 2){
        //暂停广告
        self.adType = DWAdTypePausePicture;
    }

    self.secondsCountTime = self.adInfoModel.time;
    self.skipTime = self.adInfoModel.skipTime;
    
    [self loadView];
    
    //加载默认的广告视图
    if (self.adType == DWAdTypeBeginVideo) {
        [self loadBeginVideoAd:NO];
    }
    if (self.adType == DWAdTypeBeginPicture) {
        [self loadBeginPictureAd:NO];
    }
    if (self.adType == DWAdTypePausePicture) {
        [self loadPausePictureAd:NO];
    }

}

-(void)screenRotate:(BOOL)isFull
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.isFull = isFull;
    if (self.adType == DWAdTypeBeginVideo) {
        [self loadBeginVideoAd:isFull];
    }
    if (self.adType == DWAdTypeBeginPicture) {
        [self loadBeginPictureAd:isFull];
    }
    if (self.adType == DWAdTypePausePicture) {
        [self loadPausePictureAd:isFull];
    }
}

//加载视频播放相关控件
-(void)loadAdQueuePlayer
{
    //创建player相关的
    NSMutableArray * items = [NSMutableArray array];
    for (DWVodAdMaterialModel * materialModel in self.adInfoModel.ads) {
        AVPlayerItem * item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:materialModel.materialUrl]];
        [items addObject:item];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adPlayerDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
        
    }
    self.adQueuePlayer = [AVQueuePlayer queuePlayerWithItems:items];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.adQueuePlayer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:self.playerLayer];
    [self.adQueuePlayer play];
}

//加载片头视频广告
-(void)loadBeginVideoAd:(BOOL)isFull
{
    //处理子控件 显示
    self.returnButton.hidden = NO;
    self.timeLabel.hidden = NO;
    self.beginCloseButton.hidden = !self.adInfoModel.canSkip;
    self.detailButton.hidden = NO;
    self.fullButton.hidden = NO;
    
    //处理子控件 frame
    self.returnButton.frame = CGRectMake(self.bounds.origin.x + 10, 20, 35, 35);
    self.detailButton.frame = CGRectMake(self.bounds.size.width - 120, self.bounds.size.height - 40, 70, 30);
    self.fullButton.frame = CGRectMake(self.bounds.size.width - 40, self.bounds.size.height - 40, 30, 30);
    self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    //加载定时器
    //存在的话，是横竖屏切换时走的这个方法
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginInfoTimeAction) userInfo:nil repeats:YES];
    }
}

//加载片头图片广告
-(void)loadBeginPictureAd:(BOOL)isFull
{
    //处理子控件 显示
    self.returnButton.hidden = NO;
    self.timeLabel.hidden = NO;
    self.adBeginImageView.hidden = NO;
    self.beginCloseButton.hidden = !self.adInfoModel.canSkip;
    self.detailButton.hidden = NO;
    self.fullButton.hidden = NO;
    
    //处理子控件 frame
    self.returnButton.frame = CGRectMake(self.bounds.origin.x + 10, 20, 35, 35);
    self.detailButton.frame = CGRectMake(self.bounds.size.width - 120, self.bounds.size.height - 40, 70, 30);
    self.fullButton.frame = CGRectMake(self.bounds.size.width - 40, self.bounds.size.height - 40, 30, 30);
    
    if (isFull) {
        self.adBeginImageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    }else{
        self.adBeginImageView.transform = CGAffineTransformIdentity;
    }
    
    self.adBeginImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
//    self.adBeginImageView.center = self.center;
    
    //加载广告信息
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage * adImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.adMaterialModel.materialUrl]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.adBeginImageView.image = adImage;
        });
    });
    
    //加载定时器
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginInfoTimeAction) userInfo:nil repeats:YES];
    }
}

//加载暂停广告
-(void)loadPausePictureAd:(BOOL)isFull
{
    //处理子控件 显示
    self.adPauseImageView.hidden = NO;
    self.pauseCloseButton.hidden = NO;
    
    //处理子控件 frame
    if (isFull) {
        self.adPauseImageView.frame = CGRectMake(self.bounds.size.width * 0.2, self.bounds.size.height * 0.2, self.bounds.size.width * 0.6, self.bounds.size.height * 0.6);
    }else{
        self.adPauseImageView.frame = CGRectMake(30, 40, self.bounds.size.width - 60, self.bounds.size.height - 80);
    }
    self.pauseCloseButton.frame = CGRectMake(0, 0, 30, 30);
    self.pauseCloseButton.center = CGPointMake(CGRectGetMaxX(self.adPauseImageView.frame), self.adPauseImageView.frame.origin.y);
    
    //加载广告信息
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage * adImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.adMaterialModel.materialUrl]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.adPauseImageView.image = adImage;
        });
    });
}

-(void)beginInfoChangeFrame
{
    if (self.adInfoModel.canSkip) {
        if (self.skipTime <= 0) {
            [self.beginCloseButton setTitle:@"关闭广告" forState:UIControlStateNormal];
            self.beginCloseButton.frame = CGRectMake(self.bounds.size.width - 80, 20, 70, 30);
            self.timeLabel.frame = CGRectMake(self.bounds.size.width - 117, 20, 30, 30);
            self.beginCloseButton.enabled = YES;
        }else{
            [self.beginCloseButton setTitle:[NSString stringWithFormat:@"%lds后可关闭广告",self.skipTime] forState:UIControlStateNormal];
            self.beginCloseButton.frame = CGRectMake(self.bounds.size.width - 130, 20, 120, 30);
            self.timeLabel.frame =CGRectMake(self.bounds.size.width - 130 - 5 - 30, 20, 30, 30);
            self.beginCloseButton.enabled = NO;
        }
    }
}

//清理上一个广告的对象
-(void)clearAllObject
{
    self.returnButton.hidden = YES;
    self.timeLabel.hidden= YES;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.beginCloseButton.hidden = YES;
    self.detailButton.hidden = YES;
    self.fullButton.hidden = YES;

    //清空通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.adQueuePlayer pause];
    self.adQueuePlayer = nil;
    
    self.adBeginImageView.hidden = YES;
    self.adPauseImageView.hidden = YES;
    self.pauseCloseButton.hidden = YES;
}

-(void)loadView
{
    [self addSubview:self.returnButton];
    [self addSubview:self.timeLabel];
    [self addSubview:self.beginCloseButton];
    [self addSubview:self.detailButton];
    [self addSubview:self.fullButton];
    [self addSubview:self.pauseCloseButton];
    [self insertSubview:self.adBeginImageView atIndex:0];
    [self insertSubview:self.adPauseImageView atIndex:0];
}

//广告播放完成
-(void)adShowToEnd
{
    self.hidden = YES;
    
    if ([self.delegate respondsToSelector:@selector(adShowPlayDidFinish:AndAdType:)]) {
        [self.delegate adShowPlayDidFinish:self AndAdType:self.adInfoModel.type];
    }
    [self clearAllObject];
}

#pragma mark - action
-(void)returnButtonAction
{
    [self adShowToEnd];
}

-(void)beginCloseButtonAction
{
    [self adShowToEnd];
}

-(void)detailButtonAction
{
    //广告跳转详情，要暂停广告，暂停定时器
    //app回到前台时，重新开始计时呗？？
    NSURL * clickUrl = [NSURL URLWithString:self.adMaterialModel.clickUrl];
    if ([[UIApplication sharedApplication] canOpenURL:clickUrl]) {
        [[UIApplication sharedApplication] openURL:clickUrl];
    
    }else{
        NSLog(@"%s %d openURL error",__func__,__LINE__);
    }
}

-(void)fullScreenAction
{
    //通知外部，屏幕旋转回调
    if ([self.delegate respondsToSelector:@selector(adShowPlay:DidScreenRotate:)]) {
        [self.delegate adShowPlay:self DidScreenRotate:self.isFull];
    }
}

-(void)pauseCloseButtonAction
{
    //广告播放完成回调
    [self adShowToEnd];
}

//timer
-(void)beginInfoTimeAction
{
    _timeLabel.text = [NSString stringWithFormat:@"%lds",self.secondsCountTime];
    self.secondsCountTime--;
    
    self.skipTime--;
    [self beginInfoChangeFrame];
    
    if (self.secondsCountTime < 0) {
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }

        [self adShowToEnd];
    }
}


-(void)adPlayerDidPlayToEnd:(NSNotification *)noti
{
    //判断当前item是否是最后一个item ，如果是最后一个item，广告播放完成
    AVPlayerItem * item = (AVPlayerItem *)noti.object;
    NSLog(@"%s %ld",__func__,self.adQueuePlayer.items.count);
    if ([self.adQueuePlayer.items indexOfObject:item] == 1) {
        [self adShowToEnd];
    }else{
        [self.adQueuePlayer advanceToNextItem];
    }
}

//app回到前台
-(void)adShouViewWillEnterForeground
{
    if (self.adType != DWAdTypePausePicture) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginInfoTimeAction) userInfo:nil repeats:YES];
        }
        
        if (self.adType == DWAdTypeBeginVideo) {
            [self.adQueuePlayer play];
        }
    }
}

//app进入后台
-(void)adShouViewWillResignActive
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.adType == DWAdTypeBeginVideo) {
        [self.adQueuePlayer pause];
    }else{
        
    }
}

#pragma mark - lazyLoad
-(UIButton *)returnButton
{
    if (!_returnButton) {
        _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _returnButton.backgroundColor = [UIColor clearColor];
        [_returnButton setImage:[UIImage imageNamed:@"player-back-button.png"] forState:UIControlStateNormal];
        [_returnButton addTarget:self action:@selector(returnButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _returnButton;
}

-(UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

-(UIButton *)beginCloseButton
{
    if (!_beginCloseButton) {
        _beginCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _beginCloseButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        [_beginCloseButton addTarget:self action:@selector(beginCloseButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _beginCloseButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_beginCloseButton sizeToFit];
    }
    return _beginCloseButton;
}

-(UIButton *)detailButton
{
    if (!_detailButton) {
        _detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_detailButton setTitle:@"了解详情" forState:UIControlStateNormal];
        _detailButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _detailButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        [_detailButton addTarget:self action:@selector(detailButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailButton;
}

-(UIButton *)fullButton
{
    if (!_fullButton) {
        _fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullButton.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
//        _fullButton.selected = self.switchScrBtn.selected;
        [_fullButton setImage:[UIImage imageNamed:@"icon_ad_full.png"] forState:UIControlStateNormal];
        [_fullButton setImage:[UIImage imageNamed:@"icon_ad_full_select.png"] forState:UIControlStateSelected];
        [_fullButton addTarget:self action:@selector(fullScreenAction)
         forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}

-(UIImageView *)adBeginImageView
{
    if (!_adBeginImageView) {
        _adBeginImageView = [[UIImageView alloc]init];
        _adBeginImageView.backgroundColor = [UIColor clearColor];
    }
    return _adBeginImageView;
}

-(UIImageView *)adPauseImageView
{
    if (!_adPauseImageView) {
        _adPauseImageView = [[UIImageView alloc]init];
        _adPauseImageView.backgroundColor = [UIColor clearColor];
        _adPauseImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _adPauseImageView;
}

-(UIButton *)pauseCloseButton
{
    if (!_pauseCloseButton) {
        _pauseCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseCloseButton setBackgroundImage:[UIImage imageNamed:@"icon_ad_close.png"] forState:UIControlStateNormal];
        [_pauseCloseButton addTarget:self action:@selector(pauseCloseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseCloseButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
