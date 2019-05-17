//

//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DWPlayerViewTimeOut) {
    
    DWPlayerViewStatusTimeOutLoad,//加载超时
    DWPlayerViewStatusTimeOutBuffer //缓存超时
};


@class DWPlayerView;

@protocol DWVideoPlayerDelegate <NSObject>

@optional

/*
 *
 *AVPlayerItem的三种状态
 *AVPlayerItemStatusUnknown,
 *AVPlayerItemStatusReadyToPlay,
 *AVPlayerItemStatusFailed
 */

//所有的代理方法均已回到主线程 可直接刷新UI
// 可播放
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

//加载失败
- (void)videoPlayer:(DWPlayerView *)playerView didFailWithError:(NSError *)error;

//加载超时/scrub超时
- (void)videoPlayer:(DWPlayerView *)playerView receivedTimeOut:(DWPlayerViewTimeOut )timeOut;

//未知状态
- (void)videoPlayerDidUnknown:(DWPlayerView *)playerView;

@end

typedef void (^DWErrorBlock)(NSError *error);
typedef void(^DWVideoPlayerGetPlayUrlsBlock)(NSDictionary *playUrls);

@interface DWPlayerView : UIView<NSXMLParserDelegate>

@property (nonatomic, weak) id<DWVideoPlayerDelegate> delegate;

//播放属性
@property (nonatomic, strong) AVPlayer      *player;
@property (nonatomic, strong) AVPlayerItem  *item;
@property (nonatomic, strong) AVURLAsset    *urlAsset;
@property (nonatomic, strong) AVPlayerLayer  *playerLayer;



/**
 
 AVPlayerLayer的videoGravity属性设置
 AVLayerVideoGravityResize,       // 非均匀模式。两个维度完全填充至整个视图区域
 AVLayerVideoGravityResizeAspect,  // 等比例填充，直到一个维度到达区域边界
 AVLayerVideoGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
 */
@property (nonatomic, copy) NSString         *videoGravity;

@property (nonatomic, assign,readonly) BOOL playing; //播放时为YES 暂停时为NO
@property (nonatomic, assign) BOOL looping;//是否循环播放 默认为NO
@property (nonatomic, assign) BOOL muted;//是否静音 默认为NO 

@property (copy, nonatomic)NSString *userId;//用户ID
@property (copy, nonatomic)NSString *videoId;//视频ID
@property (copy, nonatomic)NSString *key;//用户的key

@property (assign, nonatomic)NSTimeInterval timeoutSeconds;//请求播放信息超时时间

@property (assign,nonatomic)CGFloat timeOutLoad;//视频加载超时时间 默认30s

@property (assign,nonatomic)CGFloat timeOutBuffer;//缓存超时时间 默认30s

@property (nonatomic,copy)NSString *verificationCode;//授权验证码 没有此功能的用户无需设置


//1为视频 2为音频 0为视频+音频 若不传该参数默认为视频
@property (nonatomic,copy)NSString *mediatype;

@property (copy, nonatomic)DWVideoPlayerGetPlayUrlsBlock getPlayUrlsBlock;


/**
 *  @brief 获取视频播放信息或播放过程中发生错误或失败时，回调该block。可以在该block内更新UI，如更改视频播放状态。
 */
@property (copy, nonatomic)DWErrorBlock failBlock;


/**
 *  @brief drmServer 绑定的端口。
 *
 *  若你使用了DRM视频加密播放服务，则必须先启动 DWDrmServer，并在调用 play 之前，设置 drmServerPort 设置为 DWDrmServer 绑定的端口。
 */
@property (assign, nonatomic)UInt16 drmServerPort;

//单列
+ (instancetype)sharedInstance;

/**
 *  @brief 初始化播放对象
 *
 *  @param userId      用户ID，不能为nil
 *  @param videoId     即将播放的视频ID，不能为nill
 *  @param key         用户秘钥，不能为nil
 *
 *  @return 播放对象
 */
- (id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId key:(NSString *)key;

/**
 *  @brief 初始化播放对象
 *
 *  @param userId      用户ID，不能为nil
 *  @param key         用户秘钥，不能为nil
 *
 *  @return 播放对象
 */
- (id)initWithUserId:(NSString *)userId key:(NSString *)key;

/**
 *  @brief 开始请求视频播放信息。
 */
- (void)startRequestPlayInfo;



/*setURL方法 添加播放资源   如果有正在播放的资源，会释放掉当前播放的资源
 *customId 用户自定义参数  有自定义统计参数需求／流量统计的客户必须传值
                       没有此需求的客户请传nil
 *在不需要统计的地方均传nil 譬如广告视频
 */
- (void)setURL:(NSURL *)URL withCustomId:(NSString *)customId;


//切换清晰度方法
- (void)switchQuality:(NSURL *)URL;

//切换倍速的方法
- (void)setPlayerRate:(float)rate;

//重复播放的方法
- (void)repeatPlay;


//播放
- (void)play;

//暂停
- (void)pause;

// 关闭|释放播放资源
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
//支持AirPlay外部播放 默认支持 
- (void)enableAirplay;
//不支持AirPlay外部播放
- (void)disableAirplay;

//检测是否支持支持AirPlay外部播放
- (BOOL)isAirplayEnabled;

/*
 *scrub:方法和oldTimeScrub:方法 在AVPlayerItemStatusReadyToPlay即状态处于可播放后 才会有效果
*/

//拖到XX秒播放视频
- (void)scrub:(float)time;

//记录播放位置的方法(只为记忆播放功能使用 其它地方请调用scrub方法)
- (void)oldTimeScrub:(float)time;

// Volume

//设置音量
- (void)setVolume:(float)volume;
//加大音量
- (void)fadeInVolume;
//减小音量
- (void)fadeOutVolume;  

//获取可播放的持续时间
- (NSTimeInterval )playableDuration;

//获取当前player播放的URL 可用于截图
-(NSURL *)urlOfCurrentlyPlayingInPlayer;


//获取用来做GIF功能的URL 加密调用
- (NSURL *)drmGIFURL;

//获取用来做GIF功能的URL 非加密调用
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

@end
