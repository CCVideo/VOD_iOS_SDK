//
//  DWVodPlayerView.m
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWVodPlayerView.h"
#import "DWPlayerFuncBgView.h"
#import "DWPlayerSlider.h"
#import "DWPlayerSettingView.h"
#import "DWTableChooseModel.h"
#import "DWMarkView.h"
#import "DWQuestionView.h"
#import "DWFeedBackView.h"
#import "DWSubtitleView.h"
#import "DWMessageView.h"
#import "Reachability.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DWGIFManager.h"
#import "DWToastView.h"
#import "CustomDirectorFactory.h"
#import "DWGifRecordFinishView.h"
#import "DWVisitorCollectView.h"
#import "DWExercisesAlertView.h"
#import "DWExercisesView.h"
#import <AVKit/AVKit.h>
#import "DWVodPlayerPanGesture.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DWVodPlayerView ()<DWVideoPlayerDelegate,DWPlayerSettingViewDelegate,DWGifRecordFinishViewDelegate,DWVisitorCollectViewDelegate,DWExercisesAlertViewDelegate,DWExercisesViewDelegate,AVPictureInPictureControllerDelegate,DWVodPlayerPanGestureDelegate>

@property(nonatomic,strong)UIView * maskView;//遮罩层

@property(nonatomic,strong)DWVodVideoModel * videoModel;
@property(nonatomic,strong)DWDownloadModel * downloadModel;

//DWPlayerView
@property(nonatomic,strong)DWPlayerView * playerView;
//音频
@property(nonatomic,strong)UIView * radioBgView;
@property(nonatomic,strong)UIImageView * radioImageView;

//@property(nonatomic,assign)BOOL openWindowsPlay;//是否开启窗口播放功能
@property(nonatomic,assign)BOOL isWindowsPlay;//当前是否在小窗模式

@property(nonatomic,strong)UIPanGestureRecognizer * windowsPan;//窗口拖拽手势
@property(nonatomic,strong)UIButton * windowsCloseButton;
@property(nonatomic,strong)UIButton * windowsPlayOrPauseButton;
@property(nonatomic,strong)UIButton * windowsResumeButton;

//是否加载完毕
@property(nonatomic,assign)BOOL readyToPlay;

//是否开启后台播放
@property(nonatomic,assign)BOOL allowBackgroundPlay;
//是否开启画中画，仅对pad有效
@property(nonatomic,assign)BOOL allowPictureInPicture;

@property(nonatomic,assign)UIEdgeInsets areaInsets;
@property(nonatomic,assign)BOOL isFull;
@property(nonatomic,assign)BOOL isVideo;//当前播放模式 视频 / 音频
@property(nonatomic,assign)NSTimeInterval switchTime;
@property(nonatomic,assign)BOOL isSwitchquality;//是否切换清晰度
@property(nonatomic,assign)BOOL isLock;//锁屏

@property(nonatomic,strong)UITapGestureRecognizer * tap;//状态栏控制

//top
@property(nonatomic,strong)DWPlayerFuncBgView * topFuncBgView;
@property(nonatomic,strong)UIButton * backButton;//返回按钮
@property(nonatomic,strong)UILabel * titleLabel;//视频标题
@property(nonatomic,strong)UIButton * mediaKindButton;//媒体类型按钮
@property(nonatomic,strong)UIButton * otherFuncButton;//其他功能，字幕切换，画面尺寸之类的
@property(nonatomic,strong)UIButton * vrInteractiveButton;//vrButton
@property(nonatomic,strong)UIButton * vrDisplayButton;//vrButton
@property(nonatomic,strong)UIButton * screeningButton;//投屏按钮
@property(nonatomic,strong)UIButton * pipButton;//画中画按钮
@property(nonatomic,strong)UIButton * windowsButton;//窗口播放按钮

//bottom
@property(nonatomic,strong)DWPlayerFuncBgView * bottomFuncBgView;
@property(nonatomic,strong)UIButton * playOrPauseButton;//开始/暂停
@property(nonatomic,strong)UIButton * nextButton;//播放下一个视频
@property(nonatomic,strong)UILabel * currentLabel;//当前时间
@property(nonatomic,strong)UILabel * lineLabel;// /!!
@property(nonatomic,strong)UILabel * totalLabel;//总时间
@property(nonatomic,strong)DWPlayerSlider * slider;//进度条,
@property(nonatomic,strong)UIButton * speedButton;//倍速
@property(nonatomic,strong)UIButton * qualityButton;//画质，清晰度
@property(nonatomic,strong)UIButton * chooseButton;//选集
@property(nonatomic,strong)UIButton * rotateScreenButton;//横竖屏切换

@property(nonatomic,strong)UIButton * gifButton;//GIF录制
@property(nonatomic,strong)UIButton * disableGesButton;//禁用页面手势

@property(nonatomic,strong)UIButton * screenShotButton;//截屏按钮

@property(nonatomic,strong)MBProgressHUD * hud;

//funcBgView 动画
@property(nonatomic,strong)NSTimer * funcTimer;//页面手势定时器
@property(nonatomic,assign)NSInteger funcSecond;//页面手势定时器 持续时间  默认4秒
@property(nonatomic,assign)BOOL isSlidering;//拖拽手势的定时器， 为了防止频繁拖拽引发的问题

@property(nonatomic,strong)DWPlayerSettingView * settingView;//当前设置页面

@property(nonatomic,strong)NSMutableArray <DWTableChooseModel *> * speedArray;//速率选择数据
@property(nonatomic,strong)NSMutableArray <DWTableChooseModel *> * qualityArray;//清晰度选择数据
@property(nonatomic,strong)NSMutableArray <DWTableChooseModel *> * sizeArray;//画面尺寸
@property(nonatomic,strong)NSMutableArray <DWTableChooseModel *> * selectionArray;//画面尺寸
@property(nonatomic,assign)CGFloat screenLight;//屏幕亮度
@property(nonatomic,assign)CGFloat systemSound;//系统音量
@property(nonatomic,strong)UISlider * volumeViewSlider;

@property(nonatomic,strong)Reachability * reachability; //网络状态监听

@property(nonatomic,strong)DWVodPlayerPanGesture * pan;//亮度,音量，快进快退调节

//**************************** 视频打点 ****************************
@property(nonatomic,strong)NSArray * videomarkArray;//打点数组
@property(nonatomic,strong)NSMutableArray * markButtonArray;//按钮的数组 取坐标
@property(nonatomic,assign)CGFloat markScrubtime;
@property(nonatomic,strong)DWMarkView * markView;//打点视图
@property(nonatomic,strong)UIImageView * arrowImageView;//箭头
@property(nonatomic,assign)CGFloat sliderWidth;
@property(nonatomic,assign)BOOL isShowMarkView;

//**************************** 视频问答 ****************************
@property(nonatomic,strong)NSArray * questionArray;//问答数组
@property(nonatomic,strong)DWQuestionView * questionView;//问题显示
@property(nonatomic,strong)DWFeedBackView * feedBackView;//回答正确或错误
@property(nonatomic,strong)NSMutableArray * questionIdsArray;//问题ID，做统计使用

//**************************** 视频字幕 ****************************
@property(nonatomic,strong)NSMutableArray <DWTableChooseModel *> * subTitleArray;//字幕数组
@property(nonatomic,strong)DWSubtitleView * subtitleView;

//**************************** 授权验证 ****************************
@property (nonatomic,assign)BOOL enable;//能否完整播放;
@property (nonatomic,strong)UILabel * messageLabel;//授权验证提示
@property (nonatomic,strong)DWMessageView * messageView;//试看结束提示

//**************************** gif录制 ****************************
@property (nonatomic,strong)UIView * gifView;
@property (nonatomic,strong)UIButton * gifCancelBtn;//GIF取消按钮
@property (nonatomic,strong)NSTimer * gifTimer;//GIF定时器
@property (nonatomic,assign)CGFloat clipTime;//截取的视频时间
@property (nonatomic,assign)NSInteger gifStartTime;//制作GIF的起始时间
@property (nonatomic,assign)NSInteger gifTotalTime;//制作GIF的总时间
@property (nonatomic,strong)DWGIFManager * gifManager;
@property (nonatomic,strong)MBProgressHUD * gifHud;
@property (nonatomic,assign)BOOL isGIF;
@property (nonatomic,assign)BOOL isFirstClick;
@property (nonatomic,strong)DWToastView * toastView;

//**************************** VR ****************************
@property (nonatomic,strong)UIView * vrView;
@property (nonatomic,strong)DWVRLibrary * vrLibrary;
@property (nonatomic,strong)DWVRConfiguration * config;
@property (nonatomic,assign)DWModeInteractive interative;//交互模式
@property (nonatomic,assign)DWModeDisplay display;//单双屏

//**************************** 访客信息收集器 ****************************
@property (nonatomic,strong)DWVisitorCollectView * visitorCollectView;

//**************************** 课堂练习 ****************************
@property (nonatomic,assign)CGFloat exercisesFrontScrubTime;//记录回退时间
@property (nonatomic,assign)CGFloat exercisesLastScrubTime;//记录当前时间
@property (nonatomic,strong)DWExercisesAlertView * exercisesAlertView;//课堂练习提示View
@property (nonatomic,strong)DWExercisesView * exercisesView;//课堂练习view

//**************************** airPlay ****************************
@property(nonatomic,strong)UILabel * airPlayStatusLabel;

//**************************** ipad PictureInPicture ****************************
@property(nonatomic,strong)AVPictureInPictureController * pipVC;

//@property(nonatomic,strong)UILabel * testLabel;
//@property(nonatomic,strong)NSTimer * testTimer;

//**************************** marquee ****************************
#if __has_include(<HDMarqueeTool/HDMarqueeTool.h>)
@property(nonatomic,strong)HDMarqueeView * marqueeView;
#endif

@end

@implementation DWVodPlayerView

static CGFloat topFuncBgHeight = 39;
static CGFloat bottomFuncBgHeight = 39;
static const CGFloat gifSeconds = 0.25;

-(instancetype)init
{
    if (self == [super init]) {
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;

        self.isFull = NO;
        self.isShowMarkView = NO;
        self.isLock = NO;
        self.isScreening = NO;
        //是否允许后台播放
//        self.allowBackgroundPlay = YES;
        self.allowBackgroundPlay = NO;
        
        //是否开启小窗播放
//        self.openWindowsPlay = YES;

        self.isWindowsPlay = NO;

        //是否开启画中画
        self.allowPictureInPicture = NO;
        
        self.backgroundColor = [UIColor blackColor];
        
        [self initMaskView];
        [self initTopFuncView];
        [self initDownFuncView];
        [self initLeftFuncView];
        [self initPlayerView];
        [self initRadioView];
        [self initFuncGesture];
        [self initAirPlayView];
        [self initPlayerPanGesture];
        
        //初始化时，默认竖屏设置
        [self hideAndClearNotNecessaryView];
        [self reLayoutWithScreenState:self.isFull];
        
        //增加网络状态监听
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];

        //开启远程控制
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self remoteControlEvent];
        
        //增加前后台切换通知
        //回到前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
        // app退到后台
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        //airplay监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wirelessRouteActiveNotification:) name:MPVolumeViewWirelessRouteActiveDidChangeNotification object:nil];
        
//        self.testLabel = [[UILabel alloc]init];
//        self.testLabel.font = [UIFont systemFontOfSize:14];
//        self.testLabel.textColor = [UIColor purpleColor];
//        self.testLabel.textAlignment = NSTextAlignmentLeft;
//        self.testLabel.numberOfLines = 0;
//        [self addSubview:self.testLabel];
//        [self.testLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(@30);
//            make.right.equalTo(@(-30));
//            make.height.equalTo(@50);
//            make.bottom.equalTo(self.bottomFuncBgView.mas_top).offset(-10);
//        }];
//
//        self.testTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(testTimeAction) userInfo:nil repeats:YES];
//        [[NSRunLoop mainRunLoop] addTimer:self.testTimer forMode:NSRunLoopCommonModes];
    }
    return self;
}

//-(void)testTimeAction
//{
//    self.testLabel.text = [NSString stringWithFormat:@"播放时长:%.2fs \n暂停时长:%.2fs",self.playerView.playedTimes,self.playerView.pausedTimes];
//}

-(void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    //移除网络监听
    [self.reachability stopNotifier];
    self.reachability = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPVolumeViewWirelessRouteActiveDidChangeNotification object:nil];
    NSLog(@"DWVodPlayerView dealloc");
}

#pragma mark - public
-(void)setVodVideo:(DWVodVideoModel *)videoModel
{
//    _hud = [MBProgressHUD showHUDAddedTo:self.maskView animated:YES];
//    _hud.label.text = @"努力加载中，请稍后";
    self.downloadModel = nil;
    
    [self showHudWithMessage:@"努力加载中，请稍后"];
    
    self.readyToPlay = NO;
    self.enable = YES;
    self.isSwitchquality = NO;
    
    self.videoModel = videoModel;
    
    [self.playerView playVodViedo:videoModel withCustomId:nil];

    [self play];
        
    //处理视频清晰度数据
    [self dealQualityArray];
    
#if __has_include(<HDMarqueeTool/HDMarqueeTool.h>)
    //开启跑马灯功能
    [self initMarqueeView];
#endif
}

-(void)playLocalVideo:(DWDownloadModel *)downloadModel
{
    self.videoModel = nil;
    
    self.downloadModel  = downloadModel;
    self.enable = YES;
    
    self.readyToPlay = NO;
    
    self.titleLabel.text = [downloadModel.othersInfo objectForKey:@"title"];
    [self.qualityButton setTitle:downloadModel.desp forState:UIControlStateNormal];
    
    [self initVRView];
    
    if ([downloadModel.mediaType isEqualToString:@"1"]) {
        [self changePlayerMediaType:YES];
    }else{
        [self changePlayerMediaType:NO];
    }

    [self.playerView playLocalVideo:downloadModel];
    [self play];
    
#if __has_include(<HDMarqueeTool/HDMarqueeTool.h>)
    //开启跑马灯功能
    [self initMarqueeView];
#endif
}

