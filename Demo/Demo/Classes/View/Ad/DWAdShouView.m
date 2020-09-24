//
//  DWAdShouView.m
//  Demo
//
//  Created by zwl on 2019/4/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWAdShouView.h"
#import <WebKit/WebKit.h>

typedef enum : NSUInteger {
    DWAdTypePicture,
    DWAdTypeVideo,
    DWADTypeGIF,
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

///视频广告
@property(nonatomic,strong)UIView * adPlayerBgView;
@property(nonatomic,strong)AVPlayer * adPlayer;
@property(nonatomic,strong)AVPlayerLayer * playerLayer;
//当前播放广告下标
///图片广告
@property(nonatomic,strong)UIImageView * adImageView;

//GIF广告
@property(nonatomic,strong)UIImageView * gifImageView;

//关闭按钮
@property(nonatomic,strong)UIButton * pauseCloseButton;
@property(nonatomic,strong)UIButton * muteButton;

@property(nonatomic,assign)BOOL isFull;

@end

@implementation DWAdShouView

static CGFloat closeButtonWeight = 46.0;
static CGFloat closeButtonHeight = 20.0;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UITapGestureRecognizer * detailTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detailTapAction)];
        [self addGestureRecognizer:detailTap];
        
        self.isFull = NO;
        
    }
    return self;
}

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
    
    if ([[self.adMaterialModel.materialUrl lowercaseString] containsString:@".mp4"]) {
        //视频广告
        self.adType = DWAdTypeVideo;
    }else if ([[self.adMaterialModel.materialUrl lowercaseString] containsString:@".gif"]) {
        //GIF广告
        self.adType = DWADTypeGIF;
    }else{
        //图片广告
        self.adType = DWAdTypePicture;
    }

    self.secondsCountTime = self.adInfoModel.time;
    self.skipTime = self.adInfoModel.skipTime;
    
    [self loadView];
    
    //加载默认的广告视图
    if (self.adType == DWAdTypeVideo) {
        [self loadAdPlayer];
        [self loadVideoAd:self.isFull];
    }else if (self.adType == DWADTypeGIF){
        [self loadGIFAd:self.isFull];
    }else{
        [self loadPictureAd:self.isFull];
    }

}

-(void)screenRotate:(BOOL)isFull
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.isFull = isFull;

    if (self.adType == DWAdTypeVideo) {
        [self loadVideoAd:isFull];
    }
    if (self.adType == DWAdTypePicture) {
        [self loadPictureAd:isFull];
    }
    if (self.adType == DWADTypeGIF) {
        [self loadGIFAd:isFull];
    }
}

//完成广告
-(void)adFinish
{
    self.hidden = YES;
    
    [self clearAllObject];
}

//加载视频播放相关控件
-(void)loadAdPlayer
{
    DWVodAdMaterialModel * materialModel = self.adInfoModel.ads.firstObject;
    AVPlayerItem * item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:materialModel.materialUrl]];
    self.adPlayer = [AVPlayer playerWithPlayerItem:item];
    //暂停广告有音量控制，其余类型广告不做控制
    if (self.adInfoModel.type == 2) {
        self.adPlayer.muted = self.muteButton.selected;
    }
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.adPlayer];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

    [self.adPlayerBgView.layer addSublayer:self.playerLayer];
    [self.adPlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adPlayerDidPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.adPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

//加载视频广告
-(void)loadVideoAd:(BOOL)isFull
{
    if (self.adInfoModel.type == 2) {
        //暂停广告
        self.pauseCloseButton.hidden = NO;
        self.muteButton.hidden = NO;
        
        //处理子控件 frame
        if (isFull) {
//            self.adPlayerBgView.frame = CGRectMake(133, 75, (self.bounds.size.width - 133 * 2), (self.bounds.size.height - 75));
            self.adPlayerBgView.frame = CGRectMake(133, 75, (self.bounds.size.width - 133 * 2), (self.bounds.size.height - 75 * 2));
//            CGRectMake(133, 75, (ScreenWidth - 133 * 2), (ScreenHeight - 75));

        }else{
            self.adPlayerBgView.frame = CGRectMake(87, 45, (self.bounds.size.width - 87 * 2), (self.bounds.size.height - 45 * 2));
        }
        
//        self.adPlayerBgView.center = self.center;
        
    }else{
        //其他类型广告
        //处理子控件 显示
        self.returnButton.hidden = NO;
//        self.timeLabel.hidden = NO;
        self.timeLabel.hidden = !self.adInfoModel.canSkip;
        self.beginCloseButton.hidden = !self.adInfoModel.canSkip;
        self.detailButton.hidden = NO;
        self.fullButton.hidden = NO;
        
        //处理子控件 frame
        self.returnButton.frame = CGRectMake(self.bounds.origin.x + 10, 20, 35, 35);
        self.detailButton.frame = CGRectMake(self.bounds.size.width - 120, self.bounds.size.height - 40, 70, 30);
        self.fullButton.frame = CGRectMake(self.bounds.size.width - 40, self.bounds.size.height - 40, 30, 30);
        
        self.adPlayerBgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        //加载定时器
        //存在的话，是横竖屏切换时走的这个方法
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginInfoTimeAction) userInfo:nil repeats:YES];
        }
    }
    
    self.playerLayer.frame = self.adPlayerBgView.bounds;
    
    if (self.adPlayer.currentItem.status == AVPlayerStatusReadyToPlay) {
        //计算素材位置
        [self.pauseCloseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.adPlayerBgView).offset(CGRectGetMaxX(self.playerLayer.videoRect) - closeButtonWeight - 3);
            make.top.equalTo(@(self.adPlayerBgView.frame.origin.y + self.playerLayer.videoRect.origin.y + 3));
            
            make.width.equalTo(@(closeButtonWeight));
            make.height.equalTo(@(closeButtonHeight));
        }];
        
        [self.muteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.adPlayerBgView).offset(CGRectGetMaxY(self.playerLayer.videoRect) - 24 - 10);
            make.left.equalTo(self.adPlayerBgView).offset(self.playerLayer.videoRect.origin.x + 10);
            make.width.and.height.equalTo(@24);
        }];
    }
}

