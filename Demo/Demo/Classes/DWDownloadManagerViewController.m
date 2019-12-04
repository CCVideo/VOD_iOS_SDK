//
//  DWDownloadManagerViewController.m
//  Demo
//
//  Created by zwl on 2019/4/26.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWDownloadManagerViewController.h"
#import "DWDownloadTableViewCell.h"
#import "DWLocalPlayViewController.h"

@interface DWDownloadManagerViewController ()<UITableViewDelegate,UITableViewDataSource,DWDownloadSessionDelegate>

@property(nonatomic,weak)DWDownloadSessionManager * manager;

@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIButton * totolButton;
@property(nonatomic,strong)NSArray * downloadList;

@end

@implementation DWDownloadManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.index = 0;
    
    self.manager = [DWDownloadSessionManager manager];
    self.manager.delegate = self;
    
    [self initUI];
    [self setDownloadingList];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(void)setDownloadingList
{
    NSMutableArray * array = [NSMutableArray array];
    for (DWDownloadModel * downloadModel in self.manager.downloadModelList) {
        if (downloadModel.state != DWDownloadStateCompleted) {
            [array addObject:downloadModel];
        }
    }
    
    self.downloadList = array;
    [self.tableView reloadData];
    
    if (self.downloadList.count == 0) {
        self.totolButton.hidden = YES;
    }else{
        self.totolButton.hidden = NO;
    }
}

-(void)setFinishDownloadList
{
    NSMutableArray * array = [NSMutableArray array];
    for (DWDownloadModel * downloadModel in self.manager.downloadModelList) {
        if (downloadModel.state == DWDownloadStateCompleted) {
            [array addObject:downloadModel];
        }
    }
    
    self.downloadList = array;
    [self.tableView reloadData];
    
    self.totolButton.hidden = YES;
}

- (void)requestPlayInfo:(DWDownloadModel *)model{
    
    __weak typeof(self) weakSelf = self;
    //请求视频播放信息  获取下载地址 hlsSupport传@"0"
    DWPlayInfo *playinfo = [[DWPlayInfo alloc] initWithUserId:[DWConfigurationManager sharedInstance].DWAccount_userId andVideoId:model.videoId key:[DWConfigurationManager sharedInstance].DWAccount_apikey hlsSupport:@"0"];
    //网络请求超时时间
    playinfo.timeoutSeconds = 30;
    playinfo.errorBlock = ^(NSError *error){
        [@"请求资源失败" showAlert];
    };
    
    playinfo.finishBlock = ^(DWVodVideoModel *vodVideo) {
        if (!vodVideo) {
            [@"网络资源暂时不可用" showAlert];
            return;
        }
        
        NSArray <DWVideoQualityModel *> * qualitys;
        if ([model.mediaType isEqualToString:@"1"]) {
            qualitys = vodVideo.videoQualities;
        }else{
            qualitys = vodVideo.radioQualities;
        }
        [qualitys enumerateObjectsUsingBlock:^(DWVideoQualityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.quality isEqualToString:model.quality]) {
                *stop =YES;
                [weakSelf.manager reStartDownloadUrlWithNewUrlString:obj.playUrl AndDownloadModel:model];
            }
        }];
    };
    
    [playinfo start];
}


#pragma mark - action
-(void)selectButtonAction:(UIButton *)button
{
    if (button.selected) {
        return;
    }
    
    button.selected = !button.selected;
    UIView * lineView = [button viewWithTag:button.tag + 100];
    lineView.hidden = NO;
    
    UIButton * frontButton = (UIButton *)[self.view viewWithTag:100 + self.index];
    frontButton.selected = NO;
    UIView * frontLineView = [frontButton viewWithTag:frontButton.tag + 100];
    frontLineView.hidden = YES;
    
    self.index = button.tag - 100;
    
    if (self.index == 0) {
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@(-70));
        }];
        
        [self setDownloadingList];
    }else{
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@0);
        }];
                
        [self setFinishDownloadList];
    }
}

-(void)totolButtonButton
{
    if (self.downloadList.count == 0) {
        return;
    }
    
    self.totolButton.selected = !self.totolButton.selected;
    
    if (self.totolButton.selected) {
        //暂停
        [self.manager suspendAllDownloadModel];
    }else{
        //开始
        for (DWDownloadModel * downloadModel in self.downloadList) {
            if (downloadModel.state != DWDownloadStateRunning) {
                [self.manager resumeWithDownloadModel:downloadModel];
            }
        }
    }
    
    [self setDownloadingList];
}

