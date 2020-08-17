
#import <Foundation/Foundation.h>
@class DWVodAdInfoModel;

typedef void (^DWErrorBlock)(NSError *error);
typedef void (^DWAdInfoFinishBlock)(DWVodAdInfoModel * adInfo);

///广告获取类
@interface DWAdInfo : NSObject

/**
 *  @brief 请求失败回调
 */
@property(copy, nonatomic)DWErrorBlock errorBlock;

/**
 *  @brief 请求完成回调
 */
@property(copy, nonatomic)DWAdInfoFinishBlock finishBlock;

/**
 *  @brief 请求超时时间，默认10s
 */
@property(assign, nonatomic)NSTimeInterval timeoutSeconds;

/*!
 * @method
 * @abstract 初始化方法
 * @discussion 初始化方法
 * @param userId 账号id
 * @param videoId 视频id
 * @param type 广告类型
 * @result DWAdInfo对象
 */
-(id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId type:(NSString *)type;

/*!
 * @method
 * @abstract 开始获取广告数据
 * @discussion 开始获取广告数据
 */
-(void)start;

@end
