//
//  DWVodPlayViewController.m
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWVodPlayViewController.h"
#import "DWVodPlayTableViewCell.h"
#import "DWVodPlayBottomView.h"
#import "DWVodPlayerView.h"
#import "DWAdShouView.h"
#import "DWNetworkMonitorViewController.h"
#import "DWScreeningListViewController.h"
#import "DWScreeningBgView.h"

typedef enum : NSUInteger {
    DWVodPlayTableViewCellStyleDefault,
    DWVodPlayTableViewCellStyleChoose,
} DWVodPlayTableViewCellStyle;

@interface DWVodPlayViewController ()<UITableViewDelegate,UITableViewDataSource,DWVodPlayBottomViewDelegate,DWVodPlayerViewDelegate,DWAdShouViewDelegate,DWScreeningListViewControllerDelegate,DWScreeningBgViewDelegate>

@property(nonatomic,assign)CGSize playerViewSize;
@property(nonatomic,strong)DWVodPlayerView * playerView;
@property(nonatomic,strong)UITableView * listTableView;
@property(nonatomic,strong)DWVodPlayBottomView * bottomView;

@property(nonatomic,assign)DWVodPlayTableViewCellStyle cellStyle;

@property(nonatomic,strong)DWAdShouView * adShowView;//广告

@property(nonatomic,strong)DWScreeningBgView * screenBgView;//投屏控制器

@end

@implementation DWVodPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    [self initParams];
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChangeNotification) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //判断是否小窗播放
    if (DWAPPDELEGATE.vodPlayerView) {
        if ([DWAPPDELEGATE.vodPlayerView.videoModel.videoId isEqualToString:self.vodModel.videoId]) {
            //当前正在窗口播放的视频
            return;
        }
    }
    
    DWConfigurationManager * manager = [DWConfigurationManager sharedInstance];
    if (manager.isOpenAd) {
        //广告模式
        [self startRequestAdInfo:1];
    }else{
        //正常播放
        [self startRequestVideo:self.vodModel.videoId];
    }

}

-(void)startRequestVideo:(NSString *)videoId
{
    __weak typeof(self) weakSelf = self;

    DWPlayInfo * playInfo = [[DWPlayInfo alloc]initWithUserId:[DWConfigurationManager sharedInstance].DWAccount_userId andVideoId:videoId key:[DWConfigurationManager sharedInstance].DWAccount_apikey hlsSupport:@"1"];
    playInfo.timeoutSeconds = 30;
    //音频 + 视频数据，这里仅做示范，可根据自己项目业务逻辑来调整
    playInfo.mediatype = @"0";
    //开启授权验证功能传入
    playInfo.verificationCode = [DWConfigurationManager sharedInstance].verification;
    //客户端用户id，选填
//    playInfo.roleId = @"";
    playInfo.finishBlock = ^(DWVodVideoModel *vodVideo) {
        NSLog(@"%@",vodVideo);
        //下载时，保存图片，名字等数据
        weakSelf.playerView.vodModel = weakSelf.vodModel;
        [weakSelf.playerView setVodVideo:vodVideo];
    };
    playInfo.errorBlock = ^(NSError *error) {
        [error.localizedDescription showAlert];
    };
    [playInfo start];
}

