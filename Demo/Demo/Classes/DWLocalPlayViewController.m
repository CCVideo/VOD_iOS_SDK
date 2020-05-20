//
//  DWLoaclPlayViewController.m
//  Demo
//
//  Created by zwl on 2019/4/26.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWLocalPlayViewController.h"
#import "DWVodPlayerView.h"
#import "DWPlayerSkinView.h"

@interface DWLocalPlayViewController ()<DWVodPlayerViewDelegate,DWPlayerSkinViewDelegate>

@property(nonatomic,strong)DWVodPlayerView * playerView;

@property(nonatomic,strong)DWPlayerSkinView * playerSkinView;

@end

@implementation DWLocalPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (DWAPPDELEGATE.vodPlayerView) {
        self.playerView = DWAPPDELEGATE.vodPlayerView;
        [self.playerView quitWindowsModel];
    }else{
        self.playerView = [[DWVodPlayerView alloc]init];
    }

    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    if (DWAPPDELEGATE.vodPlayerView) {
        if ([DWAPPDELEGATE.vodPlayerView.downloadModel.videoId isEqualToString:self.downloadModel.videoId]) {
            return;
        }
    }
    [self.playerView playLocalVideo:self.downloadModel];
    
    /*
    //若需体验SDK自带皮肤的播放器，请将上面代码注释掉，使用下面的代码即可。
    self.playerSkinView = [[DWPlayerSkinView alloc]initSkinView];
    self.playerSkinView.delegate = self;
    self.playerSkinView.allowAutoRotate = NO;
    self.playerSkinView.isPortraitModel = NO;
    [self.view addSubview:self.playerSkinView];
    [_playerSkinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.playerSkinView playLocalVideo:self.downloadModel];
     */
    
}

-(void)dealloc
{
    NSLog(@"DWLocalPlayViewController dealloc");
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    [self.playerView reLayoutWithScreenState:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - DWVodPlayerViewDelegate
-(void)vodPlayerView:(DWVodPlayerView *)playerView ReturnBackAction:(BOOL)isFull
{
    DWAPPDELEGATE.vodPlayerView = nil;
    [self.playerView closePlayer];
    [self.navigationController popViewControllerAnimated:YES];
}

//窗口模式播放
-(void)vodPlayerViewDidEnterWindowsModel:(DWVodPlayerView *)playerView
{
    DWAPPDELEGATE.vodPlayerView = self.playerView;
    [DWAPPDELEGATE.vodPlayerView enterWindowsModel];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
-(void)videoPlayerSkin:(DWPlayerSkinView *)playerSkinView ReturnBackAction:(BOOL)backPortrait
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)videoPlayerSkinEndToPlay:(DWPlayerSkinView *)playerSkinView
{
    [@"播放完成" showAlert];
}
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