-(void)reLayoutWithScreenState:(BOOL)isFull
{
    self.isFull = isFull;
    
    [self hideAndClearNotNecessaryView];
    
    [self updateConstraintsAndHidden];
    
#if __has_include(<HDMarqueeTool/HDMarqueeTool.h>)
    if (self.marqueeView) {
        [self.marqueeView startMarquee];
    }
#endif
}

-(void)play
{
    self.playOrPauseButton.selected = YES;
    self.windowsPlayOrPauseButton.selected = self.playOrPauseButton.selected;
    [self.playerView play];
}

-(void)pause
{
    self.playOrPauseButton.selected = NO;
    self.windowsPlayOrPauseButton.selected = self.playOrPauseButton.selected;
    [self.playerView pause];
}

//处理选集数据
-(void)setSelectionList:(NSArray *)selectionList
{
    _selectionList = selectionList;
    
    if (!selectionList) {
        return;
    }
    
    [self.selectionArray removeAllObjects];
    
    for (int i = 0; i < selectionList.count; i++) {
        DWVodModel * vodModel = [selectionList objectAtIndex:i];
        
        DWTableChooseModel * chooseModel = [[DWTableChooseModel alloc]init];
        chooseModel.title = vodModel.title;
        [self.selectionArray addObject:chooseModel];
    }

}

//关闭播放器
-(void)closePlayer
{
//    [self.testTimer invalidate];
//    self.testTimer = nil;
    
    [self destroyFuncTimer];
    
    //清理player
    [self.playerView removeTimer];
    [self.playerView resetPlayer];
    
    //关闭远程控制
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    if (self.config) {
        self.config = nil;
    }
    if (self.vrLibrary) {
        self.vrLibrary = nil;
    }
}

//播放在线视频时，设置文件名
-(void)setVodModel:(DWVodModel *)vodModel
{
    _vodModel = vodModel;
    
    self.titleLabel.text = vodModel.title;
}

-(NSString *)videoTitle
{
    return self.titleLabel.text;
}

#pragma mark - function
//保存videoModel ,并对打点，问答，字幕等功能数据进行处理
-(void)setVideoModel:(DWVodVideoModel *)videoModel
{
    _videoModel = videoModel;
    
    self.titleLabel.text = videoModel.title;
    
    //处理VR
    [self initVRView];
    
    //处理选集数据
    [self dealChooseArray];
    
    //处理视频打点数据
    self.isShowMarkView = NO;
    if (videoModel.videomarks.count) {
        self.videomarkArray = videoModel.videomarks;
    }
    
    //处理问答数据
    self.questionArray = videoModel.questions;
    
    //处理字幕数据
    [self dealSubtitleArray];
    
    //处理授权验证数据
    if (videoModel.authorize) {
        [self dealAuthorizeData];
    }

}

//更新约束和控件状态
-(void)updateConstraintsAndHidden
{
    NSInteger buttonCount = 1;
    if (IS_PAD) {
        buttonCount++;
    }
    
    if (self.isFull) {
        
        self.otherFuncButton.hidden = NO;
        self.speedButton.hidden = NO;
        self.qualityButton.hidden = !self.isVideo;

        if (self.downloadModel) {
            self.chooseButton.hidden = YES;
            self.nextButton.hidden = YES;
        }else{
            self.chooseButton.hidden = NO;
            self.nextButton.hidden = NO;
        }
        self.gifButton.hidden = NO;
        self.disableGesButton.hidden = NO;
        self.screenShotButton.hidden = NO;
        
        //根据状态 切换字幕
        [self switchSubtitleStyle];
        
        if (self.funcTimer) {
            [_topFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.height.equalTo(@(20 + topFuncBgHeight));
            }];
            
            [_bottomFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@0);
                make.height.equalTo(@(self.areaInsets.bottom + bottomFuncBgHeight));
            }];
        }else{
            [_topFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@(-(20 + topFuncBgHeight)));
                make.height.equalTo(@(20 + topFuncBgHeight));
            }];
            
            [_bottomFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@(self.areaInsets.bottom + bottomFuncBgHeight));
                make.height.equalTo(@(self.areaInsets.bottom + bottomFuncBgHeight));
            }];
        }

        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
        
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {

            [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-self.areaInsets.right));
            }];
            
            [_screenShotButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-self.areaInsets.right));
                make.centerY.equalTo(self.mas_centerY).offset(-24);
                make.width.and.height.equalTo(@30);
            }];
            
            [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
            }];
            
        }
        if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {

            [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-10));
            }];
            
            [_screenShotButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-10));
                make.centerY.equalTo(self.mas_centerY).offset(-24);
                make.width.and.height.equalTo(@30);
            }];
            
            [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(self.areaInsets.left));
            }];
            
        }
        
        //本地模式 不显示选集按钮。页面控件做调整
        if (self.isVideo) {
            
            if (self.chooseButton.hidden) {
                [_slider mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 2) - 10 - 5));
                }];
                
                [_speedButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 1) - 10));
                }];
                
                [_qualityButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 0) - 10));
                }];
            }else{
                [_slider mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 3) - 10 - 5));
                }];
                
                [_speedButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 2) - 10));
                }];
                
                [_qualityButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 1) - 10));
                }];
                
                [_chooseButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 0) - 10));
                }];
            }
            
        }else{
            
            if (self.chooseButton.hidden) {
                [_slider mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 1) - 10 - 5));
                }];
                
                [_speedButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 0) - 10));
                }];
            }else{
                [_slider mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 2) - 10 - 5));
                }];
                
                [_speedButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 1) - 10));
                }];
                
                [_chooseButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-(40 * 0) - 10));
                }];
            }
        }
        
        //本地模式 ，不显示下一集按钮
        if (self.nextButton.hidden) {
            [_nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.playOrPauseButton.mas_right);
                make.width.equalTo(@0);
            }];
        }else{
            [_nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.playOrPauseButton.mas_right).offset(5);
                make.width.equalTo(@30);
            }];
        }
        
        //VR
        //此种方法组合可以实现Motion下的正确方向
        if (self.videoModel.vrmode == 1 || self.downloadModel.vrMode) {
            BOOL haveMotion = NO;
            if (_interative ==DWModeInteractiveMotion || _interative ==DWModeInteractiveMotionWithTouch) {
                haveMotion = YES;
            }
            if (haveMotion) {
                [self.vrLibrary switchInteractiveMode:DWModeInteractiveTouch];
                [self.vrLibrary switchInteractiveMode:DWModeInteractiveMotion];
            }
            [self.vrLibrary switchInteractiveMode:_interative];

            [_vrInteractiveButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-(40 * buttonCount) - 10));
            }];

            [_vrDisplayButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-(40 * (buttonCount + 1)) - 10));
            }];
        }
    
    }else{
        self.mediaKindButton.hidden = NO;
        self.screeningButton.hidden = NO;
        self.windowsButton.hidden = NO;
        
        self.rotateScreenButton.hidden = NO;
        //回复锁屏状态
        self.disableGesButton.selected = NO;
        self.screenShotButton.hidden = NO;
        self.isLock = NO;
        //如果正在录制gif ，取消
        if (self.isGIF) {
            [self gifCancelAction];
        }
        
        //隐藏字幕
        if (self.subtitleView) {
            [self.subtitleView switchSubtitleStyle:3];
        }
        
        if (self.funcTimer) {
            [_topFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.height.equalTo(@(self.areaInsets.top + topFuncBgHeight));
            }];
            
            [_bottomFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@0);
                make.height.equalTo(@(bottomFuncBgHeight));
            }];
        }else{
            [_topFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@(-(self.areaInsets.top + topFuncBgHeight)));
                make.height.equalTo(@(self.areaInsets.top + topFuncBgHeight));
            }];
            
            [_bottomFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@(bottomFuncBgHeight));
                make.height.equalTo(@(bottomFuncBgHeight));
            }];
        }

        [_nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playOrPauseButton.mas_right);
            make.width.equalTo(@0);
        }];
        
        [_slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-45));
        }];
        
        if (self.videoModel.vrmode == 1 || self.downloadModel.vrMode) {
            BOOL haveMotion = NO;
            if (_interative == DWModeInteractiveMotion || _interative == DWModeInteractiveMotionWithTouch) {
                haveMotion =YES;
            }
            if (haveMotion) {
                [self.vrLibrary switchInteractiveMode:DWModeInteractiveTouch];
                [self.vrLibrary switchInteractiveMode:DWModeInteractiveMotion];
            }
            [self.vrLibrary switchInteractiveMode:_interative];
            
            [_vrInteractiveButton mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.right.equalTo(@(-(40 * (buttonCount + 1)) - 10));
                make.right.equalTo(@(-(40 * (buttonCount + 2)) - 10));
            }];
            
            [_vrDisplayButton mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.right.equalTo(@(-(40 * (buttonCount + 2)) - 10));
                make.right.equalTo(@(-(40 * (buttonCount + 3)) - 10));
            }];
        }

        [_screenShotButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self);
            make.width.and.height.equalTo(@30);
        }];
    }
    
    //访客信息收集器
    if (self.visitorCollectView) {
        [self.visitorCollectView screenRotate:self.isFull];
    }

    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    //获取到真实位置后，重置进度条位置
    [self.slider resetSubViewFrame];
}

//清理和隐藏页面控件
-(void)hideAndClearNotNecessaryView
{
    //top
    self.mediaKindButton.hidden = YES;
    self.otherFuncButton.hidden = YES;
    self.screeningButton.hidden = YES;
    self.windowsButton.hidden = YES;
    
    //bottom
    self.nextButton.hidden = YES;
    self.speedButton.hidden = YES;
    self.qualityButton.hidden = YES;
    self.chooseButton.hidden = YES;
    self.rotateScreenButton.hidden = YES;

    //left
    self.gifButton.hidden = YES;
    self.disableGesButton.hidden = YES;
    self.screenShotButton.hidden = YES;
    
    //打点视图隐藏
    self.isShowMarkView = NO;
    [self showOrHiddenMarkView:YES];
    if (self.videomarkArray && self.videomarkArray.count) {
        //有打点数据
        [self dealMarkArray:self.videomarkArray];
    }
}

//处理清晰度数据
-(void)dealQualityArray
{
    [self.qualityArray removeAllObjects];
    
    if (!self.videoModel.videoQualities || self.videoModel.videoQualities.count == 0) {
        //无视频清晰度
        [self changePlayerMediaType:NO];
    }else if (!self.videoModel.radioQualities || self.videoModel.radioQualities.count == 0){
        //无音频清晰度
        [self changePlayerMediaType:YES];
    }else{
        [self changePlayerMediaType:YES];
    }
    
    for (DWVideoQualityModel * quality in self.videoModel.videoQualities) {
        DWTableChooseModel * chooseModel = [[DWTableChooseModel alloc]init];
        chooseModel.title = quality.desp;
        if ([quality.quality isEqualToString:self.playerView.qualityModel.quality]) {
            chooseModel.isSelect = YES;
        }else{
            chooseModel.isSelect = NO;
        }
        [self.qualityArray addObject:chooseModel];
    }
    
    [self.qualityButton setTitle:self.playerView.qualityModel.desp forState:UIControlStateNormal];
}

//处理选集默认数据
-(void)dealChooseArray
{
    if (self.selectionArray.count == 0) {
        return;
    }
    
    for (int i = 0; i < self.selectionList.count; i++) {
        DWTableChooseModel * chooseModel = [self.selectionArray objectAtIndex:i];
        //这里应该是拿videoId做判断
        DWVodModel * vodModel = [self.selectionList objectAtIndex:i];
        if ([vodModel.videoId isEqualToString:self.videoModel.videoId]) {
            chooseModel.isSelect = YES;
        }else{
            chooseModel.isSelect = NO;
        }
    }
}

//切换页面播放模式
-(void)changePlayerMediaType:(BOOL)isVideo
{
    self.mediaKindButton.selected = !isVideo;
    self.isVideo = isVideo;
    if (self.isVideo) {
        self.radioBgView.hidden = YES;
        if (self.videoModel.vrmode == 1 || self.downloadModel.vrMode) {
            self.vrView.hidden = NO;
        }else{
            self.playerView.hidden = NO;
        }
    }else{
        self.radioBgView.hidden = NO;
        self.playerView.hidden = YES;
    }
    
    //清理视频打点数据
    if (self.videomarkArray && self.videomarkArray.count) {
        [self dealMarkArray:self.videoModel.videomarks];
    }
    
    //取消gif录制
    if (self.isGIF) {
        [self gifCancelAction];
    }
    
    if (self.isFull) {
        self.qualityButton.hidden = !self.isVideo;
        if (self.isVideo) {
            //显示清晰度按钮
            [_slider mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-(40 * 3) - 10 - 5));
            }];
            
            [_speedButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-(40 * 2) - 10));
            }];
        }else{
            //隐藏清晰度按钮
            [_slider mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-(40 * 2) - 10 - 5));
            }];
            
            [_speedButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@(-(40 * 1) - 10));
            }];
        }
    }
 
}

//切换清晰度
-(void)switchQuality:(DWVideoQualityModel *)qualityModel
{
    if (!qualityModel) {
        [_hud hideAnimated:NO];
        [@"暂未找到当前清晰度，请检查数据" showAlert];
        return;
    }
    
    self.readyToPlay = NO;
    
    //如果VR视图存在，需要重新创建
    if (self.vrView) {
        [self.vrView removeFromSuperview];
        self.vrView = nil;
    }
    [self initVRView];
    
    if ([qualityModel.mediaType isEqualToString:@"1"] && !self.isVideo) {
        [self changePlayerMediaType:YES];
    }else if ([qualityModel.mediaType isEqualToString:@"2"] && self.isVideo) {
        [self changePlayerMediaType:NO];
    }
    
    //修改当前清晰度
    if (self.isVideo) {
        NSInteger selectIndex = [self.videoModel.videoQualities indexOfObject:qualityModel];
        DWTableChooseModel * chooseModel = [self.qualityArray objectAtIndex:selectIndex];
        if (!chooseModel.isSelect) {
            for (DWTableChooseModel * chooseModel in self.qualityArray) {
                if (chooseModel.isSelect) {
                    chooseModel.isSelect = NO;
                    break;
                }
            }
        }
        chooseModel.isSelect = YES;
    }
    
    //清理默认值
    self.currentLabel.text = @"00:00";
    self.totalLabel.text = @"00:00";
    self.slider.value = 0;
    self.slider.bufferValue = 0;
    self.isSwitchquality = YES;
    self.switchTime = CMTimeGetSeconds([self.playerView.player currentTime]);
    
    [self pause];

//    _hud = [MBProgressHUD showHUDAddedTo:self.maskView animated:YES];
//    _hud.label.text = @"切换清晰度，请稍后";
    [self showHudWithMessage:@"切换中..."];
    
//    self.currentQualityModel = qualityModel;
    
    [self.qualityButton setTitle:qualityModel.desp forState:UIControlStateNormal];
    [self.playerView switchQuality:qualityModel withCustomId:nil];
    
    //如果播放加密视频时,SDK解密服务需要一定的时间启动，这里延迟执行play。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self play];
    });