//1片头广告，2暂停广告，3片尾广告
-(void)startRequestAdInfo:(int)type
{
    __weak typeof(self) weakSelf = self;
    DWAdInfo * adInfo = [[DWAdInfo alloc]initWithUserId:[DWConfigurationManager sharedInstance].DWAccount_userId andVideoId:self.vodModel.videoId type:[NSString stringWithFormat:@"%d",type]];
    [adInfo start];
    adInfo.finishBlock = ^(DWVodAdInfoModel *adInfo) {
        //若获取完广告信息时，没有显示广告视图，不加载广告
        if (!weakSelf.adShowView.hidden) {
            weakSelf.playerView.isShowAd = NO;
            return;
        }
        
        [weakSelf.adShowView playAdVideo:adInfo];
    };
    adInfo.errorBlock = ^(NSError *error) {
        
        weakSelf.playerView.isShowAd = NO;

        //片尾广告请求失败，继续播放下一集
        if (type == 3) {
            [weakSelf.playerView playNextVideo];
            return;
        }
        
        if (type == 1) {
            [weakSelf startRequestVideo:weakSelf.vodModel.videoId];
        }
        
//        [@"广告请求失败" showAlert];
//        [error.localizedDescription showAlert];
    };

    self.playerView.isShowAd = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)dealloc
{
    NSLog(@"DWVodPlayViewController dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)screenOrientationDidChange:(BOOL)isFull
{
    self.listTableView.hidden = isFull;
    self.bottomView.hidden = isFull;
    
    if (isFull) {
        [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(@0);
            make.right.and.bottom.equalTo(@0);
        }];
        
        [_adShowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(@0);
            make.right.and.bottom.equalTo(@0);
        }];
        
        if (self.screenBgView) {
            [_screenBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.and.top.equalTo(@0);
                make.right.and.bottom.equalTo(@0);
            }];

        }
    }else{
        [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(@0);
            make.width.equalTo(@(self.playerViewSize.width));
            make.height.equalTo(@(self.playerViewSize.height));
        }];
        
        [_adShowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(@0);
            make.width.equalTo(@(self.playerViewSize.width));
            make.height.equalTo(@(self.playerViewSize.height - 40));
        }];
        
        if (self.screenBgView) {
            [_screenBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.equalTo(@0);
                make.width.equalTo(@(self.playerViewSize.width));
                make.height.equalTo(@(self.playerViewSize.height));
            }];
        }
    }
    
    [self.adShowView screenRotate:isFull];
    [self.playerView reLayoutWithScreenState:isFull];

    if (self.screenBgView) {
        [self.screenBgView screenRotate:isFull];
    }
}