//加载图片广告
-(void)loadPictureAd:(BOOL)isFull
{
    if (self.adInfoModel.type == 2) {
        //暂停广告
        //处理子控件 显示
        self.adImageView.hidden = NO;
        self.pauseCloseButton.hidden = NO;
        
        //处理子控件 frame
        if (isFull) {
            self.adImageView.frame = CGRectMake(133, 75, (self.bounds.size.width - 133 * 2), (self.bounds.size.height - 75 * 2));
//            CGRectMake(133, 75, (ScreenWidth - 133 * 2), (ScreenHeight - 75));
        }else{
            self.adImageView.frame = CGRectMake(87, 45, (self.bounds.size.width - 87 * 2), (self.bounds.size.height - 45 * 2));
        }
        
//        self.adImageView.center = self.center;
        
        //计算关闭按钮位置
        [self.pauseCloseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.adImageView).offset(-3);
            make.top.equalTo(self.adImageView).offset(3);
            make.width.equalTo(@46);
            make.height.equalTo(@20);
        }];

    }else{
        //其他类型广告
        //处理子控件 显示
        self.returnButton.hidden = NO;
//        self.timeLabel.hidden = NO;
        self.timeLabel.hidden = !self.adInfoModel.canSkip;
        self.adImageView.hidden = NO;
        self.beginCloseButton.hidden = !self.adInfoModel.canSkip;
        self.detailButton.hidden = NO;
        self.fullButton.hidden = NO;
        
        //处理子控件 frame
        self.returnButton.frame = CGRectMake(self.bounds.origin.x + 10, 20, 35, 35);
        self.detailButton.frame = CGRectMake(self.bounds.size.width - 120, self.bounds.size.height - 40, 70, 30);
        self.fullButton.frame = CGRectMake(self.bounds.size.width - 40, self.bounds.size.height - 40, 30, 30);
        
        if (isFull) {
            self.adImageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        }else{
            self.adImageView.transform = CGAffineTransformIdentity;
        }
        
        self.adImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

        //加载定时器
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginInfoTimeAction) userInfo:nil repeats:YES];
        }
    }
    
    //判断广告是否已经加载
    if (self.adImageView.image) {
        if (self.adInfoModel.type == 2) {
            [self pauseButtonFrameReset:self.adImageView AndImageRect:AVMakeRectWithAspectRatioInsideRect(self.adImageView.image.size, self.adImageView.bounds)];
        }
    }else{
        //加载广告信息
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage * adImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.adMaterialModel.materialUrl]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.adImageView.image = adImage;
                //对于暂停广告，重新计算关闭按钮位置
                if (self.adInfoModel.type == 2) {
                    [self pauseButtonFrameReset:self.adImageView AndImageRect:AVMakeRectWithAspectRatioInsideRect(self.adImageView.image.size, self.adImageView.bounds)];
                }
            });
        });
    }
    
}