//    [self play];
}

-(void)showHudWithMessage:(NSString *)message
{
    if (_hud) {
        [_hud hideAnimated:NO];
        self.hud = nil;
    }
    _hud = [MBProgressHUD showHUDAddedTo:self.maskView animated:YES];
    _hud.label.text = message;
}

-(void)hideHudWithMessage:(NSString *)message
{
    if (_hud) {
        if (message) {
            _hud.label.text = message;
            [_hud hideAnimated:YES afterDelay:2];
        }else{
            [_hud hideAnimated:YES];
        }
    }
    self.hud = nil;
}

//记忆播放
-(void)saveNsUserDefaults
{
    if (!self.videoModel && !self.downloadModel) {
        return;
    }
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * playTime = [NSNumber numberWithFloat:CMTimeGetSeconds([self.playerView.player currentTime])];
    if (self.videoModel) {
        [userDefaults setValue:playTime forKey:self.videoModel.videoId];
    }else{
        [userDefaults setValue:playTime forKey:self.downloadModel.filePath];
    }
    [userDefaults synchronize];
}

-(void)readNSUserDefaults
{
    if (!self.videoModel && !self.downloadModel) {
        return;
    }
    
    CGFloat playTime = 0;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    id saveTime = nil;
    if (self.videoModel) {
        saveTime = [userDefaults objectForKey:self.videoModel.videoId];
    }else{
        saveTime = [userDefaults objectForKey:self.downloadModel.filePath];
    }
    if ([saveTime isKindOfClass:[NSDictionary class]]) {
        //旧版本存储的播放数据
        playTime = [[saveTime objectForKey:@"playbackTime"] floatValue];
    }else{
        playTime = [saveTime floatValue];
    }
    
    //若不考虑旧版本的兼容性问题，这里直接获取即可
//    if (self.videoModel) {
//        playTime = [[userDefaults objectForKey:self.videoModel.videoId] floatValue];
//    }else{
//        playTime = [[userDefaults objectForKey:self.downloadModel.filePath] floatValue];
//    }
    
    self.switchTime = playTime;
}

//切换备用线路
-(void)switchSparLine
{
    if (self.playerView.isSpar) {
        [@"当前已经是备用线路了" showAlert];
        return;
    }
    
    [self showHudWithMessage:@"切换线路中，请稍后"];
    
    //记录当前播放到的时间
    if (!CMTimeCompare(self.playerView.player.currentTime, kCMTimeZero)) {
        self.switchTime = CMTimeGetSeconds([self.playerView.player currentTime]);
    }
    
    [self.playerView switchSparPlayLine];
    
}

-(void)startDownloadTask:(DWVodVideoModel *)vodVideo
{
    DWVideoQualityModel * qualitiyModel = self.playerView.qualityModel;
    
    DWDownloadSessionManager * manager = [DWDownloadSessionManager manager];
    //验证当前任务是否已经在下载队列中
    if ([manager checkLocalResourceWithVideoId:self.videoModel.videoId WithQuality:qualitiyModel.quality]) {
        [@"当前任务已经在下载队列中" showAlert];
        return;
    }
    
    NSString * imageUrl = nil;
    NSString * title = @"";
    if (self.vodModel) {
        imageUrl = self.vodModel.imageUrl;
        title = self.vodModel.title;
    }else{
        imageUrl = @"icon_placeholder.png";
    }
    
    DWDownloadModel * model = [DWDownloadSessionManager createDownloadModel:vodVideo Quality:qualitiyModel.quality AndOthersInfo:@{@"imageUrl":imageUrl,@"title":title}];
    
    if (!model) {
        [@"DownloadModel创建失败，请检查参数" showAlert];
        return;
    }
    
    [manager startWithDownloadModel:model];
    
    [[NSString stringWithFormat:@"开始下载：%@",vodVideo.title] showAlert];
}

#pragma mark - func Timer
-(void)initFuncGesture
{
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(funcIsAppearTap)];
    [self addGestureRecognizer:self.tap];

    [self createFuncTimer];
}

-(void)funcIsAppearTap
{
    //新增判断，画中画启动时，不显示状态栏
    if (self.pipVC && self.pipVC.isPictureInPictureActive) {
        return;
    }
    
    if (self.funcTimer) {
        self.isShowMarkView = NO;
        [self destroyFuncTimer];
    }else{
        [self createFuncTimer];
    }
}

//func timer 相关
-(void)createFuncTimer
{
    self.funcSecond = 4;
    
    if (self.funcTimer) {
        [self.funcTimer invalidate];
        self.funcTimer = nil;
    }
    
    self.funcTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(funcTimerAction) userInfo:nil repeats:YES];
    
    [self funcBgViewIsAppear:YES];
}

-(void)destroyFuncTimer
{
    if (self.funcTimer) {
        [self.funcTimer invalidate];
        self.funcTimer = nil;
    }
    
    [self funcBgViewIsAppear:NO];
}

-(void)funcTimerAction
{
    if (self.funcSecond == 0) {
        [self destroyFuncTimer];
        return;
    }
    
    self.funcSecond--;
}

-(void)funcBgViewIsAppear:(BOOL)appear
{
    CGFloat topHeight = self.isFull ? 20 + topFuncBgHeight : self.areaInsets.top + topFuncBgHeight;
    CGFloat bottomHeight = self.isFull ? self.areaInsets.bottom + bottomFuncBgHeight : bottomFuncBgHeight;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    if (self.isLock) {
        [_topFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(-topHeight));
            make.height.equalTo(@(topHeight));
        }];
        
        [_bottomFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@(bottomHeight));
            make.height.equalTo(@(bottomHeight));
        }];
        
        if (appear) {
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                
                [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(ScreenWidth + self.areaInsets.right + 30));
                }];
                
                [_screenShotButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(ScreenWidth + self.areaInsets.right + 30));
                }];
                
                [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@10);
                }];
            
            }
            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(10 + 30));
                }];
                
                [_screenShotButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(10 + 30));
                }];

                [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@(self.areaInsets.left));
                }];
         
            }
        }else{
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                
                [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(ScreenWidth + self.areaInsets.right + 30));
                }];
                
                [_screenShotButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(ScreenWidth + self.areaInsets.right + 30));
                }];
                
                [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@(-10 - 30));
                }];
            
            }
            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                
                [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(10 + 30));
                }];
                
                [_screenShotButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(10 + 30));
                }];
                
                [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@(-self.areaInsets.left - 30));
                }];
        
            }
        }
    }else{
        if (appear) {
            if (self.topFuncBgView.frame.origin.y == 0) {
                return;
            }
            
            if (self.isGIF) {
                return;
            }
            
            [_topFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.height.equalTo(@(topHeight));
            }];
            
            [_bottomFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@0);
                make.height.equalTo(@(bottomHeight));
            }];
            
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                
                [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-self.areaInsets.right));
                }];
                
                [_screenShotButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-self.areaInsets.right));
                }];
            
                [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@10);
                }];
                
            }
            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                
                [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-10));
                }];
                
                [_screenShotButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(-10));
                }];
                
                [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@(self.areaInsets.left));
                }];

            }
            
            if (self.isShowMarkView && self.isFull) {
                [self showOrHiddenMarkView:NO];
            }else{
                [self showOrHiddenMarkView:YES];
            }
            
        }else{
            if (self.topFuncBgView.frame.origin.y == -self.topFuncBgView.frame.size.height) {
                return;
            }
 
            [_topFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@(-topHeight));
                make.height.equalTo(@(topHeight));
            }];
            
            [_bottomFuncBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@(bottomHeight));
                make.height.equalTo(@(bottomHeight));
            }];

            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                
                if (!self.isGIF) {
                    //如果正在录制gif ，按钮不动
                    [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(@(ScreenWidth + self.areaInsets.right + 30));
                    }];
                }
                
                [_screenShotButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(ScreenWidth + self.areaInsets.right + 30));
                }];
         
                [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@(-10 - 30));
                }];
      
            }
            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                
                if (!self.isGIF) {
                    [_gifButton mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(@(10 + 30));
                    }];
                }
                
                [_screenShotButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(@(10 + 30));
                }];
                
                [_disableGesButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@(-self.areaInsets.left - 30));
                }];
    
            }
            
            [self showOrHiddenMarkView:YES];
        }
    }
    
    [UIView animateWithDuration:0.33 animations:^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}

#pragma mark - windowsPlay
//进入窗口模式
-(void)enterWindowsModel
{
//    if (!self.openWindowsPlay) {
//        return;
//    }
    
    self.isWindowsPlay = YES;
    
    [DWAPPDELEGATE.vodPlayerView removeFromSuperview];
    [DWAPPDELEGATE.window addSubview:DWAPPDELEGATE.vodPlayerView];
    
    [DWAPPDELEGATE.vodPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.bottom.equalTo(@(-134 - self.areaInsets.bottom));
        make.width.equalTo(@200);
        make.height.equalTo(@(112.5));
    }];
    
    //窗口模式拖拽手势
    self.windowsPan =  [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(windowsPanGestureTap)];
    [self addGestureRecognizer:self.windowsPan];
    
    //取消原view手势
    [self removeGestureRecognizer:self.tap];
    [self removeGestureRecognizer:self.pan];
    self.pan.vodPanDelegate = nil;
    
    //修改原view按钮，定时器等
    [self destroyFuncTimer];
    self.topFuncBgView.hidden = YES;
    self.bottomFuncBgView.hidden = YES;
    self.gifButton.hidden = YES;
    self.disableGesButton.hidden = YES;
    self.windowsButton.hidden = YES;
    self.screenShotButton.hidden = YES;

    self.windowsCloseButton.hidden = NO;
    self.windowsPlayOrPauseButton.hidden = NO;
    self.windowsResumeButton.hidden = NO;

    
}

//退出窗口模式
-(void)quitWindowsModel
{
//    if (!self.openWindowsPlay) {
//        return;
//    }
    
    self.isWindowsPlay = NO;

    [DWAPPDELEGATE.vodPlayerView removeFromSuperview];
    
    [self removeGestureRecognizer:self.windowsPan];
    
    [self initFuncGesture];
    [self initPlayerPanGesture];
    
    self.topFuncBgView.hidden = NO;
    self.bottomFuncBgView.hidden = NO;
    self.windowsButton.hidden = NO;
    self.screenShotButton.hidden = NO;
    [self reLayoutWithScreenState:NO];
    
    self.windowsCloseButton.hidden = YES;
    self.windowsPlayOrPauseButton.hidden = YES;
    self.windowsResumeButton.hidden = YES;
    
    //处理选集数据
    [self dealChooseArray];
    
#if __has_include(<HDMarqueeTool/HDMarqueeTool.h>)
    //开启跑马灯功能
    [self initMarqueeView];
#endif
        
}

//处理拖拽事件
-(void)windowsPanGestureTap
{
    CGPoint position = [self.windowsPan translationInView:self.windowsPan.view];
    
    switch (self.windowsPan.state) {
        case UIGestureRecognizerStateBegan:
        {
//            self.transform = CGAffineTransformScale(self.transform, 0, 0);
//            NSLog(@"UIGestureRecognizerStateBegan : %@",NSStringFromCGPoint(position));
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
//            NSLog(@"UIGestureRecognizerStateChanged : %@",NSStringFromCGPoint(position));
            
            self.transform = CGAffineTransformMakeTranslation(position.x, position.y);
//            CGAffineTransformTranslate(self.transform, position.x, position.y);
 
//            NSLog(@"UIGestureRecognizerStateChanged : %@",NSStringFromCGRect(self.frame));
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
//            NSLog(@"UIGestureRecognizerStateEnded : %@",NSStringFromCGPoint(position));
            
//            NSLog(@"UIGestureRecognizerStateEnded : %@",NSStringFromCGRect(self.frame));
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(self.frame.origin.x));
                make.top.equalTo(@(self.frame.origin.y));
                make.width.equalTo(@(self.frame.size.width));
                make.height.equalTo(@(self.frame.size.height));
            }];
            
            self.transform = CGAffineTransformIdentity;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
            break;
        default:
            break;
    }
}

//触发功能弹窗时，发送通知
/// @param landSpace 页面是否需要横屏显示
-(void)sendWindowsFuncNotification:(BOOL)landSpace
{
    if (!self.isWindowsPlay) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:DWVODPLAYERRESUMEEVENTNOTIFICATION object:[NSNumber numberWithBool:landSpace]];
}

-(void)windowsCloseButtonAction
{
    [self saveNsUserDefaults];

    [self removeFromSuperview];
    [self closePlayer];
    DWAPPDELEGATE.vodPlayerView = nil;
    
}

-(void)windowsPlayOrPauseButtonAction
{
    if (self.windowsPlayOrPauseButton.selected) {
        [self pause];
    }else{
        [self play];
    }
}

-(void)windowsResumeButtonAction
{
    [self sendWindowsFuncNotification:NO];
}

#pragma mark - action
//顶部
-(void)backButtonAction
{
    if (!self.isFull) {
        [self saveNsUserDefaults];
    }
    
    if ([_delegate respondsToSelector:@selector(vodPlayerView:ReturnBackAction:)]) {
        [_delegate vodPlayerView:self ReturnBackAction:self.isFull];
    }
}

