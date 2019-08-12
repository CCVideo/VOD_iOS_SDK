#import <Foundation/Foundation.h>

@class DWUploader;

@protocol DWUploaderDelegate <NSObject>

@optional
//checkupload第一次请求成功的回调
- (void)checkUploadWithFilePath:(NSString  *)filePath;

@end

/**
 上传进度

 @param progress 上传进度
 @param totalBytesWritten 已上传数据大小
 @param totalBytesExpectedToWrite 总数据大小
 */
typedef void (^DWUploaderProgressBlock)(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);

/**
 视频上传上下文

 @param videoContext 保存视频上传上下文。它用来在 filaedBlock 被调用时，使用 initWithVideoContext: 方法重新初始化 uploader，调用 resume 方法继续上传。
 */
typedef void (^DWUploaderVideoContextForRetryBlock)(NSDictionary *videoContext);

/**
 上传成功时，被调用。
 */
typedef void (^DWUploaderFinishBlock)();


/**
 上传失败时，被调用

 @param error 错误
 */
typedef void (^DWErrorBlock)(NSError *error);


@interface DWUploader : NSObject

/**
 上传过程中HTTP通信请求超时时间
 */
@property (assign, nonatomic)NSTimeInterval timeoutSeconds;


/**
 在该block获取上传进度，可以在block内更新UI，如更新上传进度条。
 */
@property (copy, nonatomic)DWUploaderProgressBlock progressBlock;


/**
 上传完成时回调该block，可以在block内更新UI，如将视频标记为上传完成。
 */
@property (copy, nonatomic)DWUploaderFinishBlock finishBlock;


/**
 上传失败时回调该block，可以在该block内更新UI，如将视频标记为上传失败。
 */
@property (copy, nonatomic)DWErrorBlock failBlock;


/**
 在该block内获取上传上下文，并保存上传上下文，用来实现断线续传。
 */
@property (copy, nonatomic)DWUploaderVideoContextForRetryBlock videoContextForRetryBlock;


/**
 当遇到网络问题或服务器原因时上传暂停，回调该block。
 */
@property (copy, nonatomic)DWErrorBlock pausedBlock;


/**
 代理
 */
@property (nonatomic,weak)id<DWUploaderDelegate> delegate;

# pragma mark - functions

/**
 初始化上传对象

 @param userId 用户ID，不能为nil
 @param key 用户秘钥，不能为nil
 @param title 视频标题，不能为nil
 @param description 视频描述
 @param videoTag 视频标签
 @param videoPath 视频路径，不能为nil
 @param notifyURL 通知URL
 @return 上传对象
 */
- (id)initWithUserId:(NSString *)userId
              andKey:(NSString *)key
    uploadVideoTitle:(NSString *)title
    videoDescription:(NSString *)description
            videoTag:(NSString *)videoTag
           videoPath:(NSString *)videoPath
           notifyURL:(NSString *)notifyURL;

/**
  重新初始化上传对象

 @param videoContext  通过 videoContextTryBlock 获取的视频上传上下文。
                                      使用该方法重新初始化 uploader，调用 resume 方法继续上传。
                                      如果 videoContextTryBlock 未调用，则需要通过 initWithUserId:... 方法重新初始化对象，调用 start 重新上传。
 
 @return 成功返回上传对象，如果 videoContext 无效，则初始化失败，返回nil。
 */
- (id)initWithVideoContext:(NSDictionary *)videoContext;

/**
 添加视频水印，请在上传开始前调用此方法。

 @param text 水印文字内容, 1-50个字符，数字、字母、汉字，不填写则文字水印不生效
 @param corner 水印位置0,左上 1右上 2左下 3右下，默认3，非必填
 @param offsetX X轴偏移像素值，要求大于0，默认值5,超出视频大小按默认值，非必填
 @param offsetY Y轴偏移像素值，要求大于0，默认值5,超出视频大小按默认值，非必填
 @param fontFamily 字体类型：0,微软雅黑 1宋体 2黑体，默认0，非必填
 @param fontSize 字体大小，[0-100]，默认12
 @param fontColor 16进制字体颜色，如#FFFFFF，不能写#号，默认灰色D3D3D3，非必填
 @param fontAlpha 透明度，[0-100],默认100，100为不透明，非必填
 @return 是否设置成功。YES 设置成功，NO 设置失败，参数不合法
 */

-(BOOL)insertWaterMarkWithText:(NSString *)text
                        Corner:(NSNumber *)corner
                       OffsetX:(NSNumber *)offsetX
                       OffsetY:(NSNumber *)offsetY
                    FontFamily:(NSNumber *)fontFamily
                      FontSize:(NSNumber *)fontSize
                     FontColor:(NSString *)fontColor
                     FontAlpha:(NSNumber *)fontAlpha;


/**
 iscrop: @"1"为裁剪 @“0”不裁剪 不设置默认为不裁剪
 */
@property (nonatomic,copy)NSString *iscrop;

@property (nonatomic,copy)NSString *ew;

/**
 文件路径
 */
@property (nonatomic,copy,readonly)NSString *videoPath;

/**
 开始上传
 */
- (void)start;


/**
 暂停上传
 */
- (void)pause;


/**
 继续上传
 */
- (void)resume;


/**
 分类上传

 @param categoryId 分类
 */
- (void)category:(NSString *)categoryId;
@end
