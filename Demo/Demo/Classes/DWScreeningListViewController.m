//
//  DWScreeningListViewController.m
//  Demo
//
//  Created by zwl on 2019/7/9.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWScreeningListViewController.h"
#import "DWScreeningTableViewCell.h"
#import "DWUPnPSearch.h"
#import "DWUPnPDevice.h"
#import "DWUPnPRenderer.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreLocation/CoreLocation.h>

@interface DWScreeningListViewController () <UITableViewDelegate,UITableViewDataSource,DWUPnPSearchDelegate>

@property(nonatomic,strong)DWUPnPSearch * upnpSearch;
@property(nonatomic,strong)DWUPnPRenderer * renderer;

@property(nonatomic,strong)UIView * headerView;
@property(nonatomic,strong)UILabel * statusLabel;
@property(nonatomic,strong)UIView * searchingBgView;//搜索中
@property(nonatomic,strong)UIView * noDevicesBgView;//未找到设备
@property(nonatomic,strong)UIView * screeningFailedBgView;//投屏失败

@property(nonatomic,strong)MPVolumeView * volumeView;//ariPlay

@property(nonatomic,strong)NSArray * listArray;
@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)CLLocationManager * locationManager;

@end

@implementation DWScreeningListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    
    self.upnpSearch = [[DWUPnPSearch alloc]init];
    self.upnpSearch.delegate = self;
    [self.upnpSearch start];
    
    //iOS13需要获取定位权限才可以获取到SSID
    if (@available(iOS 13.0, *)) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            self.locationManager = [[CLLocationManager alloc]init];
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

-(void)dealloc
{
    [self.upnpSearch destroy];
    self.upnpSearch = nil;
    
    NSLog(@"DWScreeningListViewController dealloc");
}

#pragma mark - action
-(void)returnButtonAction
{
    if ([self.delegate respondsToSelector:@selector(screeningReturnButtonAction)]) {
        [self.delegate screeningReturnButtonAction];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshButtonAction
{
    self.statusLabel.text = [NSString stringWithFormat:@"当前WiFi：%@",[DWTools getWifiName]];

    self.headerView.frame = CGRectMake(0, 0, ScreenWidth, 44 + 10 + 44);
    self.tableView.tableHeaderView = self.headerView;
    self.noDevicesBgView.hidden = YES;
    self.screeningFailedBgView.hidden = YES;
    self.searchingBgView.hidden = NO;
    
    [self.upnpSearch refresh];
}

#pragma mark - delegate
//DWUPnPSearchDelegate
//搜索结果
-(void)upnpSearchChangeWithResults:(NSArray <DWUPnPDevice *>*)devices
{
    NSLog(@"search result %@",devices);
    self.listArray = devices;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

//搜索失败
-(void)upnpSearchErrorWithError:(NSError *)error
{
    self.headerView.frame = CGRectMake(0, 0, ScreenWidth, 44 + 10 + 145);
    self.tableView.tableHeaderView = self.headerView;
    self.noDevicesBgView.hidden = YES;
    self.screeningFailedBgView.hidden = NO;
    self.searchingBgView.hidden = YES;
    
    [error.localizedDescription showAlert];
}

//tableviewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWScreeningTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWScreeningTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }

    cell.device = [self.listArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.playUrl) {
        [@"投屏连接不存在" showAlert];
        return;
    }
    
    if ([self.playUrl containsString:@".pcm"] || [[NSURL URLWithString:self.playUrl] isFileURL]) {
        [@"请使用Airplay投放" showAlert];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(screeningListDidSelectAction:AndPlayUrl:)]) {
        DWUPnPDevice * device = [self.listArray objectAtIndex:indexPath.row];
        [self.delegate screeningListDidSelectAction:device AndPlayUrl:[self.playUrl copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - init
-(void)initUI
{
    self.title = @"选择投屏设备";
    
    self.view.backgroundColor = [UIColor colorWithRed:243/255.0 green:244/255.0 blue:245/255.0 alpha:1.0];
    
    //导航功能按钮
    UIButton * refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setImage:[UIImage imageNamed:@"icon_screen_refresh.png"] forState:UIControlStateNormal];
    refreshButton.frame = CGRectMake(0, 0, 40, 40);
    [refreshButton addTarget:self action:@selector(refreshButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.width.equalTo(@(ScreenWidth));
        make.bottom.equalTo(@(-80));
    }];
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 88 + 10)];
    self.headerView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = self.headerView;
    
    self.statusLabel = [[UILabel alloc]init];
    self.statusLabel.font = TitleFont(14);
    self.statusLabel.textColor = TitleColor_102;
    self.statusLabel.textAlignment = NSTextAlignmentLeft;
    [self.headerView addSubview:self.statusLabel];
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@(-10));
        make.top.equalTo(@0);
        make.height.equalTo(@44);
    }];
    
    //iOS12下，请设置Target -> Capabilities -> Access WiFi Information -> ON，否则会查找不到wifi名字
    self.statusLabel.text = [NSString stringWithFormat:@"当前WiFi：%@",[DWTools getWifiName]];

    //未找到设备
    [self.headerView addSubview:self.noDevicesBgView];
    self.noDevicesBgView.hidden = YES;
    [_noDevicesBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(self.statusLabel.mas_bottom);
        make.height.equalTo(@195);
    }];
    
    //搜索失败
    [self.headerView addSubview:self.screeningFailedBgView];
    self.screeningFailedBgView.hidden = YES;
    [_screeningFailedBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(self.statusLabel.mas_bottom);
        make.height.equalTo(@145);
    }];
    
    //搜索中
    [self.headerView addSubview:self.searchingBgView];
    [_searchingBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(self.statusLabel.mas_bottom);
        make.height.equalTo(@44);
    }];
    
    self.volumeView = [[MPVolumeView alloc]init];
    self.volumeView.showsVolumeSlider = NO;
    [self.volumeView setRouteButtonImage:[UIImage imageNamed:@"icon_screen_airplay_bg.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.volumeView];
    [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@145);
        make.height.equalTo(@40);
        make.top.equalTo(self.tableView.mas_bottom).offset(15);
    }];
}

