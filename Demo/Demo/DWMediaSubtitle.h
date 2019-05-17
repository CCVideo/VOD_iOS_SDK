#import <Foundation/Foundation.h>

@interface DWMediaSubtitle : NSObject

@property (strong, nonatomic)NSError *error;

/**
 *  初始化srt字幕
 *
 *  @param path 字幕文件，目前支持是本地文件
 *
 *  @return DWMeidaSubtitle
 */
- (id)initWithSRTPath:(NSString *)path;

- (void)requestSTRURL:(NSURL *)URL didComplete:(void(^)(NSError *error,NSMutableDictionary *dictionary))completeBlock;

/**
 *  开始解析
 *
 *  @return  成功返回 YES，失败返回 NO，通过 error获取错误。
 */
- (BOOL)parse;

/**
 *  获取某一时间对应的字幕
 *
 *  @param currentPlaybackTime 指定一个时间
 *
 *  @return 返回指定时间对应的字幕，如果未找到，则返回nil;
 */
- (NSString *)searchWithTime:(NSTimeInterval)currentPlaybackTime;

@end