#pragma mark - notification
-(void)deviceOrientationChangeNotification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationUnknown:{
            break;
        }
        case UIInterfaceOrientationPortrait:{
            [self screenOrientationDidChange:NO];
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:{
            [self screenOrientationDidChange:YES];
            break;
        }
        case UIInterfaceOrientationLandscapeRight:{
            [self screenOrientationDidChange:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - DWAdShouViewDelegate
-(void)adShowPlayDidFinish:(DWAdShouView*)adShowView AndAdType:(NSInteger)type
{
    self.playerView.isShowAd = NO;

    if (type == 1) {
        //片头广告结束，播放正片
        [self startRequestVideo:self.vodModel.videoId];
    }
    
    if (type == 2) {
        //暂停广告结束，继续播放
        [self.playerView play];
    }
    
    if (type == 3) {
        //片尾广告结束，播放下一集
        [self.playerView playNextVideo];
    }
    
}

-(void)adShowPlay:(DWAdShouView*)adShowView DidScreenRotate:(BOOL)isFull
{
    if (isFull) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }else{
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }
}

#pragma mark - DWVodPlayerViewDelegate
//返回事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView ReturnBackAction:(BOOL)isFull
{
    if (!isFull) {
        DWAPPDELEGATE.vodPlayerView = nil;
        [self.playerView closePlayer];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
}

//播放状态改变事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView PlayStatus:(BOOL)isPlaying
{
    if (![DWConfigurationManager sharedInstance].isOpenAd) {
        return;
    }
    
    if (!isPlaying) {
        //播放暂停广告
        [self startRequestAdInfo:2];
    }else{
        if (!self.adShowView.hidden) {
            [self.adShowView adFinish];
        }
        self.playerView.isShowAd = NO;
    }
}

//选集选择事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView ChooseSelection:(NSInteger)selectionIndex
{
    DWVodModel * vodModel = [self.vidoeList objectAtIndex:selectionIndex];
    self.vodModel = vodModel;
    [self startRequestVideo:self.vodModel.videoId];
    [self.listTableView reloadData];
}

//播放下一集事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView NextSelection:(NSInteger)nextIndex
{
    if (!self.adShowView.hidden) {
        [self.adShowView adFinish];
    }
    self.playerView.isShowAd = NO;

    DWVodModel * vodModel = [self.vidoeList objectAtIndex:nextIndex];
    self.vodModel = vodModel;
    DWConfigurationManager * manager = [DWConfigurationManager sharedInstance];
    if (manager.isOpenAd) {
        //广告模式
        [self startRequestAdInfo:1];
    }else{
        //正常播放
        [self startRequestVideo:self.vodModel.videoId];
    }
    [self.listTableView reloadData];
}

//投屏事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView ScreeningJumpAction:(NSString *)playUrl
{
    DWScreeningListViewController * screeningListVC = [[DWScreeningListViewController alloc]init];
    screeningListVC.playUrl = playUrl;
    screeningListVC.delegate = self;
    [self.navigationController pushViewController:screeningListVC animated:YES];
    
    self.playerView.isScreening = YES;
}

//网络检测事件
-(void)vodPlayerView:(DWVodPlayerView *)playerView DidNetworkMonitor:(NSString *)vid AndPlayUrl:(NSString *)playUrl
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];

    DWNetworkMonitorViewController * networkMonitorVC = [[DWNetworkMonitorViewController alloc]initWithVideoId:vid];
    networkMonitorVC.currentPlayurl = playUrl;
    [self.navigationController pushViewController:networkMonitorVC animated:YES];
}

//访客信息收集器，退出填写
-(void)vodPlayerViewVisitorReturnBack:(DWVodPlayerView *)playerView
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];

    [self.playerView closePlayer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

//窗口模式播放
-(void)vodPlayerViewDidEnterWindowsModel:(DWVodPlayerView *)playerView
{
    //如果开启了小窗，开小窗，没开启正常
    DWAPPDELEGATE.vodPlayerView = self.playerView;
    [DWAPPDELEGATE.vodPlayerView enterWindowsModel];
    [self.navigationController popViewControllerAnimated:YES];
}

//片尾广告事件
-(void)vodPlayerViewEndAd:(DWVodPlayerView *)playerView
{
//    NSLog(@"准备请求片尾广告 %@",self.vodModel.videoId);
    [self startRequestAdInfo:3];
}

#pragma mark - 投屏相关
-(void)screeningReturnButtonAction
{
    self.playerView.isScreening = NO;
}

-(void)screeningListDidSelectAction:(DWUPnPDevice *)device AndPlayUrl:(NSString *)playUrl
{
    self.screenBgView = [[DWScreeningBgView alloc]initWithDevice:device AndPlayUrl:playUrl];
    self.screenBgView.delegate = self;
    self.screenBgView.title = self.playerView.videoTitle;
    self.screenBgView.seekTime = self.playerView.currentPlayDuration;
    [self.view addSubview:self.screenBgView];
    [_screenBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(@0);
        make.width.equalTo(@(self.playerViewSize.width));
        make.height.equalTo(@(self.playerViewSize.height));
    }];
    
}

-(void)screeningBgViewCloseAction
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.screenBgView removeFromSuperview];
        self.screenBgView = nil;
    });
}

