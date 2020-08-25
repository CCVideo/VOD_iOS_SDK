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
/** 该属性只对iOS10以上系统生效
 */
typedef NS_ENUM(NSUInteger, DWPlayerViewLoadStyle) {
    DWPlayerViewLoadStyleDefault, //会提前缓冲，缓冲一部分开始播放
    DWPlayerViewLoadStyleImmediately //立即播放，无论先前是否进行过缓冲
};

@class DWPlayerView;

@protocol DWVideoPlayerDelegate <NSObject>

//所有的代理方法均已回到主线程 可直接刷新UI
@optional
/** 可播放
 @param playerView 自身对象
 */
-(void)videoPlayerIsReadyToPlayVideo:(DWPlayerView *)playerView;

/** 播放完毕
 @param playerView 自身对象
 */
-(void)videoPlayerDidReachEnd:(DWPlayerView *)playerView;

/** 获取播放进度
 @param playerView 自身对象
 @param time 当前播放时间
 */
-(void)videoPlayer:(DWPlayerView *)playerView timeDidChange:(float)time;

/** 获取缓冲进度
 @param playerView 自身对象
 @param duration 当前缓冲进度
 */
-(void)videoPlayer:(DWPlayerView *)playerView loadedTimeRangeDidChange:(float)duration;

/** 播放器缓存不足，播放卡顿
 @param playerView 自身对象
 */
-(void)videoPlayerPlaybackBufferEmpty:(DWPlayerView *)playerView;

/** 播放器缓存充足，可继续播放
 @param playerView 自身对象
 */
-(void)videoPlayerPlaybackLikelyToKeepUp:(DWPlayerView *)playerView;

/** 加载超时/scrub超时
 @param playerView 自身对象
 @param timeOut 超时类型
 */
-(void)videoPlayer:(DWPlayerView *)playerView receivedTimeOut:(DWPlayerViewTimeOut )timeOut;

/** 加载失败
 @param playerView 自身对象
 @param error 错误信息
 */
-(void)videoPlayer:(DWPlayerView *)playerView didFailWithError:(NSError *)error;

/** AVPlayerLayer对象发生改变时回调
 @param playerView 自身对象
 @param playerLayer 新的AVPlayerLayer对象
 */
-(void)videoPlayer:(DWPlayerView *)playerView ChangePlayerLayer:(AVPlayerLayer *)playerLayer;

@end

@interface DWPlayerView : UIView

/**
 *  @brief 播放属性
 */
@property(nonatomic,strong,readonly)AVPlayer *player;

/**
 *  @brief 播放图层
 */
@property(nonatomic,strong,readonly)AVPlayerLayer *playerLayer;

/**
 *  @brief 代理
 */
@property(nonatomic,weak)id<DWVideoPlayerDelegate> delegate;

/**
 *  @brief 视频填充模式，默认AVLayerVideoGravityResizeAspect
 */
@property(nonatomic,copy)NSString *videoGravity;

/**
 *  @brief 当前播放状态
 */
@property(nonatomic,assign,readonly)BOOL playing;

/**
 *  @brief 是否循环播放，默认为NO
 */
@property(nonatomic,assign)BOOL looping;

/**
 *  @brief 是否静音，默认为NO
 */
@property(nonatomic,assign)BOOL muted;

/**
 *  @brief 视频加载超时时间，默认30s
 */
@property(nonatomic,assign)CGFloat timeOutLoad;

/**
 *  @brief 缓存超时时间，默认30s
 */
@property(nonatomic,assign)CGFloat timeOutBuffer;

/**
 *  @brief 缓冲模式 默认DWPlayerViewLoadStyleDefault
 */
@property(nonatomic,assign)DWPlayerViewLoadStyle loadStyle;

/**
 *  @brief 是否开启防录屏模式，默认为NO。仅对iOS11以上系统生效
 */
@property(nonatomic,assign)BOOL videoProtect;

/**
 *  @brief 期待缓冲时长，默认0，建议取值1 ~ 50。仅对iOS10以上系统，m3u8格式视频有效
 */
@property(nonatomic,assign)NSTimeInterval forwardBufferDuration;

/**
 *  @brief 是否是备用线路
 */
@property(nonatomic,assign,readonly)BOOL isSpar;

/**
 *  @brief 当前正在播放的媒体清晰度model，非在线视频返回nil。注意，在调用playVodViedo:withCustomId:方法后才可获取到此属性
 */