//切换播放媒体类型
-(void)mediaKindButtonAction
{
    //下载视频 ，直接return
    if (self.downloadModel) {
        [@"暂无其他播放模式" showAlert];
        return;
    }
    
    if (self.isVideo) {
        if (!self.videoModel.radioQualities || self.videoModel.radioQualities.count == 0) {
            [@"暂无音频格式" showAlert];
            return;
        }
    }
    
    if (!self.isVideo) {
        if (!self.videoModel.videoQualities || self.videoModel.videoQualities.count == 0) {
            [@"暂无视频格式" showAlert];
            return;
        }
    }
    
    [self changePlayerMediaType:!self.isVideo];
    
    //切换播放数据
    DWVideoQualityModel * playQualityModel = nil;
    if (self.isVideo) {
        playQualityModel = self.videoModel.videoQualities.firstObject;
    }else{
        playQualityModel = self.videoModel.radioQualities.firstObject;
    }
    
    //切换清晰度默认值
    [self switchQuality:playQualityModel];
}

//VR设置
-(void)vrInteractiveButtonAction
{
    self.vrInteractiveButton.selected = !self.vrInteractiveButton.selected;
    if (self.vrInteractiveButton.selected) {
        [self.vrLibrary switchInteractiveMode:DWModeInteractiveTouch];
        _interative = DWModeInteractiveTouch;
    }else{
        [self.vrLibrary switchInteractiveMode:DWModeInteractiveMotion];
        _interative = DWModeInteractiveMotion;
    }
}

-(void)vrDisplayButtonAction
{
    self.vrDisplayButton.selected = !self.vrDisplayButton.selected;
    if (self.vrDisplayButton.selected) {
        [self.vrLibrary switchDisplayMode:DWModeDisplayGlass];
        _display = DWModeDisplayGlass;
    }else{
        [self.vrLibrary switchDisplayMode:DWModeDisplayNormal];
        _display = DWModeDisplayNormal;
    }
}

-(void)screeningButtonAction
{
    [self pause];
    
    if ([self.delegate respondsToSelector:@selector(vodPlayerView:ScreeningJumpAction:)]) {
        [self.delegate vodPlayerView:self ScreeningJumpAction:self.playerView.qualityModel.playUrl];
    }
}

//其他设置
-(void)otherFuncButtonAction
{
    self.settingView = [[DWPlayerSettingView alloc]initWithStyle:DWVodSettingStyleTotal];
    self.settingView.delegate = self;
    [self.settingView setTotalMediaType:self.isVideo SizeList:self.sizeArray SubtitleList:self.subTitleArray DefaultLight:self.screenLight AndDefaultSound:self.systemSound];
    [self.settingView show];
}

//开启画中画
-(void)pipButtonAction
{
    /*
     注意：
     如果要启用画中画功能，请务必设置DWPlayerView对象下列方法值为YES，允许播放器进行后台播放。否则程序进入后台时，可能无法播放视频。
     - (void)setPlayInBackground:(BOOL)play;
     */
  
    if (![AVPictureInPictureController isPictureInPictureSupported]) {
        [@"设备不支持画中画功能" showAlert];
        return;
    }
    
    if (!self.pipVC) {
        return;
    }
    
    if (self.pipVC.isPictureInPictureActive) {
        [self.pipVC stopPictureInPicture];
    }else{
        [self.pipVC startPictureInPicture];
    }
}

-(void)windowsButtonAction
{
    //VR视频无法窗口播放
    if (self.videoModel.vrmode == 1 || self.downloadModel.vrMode) {
        [@"暂不支持VR视频窗口播放" showAlert];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(vodPlayerViewDidEnterWindowsModel:)]) {
        [self.delegate vodPlayerViewDidEnterWindowsModel:self];
    }
}

//播放/暂停
-(void)playOrPauseButtonAction
{
    if (self.playOrPauseButton.selected) {
        [self pause];
    }else{
        [self play];
    }
    
    if ([_delegate respondsToSelector:@selector(vodPlayerView:PlayStatus:)]) {
        [_delegate vodPlayerView:self PlayStatus:self.playerView.playing];
    }

}

//下一集
-(void)nextButtonAction
{
    if (self.selectionArray.count == 0) {
        [@"暂无下一集" showAlert];
        return;
    }
    
    DWTableChooseModel * lastModel = self.selectionArray.lastObject;
    if (lastModel.isSelect) {
        [@"最后一集啦" showAlert];
        return;
    }
    
    //获取当前播放集数
    __weak typeof(self) weakSelf = self;
    [self.selectionArray enumerateObjectsUsingBlock:^(DWTableChooseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            *stop = YES;
            //播放下一集
            if ([weakSelf.delegate respondsToSelector:@selector(vodPlayerView:NextSelection:)]) {
                [weakSelf.delegate vodPlayerView:weakSelf NextSelection:idx + 1];
            }
        }
    }];
}

//进度条拖拽相关
-(void)sliderMovingAction
{
    if (!self.readyToPlay) {
        return;
    }
    
    self.isSlidering = YES;
}

-(void)sliderBeganAction
{
    if (!self.readyToPlay) {
        return;
    }
    
    CGFloat durationInSeconds = CMTimeGetSeconds(self.playerView.player.currentItem.duration);
    self.exercisesFrontScrubTime = durationInSeconds * self.slider.value;
    
    self.isSlidering = YES;
}

-(void)sliderEndedAction
{
    //未加载完成，不触发拖拽事件
    if (!self.readyToPlay) {
        self.isSlidering = NO;
        return;
    }
    
    CGFloat durationInSeconds = CMTimeGetSeconds(self.playerView.player.currentItem.duration);
    CGFloat time = durationInSeconds * self.slider.value;
    
    //授权验证功能
    if (!self.enable) {
        NSInteger freetime = self.videoModel.authorize.freetime;
        if (time > freetime) {
            time = freetime;
        }
    }
    
    self.exercisesLastScrubTime = time;
    
    //拖拽时，视频问答逻辑
    for (DWVideoQuestionModel *questionModel in self.questionArray) {
        if (questionModel.isShow && !questionModel.jump && time > questionModel.showTime) {
            time = questionModel.showTime;
            break;
        }
        
    }
    
    //解决弱网下，拖拽可能会引起音画不同步的问题
    [self pause];
    
    __weak typeof(self) weakSelf = self;
    [self.playerView scrubPrecise:time CompletionHandler:^(BOOL finished) {
        weakSelf.isSlidering = NO;
        
        if (![weakSelf haveUnansweredExercises:weakSelf.exercisesFrontScrubTime AndLastTime:weakSelf.exercisesLastScrubTime]) {
            weakSelf.exercisesFrontScrubTime = -1;
            weakSelf.exercisesLastScrubTime = -1;
        }
        
        if (_questionView || weakSelf.visitorCollectView || weakSelf.exercisesAlertView || weakSelf.exercisesView) {
            return;
        }
        
        [self play];
    }];
        
}

//速率选择
-(void)speedButtonAction
{
    self.settingView = [[DWPlayerSettingView alloc]initWithStyle:DWVodSettingStyleListSpeed];
    self.settingView.delegate = self;
    [self.settingView setTableList:self.speedArray];
    [self.settingView show];
}

//清晰度选择
-(void)qualityButtonAction
{
    if (self.qualityArray.count == 0) {
        [@"无清晰度" showAlert];
        return;
    }
    
    self.settingView = [[DWPlayerSettingView alloc]initWithStyle:DWVodSettingStyleListQuality];
    self.settingView.delegate = self;
    [self.settingView setTableList:self.qualityArray];
    [self.settingView show];
}

//选集
-(void)chooseButtonAction
{
    if (self.selectionArray.count == 0) {
        [@"无选集列表" showAlert];
        return;
    }
    
    self.settingView = [[DWPlayerSettingView alloc]initWithStyle:DWVodSettingStyleListChooseSelection];
    self.settingView.selectionList = self.selectionList;
    self.settingView.delegate = self;
    [self.settingView setTableList:self.selectionArray];
    [self.settingView show];
}

//转屏
-(void)rotateScreenButtonAction
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
}

//手势禁用
-(void)disableGesButtonAction
{
    self.disableGesButton.selected = !self.disableGesButton.selected;
    
    self.isLock = self.disableGesButton.selected;
    if (self.disableGesButton.selected) {
        //锁屏
        [self destroyFuncTimer];
    }else{
        //非锁屏
        [self createFuncTimer];
    }
}

-(void)setIsLock:(BOOL)isLock
{
    _isLock = isLock;
    
    //锁屏时，禁用拖拽手势
    self.pan.canResponse = !_isLock;
}

//截屏
-(void)screenShotButtonAction
{
    if (!self.readyToPlay) {
        return;
    }
    
    UIImage * image = [self.playerView screenShot];
    ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if (error) {
            [error.localizedDescription showAlert];
            return;
        }
        
        [@"截图已保存" showAlert];
    }];

}

