#import <Foundation/Foundation.h>
@class DWVodVideoModel;

typedef void (^DWErrorBlock)(NSError *error);
typedef void (^DWPlayInfoFinishBlock)(DWVodVideoModel * vodVideo);

@interface DWPlayInfo : NSObject

/**
 *  @brief 请求超时时间，默认10s
 */
@property(assign, nonatomic)NSTimeInterval timeoutSeconds;

/**
 *  @brief 1为视频 2为音频 0为视频+音频，若不传该参数默认为视频
 */
@property(nonatomic,copy)NSString *mediatype;

/**
 *  @brief 授权验证码
 */
@property(nonatomic,copy)NSString *verificationCode;

/**
 *  @brief 客户端用户id，选填
 */
@property(nonatomic,strong)NSString * roleId;

/**
 *  @brief 请求失败回调
 */
@property(copy, nonatomic)DWErrorBlock errorBlock;

/**
 *  @brief 请求完成回调
 */
@property(copy, nonatomic)DWPlayInfoFinishBlock finishBlock;

/*!
 * @method
 * @abstract 初始化方法
 * @discussion 初始化方法
 * @param userId 账号id
 * @param key 账号key
 * @result DWPlayInfo对象
 */
-(id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId key:(NSString *)key;

/*!
 * @method
 * @abstract 初始化方法
 * @discussion 初始化方法
 * @param userId 账号id
 * @param videoId 视频id
 * @param key 账号key
 * @param hlsSupport 获取播放地址时，若账号支持hls，填@"1"会返回m3u8下载地址。获取下载地址时，请填@"0"
 * @result 操作结果
 */
-(id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId key:(NSString *)key hlsSupport:(NSString *)hlsSupport;

/*!
 * @method
 * @abstract 开始获取视频数据
 * @discussion 开始获取视频数据
 */
-(void)start;

/*!
 * @method
 * @abstract 取消获取视频数据
 * @discussion 取消之后，不会调用errorBlock或finishBlock
 * @param time 当前播放时间
 */
-(void)cancel;

@end