@property(nonatomic,strong,readonly)DWVideoQualityModel * qualityModel;

/**
 *  @brief 返回当前播放的离线model，在线视频返回nil。注意，在调用playLocalVideo:方法后才可获取到此属性
 */
@property(nonatomic,strong,readonly)DWDownloadModel * downloadModel;

/**
 *  @brief 当前播放时长
 */
@property(nonatomic,assign,readonly)NSTimeInterval playedTimes;

/**
 *  @brief 当前暂停时长
 */
@property(nonatomic,assign,readonly)NSTimeInterval pausedTimes;

/*!
 * @method
 * @abstract 初始化播放对象
 * @discussion 以单例的形式，初始化播放对象
 * @result DWPlayerView对象
 */
+(instancetype)sharedInstance;

/*!
 * @method
 * @abstract 初始化播放对象
 * @discussion 初始化播放对象
 * @result DWPlayerView对象
 */
-(instancetype)init;

/*!
 * @method
 * @abstract 初始化播放对象
 * @discussion 初始化播放对象
 * @param frame 视图frame
 * @result DWPlayerView对象
 */
-(instancetype)initWithFrame:(CGRect)frame;

/*!
 * @method
 * @abstract 播放网络视频
 * @discussion 播放默认清晰度，对于在线媒体，必须要执行此方法，否则会导致数据统计缺失
 * @param videoModel 在线视频model
 * @param customId 用户自定义参数，有自定义统计参数需求／流量统计的客户必须传值，没有此需求的客户请传nil
 */
-(void)playVodViedo:(DWVodVideoModel *)videoModel withCustomId:(NSString *)customId;

/*!
 * @method
 * @abstract 播放本地视频
 * @discussion 播放本地视频
 * @param downloadModel 离线视频model
 */
-(void)playLocalVideo:(DWDownloadModel *)downloadModel;

/*!
 * @method
 * @abstract 切换清晰度方法
 * @discussion 切换清晰度方法
 * @param qualitiyModel 清晰度model
 * @param customId 用户自定义参数，有自定义统计参数需求／流量统计的客户必须传值，没有此需求的客户请传nil
 */
-(void)switchQuality:(DWVideoQualityModel *)qualitiyModel withCustomId:(NSString *)customId;

/*!
 * @method
 * @abstract 切换备用线路
 * @discussion 切换当前清晰度下的备用线路
 */
-(void)switchSparPlayLine;

/*!
 * @method
 * @abstract 后台播放功能
 * @discussion 开启/关闭后台播放功能
 * @param play 是否允许后台播放
 */
-(void)setPlayInBackground:(BOOL)play;

/*!
 * @method
 * @abstract 画中画功能
 * @discussion 开启/关闭画中画功能
 * @param openPIP 是否开启画中画功能
 */
-(void)setPictureInPicture:(BOOL)openPIP API_AVAILABLE(ios(9.0));

/*!
 * @method
 * @abstract 切换倍速
 * @discussion 切换倍速
 * @param rate 倍速速率
 */
-(void)setPlayerRate:(float)rate;

/*!
 * @method
 * @abstract 重复播放当前媒体
 * @discussion 重复播放当前媒体
 */
-(void)repeatPlay;

/*!
 * @method
 * @abstract 播放
 * @discussion 播放当前媒体资源
 */
-(void)play;

/*!
 * @method
 * @abstract 暂停
 * @discussion 暂停当前媒体资源
 */
-(void)pause;

/*!
 * @method
 * @abstract 拖到XX秒播放视频
 * @discussion 在AVPlayerItemStatusReadyToPlay即状态处于可播放后，拖拽生效
 * @param time 跳转时间
 */
-(void)scrub:(float)time;

/*!
 * @method
 * @abstract 拖到XX秒播放视频
 * @discussion 在AVPlayerItemStatusReadyToPlay即状态处于可播放后，拖拽生效
 * @param time 跳转时间
 * @param completion 跳转完成回调
 */
-(void)scrubPrecise:(float)time CompletionHandler:(void(^)(BOOL finished))completion;

/*!
 * @method
 * @abstract 记录播放位置的方法
 * @discussion 只为记忆播放功能使用，其它地方请调用scrub / scrubPrecise方法，在AVPlayerItemStatusReadyToPlay即状态处于可播放后 才会有效果
 * @param time 跳转时间
 */
