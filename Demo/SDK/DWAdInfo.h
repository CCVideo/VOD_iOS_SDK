
#import <Foundation/Foundation.h>
typedef void (^DWErrorBlock)(NSError *error);
typedef void (^DWAdInfoFinishBlock)(NSDictionary *response);

@interface DWAdInfo : NSObject

@property (copy, nonatomic)DWErrorBlock errorBlock;
@property (copy, nonatomic)DWAdInfoFinishBlock finishBlock;

@property (assign, nonatomic)NSTimeInterval timeoutSeconds;//请求超时时间 默认10s

@property (assign, nonatomic)NSInteger time;//播放时间
@property (nonatomic,assign)NSInteger skiptime;// 跳过时间，单位秒，经过若干秒后显示跳过按钮，0代表立即显示跳过按钮
@property (assign, nonatomic)BOOL canClick;//是否能够点击广告跳转
@property (assign, nonatomic)BOOL canSkip;//是否可以跳过
@property (strong, nonatomic)NSMutableArray *ad;


- (id)initWithUserId:(NSString *)userId andVideoId:(NSString *)videoId type:(NSString *)type;

- (void)start;

@end
