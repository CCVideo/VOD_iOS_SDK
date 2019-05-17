//
//  DWGIFManager.h
//  GIF功能整合
//
//  Created by zwl on 2018/11/26.
//  Copyright © 2018 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, GIFQuality) {
    GIFQualityLow  = 0,
    GIFQualityMedium   = 1,
    GIFQualityHigh     = 2,
    GIFQualityVeryHigh     = 3,
};

/**
 
 * Gif制作完成回调
 
 * @param GifURL     GIF的本地URL(本地路径存储到tmp文件夹下，如果需要本地保存，请copy到自己需要的路径下)
 * @param error      错误原因
 
 */
typedef void(^CompleteBlock)(NSError *error,NSURL *GifURL);

@interface DWGIFManager : NSObject

/**
 
 * 制作完成GIF回调
 
 */
@property(nonatomic,copy) CompleteBlock completeBlock;

/**
 
 * 生成GIF质量
 
 */
@property(nonatomic,assign) GIFQuality quality;

/**
 
 * GIF播放的次数  0无限循环
 
 */
@property(nonatomic,assign) NSInteger loopCount;

/**
 
 * 是否正在录制gif
 
 */
@property(nonatomic,readonly) BOOL isRecording;

/**
 
 * 关联播放器，startRecordingGif录制开始前调用     !!!在每次startRecordingGif前，都要调用此方法
 
 * @param playUrl                 播放路径
 * @param currentPlayer           当前播放player
 * @param m3u8Method              为YES，会强制使用m3u8视频格式截取GIF方式，一般设置为NO即可
 
 */
-(void)associationWithUrl:(NSURL *)playUrl CurrentPlayer:(AVPlayer *)currentPlayer AndUseM3U8Method:(BOOL)m3u8Method;

/**
 
 * 开始录制gif
 
 */
-(void)startRecordingGif;

/**
 
 * 结束录制gif                如果视频播放完成，内部会自动调用此方法，完成GIF回调
 
 */
-(void)endRecordingGif;

/**
 
 * 取消录制gif
 
 */
-(void)cancelRecordGif;


/*------------------------------------以下方法已弃用，请及时更换----------------------------------*/

typedef NS_ENUM(NSInteger, GIFSize) {
    GIFSizeVeryLow  = 2,
    GIFSizeLow      = 3,
    GIFSizeMedium   = 5,
    GIFSizeHigh     = 7,
    GIFSizeOriginal = 10
};

/**
 
 截取视频
 @param error 错误信息
 @param outPutURL 视频导出的路径
 */
typedef void(^InterceptBlock)(NSError *error,NSURL *outPutURL);

//决定GIF图片的分辨率 默认GIFSizeMedium
@property (nonatomic,assign)GIFSize gifSize;

@property (nonatomic,copy)InterceptBlock interceptBlock;

/**
 
 
 @param videoUrl 视频的URL
 @param outPath 输出路径
 @param outputFileType 输出视频格式
 @param videoRange 截取视频的范围
 @param completeBlock 视频截取的回调
 */
- (void)interceptVideoAndVideoUrl:(NSURL *)videoUrl withOutPath:(NSString *)outPath outputFileType:(NSString *)outputFileType range:(NSRange)videoRange intercept:(InterceptBlock)interceptBlock __attribute__((deprecated("3.3.0 版本已过期")));


/**
 
 
 @param mediaUrlStr URL字符串
 @return 返回视频时长
 */
- (CGFloat)getMediaDurationWithMediaUrl:(NSString *)mediaUrlStr __attribute__((deprecated("3.3.0 版本已过期")));


/**
 生成GIF图片
 
 
 @param videoURL 视频的路径URL
 @param loopCount 播放次数
 @param time 每帧的时间间隔 默认0.25s
 @param imagePath 存放GIF图片的文件路径
 @param completeBlock 完成的回调
 
 */
- (void)createGIFfromURL:(NSURL*)videoURL loopCount:(int)loopCount delayTime:(CGFloat )time gifImagePath:(NSString *)imagePath complete:(CompleteBlock)completeBlock __attribute__((deprecated("3.3.0 版本已过期")));

/**
 生成GIF图片
 
 @param videoURL 视频的路径URL
 @param frameCount 视频的总时长乘以固定数值 如：视频总时长*4
 @param time 每帧的时间间隔
 @param loopCount 播放次数
 @param imagePath 存放GIF图片的文件路径
 @param completeBlock 完成的回调
 */
- (void)createGIFfromURL:(NSURL*)videoURL withFrameCount:(int)frameCount delayTime:(CGFloat )time loopCount:(int)loopCount gifImagePath:(NSString *)imagePath complete:(CompleteBlock)completeBlock __attribute__((deprecated("3.3.0 版本已过期")));

@end

