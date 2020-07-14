#import <Foundation/Foundation.h>
@class DWVodVideoModel;

typedef void (^DWErrorBlock)(NSError *error);
typedef void (^DWPlayInfoFinishBlock)(DWVodVideoModel * vodVideo);

@interface DWPlayInfo : NSObject

//请求超时时间，默认10s
@property (assign, nonatomic)NSTimeInterval timeoutSeconds;

//1为视频 2为音频 0为视频+音频 若不传该参数默认为视频
@property (nonatomic,copy)NSString *mediatype;

//授权验证码
@property (nonatomic,copy)NSString *verificationCode;

//客户端用户id，选填
@property(nonatomic,strong)NSString * roleId;

//请求失败回调
@property (copy, nonatomic)DWErrorBlock errorBlock;

//请求完成回调
@property (copy, nonatomic)DWPlayInfoFinishBlock finishBlock;

/// 初始化方法
/// @param userId 账号id
/// @param videoId 视频id
/// @param key 账号key
- (id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId key:(NSString *)key;

/// 初始化方法
/// @param userId 账号id
/// @param videoId 视频id
/// @param key 账号key
/// @param hlsSupport 获取播放地址时，若账号支持hls，填@"1"会返回m3u8下载地址。获取下载地址时，请填@"0"
- (id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId key:(NSString *)key hlsSupport:(NSString *)hlsSupport;

/// 开始获取视频数据
- (void)start;  

/// 取消获取视频数据，取消之后，不会调用errorBlock或finishBlock。
- (void)cancel;

@end