#pragma mark - 网络状态改变
-(void)networkStateChange
{
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    switch (status) {
        case NotReachable:{
            if (self.videoModel) {
                [@"暂无网络" showAlert];
            }
            break;
        }
            
        case ReachableViaWiFi:{
            [@"切换到wi-fi网络" showAlert];
            if (self.videoModel) {
                //切换到wifi  继续播放
                if (self.isScreening) {
                    return;
                }
                
                if (self.playOrPauseButton.selected) {
                    [self play];
                }
            }
        
            break;
        }
        case ReachableViaWWAN:{
            [@"切换到4g网络，暂停播放" showAlert];
            
            if (self.videoModel) {
                if (self.playerView.playing) {
                    [self pause];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - 快进/快退
-(void)playerPanHandleEnd:(CGFloat)sliderProgress
{
    self.slider.value = sliderProgress;
    
    [self sliderEndedAction];
}

#pragma mark - 前后台切换
-(void)enterForegroundNotification
{
    //投屏时，禁止播放
    if (self.isScreening) {
        return;
    }
    
    if (_questionView || self.visitorCollectView || self.exercisesAlertView || self.exercisesView) {
        return;
    }
    
}

-(void)didEnterBackgroundNotification
{
    if (!self.allowBackgroundPlay) {
        [self pause];
    }
}

-(void)wirelessRouteActiveNotification:(NSNotification *)noti
{
    MPVolumeView * volumeView = (MPVolumeView *)noti.object;
    self.airPlayStatusLabel.hidden = !volumeView.wirelessRouteActive;
    if (!self.airPlayStatusLabel.hidden) {
        [self play];
    }
}

#pragma mark - 远程控制
//远程控制
-(void)remoteControlEvent
{
    //这里可以根据自己的业务需求，修改，此处只是简单的示范
    __weak typeof(self) weakSelf = self;
    MPRemoteCommandCenter * commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.playCommand.enabled = YES;
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
//        if (!weakSelf.playerView.playing) {
            [weakSelf play];
//        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    
    commandCenter.pauseCommand.enabled = YES;
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
//        if (weakSelf.playerView.playing) {
            [weakSelf pause];
//        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}


#pragma mark - 视频打点功能
//处理视频打点数据
-(void)dealMarkArray:(NSArray <DWVideoMarkModel *>*)videomarks
{
    //!!!demo中，只有横屏会显示打点，这里frame只是示例，自己项目根据业务需求做调整
    if (self.isFull && self.isVideo) {
        
        [videomarks enumerateObjectsUsingBlock:^(DWVideoMarkModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat duration = CMTimeGetSeconds([self.playerView.player.currentItem duration]);
            CGFloat sliderWidth = self.sliderWidth;
            NSNumber *number = [NSNumber numberWithFloat:obj.marktime / duration * sliderWidth];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake([number integerValue],(30-2)/2,5,2);
            button.layer.cornerRadius =1;
            button.layer.masksToBounds =YES;
            button.backgroundColor = [UIColor clearColor];
            [button setBackgroundImage:[[UIColor whiteColor] createImageWithSize:CGSizeMake(5, 5)] forState:UIControlStateNormal];
            [self.slider addSubview:button];
            [self.markButtonArray addObject:button];
        }];
        
    }else{
        for (UIButton * markButton in self.markButtonArray) {
            [markButton removeFromSuperview];
        }
        [self.markButtonArray removeAllObjects];
    }
}

-(void)showOrHiddenMarkView:(BOOL)isHidden
{
    self.markView.hidden = isHidden;
    self.arrowImageView.hidden = isHidden;
}

- (void)showVideoMarkCurrentValue:(CGFloat )currentValue videoDuration:(CGFloat )duration
{
    
    NSNumber *number =[NSNumber numberWithFloat:currentValue * duration];
    NSInteger integer =[number integerValue];
    
    __weak typeof(self) weakSelf = self;
    [self.videomarkArray enumerateObjectsUsingBlock:^(DWVideoMarkModel *markModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //根据打点时间设置取值范围
        if (integer >= markModel.marktime - 6 && integer <= markModel.marktime + 6) {
            
            *stop =YES;
            weakSelf.markView.markModel =markModel;
            CGFloat width = weakSelf.markView.width;
            UIButton *button = weakSelf.markButtonArray[idx];
            CGRect frame = [button convertRect:button.bounds toView:self];
            
            //防止 markView 超出屏幕外
            CGFloat markViewLeft = frame.origin.x+2.5 - width/2;
            if (markViewLeft < 0) {
                markViewLeft = 0;
            }
            if (markViewLeft + width > weakSelf.frame.size.width) {
                markViewLeft = weakSelf.frame.size.width - width;
            }
            weakSelf.markView.frame = CGRectMake(markViewLeft, ScreenHeight-77/2-50,width,30);
            weakSelf.arrowImageView.frame = CGRectMake(frame.origin.x+2.5 -17/2, CGRectGetMaxY(self.markView.frame), 34/2, 15/2);
            
            [weakSelf showOrHiddenMarkView:NO];
            
            weakSelf.markScrubtime =markModel.marktime;
        }
        
    }];
    
}

//markView的tap方法
- (void)markViewTapAction:(UITapGestureRecognizer *)tap
{
    [self showOrHiddenMarkView:YES];
    self.isShowMarkView = NO;
    [self.playerView scrub:_markScrubtime];
    //为了防止打点播放后  视频进度条不走
    self.isSlidering =NO;
}

//视频打点
- (void)tapOfVideoMarkAction:(UITapGestureRecognizer *)tap
{
    if (!self.isFull) {
        return;
    }
    
    self.isShowMarkView = YES;
    
    CGPoint point = [tap locationInView:self.slider];
    CGFloat tapValue = point.x / self.sliderWidth;
    //视频总时长
    CGFloat duration = CMTimeGetSeconds([self.playerView.player.currentItem duration]);
    [self showVideoMarkCurrentValue:tapValue videoDuration:duration];
}

#pragma mark - 视频问答功能
- (void)showQuestionsView:(float)time
{
    for (DWVideoQuestionModel * questionModel in self.questionArray) {
        
        if (questionModel.showTime <= (NSInteger)time && questionModel.isShow) {
                        
            if (_questionView) {
                break;
            }

            [self sendWindowsFuncNotification:NO];
            
            [self destroyFuncTimer];
            
            [self.playerView scrub:questionModel.showTime];
            [self pause];//暂停
            self.questionView.questionModel = questionModel;
            
            WeakSelf(self);
            [self.questionView didQuestionBlock:^(NSMutableArray *answerIdsArray,BOOL right) {
                StrongSelf(self);
                
                [self showFeedBackView:questionModel withRight:right];
                
                //如果没有发送过 则发送一次统计
                if (![self.questionIdsArray containsObject:questionModel.questionId]) {
                    //发送问答统计(有此需求的客户调用 且每次播放只发送一次) 用户选择的选项ID，以逗号分隔多个选项ID 如1345是单选 2067,3092,4789是多选
                    [self.playerView reportQuestionWithVideoId:self.videoModel.videoId questionId:questionModel.questionId answerId:[answerIdsArray componentsJoinedByString:@","] status:right];
                    //放入数组
                    [self.questionIdsArray addObject:questionModel.questionId];
                }
                
            }];
            
            [self.questionView didSkipBlock:^{
                
                StrongSelf(self);
                [self resumeVideoPlay];
                
            }];
            
            break;
        }
        
    }
    
}

- (void)showFeedBackView:(DWVideoQuestionModel *)model withRight:(BOOL )right
{
    //视频问答修改流程
    model.isShow = !right;
    
    self.feedBackView =[[DWFeedBackView alloc]initWithFrame:CGRectMake(0,0,ScreenWidth,ScreenHeight)];
    [self.questionView addSubview:self.feedBackView];
    [self.feedBackView showResult:model withRight:right];
    WeakSelf(self);
    
    self.feedBackView.backBlock = ^{
        StrongSelf(self);
        [self removeQuestionAndFeedBackView];
        [self.playerView scrub:model.backSecond];
        [self play];
    };
    
    self.feedBackView.resumeBlock = ^{
        StrongSelf(self);
        [self resumeVideoPlay];
    };
    
}

- (void)resumeVideoPlay
{
    [self play];//播放
    [self removeQuestionAndFeedBackView];
}

- (void)removeQuestionAndFeedBackView
{
    [self.feedBackView removeFromSuperview];
    [self.questionView removeFromSuperview];
    self.feedBackView =nil;
    self.questionView =nil;
}

#pragma mark - 视频字幕功能
//处理字幕数据
-(void)dealSubtitleArray
{
    [self.subTitleArray removeAllObjects];
    
    if (!self.videoModel.subtitle && !self.videoModel.subtitle2) {
        //无字幕
        DWTableChooseModel * chooseModel = [[DWTableChooseModel alloc]init];
        chooseModel.title = @"无字幕";
        chooseModel.isSelect = YES;
        [self.subTitleArray addObject:chooseModel];
    }else if (self.videoModel.subtitle && self.videoModel.subtitle2) {
        //双语字幕
        NSArray * titles = @[@"双语",self.videoModel.subtitle.subtitleName,self.videoModel.subtitle2.subtitleName,@"关闭字幕"];
        [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DWTableChooseModel * chooseModel = [[DWTableChooseModel alloc]init];
            chooseModel.title = obj;
            if (idx == 0) {
                chooseModel.isSelect = self.videoModel.defaultSubtitle == 2 ? YES : NO;
            }else if (idx == 1){
                chooseModel.isSelect = self.videoModel.defaultSubtitle == 0 ? YES : NO;
            }else if (idx == 2){
                chooseModel.isSelect = self.videoModel.defaultSubtitle == 1 ? YES : NO;
            }else{
                chooseModel.isSelect = NO;
            }
            [self.subTitleArray addObject:chooseModel];
        }];
    }else{
        //单语字幕  单字幕时 subtitle 有值
        NSArray * titles = @[self.videoModel.subtitle.subtitleName,@"关闭字幕"];
        [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DWTableChooseModel * chooseModel = [[DWTableChooseModel alloc]init];
            chooseModel.title = obj;
            if (idx == 0) {
                chooseModel.isSelect = YES;
            }else{
                chooseModel.isSelect = NO;
            }
            [self.subTitleArray addObject:chooseModel];
        }];
    }
    
    //初始化字幕
    if (self.subtitleView) {
        [self.subtitleView removeFromSuperview];
        self.subtitleView = nil;
    }
    
    self.subtitleView = [[DWSubtitleView alloc]initWithSubtitle:self.videoModel.subtitle Subtitle2:self.videoModel.subtitle2 WithDefauleSubtitle:self.videoModel.defaultSubtitle];
    [self.playerView addSubview:self.subtitleView];
    [self switchSubtitleStyle];
}

//切换字幕
-(void)switchSubtitleStyle
{
    if (!self.isFull) {
        [self.subtitleView switchSubtitleStyle:3];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (self.subTitleArray.count == 4) {
        [self.subTitleArray enumerateObjectsUsingBlock:^(DWTableChooseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSelect) {
                [weakSelf.subtitleView switchSubtitleStyle:idx];
            }
        }];
    }else if (self.subTitleArray.count == 2){
        [self.subTitleArray enumerateObjectsUsingBlock:^(DWTableChooseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSelect) {
                if (idx == 0) {
                    [weakSelf.subtitleView switchSubtitleStyle:1];
                }
                if (idx == 1) {
                    [weakSelf.subtitleView switchSubtitleStyle:3];
                }
            }
        }];
    }else{
        //无字幕 关闭
        [self.subtitleView switchSubtitleStyle:3];
    }
}

#pragma mark - 授权验证功能
-(void)dealAuthorizeData
{
    if (!self.videoModel.authorize) {
        return;
    }
    
    self.enable = self.videoModel.authorize.enable;
    
    if (!self.enable && self.videoModel.authorize.freetime == 0) {
        //说明验证异常
        DWMessageView *messageView = [[DWMessageView alloc]initWithFrame:self.maskView.frame];
        messageView.backgroundColor =[UIColor grayColor];
        messageView.toastText = self.videoModel.authorize.message;
        [messageView hiddenRepeatButton];
        [self.maskView addSubview:messageView];
        messageView.backBlock = ^{
            [self backButtonAction];
        };
        [self pause];
    }
}

-(void)verificationCode:(float)time
{
    NSNumber *number =[NSNumber numberWithFloat:time];

    NSInteger freetime = self.videoModel.authorize.freetime;
    //说明不可完整观看
    if (!self.enable) {
        __weak typeof(self) weakSelf = self;
        if (!_messageLabel) {
            _messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(self.frame) - 90, (ScreenWidth - 20)/2, 27)];
            _messageLabel.text = [NSString stringWithFormat:@"可试看%ld秒,购买会员查看完整版",(long)freetime];
            _messageLabel.font = [UIFont systemFontOfSize:13];
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            _messageLabel.layer.cornerRadius = 15;
            _messageLabel.layer.masksToBounds = YES;
            _messageLabel.textColor = [UIColor whiteColor];
            _messageLabel.backgroundColor = [UIColor colorWithRed:34/255 green:34/255 blue:34/255 alpha:0.5];
            [self.maskView addSubview:_messageLabel];
        }
        
        if ([number integerValue] == freetime) {
            
            [self pause];
            
            if (!_messageView) {
                _messageView =[[DWMessageView alloc]initWithFrame:self.maskView.frame];
                _messageView.backgroundColor =[UIColor grayColor];
                _messageView.toastText = self.videoModel.authorize.message;
                [self.maskView addSubview:_messageView];
            }
            
            _messageView.hidden = NO;
            [self.maskView bringSubviewToFront:_messageView];
            
            _messageView.repeatBlock = ^{
                weakSelf.messageView.hidden = YES;
                weakSelf.playOrPauseButton.selected = YES;
                [weakSelf.playerView repeatPlay];
            };
            
            _messageView.backBlock = ^{
                [weakSelf backButtonAction];
            };
        }
    }
}

#pragma mark - GIF录制
//gif录制
-(void)gifButtonAction
{
    //截取视频的默认时长 15s
    _gifTotalTime = 15;
    
    __weak typeof(self) weakSelf = self;
    if (!self.gifManager) {
        self.gifManager = [[DWGIFManager alloc]init];
        self.gifManager.quality = GIFQualityVeryHigh;
        self.gifManager.loopCount = 0;
        
        self.gifManager.completeBlock = ^(NSError *error, NSURL *GifURL) {
            
            [weakSelf.gifHud setHidden:YES];
            
            if (error) {
                //报错
                [[NSString stringWithFormat:@"gif生成失败:%@",[error localizedDescription]] showAlert];
                
                [weakSelf gifCancelAction];
            }
            if (GifURL) {
                //这里自己处理逻辑，看是否要保存本地之类的
                NSLog(@"gif录制成功 GifURL ========== %@",GifURL);
                
                DWGifRecordFinishView * gifFinishView = [[DWGifRecordFinishView alloc]initWithFilePath:GifURL];
                gifFinishView.delegate = weakSelf;
                [weakSelf addSubview:gifFinishView];
                [gifFinishView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(weakSelf);
                }];
                
            }
        };
    }
    
    _isFirstClick = !_isFirstClick;
    
    self.gifButton.enabled = NO;
    self.gifCancelBtn.hidden = NO;
    self.isGIF = YES;
    
    if (_isFirstClick) {
        
        self.gifView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,0,4.5)];
        [self.maskView addSubview:self.gifView];
        
        self.toastView = [[DWToastView alloc]initWithFrame:CGRectMake((ScreenWidth-150)/2, 60, 150,30)];
        [self.maskView addSubview:self.toastView];
        
        self.gifCancelBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [self.gifCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.gifCancelBtn.titleLabel.font =[UIFont systemFontOfSize:15];

        self.gifCancelBtn.layer.cornerRadius =15;
        self.gifCancelBtn.layer.masksToBounds =YES;
        [self.gifCancelBtn addTarget:self action:@selector(gifCancelAction) forControlEvents:UIControlEventTouchUpInside];
        self.gifCancelBtn.backgroundColor =[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
        //        self.gifCancelBtn.hidden =YES;
        [self.maskView addSubview:self.gifCancelBtn];
        [_gifCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@30);
            make.top.equalTo(@60);
            make.right.equalTo(self.gifButton);
        }];
        
        if (!self.playerView.playing) {
            [self play];
        }
        //获取点击时的时间
        [self.gifManager associationWithUrl:[self.playerView drmGIFURL] CurrentPlayer:self.playerView.player AndUseM3U8Method:NO];
        [self.gifManager startRecordingGif];
       
    }else{
        //第二次点击
        if (_clipTime > 3) {
            [self.gifHud setHidden:NO];

            [self endRecordGif];
        }
    }
    
    [self destroyFuncTimer];
    
    if (!_gifTimer) {
        _gifTimer =[NSTimer scheduledTimerWithTimeInterval:gifSeconds target:self selector:@selector(gifTimerAction) userInfo:nil repeats:YES];
    }
}


//取消GIF
- (void)gifCancelAction
{
    if (_gifTimer) {
        [_gifTimer invalidate];
        _gifTimer =nil;
    }
    
    self.isGIF = NO;
    [self.gifView removeFromSuperview];
    self.gifView = nil;
    [self.toastView recoverTextAndColor];
    [self.toastView removeFromSuperview];
    self.toastView = nil;
    self.clipTime = 0;
    self.gifTotalTime = 0;
    self.gifStartTime = 0;
    
    self.isFirstClick = NO;
    self.gifButton.selected = NO;
    self.gifButton.enabled = YES;
    [self.gifCancelBtn removeFromSuperview];
    self.gifCancelBtn = nil;
    
    if (self.gifManager.isRecording) {
        [self.gifManager cancelRecordGif];
    }
}

- (void)gifTimerAction
{
    self.clipTime += gifSeconds;
    self.gifView.hidden = NO;
    self.gifView.frame = CGRectMake(0, 0,ScreenWidth/_gifTotalTime*_clipTime,_gifView.frame.size.height);
    self.toastView.hidden = NO;
    // 大于3秒 制作GIF
    if (_clipTime > 3) {
        self.gifButton.enabled = YES;
        self.gifButton.selected = YES;
        self.gifView.backgroundColor =[UIColor greenColor];
        [self.toastView changeTextAndColor];
    }else{
        self.gifView.backgroundColor =[UIColor orangeColor];
    }
    
    NSInteger clipTime = [[NSNumber numberWithFloat:self.clipTime] integerValue];
    if (clipTime >= self.gifTotalTime) {
        [self endRecordGif];
    }
    
}

-(void)endRecordGif
{
    if (self.playerView.playing) {
        [self pause];
    }
    
    [self.gifManager endRecordingGif];
    [self gifCancelAction];
}

-(void)GifRecordFinishEndShow:(DWGifRecordFinishView *)recordFinishView
{
    [self play];

    [recordFinishView removeFromSuperview];
}

