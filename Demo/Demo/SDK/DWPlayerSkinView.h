//
//  DWPlayerFullView.h
//  Demo
//
//  Created by zwl on 2019/3/6.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWPlayerView.h"

NS_ASSUME_NONNULL_BEGIN
@class DWPlayerSkinView;

@protocol DWPlayerSkinViewDelegate <NSObject>

//所有的代理方法均已回到主线程 可直接刷新UI
@optional
//准备播放
-(void)videoPlayerSkinReadyToPlay:(DWPlayerSkinView *)playerSkinView;

//当前播放时长回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView timeDidChange:(NSTimeInterval)time;

//媒体播放完毕回调
-(void)videoPlayerSkinEndToPlay:(DWPlayerSkinView *)playerSkinView;

//开始/暂停事件触发回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView PlayOrPauseAction:(BOOL)isPlay;

//全屏/非全屏旋转回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView FullScreenAction:(BOOL)isScreen;

//后退按钮回调 注意：若backPortrait为YES，会清空播放器。
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView ReturnBackAction:(BOOL)backPortrait;

//倍速切换回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView SpeedSwitchAction:(CGFloat)speed;

//下载事件回调 ，返回当前播放清晰度model
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView DownloadAction:(DWVideoQualityModel *)qualityModel;

//错误/警告信息回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView didFailWithError:(NSError *)error;

@end

@interface DWPlayerSkinView : UIView

/**
 delegate
 */
@property(nonatomic,weak) id<DWPlayerSkinViewDelegate> delegate;

/**
 当期视频标题
 */
@property(nonatomic,strong)NSString * title;

/**
 在线视频model
 */
@property(nonatomic,strong,readonly)DWVodVideoModel * videoModel;

/**
 离线视频model
 */
@property(nonatomic,strong,readonly)DWDownloadModel * downloadModel;

/**
 DWPlayerView 对象
 */
@property(nonatomic,strong,readonly)DWPlayerView * player;

/**
 用户自定义参数  有自定义统计参数需求／流量统计的客户必须传值
 没有此需求的客户请传nil
 在不需要统计的地方均传nil 譬如广告视频
 */
@property(nonatomic,copy)NSString * customId;

/**
 AVLayerVideoGravityResize,       // 非均匀模式。两个维度完全填充至整个视图区域
 AVLayerVideoGravityResizeAspect,  // 等比例填充，直到一个维度到达区域边界
 AVLayerVideoGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
 */
@property(nonatomic,strong)NSString * videoGravity;

/**
 宽高比 默认是4:3
 若需改变view的大小，请设置此属性，不要直接设置frame
 */
@property(nonatomic,assign)CGFloat screenScale;

/**
 是否在播放中 YES 正在播放，NO 暂停播放
 */
@property(nonatomic,assign,readonly)BOOL isPlaying;

/**
 当前是否全屏  YES 全屏，NO 非全屏
 */
@property(nonatomic,assign,readonly)BOOL isFull;

/**
 当前播放倍速  默认 1
 */
@property(nonatomic,assign,readonly)CGFloat speed;

/**
 当期播放媒体是否是视频 YES 视频，NO 音频
 */
@property(nonatomic,assign,readonly)BOOL isPlayVideo;

/**
 媒体总时长 收到videoPlayerSkinReadyToPlay回调以后 生效
 */
@property(nonatomic,assign,readonly)NSTimeInterval totalDuration;

/**
 当前播放时间
 */
@property(nonatomic,assign,readonly)NSTimeInterval currentDuration;

/**
 当前缓冲时间 只对在线视频有效，离线视频为0
 */
@property(nonatomic,assign,readonly)NSTimeInterval bufferDuration;

/**
 媒体播放的起始位置
 如果设置此值 收到videoPlayerSkinReadyToPlay回调以后，会自动跳转到当前进度，包括切换清晰度时，也会拖拽到此。 默认为0
 */
@property(nonatomic,assign)NSTimeInterval scrubPosition;

/**
 是否允许自动旋转 默认YES ，若设置NO，屏幕旋转时，将不会改变view的大小
 */
@property(nonatomic,assign)BOOL allowAutoRotate;

/**
 播放器默认横竖屏状态设置
 仅在自动旋转功能关闭的情况下生效 会强制转换屏幕，需跟allowAutoRotate搭配使用。 默认YES，竖屏模式
 */
@property(nonatomic,assign)BOOL isPortraitModel;

/**
 初始化方法，请调用此方法，不要调用init，initWithFrame等初始化方法
 
 @return DWPlayerSkinView对象
 */
-(instancetype)initSkinView;

/**
 设置播放网络视频数据，并开始播放

 @param videoModel DWVodVideoModel对象
 */
-(void)playVodViedo:(DWVodVideoModel *)videoModel;

/**
 设置播放本地视频，并开始播放

 @param downloadModel DWDownloadModel对象
 */
-(void)playLocalVideo:(DWDownloadModel *)downloadModel;


@end

NS_ASSUME_NONNULL_END