#pragma mark - tabelViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vidoeList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 7.5 + 90 + 7.5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = self.cellStyle == DWVodPlayTableViewCellStyleDefault ? @"CellStyleDefault" : @"CellStyleChoose";
    DWVodPlayTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[DWVodPlayTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    DWVodModel * vodModel = [self.vidoeList objectAtIndex:indexPath.row];
    [cell setVodModel:vodModel AndPlaying:[vodModel.videoId isEqualToString:self.vodModel.videoId]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.playerView.isScreening) {
        //正在投屏
        [@"正在投屏中，请退出投屏再切换视频" showAlert];
        return;
    }
    
    DWVodModel * vodModel = [self.vidoeList objectAtIndex:indexPath.row];
    
    if ([vodModel.videoId isEqualToString:self.vodModel.videoId]) {
        [@"当前正在播放此集" showAlert];
        return;
    }
    
    if (!self.adShowView.hidden) {
        [self.adShowView adFinish];
    }
    self.playerView.isShowAd = NO;

    self.vodModel = vodModel;
    DWConfigurationManager * manager = [DWConfigurationManager sharedInstance];
    if (manager.isOpenAd) {
        //广告模式
        [self startRequestAdInfo:1];
    }else{
        //正常播放
        [self startRequestVideo:self.vodModel.videoId];
    }
    
//    self.vodModel = vodModel;
//    [self startRequestVideo:self.vodModel.videoId];
    
    [tableView reloadData];
}

#pragma mark - bottomViewDelegate
-(void)vodPlayBottomViewDownloadButtonAction
{
    self.cellStyle = DWVodPlayTableViewCellStyleChoose;
    [self.listTableView reloadData];
}
    
-(void)vodPlayBottomViewSureButtonAction
{
    self.cellStyle = DWVodPlayTableViewCellStyleDefault;
    [self.listTableView reloadData];
    
    NSMutableArray * downloadArray = [NSMutableArray array];
    [self.vidoeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DWVodModel * vodModel = (DWVodModel *)obj;
        if (vodModel.isSelect) {
            [downloadArray addObject:vodModel.videoId];
        }
    }];
    
    if (downloadArray.count == 0) {
        [@"请选择下载视频" showAlert];
        return;
    }
    
    //批量下载
    DWBatchDownloadUtility * bdUtility = [[DWBatchDownloadUtility alloc]initWithUserId:[DWConfigurationManager sharedInstance].DWAccount_userId key:[DWConfigurationManager sharedInstance].DWAccount_apikey AndVideoIds:downloadArray];
    bdUtility.verificationCode = [DWConfigurationManager sharedInstance].verification;
    //音频 + 视频数据，这里仅做示范，可根据自己项目业务逻辑来调整
    bdUtility.mediatype = @"0";
    __weak typeof(self) weakSelf = self;
    bdUtility.finishBlock = ^(NSArray<DWVodVideoModel *> * _Nonnull playInfosArray) {
        
        if (playInfosArray.count == 0) {
            [@"未获取到视频数据" showAlert];
            return;
        }
        
        [weakSelf startDownloadTask:playInfosArray];
    };
    
    bdUtility.errorBlock = ^(NSError * _Nonnull error) {
        [error.localizedDescription showAlert];
    };
    [bdUtility start];

}

-(void)startDownloadTask:(NSArray<DWVodVideoModel *> *)playInfosArray
{
    for (DWVodVideoModel * videoModel in playInfosArray) {

        if (!videoModel) {
            //某个视频数据获取失败
            continue;
        }
        
        if (videoModel.authorize && !videoModel.authorize.enable) {
            //授权验证未通过，无法下载
            continue;
        }
        
        //这里根据自身业务逻辑进行调整， 默认全部下载首个媒体数据
        DWVideoQualityModel * qualityModel = videoModel.videoQualities.firstObject;
        if (!qualityModel) {
            qualityModel = videoModel.radioQualities.firstObject;
        }
        
        DWDownloadSessionManager * manager = [DWDownloadSessionManager manager];
        //验证当前任务是否已经在下载队列中
        if ([manager checkLocalResourceWithVideoId:videoModel.videoId WithQuality:qualityModel.quality]) {
            continue;
        }
        
        //获取视频图片地址，保存
        NSString * imageUrl = @"icon_placeholder.png";
        NSString * title = @"";
        for (DWVodModel * vodModel in self.vidoeList) {
            if ([vodModel.videoId isEqualToString:videoModel.videoId]) {
                imageUrl = vodModel.imageUrl;
                title = vodModel.title;
                break;
            }
        }
        
        DWDownloadModel * model = [DWDownloadSessionManager createDownloadModel:videoModel Quality:qualityModel.quality AndOthersInfo:@{@"imageUrl":imageUrl,@"title":title}];
        
        if (!model) {
            [@"DownloadModel创建失败，请检查参数" showAlert];
            continue;
        }
        
        [manager startWithDownloadModel:model];
        
    }
    
    [[NSString stringWithFormat:@"已开始下载%lu个视频",(unsigned long)playInfosArray.count] showAlert];
}
    