//加载gif
-(void)loadGIFAd:(BOOL)isFull
{
    if (self.adInfoModel.type == 2) {
        //暂停广告
        //处理子控件 显示
        self.gifImageView.hidden = NO;
        self.pauseCloseButton.hidden = NO;
        
        //处理子控件 frame
        if (isFull) {
            self.gifImageView.frame = CGRectMake(133, 75, (self.bounds.size.width - 133 * 2), (self.bounds.size.height - 75 * 2));
        }else{
            self.gifImageView.frame = CGRectMake(87, 45, (self.bounds.size.width - 87 * 2), (self.bounds.size.height - 45 * 2));
        }
                
        //计算关闭按钮位置
        [self.pauseCloseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.gifImageView).offset(-3);
            make.top.equalTo(self.gifImageView).offset(3);
            make.width.equalTo(@46);
            make.height.equalTo(@20);
        }];
        
    }else{
        //其他类型广告
        //处理子控件 显示
        self.returnButton.hidden = NO;
//        self.timeLabel.hidden = NO;
        self.timeLabel.hidden = !self.adInfoModel.canSkip;
        self.gifImageView.hidden = NO;
        self.beginCloseButton.hidden = !self.adInfoModel.canSkip;
        self.detailButton.hidden = NO;
        self.fullButton.hidden = NO;
        
        //处理子控件 frame
        self.returnButton.frame = CGRectMake(self.bounds.origin.x + 10, 20, 35, 35);
        self.detailButton.frame = CGRectMake(self.bounds.size.width - 120, self.bounds.size.height - 40, 70, 30);
        self.fullButton.frame = CGRectMake(self.bounds.size.width - 40, self.bounds.size.height - 40, 30, 30);
        
        if (isFull) {
            self.gifImageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        }else{
            self.gifImageView.transform = CGAffineTransformIdentity;
        }
        
        self.gifImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                
        //加载定时器
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginInfoTimeAction) userInfo:nil repeats:YES];
        }
    }
    
    if (self.gifImageView.animationImages) {
        //对于暂停广告，重新计算关闭按钮位置
        if (self.adInfoModel.type == 2) {
            UIImageView * imageView = [[UIImageView alloc]init];
            imageView.frame = self.gifImageView.frame;
            imageView.image = self.gifImageView.animationImages.firstObject;
            
            [self pauseButtonFrameReset:self.gifImageView AndImageRect:AVMakeRectWithAspectRatioInsideRect(imageView.image.size, self.gifImageView.bounds)];
        }
    }else{
        //加载GIF
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData * gifData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.adMaterialModel.materialUrl]];
            if (!gifData) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.gifImageView.animationImages = [DWTools getImageFromGIFData:gifData];
                self.gifImageView.animationDuration = 3;
                [self.gifImageView startAnimating];
                
                //对于暂停广告，重新计算关闭按钮位置
                if (self.adInfoModel.type == 2) {
                    UIImageView * imageView = [[UIImageView alloc]init];
                    imageView.frame = self.gifImageView.frame;
                    imageView.image = self.gifImageView.animationImages.firstObject;
                    
                    [self pauseButtonFrameReset:self.gifImageView AndImageRect:AVMakeRectWithAspectRatioInsideRect(imageView.image.size, self.gifImageView.bounds)];
                }
            });
        });
    }
    
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
    [self.adPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.adPlayer pause];
    self.adPlayer = nil;
    
    self.muteButton.hidden = YES;
    self.muteButton.selected = YES;
    
    [self.gifImageView stopAnimating];
    self.gifImageView.hidden = YES;
    self.gifImageView.animationImages = nil;
    
    self.adImageView.hidden = YES;
    self.adImageView.image = nil;
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

    [self insertSubview:self.adPlayerBgView atIndex:0];
    [self addSubview:self.muteButton];
    
    [self insertSubview:self.adImageView atIndex:0];
    [self insertSubview:self.gifImageView atIndex:0];
}

//广告播放完成
-(void)adShowToEnd
{
    self.hidden = YES;

    [self clearAllObject];
    
    if ([self.delegate respondsToSelector:@selector(adShowPlayDidFinish:AndAdType:)]) {
        [self.delegate adShowPlayDidFinish:self AndAdType:self.adInfoModel.type];
    }
}

