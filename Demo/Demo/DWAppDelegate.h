#import <UIKit/UIKit.h>

#import "DWSDK.h"

//#import "DWVodPlayerView.h"
@class DWVodPlayerView;

@interface DWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)UIWindow *window;

//窗口播放视图
@property(nonatomic,weak)DWVodPlayerView * vodPlayerView;
//视频列表。窗口播放时，跳转视频播放页面需要
@property(nonatomic,strong)NSArray * videoList;

@end