#pragma mark--访客信息收集器------
-(void)showVisitorView:(CGFloat)time
{
    if (!self.videoModel.visitor) {
        return;
    }

    DWVideoVisitorModel * visitor = self.videoModel.visitor;
    
    if ((int)time >= visitor.appearTime && visitor.isShow) {
        
        [self sendWindowsFuncNotification:NO];

        [self destroyFuncTimer];
        
        [self pause];//暂停
        
        self.visitorCollectView = [[DWVisitorCollectView alloc]initWithVisitorDict:visitor];
        self.visitorCollectView.delegate = self;
        [self.visitorCollectView screenRotate:self.isFull];
        [self addSubview:self.visitorCollectView];
        [_visitorCollectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        visitor.isShow = NO;
    }
}

-(void)visitorCollectDidJump
{
    [self play];
    
    [self.visitorCollectView removeFromSuperview];
    self.visitorCollectView = nil;
}

-(void)visitorCollectDidCancel
{
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否要退出当前播放的视频" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if ([_delegate respondsToSelector:@selector(vodPlayerViewVisitorReturnBack:)]) {
            [_delegate vodPlayerViewVisitorReturnBack:self];
        }
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"继续填写" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    UINavigationController * currentNC = (UINavigationController *)DWAPPDELEGATE.window.rootViewController;
    UIViewController * preVC = [currentNC.viewControllers objectAtIndex:currentNC.viewControllers.count - 1];
    [preVC presentViewController:ac animated:YES completion:nil];
}

-(void)visitorCollectDidCommit:(NSString *)message
{
    //访客信息统计上报
    [self.playerView reportVisitorCollectWithVisitorId:self.videoModel.visitor.visitorId VideoId:self.videoModel.videoId UserId:self.videoModel.CCUserId AndMessage:message];
    
    [self play];
    
    [self.visitorCollectView removeFromSuperview];
    self.visitorCollectView = nil;
}

#pragma mark--课堂练习------
-(void)showExercisesAlertView:(CGFloat)time
{
    if (!self.videoModel.exercises || self.videoModel.exercises.count == 0) {
        return;
    }
    
    if (self.exercisesAlertView || self.exercisesView) {
        //当前正在展示课堂练习
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    for (DWVideoExercisesModel * exercises in self.videoModel.exercises) {
        if ((NSInteger)time >= exercises.showTime && exercises.isShow) {

            [self sendWindowsFuncNotification:YES];
            
            [self pause];
            
            if (self.exercisesFrontScrubTime != -1) {
                self.exercisesAlertView = [[DWExercisesAlertView alloc]init];
                self.exercisesAlertView.frontScrubTime = self.exercisesFrontScrubTime;
                self.exercisesAlertView.delegate = self;
                [self.exercisesAlertView show];
            }else{
                UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
                UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;

                if (UIInterfaceOrientationIsPortrait(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationUnknown) {
                    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
                }
                
                DWExercisesView * exercisesView = [[DWExercisesView alloc]initWithExercisesModel:exercises];
                exercisesView.lastScrubTime = weakSelf.exercisesLastScrubTime;
                exercisesView.delegate = self;
                [exercisesView show];
                weakSelf.exercisesView = exercisesView;
            }
            break;
        }
    }
}

//DWExercisesAlertViewDelegate
-(void)exercisesAlertViewReturn
{
    self.exercisesFrontScrubTime = -1;
    
    [self.playerView scrub:self.exercisesAlertView.frontScrubTime];
    [self play];
    
    [self.exercisesAlertView dismiss];
    self.exercisesAlertView = nil;
}

-(void)exercisesAlertViewAnswer
{
    //UIInterfaceOrientationMaskLandscapeRight
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];

    DWVideoExercisesModel * exercisesModel = nil;
    for (DWVideoExercisesModel * exercises in self.videoModel.exercises) {
        if (exercises.isShow) {
            exercisesModel = exercises;
            break;
        }
    }
    
    DWExercisesView * exercisesView = [[DWExercisesView alloc]initWithExercisesModel:exercisesModel];
    exercisesView.lastScrubTime = self.exercisesLastScrubTime;
    exercisesView.delegate = self;
    [exercisesView show];
    self.exercisesView = exercisesView;
        
    [self.exercisesAlertView dismiss];
    self.exercisesAlertView = nil;
}

//DWExercisesViewDelegate
-(void)exercisesViewFinish:(DWVideoExercisesModel *)exercisesModel
{
    //课堂练习完成，提交
    NSMutableArray * jsonArray = [NSMutableArray array];
    [exercisesModel.questions enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [jsonArray addObject:@{@"questionId":[NSNumber numberWithInteger:[obj.questionId integerValue]],
                               @"isRight":[NSNumber numberWithInt:obj.isCorrect]}];
    }];
    
    NSData * questionMesData = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsonStr = [[NSString alloc]initWithData:questionMesData encoding:NSUTF8StringEncoding];
    __weak typeof(self) weakSelf = self;
    [self.playerView reportExercisesWithExercisesId:exercisesModel.exercisesId videoId:self.videoModel.videoId UserId:self.videoModel.CCUserId QuestionMes:jsonStr AndCompletion:^(NSArray *resultArray, NSError *error) {
        
        if (error) {
            [error.localizedDescription showAlert];
            [weakSelf exercisesViewFinishResumePlay:exercisesModel];
            return;
        }
        
        //处理答题正确率
        [exercisesModel.questions enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary * accuracyDict = [resultArray objectAtIndex:idx];
            obj.accuracy = [[accuracyDict objectForKey:@"accuracy"] integerValue];
        }];
        
        [weakSelf.exercisesView exerciseSsumbitSuccess];
    }];
}

-(void)exercisesViewFinishResumePlay:(DWVideoExercisesModel *)exercisesModel
{
    exercisesModel.isShow = NO;

    if (![self haveUnansweredExercises:self.exercisesFrontScrubTime AndLastTime:self.exercisesView.lastScrubTime]) {
        self.exercisesFrontScrubTime = -1;
    }

    [self.playerView scrub:self.exercisesView.lastScrubTime];
    
    [self.exercisesView dismiss];
    self.exercisesView = nil;
    
    if (self.exercisesAlertView) {
        [self.exercisesAlertView removeFromSuperview];
        self.exercisesAlertView = nil;
    }
    
    [self play];
}

-(BOOL)haveUnansweredExercises:(CGFloat)frontTime AndLastTime:(CGFloat)lastTime
{
    BOOL ret = NO;
    for (DWVideoExercisesModel * exercises in self.videoModel.exercises) {
        if (exercises.showTime > lastTime) {
            continue;
        }
        if (exercises.showTime < frontTime) {
            continue;
        }
        if (exercises.isShow) {
            ret = YES;
            break;
        }
    }
    return ret;
}

#pragma mark - DWPlayerSettingViewDelegate
-(void)playerSettingViewStyle:(DWVodSettingStyle)style AndSelectIndex:(NSInteger)selectIndex
{
    if (style == DWVodSettingStyleListSpeed) {
        //倍速选择
        for (DWTableChooseModel * chooseModel in self.speedArray) {
            if (chooseModel.isSelect) {
                chooseModel.isSelect = NO;
                break;
            }
        }
        
        DWTableChooseModel * chooseModel = [self.speedArray objectAtIndex:selectIndex];
        chooseModel.isSelect = YES;
        
        CGFloat rate = [[chooseModel.title substringWithRange:NSMakeRange(0, 3)] floatValue];
        [self.playerView setPlayerRate:rate];
        
        [[NSString stringWithFormat:@"已切换%@",chooseModel.title] showAlert];
    }
    
    if (style == DWVodSettingStyleListQuality) {
        //清晰度修改
        for (DWTableChooseModel * chooseModel in self.qualityArray) {
            if (chooseModel.isSelect) {
                chooseModel.isSelect = NO;
                break;
            }
        }

        DWVideoQualityModel * qualityModel = [self.videoModel.videoQualities objectAtIndex:selectIndex];
        [self switchQuality:qualityModel];
    }
    
    if (style == DWVodSettingStyleListChooseSelection) {
        //选集
        for (DWTableChooseModel * chooseModel in self.selectionArray) {
            if (chooseModel.isSelect) {
                chooseModel.isSelect = NO;
                break;
            }
        }
        
        DWTableChooseModel * chooseModel = [self.selectionArray objectAtIndex:selectIndex];
        chooseModel.isSelect = YES;
        
        //外部回调
        if ([_delegate respondsToSelector:@selector(vodPlayerView:ChooseSelection:)]) {
            [_delegate vodPlayerView:self ChooseSelection:selectIndex];
        }
    }
    
    [self.settingView disAppear];
    self.settingView = nil;
}

//下载回调
-(void)playerSettingViewDownloadAction
{
    if (!self.videoModel) {
        [@"本地视频，无法下载" showAlert];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    //获取下载地址 hlsSupport传@"0"
    DWPlayInfo *playinfo = [[DWPlayInfo alloc] initWithUserId:[DWConfigurationManager sharedInstance].DWAccount_userId andVideoId:self.videoModel.videoId key:[DWConfigurationManager sharedInstance].DWAccount_apikey hlsSupport:@"0"];
    
    playinfo.verificationCode = [DWConfigurationManager sharedInstance].verification;
    playinfo.mediatype = @"0";
    //网络请求超时时间
    playinfo.timeoutSeconds = 20;
    playinfo.errorBlock = ^(NSError *error){
        [@"请求资源失败" showAlert];
    };
    
    playinfo.finishBlock = ^(DWVodVideoModel *vodVideo) {
        
        if (!vodVideo) {
            [@"网络资源暂时不可用" showAlert];
            return;
        }
        
        if (vodVideo.authorize && !vodVideo.authorize.enable) {
            [@"授权验证未通过，无法下载" showAlert];
            return;
        }
        
        [weakSelf startDownloadTask:vodVideo];
    };
    
    [playinfo start];
}

//投屏回调
-(void)playerSettingViewScreeningAction
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    [self screeningButtonAction];
}

//音视频回调
-(void)playerSettingViewMediaTypeAction
{
    [self.settingView disAppear];
    self.settingView = nil;
    
    [self mediaKindButtonAction];
}

//网络检测回调
-(void)playerSettingViewNetworkMonitorAction
{
    if (self.downloadModel) {
        [@"正在播放离线视频" showAlert];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(vodPlayerView:DidNetworkMonitor:AndPlayUrl:)]) {
        [_delegate vodPlayerView:self DidNetworkMonitor:self.videoModel.videoId AndPlayUrl:self.playerView.qualityModel.playUrl];
        [self pause];
    }
}

-(void)playerSettingWindowsPlay
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];

    [self windowsButtonAction];
}

//字幕回调
-(void)playerSettingViewSubtitleSelect
{
    [self switchSubtitleStyle];
}

//画面尺寸回调
-(void)playerSettingViewScreenSizeSelect
{
    [self.sizeArray enumerateObjectsUsingBlock:^(DWTableChooseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            switch (idx) {
                case 0:{
                    self.playerView.transform = CGAffineTransformIdentity;
                    if (_vrView) {
                        _vrView.transform = CGAffineTransformIdentity;
                    }
                    break;
                }
                case 1:{
                    self.playerView.transform = CGAffineTransformMakeScale(0.75, 0.75);
                    if (_vrView) {
                        _vrView.transform = CGAffineTransformMakeScale(0.75, 0.75);
                    }
                    break;
                }
                case 2:{
                    self.playerView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                    if (_vrView) {
                        _vrView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                    }
                    break;
                }
                case 3:{
                    self.playerView.transform = CGAffineTransformMakeScale(0.25, 0.25);
                    if (_vrView) {
                        _vrView.transform = CGAffineTransformMakeScale(0.25, 0.25);
                    }
                    break;
                }
                default:
                    break;
            }
            *stop = YES;
        }
    }];
}

//屏幕亮度改变回调
-(void)playerSettingViewScreenLightChange:(CGFloat)changeValue
{
    self.screenLight = changeValue;
}

//系统音量改变回调
-(void)playerSettingViewSoundChange:(CGFloat)changeValue
{
    self.systemSound = changeValue;
}

#pragma mark - DWVideoPlayerDelegate
// 可播放
- (void)videoPlayerIsReadyToPlayVideo:(DWPlayerView *)playerView
{
    self.readyToPlay = YES;

    [self hideHudWithMessage:nil];
    
    if (self.videoModel.vrmode == 1 || self.downloadModel.vrMode) {
        //设置VR
        [self initVRConfig];
    }
    
    if (!_isSwitchquality) {
        [self readNSUserDefaults];
    }
    
    //处理记忆播放时，课堂练习拖拽的位置。
    if (_isSwitchquality) {
        self.exercisesFrontScrubTime = -1;
        self.exercisesLastScrubTime = -1;
    }else{
        if (self.switchTime == 0) {
            self.exercisesFrontScrubTime = -1;
            self.exercisesLastScrubTime = -1;
        }else{
            self.exercisesFrontScrubTime = 0;
            self.exercisesLastScrubTime = self.switchTime;
            if (![self haveUnansweredExercises:self.exercisesFrontScrubTime AndLastTime:self.exercisesLastScrubTime]) {
                self.exercisesFrontScrubTime = -1;
                self.exercisesLastScrubTime = -1;
            }
        }
    }

    //读取原先的播放时间 用oldTimeScrub方法
    [self.playerView oldTimeScrub:self.switchTime];
    
    //同步视频总时间
    self.pan.duration = CMTimeGetSeconds(self.playerView.player.currentItem.duration);
    
}

//播放完毕
- (void)videoPlayerDidReachEnd:(DWPlayerView *)playerView
{
    [self pause];
    
    //播放完成，自动播放下一集
    [self nextButtonAction];
    
    [@"播放完成" showAlert];
    
    //播放完成时，如果在录制GIF，结束录制
    if (_isGIF && self.gifManager.isRecording) {
        [self endRecordGif];
        return;
    }
    
}