-(void)vodPlayBottomViewCancelButtonAction
{
    self.cellStyle = DWVodPlayTableViewCellStyleDefault;
    [self.listTableView reloadData];
    
    //清空选中数据
    for (DWVodModel * vodModel in self.vidoeList) {
        vodModel.isSelect = NO;
    }
}

#pragma mark - init
-(void)initParams
{
    self.cellStyle = DWVodPlayTableViewCellStyleDefault;
}

-(void)initUI
{
    CGSize viewSize = CGSizeZero;
    if (@available(iOS 11.0, *)) {
        CGFloat a =  [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        if (a > 0) {
            viewSize = CGSizeMake(ScreenWidth, ScaleHeight(ScreenWidth, 375 / 211.0) + 64);
        }else{
            viewSize = CGSizeMake(ScreenWidth, ScaleHeight(ScreenWidth, 375 / 211.0));
        }
    } else {
        viewSize = CGSizeMake(ScreenWidth, ScaleHeight(ScreenWidth, 375 / 211.0));
    }
    self.playerViewSize = viewSize;
    
    if (DWAPPDELEGATE.vodPlayerView) {
        self.playerView = DWAPPDELEGATE.vodPlayerView;
        //选集，要在退出小窗之前设置，否则选集列表会有显示问题
        self.playerView.selectionList = self.vidoeList;
        [self.playerView quitWindowsModel];
    }else{
        self.playerView = [[DWVodPlayerView alloc]init];
        //选集
        self.playerView.selectionList = self.vidoeList;
    }
    
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(@0);
        make.width.equalTo(@(self.playerViewSize.width));
        make.height.equalTo(@(self.playerViewSize.height));
    }];
    
    self.adShowView = [[DWAdShouView alloc]init];
    self.adShowView.hidden = YES;
    self.adShowView.delegate = self;
    [self.view addSubview:self.adShowView];
    [_adShowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(@0);
        make.width.equalTo(@(self.playerViewSize.width));
        make.height.equalTo(@(self.playerViewSize.height - 40));
    }];
    
    self.listTableView = [[UITableView alloc]init];
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.listTableView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.listTableView];
    [_listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(self.playerView.mas_bottom);
        make.bottom.equalTo(@(-15 - 40 - 15));
    }];
    
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 15 + 14 + 2.5)];
    self.listTableView.tableHeaderView = headerView;
    UILabel * headerTsLabel = [[UILabel alloc]init];
    headerTsLabel.text = @"课程目录";
    headerTsLabel.font = TitleFont(14);
    headerTsLabel.textColor = TitleColor_51;
    headerTsLabel.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:headerTsLabel];
    [headerTsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@15);
        make.width.equalTo(@(ScreenWidth - 20));
        make.height.equalTo(@14);
    }];
    
    self.bottomView = [[DWVodPlayBottomView alloc]init];
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.listTableView.mas_bottom);
        make.bottom.equalTo(@0);
        make.left.and.right.equalTo(@0);
    }];
    
    if (self.landScape) {
        [self screenOrientationDidChange:YES];
    }
}

-(BOOL)shouldAutorotate
{
    return YES;
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
