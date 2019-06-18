#import <Foundation/Foundation.h>
@class DWVodVideoModel;

typedef void (^DWErrorBlock)(NSError *error);
typedef void (^DWPlayInfoFinishBlock)(DWVodVideoModel * vodVideo);

@interface DWPlayInfo : NSObject

@property (assign, nonatomic)NSTimeInterval timeoutSeconds;

//1为视频 2为音频 0为视频+音频 若不传该参数默认为视频
@property (nonatomic,copy)NSString *mediatype;

@property (nonatomic,copy)NSString *verificationCode;//授权验证码

@property (copy, nonatomic)DWErrorBlock errorBlock;
@property (copy, nonatomic)DWPlayInfoFinishBlock finishBlock;

- (id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId key:(NSString *)key;
- (id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId key:(NSString *)key hlsSupport:(NSString *)hlsSupport;

- (void)start;  

@end