-(void)oldTimeScrub:(float)time;

/*!
 * @method
 * @abstract 设置音量
 * @discussion 设置音量
 * @param volume 音量
 */
-(void)setVolume:(float)volume;

/*!
 * @method
 * @abstract 加大音量
 * @discussion 加大音量
 */
-(void)fadeInVolume;

/*!
 * @method
 * @abstract 减小音量
 * @discussion 减小音量
 */
-(void)fadeOutVolume;

/*!
 * @method
 * @abstract 关闭|释放播放资源
 * @discussion 关闭|释放播放资源
 */
-(void)resetPlayer;

/*!
 * @method
 * @abstract 停止视频播放统计
 * @discussion 播放页面关闭时务必调用removeTimer方法 注意：播放页面关闭时 如需释放资源 调用方式如下{
                                         [playerView removeTimer];
                                         [playerView resetPlayer];
                                       }
                如无需释放播放资源 调用方式如下{
                                         [playerView removeTimer];
                                         [playerView pause];
                                       }
 */
-(void)removeTimer;

/*!
 * @method
 * @abstract 触发一次震动
 * @discussion 触发一次震动
 */
-(void)shockFeedback;

//AirPlay技术 外部播放设置
/*!
 * @method
 * @abstract 支持AirPlay外部播放
 * @discussion 默认支持
 */
-(void)enableAirplay;

/*!
 * @method
 * @abstract 不支持AirPlay外部播放
 * @discussion 不支持AirPlay外部播放
 */
-(void)disableAirplay;

/*!
 * @method
 * @abstract 检测是否支持支持AirPlay外部播放
 * @discussion 检测是否支持支持AirPlay外部播放
 * @result 检测结果
 */
-(BOOL)isAirplayEnabled;

/*!
 * @method
 * @abstract 播放器截图
 * @discussion 获取播放器在当前时间点的截图
 * @result 图片对象
 */
-(UIImage *)screenShot;

/*!
 * @method
 * @abstract 获取可播放的持续时间
 * @discussion 获取可播放的持续时间
 * @result 可播放的持续时间
 */
-(NSTimeInterval)playableDuration;

/*!
 * @method
 * @abstract 获取当前player播放的URL
 * @discussion 可用于截图
 * @result 当前播放URL
 */
-(NSURL *)urlOfCurrentlyPlayingInPlayer;

/*!
 * @method
 * @abstract 获取用来做GIF功能的URL
 * @discussion 加密调用
 * @result 当前播放URL
 */
-(NSURL *)drmGIFURL;

/*!
 * @method
 * @abstract 获取用来做GIF功能的URL
 * @discussion 非加密调用
 * @result 当前播放URL
 */
-(NSURL *)unDrmGIFURL;

/*!
 * @method
 * @abstract 问答统计
 * @discussion 有此需求的客户调用，一个问题只发送一次
 * @param videoId 视频ID
 * @param questionId 问题ID
 * @param answerId 用户选择的选项ID，以逗号分隔多个选项ID，如1345是单选 2067,3092,4789是多选
 * @param status YES正确 NO错误
 */
-(void)reportQuestionWithVideoId:(NSString *)videoId questionId:(NSString *)questionId answerId:(NSString *)answerId status:(BOOL)status;

/*!
 * @method
 * @abstract 访客信息统计上报
 * @discussion 有此需求的客户调用
 * @param visitorId 访客信息收集器ID，必填
 * @param videoId 视频ID，必填
 * @param userId CC账号ID，必填
 * @param message 上报信息，必填，具体格式详见demo
 */
-(void)reportVisitorCollectWithVisitorId:(NSString *)visitorId VideoId:(NSString *)videoId UserId:(NSString *)userId AndMessage:(NSString *)message;

/*!
 * @method
 * @abstract 课堂练习统计上报
 * @discussion 有此需求的客户调用
 * @param exercisesId 课堂练习ID，必填
 * @param videoId 视频ID，必填
 * @param userId CC账号ID，必填
 * @param questionMes 上报信息，必填，具体格式详见demo
 * @param completion  完成回调，返回课堂练习结果
*/
-(void)reportExercisesWithExercisesId:(NSString *)exercisesId videoId:(NSString *)videoId UserId:(NSString *)userId QuestionMes:(NSString *)questionMes AndCompletion:(void (^)(NSArray * resultArray,NSError * error))completion;

@end
