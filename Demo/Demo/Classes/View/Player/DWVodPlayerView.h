//
//  DWVodPlayerView.h
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWVodPlayerView;

NS_ASSUME_NONNULL_BEGIN

@protocol DWVodPlayerViewDelegate <NSObject>

@optional
//返回事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView ReturnBackAction:(BOOL)isFull;
//播放状态改变事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView PlayStatus:(BOOL)isPlaying;
//选集选择事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView ChooseSelection:(NSInteger)selectionIndex;
//播放下一集事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView NextSelection:(NSInteger)nextIndex;
//投屏跳转事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView ScreeningJumpAction:(NSString *)playUrl;
//网络检测事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView DidNetworkMonitor:(NSString *)vid AndPlayUrl:(NSString *)playUrl;
//访客信息收集器，退出填写
-(void)vodPlayerViewVisitorReturnBack:(DWVodPlayerView *)playerView;
//窗口模式播放
-(void)vodPlayerViewDidEnterWindowsModel:(DWVodPlayerView *)playerView;

@end

/*
 !!! 此view仅做功能演示使用，页面逻辑仅做参考
 */

@interface DWVodPlayerView : UIView

@property(nonatomic,weak) id <DWVodPlayerViewDelegate> delegate;

@property(nonatomic,strong,readonly)DWVodVideoModel * videoModel;

@property(nonatomic,strong,readonly)DWDownloadModel * downloadModel;

//选集列表
@property(nonatomic,strong)NSArray * selectionList;

//视频数据，下载时，保存视频URL时使用。
@property(nonatomic,strong)DWVodModel * vodModel;

//是否在投屏
@property(nonatomic,assign)BOOL isScreening;

//当前视频标题
@property(nonatomic,strong,readonly)NSString * videoTitle;

//当前播放时间
@property(nonatomic,assign)CGFloat currentPlayDuration;

-(void)reLayoutWithScreenState:(BOOL)isFull;

//播放在线视频
-(void)setVodVideo:(DWVodVideoModel *)videoModel;

//播放本地视频
-(void)playLocalVideo:(DWDownloadModel *)downloadModel;

-(void)play;

-(void)pause;

//清理player
-(void)closePlayer;

//进入窗口模式
-(void)enterWindowsModel;

//退出窗口模式
-(void)quitWindowsModel;

@end

NS_ASSUME_NONNULL_END
