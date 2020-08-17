//
//  DWCustomFullPlayerViewController.m
//  Demo
//
//  Created by zwl on 2019/3/7.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWVodPlayerSkinViewController.h"

@interface DWVodPlayerSkinViewController ()<DWPlayerSkinViewDelegate>

@property(nonatomic,strong)DWPlayerSkinView * playerSkinView;

@end

@implementation DWVodPlayerSkinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    self.playerSkinView = [[DWPlayerSkinView alloc]initSkinView];
    self.playerSkinView.screenScale = 4 / 3.0;
    self.playerSkinView.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerSkinView.title = self.vodModel.title;
    self.playerSkinView.delegate = self;
    [self.view addSubview:self.playerSkinView];
//    self.playerSkinView.allowAutoRotate = NO;
//    self.playerSkinView.isPortraitModel = YES;

    __weak typeof(self) weakSelf = self;
    DWPlayInfo * playInfo = [[DWPlayInfo alloc]initWithUserId:[DWConfigurationManager sharedInstance].DWAccount_userId andVideoId:self.vodModel.videoId key:[DWConfigurationManager sharedInstance].DWAccount_apikey hlsSupport:@"1"];
    playInfo.mediatype = @"0";
    playInfo.timeoutSeconds = 10;
    
    playInfo.errorBlock = ^(NSError *error) {
        NSLog(@"%d %@",__LINE__,error);
    };
    
    playInfo.finishBlock = ^(DWVodVideoModel *vodVideo) {
        NSLog(@"%@",vodVideo);
        
        [weakSelf.playerSkinView playVodViedo:vodVideo];
    };
    
    [playInfo start];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

-(void)dealloc
{
    NSLog(@"DWCustomFullPlayerViewController dealloc");
}

-(BOOL)shouldAutorotate
{
    return YES;
}
 
#pragma mark - DWPlayerSkinViewDelegate
/*
 !!! delegate方法可根据自己业务逻辑添加，这里仅做示例
 */
//准备播放
-(void)videoPlayerSkinReadyToPlay:(DWPlayerSkinView *)playerSkinView
{
    
}

//当前播放时长回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView timeDidChange:(NSTimeInterval)time
{
    //这里可以实现一些字幕，问答的逻辑，具体实现过程参考DWVodPlayerView中的逻辑
}

//媒体播放完毕回调
-(void)videoPlayerSkinEndToPlay:(DWPlayerSkinView *)playerSkinView
{
    [@"播放完成" showAlert];
}

//开始/暂停事件触发回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView PlayOrPauseAction:(BOOL)isPlay
{
//    NSLog(@"%s %d",__func__,isPlay);
}

//全屏/非全屏旋转回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView FullScreenAction:(BOOL)isScreen
{
//    NSLog(@"%s %d",__func__,isScreen);
}

//后退按钮回调 注意：若backPortrait为YES，会清空播放器。
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView ReturnBackAction:(BOOL)backPortrait
{
    if (!playerSkinView.allowAutoRotate) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (!backPortrait) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//倍速切换回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView SpeedSwitchAction:(CGFloat)speed
{
//    NSLog(@"%s %lf",__func__,speed);
}

//下载事件回调 ，返回当前播放清晰度model
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView DownloadAction:(DWVideoQualityModel *)qualityModel
{
    DWDownloadSessionManager * manager = [DWDownloadSessionManager manager];
    if ([manager checkLocalResourceWithVideoId:playerSkinView.videoModel.videoId WithQuality:qualityModel.quality]) {
        [@"当前视频已在下载队列中" showAlert];
        return;
    }
    
    if (playerSkinView.videoModel.authorize && !playerSkinView.videoModel.authorize.enable) {
        [@"授权验证未通过，无法下载" showAlert];
        return;
    }
    
    NSString * imageUrl = nil;
    NSString * title = @"";
    if (self.vodModel) {
        imageUrl = self.vodModel.imageUrl;
        title = self.vodModel.title;
    }else{
        imageUrl = @"icon_placeholder.png";
    }
    
    DWDownloadModel * downloadModel = [DWDownloadSessionManager createDownloadModel:playerSkinView.videoModel Quality:qualityModel.quality AndOthersInfo:@{@"imageUrl":imageUrl,@"title":title}];
    [manager startWithDownloadModel:downloadModel];
    [NSString stringWithFormat:@"开始下载此%@",[qualityModel.mediaType isEqualToString:@"1"] ? @"视频" : @"音频"];
}

//错误/警告信息回调
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView didFailWithError:(NSError *)error
{
    [error.localizedDescription showAlert];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
