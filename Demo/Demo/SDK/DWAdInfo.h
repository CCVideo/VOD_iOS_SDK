
#import <Foundation/Foundation.h>
@class DWVodAdInfoModel;

typedef void (^DWErrorBlock)(NSError *error);
typedef void (^DWAdInfoFinishBlock)(DWVodAdInfoModel * adInfo);

@interface DWAdInfo : NSObject

@property (copy, nonatomic)DWErrorBlock errorBlock;
@property (copy, nonatomic)DWAdInfoFinishBlock finishBlock;

@property (assign, nonatomic)NSTimeInterval timeoutSeconds;//请求超时时间 默认10s

- (id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId type:(NSString *)type;

- (void)start;

@end
