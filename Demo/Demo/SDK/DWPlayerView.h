//

//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

@class DWVodVideoModel;
@class DWDownloadModel;
@class DWVideoQualityModel;

typedef NS_ENUM(NSUInteger, DWPlayerViewTimeOut) {
    DWPlayerViewStatusTimeOutLoad,//加载超时
    DWPlayerViewStatusTimeOutBuffer //缓存超时
};

//无缓冲，立即播放相关设置
/**
 该属性只对iOS10以上系统生效

 */
typedef NS_ENUM(NSUInteger, DWPlayerViewLoadStyle) {
    DWPlayerViewLoadStyleDefault, //会提前缓冲，缓冲一部分开始播放
    DWPlayerViewLoadStyleImmediately //立即播放，无论先前是否进行过缓冲
};

@class DWPlayerView;

@protocol DWVideoPlayerDelegate <NSObject>

@optional
//所有的代理方法均已回到主线程 可直接刷新UI
//可播放
- (void)videoPlayerIsReadyToPlayVideo:(DWPlayerView *)playerView;

//播放完毕
- (void)videoPlayerDidReachEnd:(DWPlayerView *)playerView;

//播放中  time:当前播放时间
- (void)videoPlayer:(DWPlayerView *)playerView timeDidChange:(float)time;

//duration 当前缓冲的长度
- (void)videoPlayer:(DWPlayerView *)playerView loadedTimeRangeDidChange:(float)duration;

//没数据 即播放卡顿
- (void)videoPlayerPlaybackBufferEmpty:(DWPlayerView *)playerView;

//有数据 能够继续播放
- (void)videoPlayerPlaybackLikelyToKeepUp:(DWPlayerView *)playerView;

//加载超时/scrub超时
- (void)videoPlayer:(DWPlayerView *)playerView receivedTimeOut:(DWPlayerViewTimeOut )timeOut;

//加载失败
- (void)videoPlayer:(DWPlayerView *)playerView didFailWithError:(NSError *)error;

//AVPlayerLayer对象发生改变时回调
- (void)videoPlayer:(DWPlayerView *)playerView ChangePlayerLayer:(AVPlayerLayer *)playerLayer;

@end

@interface DWPlayerView : UIView

/**
 播放属性
 */
@property(nonatomic,strong,readonly)AVPlayer *player;

/**
 播放图层
 */
@property(nonatomic,strong,readonly)AVPlayerLayer *playerLayer;

/**
 代理
 */
@property(nonatomic,weak)id<DWVideoPlayerDelegate> delegate;

/**
 AVPlayerLayer的videoGravity属性设置
 AVLayerVideoGravityResize,       // 非均匀模式。两个维度完全填充至整个视图区域
 AVLayerVideoGravityResizeAspect,  // 等比例填充，直到一个维度到达区域边界
 AVLayerVideoGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
 */
@property(nonatomic,copy)NSString *videoGravity;


/**
 //是否正在播放
 */
@property(nonatomic,assign,readonly)BOOL playing;


/**
 是否循环播放 默认为NO
 */
@property(nonatomic,assign)BOOL looping;


/**
 是否静音 默认为NO
 */
@property(nonatomic,assign)BOOL muted;


/**
 视频加载超时时间 默认30s
 */
@property(nonatomic,assign)CGFloat timeOutLoad;


/**
 缓存超时时间 默认30s
 */
@property(nonatomic,assign)CGFloat timeOutBuffer;


/**
 缓冲模式 默认DWPlayerViewLoadStyleDefault
 */
@property(nonatomic,assign)DWPlayerViewLoadStyle loadStyle;

/**
 是否开启防录屏模式，默认为NO。
 注意：此属性仅针对iOS11以上系统生效。
 */
@property(nonatomic,assign)BOOL videoProtect;

/**
 期待缓冲时长 默认 0，建议取值1 ~ 50 。
 注意：此属性仅针对iOS10以上系统， m3u8格式视频有效。
 */
@property(nonatomic,assign)NSTimeInterval forwardBufferDuration;

/**
 是否是备用线路
 */
@property(nonatomic,assign,readonly)BOOL isSpar;

/**
 当前正在播放的媒体清晰度model，非在线视频返回nil。注意，在调用playVodViedo:withCustomId:方法后才可获取到此属性
 */
@property (nonatomic,strong,readonly) DWVideoQualityModel * qualityModel;


/**
 返回当前播放的离线model，在线视频返回nil。注意，在调用playLocalVideo:方法后才可获取到此属性。
 */
@property (nonatomic,strong,readonly) DWDownloadModel * downloadModel;

/**
 当前播放时长
 */
@property (nonatomic,assign,readonly)NSTimeInterval playedTimes;

/**
 当前暂停时长
*/
@property (nonatomic,assign,readonly)NSTimeInterval pausedTimes;

/**
 单例

 @return 单例对象
 */
+ (instancetype)sharedInstance;

/**
 初始化播放对象

 @return DWPlayerView
 */
-(instancetype)init;

/**
 初始化播放对象

 @param frame 
 @return DWPlayerView
 */
-(instancetype)initWithFrame:(CGRect)frame;