//播放中  time:当前播放时间
- (void)videoPlayer:(DWPlayerView *)playerView timeDidChange:(float)time
{
    if (_hud) {
        [self hideHudWithMessage:nil];
    }
    
    self.currentPlayDuration = time;

    //授权验证功能
    [self verificationCode:time];
    
    //显示字幕
    if (self.subtitleView && !self.subtitleView.hidden) {
        [self.subtitleView setSubtitleWithTime:time];
    }
    
    //问答功能
    [self showQuestionsView:time];
    
    //访客信息收集器
    [self showVisitorView:time];
    
    //课堂练习
    [self showExercisesAlertView:time];
    
    self.exercisesLastScrubTime = time;
  
    //拖拽时，禁止刷新进度信息
    if (self.isSlidering) {
        return;
    }
    
    @autoreleasepool {
        CGFloat durSec = CMTimeGetSeconds(self.playerView.player.currentItem.duration);
        self.slider.value = (float)time / durSec;
        
        self.currentLabel.text = [DWTools formatSecondsToString:time];
        self.totalLabel.text = [DWTools formatSecondsToString:durSec];
        
        //同步进度
        self.pan.progress = self.slider.value;
    }
}

//duration 当前缓冲的长度
- (void)videoPlayer:(DWPlayerView *)playerView loadedTimeRangeDidChange:(float)duration
{
    CGFloat durSec = CMTimeGetSeconds(self.playerView.player.currentItem.duration);
    self.slider.bufferValue = duration / durSec;
    
//    NSLog(@"当前缓冲的长度 %f  百分比 %f",duration,duration / durSec);
}

//没数据 即播放卡顿
- (void)videoPlayerPlaybackBufferEmpty:(DWPlayerView *)playerView
{
//    _hud = [MBProgressHUD showHUDAddedTo:self.maskView animated:YES];
//    _hud.label.text = @"播放卡顿，请稍后";
    [self showHudWithMessage:@"播放卡顿，请稍后"];
    
//    NSLog(@"videoPlayerPlaybackBufferEmpty rate:%lf",playerView.player.rate);
}

//有数据 能够继续播放
- (void)videoPlayerPlaybackLikelyToKeepUp:(DWPlayerView *)playerView
{
    [self hideHudWithMessage:nil];
    
    if (!self.videoModel) {
        return;
    }
    
    if (_questionView || self.visitorCollectView || self.exercisesAlertView || self.exercisesView) {
        return;
    }
    
    //防止在有数据缓冲，但播放器播放状态与页面按钮状态不一致。
    if (self.playerView.player.rate == 0 && self.playOrPauseButton.selected) {
        self.playOrPauseButton.selected = NO;
    }

}

//加载失败
- (void)videoPlayer:(DWPlayerView *)playerView didFailWithError:(NSError *)error
{
    if (self.videoModel && !self.playerView.isSpar) {
        [self switchSparLine];
        return;
    }
    
    [[NSString stringWithFormat:@"%@",error.localizedDescription] showAlert];
    
    [self hideHudWithMessage:nil];
}

//加载超时/scrub超时
- (void)videoPlayer:(DWPlayerView *)playerView receivedTimeOut:(DWPlayerViewTimeOut )timeOut
{
    [@"加载超时，请稍后" showAlert];
}

//AVPlayerLayer对象变动时回调
- (void)videoPlayer:(DWPlayerView *)playerView ChangePlayerLayer:(AVPlayerLayer *)playerLayer
{
    if (IS_PAD) {
        self.pipVC = [[AVPictureInPictureController alloc]initWithPlayerLayer:self.playerView.playerLayer];
        self.pipVC.delegate = self;
    }
}

#pragma mark - init
-(void)initMaskView
{
    [self addSubview:self.maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

//顶部控件
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
    
    [self.topFuncBgView addSubview:self.mediaKindButton];
    [_mediaKindButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-10));
        make.width.and.height.equalTo(@30);
        make.centerY.equalTo(self.backButton);
    }];
    
    [self.topFuncBgView addSubview:self.otherFuncButton];
    [_otherFuncButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-10));
        make.width.and.height.equalTo(@30);
        make.centerY.equalTo(self.backButton);
    }];
    
    NSInteger buttonCount = 1;
    if (IS_PAD) {
        buttonCount++;
        [self.topFuncBgView addSubview:self.pipButton];
        [_pipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-(40 * 1) - 10));
            make.width.and.height.equalTo(@30);
            make.centerY.equalTo(self.backButton);
        }];
    }
    
    self.screeningButton.hidden = YES;
    [self.topFuncBgView addSubview:self.screeningButton];
    [_screeningButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-(40 * buttonCount) - 10));
        make.width.and.height.equalTo(@30);
        make.centerY.equalTo(self.backButton);
    }];
    
    [self addSubview:self.windowsButton];
    [_windowsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-(40 * (buttonCount + 1)) - 10));
        make.width.and.height.equalTo(@30);
        make.centerY.equalTo(self.backButton);
    }];
//    buttonCount++;
    
    self.vrInteractiveButton.hidden = YES;
    [self.topFuncBgView addSubview:self.vrInteractiveButton];
    [_vrInteractiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(@(-(40 * (buttonCount + 1)) - 10));
        make.right.equalTo(@(-(40 * (buttonCount + 2)) - 10));
        make.width.and.height.equalTo(@30);
        make.centerY.equalTo(self.backButton);
    }];
    
    self.vrDisplayButton.hidden = YES;
    [self.topFuncBgView addSubview:self.vrDisplayButton];
    [_vrDisplayButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(@(-(40 * (buttonCount + 2)) - 10));
        make.right.equalTo(@(-(40 * (buttonCount + 3)) - 10));
        make.width.and.height.equalTo(@30);
        make.centerY.equalTo(self.backButton);
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
    
    [self.bottomFuncBgView addSubview:self.nextButton];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playOrPauseButton.mas_right).offset(5);
        make.centerY.equalTo(self.playOrPauseButton);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.bottomFuncBgView addSubview:self.currentLabel];
    [_currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nextButton.mas_right).offset(5);
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
    
    [self.bottomFuncBgView addSubview:self.speedButton];
    [_speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-(40 * 2) - 10));
        make.centerY.equalTo(self.playOrPauseButton);
        make.width.equalTo(@40);
        make.height.equalTo(@30);
    }];
    
    [self.bottomFuncBgView addSubview:self.qualityButton];
    [_qualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-(40 * 1) - 10));
        make.centerY.equalTo(self.playOrPauseButton);
        make.width.equalTo(@40);
        make.height.equalTo(@30);
    }];
    
    [self.bottomFuncBgView addSubview:self.chooseButton];
    [_chooseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-(40 * 0) - 10));
        make.centerY.equalTo(self.playOrPauseButton);
        make.width.equalTo(@40);
        make.height.equalTo(@30);
    }];
    
    [self.bottomFuncBgView addSubview:self.rotateScreenButton];
    [_rotateScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-5));
        make.centerY.equalTo(self.playOrPauseButton);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
}

//侧方功能
-(void)initLeftFuncView
{
    [self addSubview:self.gifButton];
    [_gifButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(self.areaInsets.right));
        make.centerY.equalTo(self).offset(24);
        make.width.and.height.equalTo(@30);
    }];
    
    [self addSubview:self.disableGesButton];
    [_disableGesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(self.areaInsets.left));
        make.centerY.equalTo(self);
        make.width.and.height.equalTo(@30);
    }];
    
    [self addSubview:self.screenShotButton];
    [self.screenShotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(self.areaInsets.right));
        make.centerY.equalTo(self).offset(-24);
        make.width.and.height.equalTo(@30);
    }];
}

//创建播放器
-(void)initPlayerView
{
    self.playerView = [[DWPlayerView alloc]init];
    self.playerView.timeOutLoad = 30;
    self.playerView.timeOutBuffer = 30;
//    self.playerView.loadStyle = DWPlayerViewLoadStyleImmediately;
    self.playerView.forwardBufferDuration = 30;
    self.playerView.delegate = self;
    [self.playerView setPlayInBackground:self.allowBackgroundPlay];
    [self.playerView setPictureInPicture:self.allowPictureInPicture];
    
    //是否开启防录屏
//    self.playerView.videoProtect = YES;
    [self insertSubview:self.playerView atIndex:0];
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

//音频播放view
-(void)initRadioView
{
    [self insertSubview:self.radioBgView atIndex:0];
    self.radioBgView.hidden = YES;
    [_radioBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.radioBgView addSubview:self.radioImageView];
    [_radioImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.radioBgView);
        make.width.equalTo(@(373 / 2.0));
        make.height.equalTo(@(151 / 2.0));
    }];
}

//VR视图以及设置
-(void)initVRView
{
    if (self.videoModel.vrmode == 1 || self.downloadModel.vrMode) {
        //VR模式下 修改布局
        self.vrInteractiveButton.hidden = NO;
        self.vrDisplayButton.hidden = NO;
        
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-(40 * 4) - 10 - 5));
        }];
        
        //vr初始化设置
        self.interative = DWModeInteractiveMotion;
        self.display = DWModeDisplayNormal;
        
        if (self.vrView) {
            [self.vrView removeFromSuperview];
            self.vrView = nil;
        }
        [self insertSubview:self.vrView atIndex:0];
        [_vrView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.playerView.hidden = YES;
        
    }else{
        self.vrInteractiveButton.hidden = YES;
        self.vrDisplayButton.hidden = YES;
        
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-45));
        }];
        
        self.playerView.hidden = NO;
        
        [self.vrView removeFromSuperview];
        self.vrView = nil;
    }
    
}

-(void)initVRConfig
{
    //vr
    if (self.config) {
        self.config = nil;
    }
    if (self.vrLibrary) {
        self.vrLibrary = nil;
    }
    
    self.config = [DWVRLibrary createConfig];
    
    [_config asVideo:self.playerView.player.currentItem];

    UINavigationController * currentNC = (UINavigationController *)DWAPPDELEGATE.window.rootViewController;
    UIViewController * preVC = [currentNC.viewControllers objectAtIndex:currentNC.viewControllers.count - 1];
    [_config setContainer:preVC view:self.vrView];
    // optional
    [_config projectionMode:DWModeProjectionSphere];//效果
    [_config displayMode:_display];//是否分屏
    [_config interactiveMode:_interative];//交互方式
    [_config pinchEnabled:true];
    [_config setDirectorFactory:[[CustomDirectorFactory alloc]init]];
    self.vrLibrary = [_config build];
}

-(void)initAirPlayView
{
    [self addSubview:self.airPlayStatusLabel];
    self.airPlayStatusLabel.hidden = YES;
    [self.airPlayStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.equalTo(@15);
        make.width.equalTo(@(200));
    }];
}

-(void)initPlayerPanGesture
{
    self.pan = [[DWVodPlayerPanGesture alloc]initWithFatherView:self];
    self.pan.vodPanDelegate = self;
}

#if __has_include(<HDMarqueeTool/HDMarqueeTool.h>)
-(void)initMarqueeView
{
    if (self.marqueeView) {
        [self.marqueeView removeFromSuperview];
        self.marqueeView = nil;
    }
    
    NSData * jsonData = nil;
    //判断是否是离线视频
    if (self.downloadModel) {
        //离线视频
        jsonData = [self.downloadModel.marqueeStr dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        //在线视频
        jsonData = [self.videoModel.authorize.marqueeStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (!jsonData) {
        return;
    }
    
    NSDictionary * marqueeSetDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    
    self.marqueeView = [[HDMarqueeView alloc]init];
    
    HDMarqueeViewStyle style = [[marqueeSetDict objectForKey:@"type"] isEqualToString:@"text"] ? HDMarqueeViewStyleTitle : HDMarqueeViewStyleImage;
    self.marqueeView.style = style;
    self.marqueeView.fatherView = self.playerView;
    self.marqueeView.repeatCount = [[marqueeSetDict objectForKey:@"loop"] integerValue];
    if (style == HDMarqueeViewStyleTitle) {
        NSDictionary * textDict = [marqueeSetDict objectForKey:@"text"];
        NSString * text = [textDict objectForKey:@"content"];
        UIColor * textColor = [DWTools colorWithHexString:[textDict objectForKey:@"color"]];
        UIFont * textFont = [UIFont systemFontOfSize:[[textDict objectForKey:@"font_size"] floatValue] / [UIScreen mainScreen].scale];
        
        self.marqueeView.text = text;
        self.marqueeView.textAttributed = @{NSFontAttributeName:textFont,NSForegroundColorAttributeName:textColor};
            
        CGSize textSize = [self.marqueeView.text calculateRectWithSize:CGSizeMake(ScreenWidth, ScreenHeight) Font:textFont WithLineSpace:0];
        width = textSize.width;
        height = textSize.height;
        
    }else{
        NSDictionary * imageDict = [marqueeSetDict objectForKey:@"image"];
        NSURL * imageURL = [NSURL URLWithString:[imageDict objectForKey:@"image_url"]];
        self.marqueeView.imageURL = imageURL;
        
        width = [[imageDict objectForKey:@"width"] floatValue] / [UIScreen mainScreen].scale;
        height = [[imageDict objectForKey:@"height"] floatValue] / [UIScreen mainScreen].scale;
    }
    self.marqueeView.frame = CGRectMake(0, 0, width, height);
    
    //处理action
    NSArray * setActionsArray = [marqueeSetDict objectForKey:@"action"];
    
    NSMutableArray <HDMarqueeAction *> * actions = [NSMutableArray array];
    for (int i = 0; i < setActionsArray.count; i++) {
        NSDictionary * actionDict = [setActionsArray objectAtIndex:i];
        CGFloat duration = [[actionDict objectForKey:@"duration"] floatValue];
        NSDictionary * startDict = [actionDict objectForKey:@"start"];
        NSDictionary * endDict = [actionDict objectForKey:@"end"];

        HDMarqueeAction * marqueeAction = [[HDMarqueeAction alloc]init];
        marqueeAction.duration = duration / 1000.0;
        marqueeAction.startPostion.alpha = [[startDict objectForKey:@"alpha"] floatValue];
        marqueeAction.startPostion.pos = CGPointMake([[startDict objectForKey:@"xpos"] floatValue], [[startDict objectForKey:@"ypos"] floatValue]);
        marqueeAction.endPostion.alpha = [[endDict objectForKey:@"alpha"] floatValue];
        marqueeAction.endPostion.pos = CGPointMake([[endDict objectForKey:@"xpos"] floatValue], [[endDict objectForKey:@"ypos"] floatValue]);
        
        [actions addObject:marqueeAction];
    }
    
//    NSLog(@"marqueeView actions : %@",actions);
    
    self.marqueeView.actions = actions;
//    [self.playerView insertSubview:self.marqueeView atIndex:0];
    [self.playerView addSubview:self.marqueeView];
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.marqueeView startMarquee];
    });
    
//    [self.marqueeView startMarquee];
}
#endif