-(UIView *)searchingBgView
{
    if (!_searchingBgView) {
        _searchingBgView = [[UIView alloc]init];
        _searchingBgView.backgroundColor = [UIColor whiteColor];
        
        NSString * str = @"正在搜索可投屏设备...";
        
        UIActivityIndicatorView * aiView = [[UIActivityIndicatorView alloc]init];
        aiView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [aiView startAnimating];
        [_searchingBgView addSubview:aiView];
        
        UILabel * label = [[UILabel alloc]init];
        label.text = str;
        label.textColor = TitleColor_51;
        label.font = TitleFont(15);
        [_searchingBgView addSubview:label];
        
        CGFloat x = (ScreenWidth - (15 + 5 + 150)) / 2.0;
        [aiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(x));
            make.centerY.equalTo(_searchingBgView);
            make.width.equalTo(@(15));
            make.height.equalTo(@(15));
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(aiView.mas_right).offset(5);
            make.centerY.equalTo(aiView);
            make.height.equalTo(@15);
            make.width.equalTo(@(150));
        }];
    }
    return _searchingBgView;
}

-(UIView *)noDevicesBgView
{
    if (!_noDevicesBgView) {
        _noDevicesBgView = [[UIView alloc]init];
        _noDevicesBgView.backgroundColor = [UIColor whiteColor];
        
        UILabel * tsLabel = [[UILabel alloc]init];
        tsLabel.text = @"当前网络下暂未找到可投屏设备";
        tsLabel.font = TitleFont(15);
        tsLabel.textColor = TitleColor_51;
        tsLabel.textAlignment = NSTextAlignmentCenter;
        [_noDevicesBgView addSubview:tsLabel];
        [tsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@15);
            make.height.equalTo(@15);
            make.left.and.right.equalTo(@0);
        }];
        
        UILabel * contentLabel = [[UILabel alloc]init];
        contentLabel.text = @"  1、请确认设备是否是可投屏设备，如智能电视、智能盒子、电视果及其他投屏设备。如果无法确认，可咨询设备厂商。\n\n  2、请确保手机和设备连接在同一个Wi-Fi下。\n\n  3、重新启动APP，再次尝试投屏。";
        contentLabel.font = TitleFont(13);
        contentLabel.textColor = TitleColor_102;
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.numberOfLines = 0;
        [_noDevicesBgView addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tsLabel.mas_bottom).offset(20);
            make.left.and.right.equalTo(@0);
            make.height.equalTo(@120);
        }];
    }
    return _noDevicesBgView;
}

-(UIView *)screeningFailedBgView
{
    if (!_screeningFailedBgView) {
        _screeningFailedBgView = [[UIView alloc]init];
        _screeningFailedBgView.backgroundColor = [UIColor whiteColor];
        
        UILabel * tsLabel = [[UILabel alloc]init];
        tsLabel.text = @"投屏连接失败";
        tsLabel.font = TitleFont(15);
        tsLabel.textColor = TitleColor_51;
        tsLabel.textAlignment = NSTextAlignmentCenter;
        [_screeningFailedBgView addSubview:tsLabel];
        [tsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@15);
            make.height.equalTo(@15);
            make.left.and.right.equalTo(@0);
        }];
        
        UILabel * contentLabel = [[UILabel alloc]init];
        contentLabel.text = @"  1、请确保手机与投屏设备连接在同一个WiFi下。\n\n  2、请重新投屏或重启APP再次尝试。";
        contentLabel.font = TitleFont(13);
        contentLabel.textColor = TitleColor_102;
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.numberOfLines = 0;
        [_screeningFailedBgView addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tsLabel.mas_bottom).offset(20);
            make.left.and.right.equalTo(@0);
            make.height.equalTo(@70);
        }];
    }
    return _screeningFailedBgView;
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