#pragma mark - DWDownloadSessionDelegate
// 更新下载进度
- (void)downloadModel:(DWDownloadModel *)downloadModel didUpdateProgress:(DWDownloadProgress *)progress
{
    @autoreleasepool {
        NSInteger row = [self.downloadList indexOfObject:downloadModel];
        DWDownloadTableViewCell * cell = (DWDownloadTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        cell.downloadModel = downloadModel;
    }
}

// 更新下载状态/出现error时回调
- (void)downloadModel:(DWDownloadModel *)downloadModel error:(NSError *)error
{
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    if (!downloadModel) {
        return;
    }
    
    if (downloadModel.state == DWDownloadStateCompleted) {
        //下载完成
        if (self.index == 0) {
            [self setDownloadingList];
        }else{
            [self setFinishDownloadList];
        }
    }else{
        NSInteger row = [self.downloadList indexOfObject:downloadModel];
        DWDownloadTableViewCell * cell = (DWDownloadTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        cell.downloadModel = downloadModel;
    }
}

-(void)downloadBackgroundSessionCompletion
{
    NSLog(@"DWDownloadManagerViewController downloadBackgroundSessionCompletion");
}

#pragma mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.downloadList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 87;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDownloadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWDownloadTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.downloadModel = [self.downloadList objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DWDownloadModel * downloadModel = [self.downloadList objectAtIndex:indexPath.row];
    
    if (self.index == 0) {
        //未完成
        if (downloadModel.state == DWDownloadStateRunning || downloadModel.state == DWDownloadStateReadying) {
            [self.manager suspendWithDownloadModel:downloadModel];
        }else{
            //判断下载链接是否超时
            if ([self.manager isValidateURLWithDownloadModel:downloadModel]) {
                NSLog(@"url可用");
                [self.manager resumeWithDownloadModel:downloadModel];
//                [self.manager startWithDownloadModel:downloadModel];
            }else{
                NSLog(@"url不可用");
                //重新获取下载路径
                [self requestPlayInfo:downloadModel];
            }
        }
    }else{
        //已完成
        DWLocalPlayViewController * localPlayVC = [[DWLocalPlayViewController alloc]init];
        localPlayVC.downloadModel = downloadModel;
        [self.navigationController pushViewController:localPlayVC animated:YES];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

//tableView侧滑
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDownloadModel * model = [self.downloadList objectAtIndex:indexPath.row];
    [self.manager deleteWithDownloadModel:model];
    
    if (self.index == 0) {
        [self setDownloadingList];
    }else{
        [self setFinishDownloadList];
    }
}

#pragma mark - init
-(void)initUI
{
    self.title = @"下载管理";
    
    NSArray * titles = @[@"下载中",@"已完成"];
    for (int i = 0; i < titles.count; i++) {
        UIButton * selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectButton setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [selectButton setTitleColor:TitleColor_102 forState:UIControlStateNormal];
        [selectButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0] forState:UIControlStateSelected];
        selectButton.titleLabel.font = TitleFont(14);
        selectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        selectButton.tag = 100 + i;
        [selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:selectButton];
        [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(ScreenWidth / 2.0 * i));
            make.top.equalTo(@0);
            make.width.equalTo(@(ScreenWidth / 2.0));
            make.height.equalTo(@39);
        }];
        
        UIView * lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0];
        lineView.tag = 200 + i;
        lineView.hidden = YES;
        [selectButton addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@0);
            make.height.equalTo(@2);
            make.width.equalTo(@30);
            make.centerX.equalTo(selectButton);
        }];
        
        if (self.index == i) {
            selectButton.selected = YES;
            lineView.hidden = NO;
        }
    }
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@(-115));
        make.top.equalTo(@39);
    }];
    
    self.totolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.totolButton setTitle:@"全部暂停" forState:UIControlStateNormal];
    [self.totolButton setTitle:@"全部开始" forState:UIControlStateSelected];
    [self.totolButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.totolButton.titleLabel.font = TitleFont(15);
    self.totolButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.totolButton.layer.borderWidth = 1;
    self.totolButton.layer.borderColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0].CGColor;
    self.totolButton.layer.cornerRadius = 20;
    [self.totolButton addTarget:self action:@selector(totolButtonButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.totolButton];
    [_totolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@145);
        make.height.equalTo(@40);
        make.top.equalTo(self.tableView.mas_bottom).offset(15);
    }];
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