#pragma mark - lazyLoad
//顶部
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

-(UIButton *)mediaKindButton
{
    if (!_mediaKindButton) {
        _mediaKindButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mediaKindButton setImage:[UIImage imageNamed:@"icon_play_radio.png"] forState:UIControlStateNormal];
        [_mediaKindButton setImage:[UIImage imageNamed:@"icon_play_video.png"] forState:UIControlStateSelected];
        [_mediaKindButton addTarget:self action:@selector(mediaKindButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mediaKindButton;
}

-(UIButton *)otherFuncButton
{
    if (!_otherFuncButton) {
        _otherFuncButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherFuncButton setImage:[UIImage imageNamed:@"icon_play_more.png"] forState:UIControlStateNormal];
        [_otherFuncButton addTarget:self action:@selector(otherFuncButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherFuncButton;
}

-(UIButton *)vrInteractiveButton
{
    if (!_vrInteractiveButton) {
        _vrInteractiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_vrInteractiveButton setImage:[UIImage imageNamed:@"icon_play_vr_inselect_select.png"] forState:UIControlStateSelected];
        [_vrInteractiveButton setImage:[UIImage imageNamed:@"icon_play_vr_inselect_normal.png"] forState:UIControlStateNormal];
        [_vrInteractiveButton addTarget:self action:@selector(vrInteractiveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vrInteractiveButton;
}

-(UIButton *)vrDisplayButton
{
    if (!_vrDisplayButton) {
        _vrDisplayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_vrDisplayButton setImage:[UIImage imageNamed:@"icon_play_vr_display_select.png"] forState:UIControlStateSelected];
        [_vrDisplayButton setImage:[UIImage imageNamed:@"icon_play_vr_display_normal.png"] forState:UIControlStateNormal];
        [_vrDisplayButton addTarget:self action:@selector(vrDisplayButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vrDisplayButton;
}

-(UIButton *)screeningButton
{
    if (!_screeningButton) {
        _screeningButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screeningButton setImage:[UIImage imageNamed:@"icon_screen_vertical.png"] forState:UIControlStateNormal];
        [_screeningButton addTarget:self action:@selector(screeningButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screeningButton;
}

-(UIButton *)pipButton
{
    if (!_pipButton) {
        _pipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pipButton setImage:[UIImage imageNamed:@"icon_pip.png"] forState:UIControlStateNormal];
        [_pipButton addTarget:self action:@selector(pipButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pipButton;
}

-(UIButton *)windowsButton
{
    if (!_windowsButton) {
        _windowsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_windowsButton setBackgroundImage:[UIImage imageNamed:@"icon_windows.png"] forState:UIControlStateNormal];
        [_windowsButton addTarget:self action:@selector(windowsButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _windowsButton;
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

-(UIButton *)nextButton
{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"icon_play_next.png"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
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

-(DWPlayerSlider *)slider
{
    if (!_slider) {
        _slider = [[DWPlayerSlider alloc]init];
        [_slider addTarget:self action:@selector(sliderMovingAction) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderEndedAction) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_slider addTarget:self action:@selector(sliderBeganAction) forControlEvents:UIControlEventTouchDown];
        //添加tap手势 用于视频打点功能
        UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOfVideoMarkAction:)];
        tap.cancelsTouchesInView = NO;
        [_slider addGestureRecognizer:tap];
    }
    return _slider;
}


-(UIButton *)speedButton
{
    if (!_speedButton) {
        _speedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _speedButton.titleLabel.font = TitleFont(14);
        [_speedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_speedButton setTitle:@"倍速" forState:UIControlStateNormal];
        [_speedButton addTarget:self action:@selector(speedButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_speedButton sizeToFit];
    }
    return _speedButton;
}

-(UIButton *)qualityButton
{
    if (!_qualityButton) {
        _qualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _qualityButton.titleLabel.font = TitleFont(14);
        [_qualityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_qualityButton setTitle:@"清晰" forState:UIControlStateNormal];
        [_qualityButton addTarget:self action:@selector(qualityButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qualityButton;
}

-(UIButton *)chooseButton
{
    if (!_chooseButton) {
        _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseButton.titleLabel.font = TitleFont(14);
        [_chooseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_chooseButton setTitle:@"选集" forState:UIControlStateNormal];
        [_chooseButton addTarget:self action:@selector(chooseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chooseButton;
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

//侧方功能按钮
-(UIButton *)gifButton
{
    if (!_gifButton) {
        _gifButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_gifButton setImage:[UIImage imageNamed:@"icon_play_gif_normal.png"] forState:UIControlStateNormal];
        [_gifButton setImage:[UIImage imageNamed:@"icon_play_gif_select.png"] forState:UIControlStateSelected];
        [_gifButton setImage:[UIImage imageNamed:@"icon_play_gif_disable.png"] forState:UIControlStateDisabled];
        [_gifButton addTarget:self action:@selector(gifButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gifButton;
}

-(UIButton *)disableGesButton
{
    if (!_disableGesButton) {
        _disableGesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_disableGesButton setImage:[UIImage imageNamed:@"icon_play_locked_normal.png"] forState:UIControlStateNormal];
        [_disableGesButton setImage:[UIImage imageNamed:@"icon_play_locked_select.png"] forState:UIControlStateSelected];
        [_disableGesButton addTarget:self action:@selector(disableGesButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _disableGesButton;
}

-(UIButton *)screenShotButton
{
    if (!_screenShotButton) {
        _screenShotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenShotButton setImage:[UIImage imageNamed:@"icon_screenshot.png"] forState:UIControlStateNormal];
        [_screenShotButton addTarget:self action:@selector(screenShotButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenShotButton;
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

-(UIView *)radioBgView
{
    if (!_radioBgView) {
        _radioBgView = [[UIView alloc]init];
        _radioBgView.backgroundColor = [UIColor blackColor];
    }
    return _radioBgView;
}

-(UIImageView *)radioImageView
{
    if (!_radioImageView) {
        _radioImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_radio_bg.png"]];
    }
    return _radioImageView;
}

-(NSMutableArray <DWTableChooseModel *> *)speedArray
{
    if (!_speedArray) {
        _speedArray = [[NSMutableArray alloc]init];
        NSArray * titles = @[@"0.5X",@"1.0X",@"1.5X",@"2.0X"];
        [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DWTableChooseModel * chooseModel = [[DWTableChooseModel alloc]init];
            chooseModel.title = (NSString *)obj;
            //默认 常速播放
            if (idx == 1) {
                chooseModel.isSelect = YES;
            }else{
                chooseModel.isSelect = NO;
            }
            [_speedArray addObject:chooseModel];
        }];
    }
    return _speedArray;
}

-(NSMutableArray <DWTableChooseModel *> *)qualityArray
{
    if (!_qualityArray) {
        _qualityArray = [[NSMutableArray alloc]init];
    }
    return _qualityArray;
}

- (NSMutableArray *)markButtonArray{
    
    if (!_markButtonArray) {
        _markButtonArray =[[NSMutableArray alloc]init];
    }
    return _markButtonArray;
}

- (DWMarkView *)markView{
    
    if (!_markView) {
        _markView = [[DWMarkView alloc]init];
        _markView.backgroundColor = [DWTools colorWithHexString:@"#1e1f21"];
        _markView.alpha = 0.69;
        _markView.layer.cornerRadius = 15;
        _markView.layer.masksToBounds = YES;
        [self addSubview:_markView];
        
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(markViewTapAction:)];
        [_markView addGestureRecognizer:tap];
    }
    
    return _markView;
}

- (UIImageView *)arrowImageView{
    
    if (!_arrowImageView) {
        _arrowImageView =[[UIImageView alloc]init];
        _arrowImageView.image =[UIImage imageNamed:@"icon_arrow.png"];
        [self addSubview:_arrowImageView];
    }
    
    return _arrowImageView;
}

-(CGFloat)sliderWidth
{
    CGFloat w = MAX(ScreenWidth, ScreenHeight);
//    -(40 * 3) - 10 - 5
    CGFloat rightWidth = 0;
    if (self.isVideo) {
        if (self.chooseButton.hidden) {
            rightWidth = (40 * 2);
        }else{
            rightWidth = (40 * 3);
        }
    }else{
        if (self.chooseButton.hidden) {
            rightWidth = (40 * 1);
        }else{
            rightWidth = (40 * 2);
        }
    }
    
    CGFloat nextButtonWidth = 0;
    if (!self.nextButton.hidden) {
        nextButtonWidth = 30 + 5;
    }
    
    return w - 10 - 30 - nextButtonWidth - 5 - self.currentLabel.frame.size.width - 2.5 - self.lineLabel.frame.size.width - 2.5 - self.totalLabel.frame.size.width - 5 - rightWidth - 10 - 5;

}

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

- (NSMutableArray *)questionIdsArray
{
    if (!_questionIdsArray) {
        _questionIdsArray = [[NSMutableArray alloc]init];
    }
    return _questionIdsArray;
}

- (DWQuestionView *)questionView
{
    if (!_questionView) {
        _questionView = [[DWQuestionView alloc]init];
    }
    return _questionView;
}

-(NSMutableArray<DWTableChooseModel *> *)subTitleArray
{
    if (!_subTitleArray) {
        _subTitleArray = [[NSMutableArray alloc]init];
    }
    return _subTitleArray;
}

-(NSMutableArray<DWTableChooseModel *> *)sizeArray
{
    if (!_sizeArray) {
        _sizeArray = [[NSMutableArray alloc]init];
        NSArray * titles = @[@"100%",@"75%",@"50%",@"25%"];
        [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DWTableChooseModel * chooseModel = [[DWTableChooseModel alloc]init];
            chooseModel.title = (NSString *)obj;
            if (idx == 0) {
                chooseModel.isSelect = YES;
            }else{
                chooseModel.isSelect = NO;
            }
            [_sizeArray addObject:chooseModel];
        }];
    }
    return _sizeArray;
}

-(NSMutableArray<DWTableChooseModel *> *)selectionArray
{
    if (!_selectionArray) {
        _selectionArray = [[NSMutableArray alloc]init];
    }
    return _selectionArray;
}

-(void)setScreenLight:(CGFloat)screenLight
{
    [UIScreen mainScreen].brightness = screenLight;
}

-(CGFloat)screenLight
{
    return [UIScreen mainScreen].brightness;
}

-(void)setSystemSound:(CGFloat)systemSound
{
    self.volumeViewSlider.value = systemSound;
}

-(CGFloat)systemSound
{
    return self.volumeViewSlider.value;
}

-(UISlider *)volumeViewSlider
{
    if (!_volumeViewSlider) {
        MPVolumeView * volumeView = [[MPVolumeView alloc] init];
        volumeView.showsRouteButton = NO;
        volumeView.showsVolumeSlider = NO;
        volumeView.hidden = YES;
        _volumeViewSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider *)view;
                break;
            }
        }
    }
    return _volumeViewSlider;
}

-(MBProgressHUD *)gifHud
{
    if (!_gifHud) {
        _gifHud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        _gifHud.label.text = @"GIF生成中，请稍后";
        [_gifHud setHidden:YES];
    }
    return _gifHud;
}

-(UIView *)vrView
{
    if (!_vrView) {
        _vrView = [[UIView alloc]init];
    }
    return _vrView;
}

-(UILabel *)airPlayStatusLabel
{
    if (!_airPlayStatusLabel) {
        _airPlayStatusLabel = [[UILabel alloc]init];
        _airPlayStatusLabel.font = TitleFont(15);
        _airPlayStatusLabel.textAlignment = NSTextAlignmentCenter;
        _airPlayStatusLabel.textColor = [UIColor whiteColor];
        _airPlayStatusLabel.text = @"AirPlay投屏中";
    }
    return _airPlayStatusLabel;
}

//窗口播放
-(UIButton *)windowsCloseButton
{
    if (!_windowsCloseButton) {
        _windowsCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _windowsCloseButton.hidden = YES;
        [_windowsCloseButton setBackgroundImage:[UIImage imageNamed:@"icon_windows_close.png"] forState:UIControlStateNormal];
        [_windowsCloseButton addTarget:self action:@selector(windowsCloseButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_windowsCloseButton];
        [_windowsCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@0);
            make.top.equalTo(@0);
            make.width.and.height.equalTo(@22);
        }];
    }
    return _windowsCloseButton;
}

-(UIButton *)windowsPlayOrPauseButton
{
    if (!_windowsPlayOrPauseButton) {
        _windowsPlayOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _windowsPlayOrPauseButton.hidden = YES;
        [_windowsPlayOrPauseButton setBackgroundImage:[UIImage imageNamed:@"icon_windows_play.png"] forState:UIControlStateNormal];
        [_windowsPlayOrPauseButton setBackgroundImage:[UIImage imageNamed:@"icon_windows_pause.png"] forState:UIControlStateSelected];
        [_windowsPlayOrPauseButton addTarget:self action:@selector(windowsPlayOrPauseButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_windowsPlayOrPauseButton];
        [_windowsPlayOrPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_centerX).offset(-7.5);
            make.bottom.equalTo(@0);
            make.width.and.height.equalTo(@24);
        }];
    }
    return _windowsPlayOrPauseButton;
}

-(UIButton *)windowsResumeButton
{
    if (!_windowsResumeButton) {
        _windowsResumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _windowsResumeButton.hidden = YES;
        [_windowsResumeButton setBackgroundImage:[UIImage imageNamed:@"icon_windows_resume.png"] forState:UIControlStateNormal];
        [_windowsResumeButton addTarget:self action:@selector(windowsResumeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_windowsResumeButton];
        [_windowsResumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX).offset(7.5);
            make.bottom.equalTo(@0);
            make.width.and.height.equalTo(@24);
        }];
    }
    return _windowsResumeButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