/**
 播放网络视频 , 播放默认清晰度，对于在线媒体，必须要执行此方法，否则会导致数据统计缺失

 @param videoModel 视频model
 @param customId 用户自定义参数  有自定义统计参数需求／流量统计的客户必须传值，没有此需求的客户请传nil
 */
-(void)playVodViedo:(DWVodVideoModel *)videoModel withCustomId:(NSString *)customId;

/**
 播放本地视频

 @param downloadModel 下载model
 */
-(void)playLocalVideo:(DWDownloadModel *)downloadModel;

/**
 切换清晰度方法

 @param qualitiyModel 清晰度model
 @param customId 用户自定义参数  有自定义统计参数需求／流量统计的客户必须传值，没有此需求的客户请传nil
 */
-(void)switchQuality:(DWVideoQualityModel *)qualitiyModel withCustomId:(NSString *)customId;

/**
 切换备用线路 切换当前清晰度下的备用线路
 */
-(void)switchSparPlayLine;

/**
 设置是否允许后台播放

 @param play 是否允许后台播放
 */

- (void)setPlayInBackground:(BOOL)play;

/**
设置是否画中画模式

@param play 是否画中画模式
*/
- (void)setPictureInPicture:(BOOL)openPIP API_AVAILABLE(ios(9.0));

/**
 切换倍速
 
 @param rate 速率
 */
- (void)setPlayerRate:(float)rate;

/**
 重复播放当前媒体
 */
- (void)repeatPlay;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 拖到XX秒播放视频，在AVPlayerItemStatusReadyToPlay即状态处于可播放后 才会有效果

 @param time 跳转时间
 */
- (void)scrub:(float)time;

/**
 精确拖拽到XX秒播放视频，在AVPlayerItemStatusReadyToPlay即状态处于可播放后 才会有效果

 @param time 跳转时间
 @param completion 跳转完成回调
 */
-(void)scrubPrecise:(float)time CompletionHandler:(void(^)(BOOL finished))completion;

/**
 记录播放位置的方法(只为记忆播放功能使用 其它地方请调用scrub / scrubPrecise方法)，在AVPlayerItemStatusReadyToPlay即状态处于可播放后 才会有效果

 @param time 跳转时间
 */
- (void)oldTimeScrub:(float)time;

/**
 设置音量

 @param volume 音量
 */
- (void)setVolume:(float)volume;

/**
 加大音量
 */
- (void)fadeInVolume;

/**
 减小音量
 */
- (void)fadeOutVolume;

/**
 关闭|释放播放资源
 */
- (void)resetPlayer;

/**
 停止视频播放统计 播放页面关闭时务必调用removeTimer方法
 注意：播放页面关闭时 如需释放资源 调用方式如下{
                                          [playerView removeTimer];
                                          [playerView resetPlayer];
 
                                        }
 
                 如无需释放播放资源 调用方式如下{
                                            [playerView removeTimer];
                                            [playerView pause];
 }
 */
- (void)removeTimer;

// AirPlay技术 外部播放设置
/**
 支持AirPlay外部播放 默认支持
 */
- (void)enableAirplay;

/**
 不支持AirPlay外部播放
 */
- (void)disableAirplay;

/**
 检测是否支持支持AirPlay外部播放

 @return BOOL
 */
- (BOOL)isAirplayEnabled;

/**
 获取当前播放器截图
*/
- (UIImage *)screenShot;

/**
 获取可播放的持续时间

 @return 可播放的持续时间
 */
- (NSTimeInterval )playableDuration;


/**
 获取当前player播放的URL 可用于截图

 @return 当前播放URL
 */
-(NSURL *)urlOfCurrentlyPlayingInPlayer;


/**
 获取用来做GIF功能的URL 加密调用
 
 @return URL
 */
- (NSURL *)drmGIFURL;


/**
 获取用来做GIF功能的URL 非加密调用
 
 @return URL
 */
- (NSURL *)unDrmGIFURL;


/**
 问答统计 有此需求的客户调用 一个问题只发送一次
 
 @param videoId 视频ID
 @param questionId 问题ID
 @param answerId 用户选择的选项ID，以逗号分隔多个选项ID。
 如1345是单选 2067,3092,4789是多选
 @param status YES正确 NO错误
 */
- (void)reportQuestionWithVideoId:(NSString *)videoId questionId:(NSString *)questionId answerId:(NSString *)answerId status:(BOOL )status;


/**
 访客信息统计上报 有此需求的客户调用
 
 @param visitorId 访客信息收集器ID  必填
 @param videoId 视频ID 必填
 @param userId CC账号ID  必填
 @param message 上报信息 必填 具体格式详见demo
 */
-(void)reportVisitorCollectWithVisitorId:(NSString *)visitorId VideoId:(NSString *)videoId UserId:(NSString *)userId AndMessage:(NSString *)message;

/**
 课堂练习统计上报 有此需求的客户调用
 
 @param exercisesId 课堂练习ID 必填
 @param videoId 视频ID 必填
 @param userId CC账号ID  必填
 @param questionMes 上报信息 必填 具体格式详见demo
 @param completion  完成回调，返回课堂练习结果
 */
-(void)reportExercisesWithExercisesId:(NSString *)exercisesId videoId:(NSString *)videoId UserId:(NSString *)userId QuestionMes:(NSString *)questionMes AndCompletion:(void (^)(NSArray * resultArray,NSError * error))completion;

@end
