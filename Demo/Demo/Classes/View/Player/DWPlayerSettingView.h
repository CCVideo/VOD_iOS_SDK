//
//  DWPlayerSettingView.h
//  Demo
//
//  Created by zwl on 2019/4/17.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWTableChooseModel;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DWVodSettingStyle) {
    DWVodSettingStyleListSpeed,    //倍速列表
    DWVodSettingStyleListQuality,    //清晰度列表
    DWVodSettingStyleListChooseSelection,   //选集列表
    DWVodSettingStyleTotal      //整体设置
};

@protocol DWPlayerSettingViewDelegate <NSObject>

-(void)playerSettingViewStyle:(DWVodSettingStyle)style AndSelectIndex:(NSInteger)selectIndex;

//DWVodSettingStyleTotal 回调
//下载回调
-(void)playerSettingViewDownloadAction;
//投屏回调
-(void)playerSettingViewScreeningAction;
//音视频回调
-(void)playerSettingViewMediaTypeAction;
//网络检测回调
-(void)playerSettingViewNetworkMonitorAction;
//画面尺寸回调
-(void)playerSettingViewScreenSizeSelect;
//字幕回调
-(void)playerSettingViewSubtitleSelect;
//屏幕亮度改变回调
-(void)playerSettingViewScreenLightChange:(CGFloat)changeValue;
//系统音量改变回调
-(void)playerSettingViewSoundChange:(CGFloat)changeValue;
//窗口播放
-(void)playerSettingWindowsPlay;
//动感开关
-(void)playerSettingViewImpactSelect:(BOOL)isSelect;

@end

@interface DWPlayerSettingView : UIView

@property(nonatomic,weak) id <DWPlayerSettingViewDelegate> delegate;

//选集list，非选集不需要设置
@property(nonatomic,strong)NSArray * selectionList;

-(instancetype)initWithStyle:(DWVodSettingStyle)style;

//设置list数据
-(void)setTableList:(NSArray *)listArray;

//设置total数据
-(void)setTotalMediaType:(BOOL)isVideo SizeList:(NSArray *)sizeList SubtitleList:(NSArray *)subTitleList DefaultLight:(CGFloat)light DefaultSound:(CGFloat)sound AndDeafultImpact:(BOOL)impact;

-(void)show;

-(void)disAppear;

@end

@interface DWPlayerSettingTableViewCell : UITableViewCell

@property(nonatomic,strong)DWTableChooseModel * chooseModel;

@end

@interface DWPlayerSelectionTableViewCell : UITableViewCell

@property(nonatomic,strong)DWTableChooseModel * chooseModel;

-(void)setSectionImage:(NSString *)imageUrl;

@end

NS_ASSUME_NONNULL_END