//对暂停关闭按钮重新布局
-(void)pauseButtonFrameReset:(UIView *)fatherView AndImageRect:(CGRect)imageRect
{
    [self.pauseCloseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(fatherView).offset(CGRectGetMaxX(imageRect) - closeButtonWeight - 3);
//         make.top.equalTo(@(CGRectGetMidY(imageRect)));
        make.top.equalTo(@(fatherView.frame.origin.y + imageRect.origin.y + 3));
         make.width.equalTo(@(closeButtonWeight));
         make.height.equalTo(@(closeButtonHeight));
     }];
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

-(void)detailTapAction
{
    if (!self.adInfoModel.canClick) {
        return;
    }
    
    NSURL * clickUrl = [NSURL URLWithString:self.adMaterialModel.clickUrl];
    if ([[UIApplication sharedApplication] canOpenURL:clickUrl]) {
        [[UIApplication sharedApplication] openURL:clickUrl];
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
    [self beginInfoChangeFrame];

    self.secondsCountTime--;
    
    self.skipTime--;
    
    if (self.secondsCountTime < 0) {
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }

        [self adShowToEnd];
    }
}

-(void)muteButtonAction
{
    self.muteButton.selected = !self.muteButton.selected;
    
    self.adPlayer.muted = self.muteButton.selected;
}

-(void)adPlayerDidPlayToEnd
{
    [self.adPlayer seekToTime:CMTimeMake(0, self.adPlayer.currentItem.duration.timescale)];
    [self.adPlayer play];
}

//app回到前台
-(void)adShouViewWillEnterForeground
{
    if (self.adInfoModel.type != 2) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginInfoTimeAction) userInfo:nil repeats:YES];
        }
    }
    
    if (self.adType == DWAdTypeVideo) {
        [self.adPlayer play];
    }
}

//app进入后台
-(void)adShouViewWillResignActive
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }

    if (self.adType == DWAdTypeVideo) {
        [self.adPlayer pause];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        if (self.adPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            //计算素材位置
            [self.pauseCloseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.adPlayerBgView).offset(CGRectGetMaxX(self.playerLayer.videoRect) - closeButtonWeight - 3);
                make.top.equalTo(@(self.adPlayerBgView.frame.origin.y + self.playerLayer.videoRect.origin.y + 3));

                make.width.equalTo(@(closeButtonWeight));
                make.height.equalTo(@(closeButtonHeight));
            }];

            [self.muteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.adPlayerBgView).offset(CGRectGetMaxY(self.playerLayer.videoRect) - 24 - 10);
                make.left.equalTo(self.adPlayerBgView).offset(self.playerLayer.videoRect.origin.x + 10);
                make.width.and.height.equalTo(@24);
            }];
            
            [self.adPlayer play];
        }
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
        _detailButton.enabled = NO;
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

-(UIImageView *)adImageView
{
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc]init];
        _adImageView.backgroundColor = [UIColor clearColor];
        _adImageView.contentMode = UIViewContentModeScaleAspectFit;
        _adImageView.userInteractionEnabled = YES;

    }
    return _adImageView;
}

-(UIButton *)pauseCloseButton
{
    if (!_pauseCloseButton) {
        _pauseCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseCloseButton setTitle:@" 关闭 X " forState:UIControlStateNormal];
        [_pauseCloseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _pauseCloseButton.titleLabel.font = TitleFont(12);
        _pauseCloseButton.layer.masksToBounds = YES;
        _pauseCloseButton.layer.cornerRadius = 2;
        [_pauseCloseButton setBackgroundImage:[[UIColor colorWithWhite:0 alpha:0.4] createImage] forState:UIControlStateNormal];
        [_pauseCloseButton addTarget:self action:@selector(pauseCloseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseCloseButton;
}

-(UIImageView *)gifImageView
{
    if (!_gifImageView) {
        _gifImageView = [[UIImageView alloc]init];
        _gifImageView.backgroundColor = [UIColor clearColor];
        _gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        _gifImageView.userInteractionEnabled = YES;
    }
    return _gifImageView;
}

-(UIView *)adPlayerBgView
{
    if (!_adPlayerBgView) {
        _adPlayerBgView = [[UIView alloc]init];
        _adPlayerBgView.backgroundColor = [UIColor clearColor];
    }
    return _adPlayerBgView;
}

-(UIButton *)muteButton
{
    if (!_muteButton) {
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteButton setImage:[UIImage imageNamed:@"icon_ad_mute.png"] forState:UIControlStateNormal];
        [_muteButton setImage:[UIImage imageNamed:@"icon_ad_mute_select.png"] forState:UIControlStateSelected];
        [_muteButton addTarget:self action:@selector(muteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _muteButton.selected = YES;
    }
    return _muteButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
