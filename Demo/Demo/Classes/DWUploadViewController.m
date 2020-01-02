#import "DWUploadViewController.h"
#import "DWUploadInfoSetupViewController.h"
#import "DWUploadTableViewCell.h"
#import "MJExtension.h"
#import <MobileCoreServices/MobileCoreServices.h>
#include <AssetsLibrary/AssetsLibrary.h>
#import "DWUploadSessionManager.h"
#import "Reachability.h"

static NSString *const uploadsArray =@"uploadsArray";

@interface DWUploadViewController () <UITableViewDataSource, UITableViewDelegate,DWUploadSessionManagerDelegate>

@property(strong, nonatomic)NSString *videoPath;

@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)UIButton * totolButton;

@property(strong, nonatomic)UITableView *tableView;

@property(nonatomic,weak)DWUploadSessionManager * manager;

@property(nonatomic,strong)NSArray * uploadList;

@property(nonatomic,strong)Reachability * reachability; //网络状态监听

@end

@implementation DWUploadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //** !! **
    //温馨提示:演示账号没有开通上传视频的权限，如需测试上传功能，请填写自己的账号信息
    
    self.manager = [DWUploadSessionManager manager];
    self.manager.delegate = self;
    
    self.index = 0;
    
    [self initUI];
    
    [self setUploadingList];

    //增加网络状态监听
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
}

-(void)setUploadingList
{
    NSMutableArray * array = [NSMutableArray array];
    for (DWUploadModel * uploadModel in self.manager.uploadModelList) {
        if (uploadModel.state != DWUploadStateFinish) {
            [array addObject:uploadModel];
        }
    }

    self.uploadList = array;
    [self.tableView reloadData];
    
    if (self.uploadList.count == 0) {
        self.totolButton.hidden = YES;
    }else{
        self.totolButton.hidden = NO;
    }
}

-(void)setFinishUploadList
{
    NSMutableArray * array = [NSMutableArray array];
    for (DWUploadModel * uploadModel in self.manager.uploadModelList) {
        if (uploadModel.state == DWUploadStateFinish) {
            [array addObject:uploadModel];
        }
    }
    
    self.uploadList = array;
    [self.tableView reloadData];
    
    self.totolButton.hidden = YES;
}

-(void)suspendOrResumeUploadWithNetwork:(BOOL)reachable
{
    if (reachable) {
        //网络恢复
        for (DWUploadModel * uploadModel in self.manager.uploadModelList) {
            if (uploadModel.state == DWUploadStatePause) {
                if ([uploadModel.otherInfo objectForKey:@"NetworkFailure"] && [[uploadModel.otherInfo objectForKey:@"NetworkFailure"] boolValue]) {
                    [self.manager resumeWithUploadModel:uploadModel];
                    NSMutableDictionary * otherInfo = [uploadModel.otherInfo mutableCopy];
                    [otherInfo removeObjectForKey:@"NetworkFailure"];
                    uploadModel.otherInfo = otherInfo;
                }
            }
        }
    }else{
        //网络故障
        for (DWUploadModel * uploadModel in self.manager.uploadModelList) {
            if (uploadModel.state == DWUploadStateUploading) {
                [self.manager suspendWithUploadModel:uploadModel];
                NSMutableDictionary * otherInfo = [uploadModel.otherInfo mutableCopy];
                [otherInfo setValue:@YES forKey:@"NetworkFailure"];
                uploadModel.otherInfo = otherInfo;
            }
        }
    }
}

-(void)dealloc
{
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    NSLog(@"DWUploadViewController dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - action
- (void)addButtonAction
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择"
                                        delegate:self
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"取消"
                               otherButtonTitles:@"从相册选择", nil];
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [sheet showInView:self.view];
}

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
        
        [self setUploadingList];

    }else{
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@0);
        }];
        
        [self setFinishUploadList];
    }
    
}

-(void)totolButtonButton
{
    if (self.uploadList.count == 0) {
        return;
    }
    self.totolButton.selected = !self.totolButton.selected;

    if (self.totolButton.selected) {
        //暂停
        for (DWUploadModel * uploadModel in self.uploadList) {
            if (uploadModel.state == DWUploadStateUploading) {
                [self.manager suspendWithUploadModel:uploadModel];
            }
        }
    }else{
        //开始
        for (DWUploadModel * uploadModel in self.uploadList) {
            if (uploadModel.state == DWUploadStatePause || uploadModel.state == DWUploadStateNone) {
                [self.manager resumeWithUploadModel:uploadModel];
            }
        }
    }
    
    [self setUploadingList];
}

-(void)networkStateChange
{
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    switch (status) {
        case NotReachable:{
            //暂无网络
            [self suspendOrResumeUploadWithNetwork:NO];
            break;
        }
        case ReachableViaWiFi:{
            [self suspendOrResumeUploadWithNetwork:YES];
            break;
        }
        case ReachableViaWWAN:{
            [self suspendOrResumeUploadWithNetwork:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex <= 0) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
        
    DWVideoCompressController *imagePicker = [[DWVideoCompressController alloc] initWithQuality: DWUIImagePickerControllerQualityTypeMedium andSourceType:DWUIImagePickerControllerSourceTypePhotoLibrary andMediaType:DWUIImagePickerControllerMediaTypeMovie];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        [@"请选择视频文件" showAlert];
        return;
    }

    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    //注意！获取到上传路径之后，请务必调用moveToLocalWithVideoPath:方法获取SDK所需的视频url，否则可能会出现上传失败，找不到视频文件等情况。
    self.videoPath = [self.manager moveToLocalWithVideoPath:[videoURL path]];
    
    if (!self.videoPath) {
        [@"上传视频保存失败，请重试" showAlert];
        [picker dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    NSLog(@"imagePickerController videoPath:%@",self.videoPath);
    
    // 跳转到 设置视频标题、标签、简介等信息界面。
    DWUploadInfoSetupViewController *viewController = [[DWUploadInfoSetupViewController alloc] init];
    
    //开始上传
    WeakSelf(self);
    [viewController didBackBlock:^(BOOL isCancel, NSString *userId, NSString *apiKey, NSString *videoTitle, NSString *videoTag, NSString *videoDescription) {
     
        if (!isCancel) {
            DWUploadModel * uploadModel = [DWUploadSessionManager createUploadModelWithUserId:userId Apikey:apiKey VideoTitle:videoTitle VideoDescription:videoDescription VideoTag:videoTag VideoPath:weakself.videoPath CategoryId:nil NotifyURL:nil];

            UIImage * image = [DWTools getThumbnailImage:self.videoPath time:0];
            if (image) {
                uploadModel.otherInfo = @{@"image":UIImagePNGRepresentation(image)};
            }
            
            //添加视频水印，根据自己需求调用即可。
//            [self.manager insertWaterMarkWithUploadModel:uploadModel Text:@"测试水印" Corner:@0 OffsetX:@5 OffsetY:@5 FontFamily:@0 FontSize:@20 FontColor:@"FF00FF" FontAlpha:@100];
            
            //开始上传
            [self.manager startWithUploadModel:uploadModel];
            
            if (self.index == 0) {
                [self setUploadingList];
            }else{
                [self setFinishUploadList];
            }
        }
    
    }];
    
    [self.navigationController pushViewController:viewController animated:NO];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - DWUploadSessionManagerDelegate
//开始上传
-(void)uploadSessionManagerBeginWithUploadModel:(DWUploadModel *)uploadModel
{
    NSLog(@"uploadSessionManagerBeginWithUploadModel videoId:%@",uploadModel.videoId);
}

//更新上传状态
-(void)uploadSessionManagerUploadModel:(DWUploadModel *)uploadModel WithState:(DWUploadState)state
{
    NSLog(@"uploadSessionManagerUploadModel state:%ld",state);
    if (state == DWUploadStateFinish) {
        //完成
        if (self.index == 0) {
            [self setUploadingList];
        }else{
            [self setFinishUploadList];
        }
    }else{
        NSInteger row = [self.uploadList indexOfObject:uploadModel];
        DWUploadTableViewCell * cell = (DWUploadTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        cell.uploadModel = uploadModel;
    }
}

//更新上传进度
-(void)uploadSessionManagerUploadModel:(DWUploadModel *)uploadModel totalBytesSent:(int64_t)totalBytesSent WithExpectedToSend:(int64_t)expectedToSend
{
    @autoreleasepool {
        NSInteger row = [self.uploadList indexOfObject:uploadModel];
        DWUploadTableViewCell * cell = (DWUploadTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        [cell updateCellTotalBytesSent:totalBytesSent WithExpectedToSend:expectedToSend];
    }
    
//    NSLog(@"上传进度 totalBytesSent:%lld  expectedToSend:%lld progress:%lf",totalBytesSent,expectedToSend,uploadModel.progress);
}

//上传失败回调
-(void)uploadSessionManagerUploadModel:(DWUploadModel *)uploadModel WithError:(NSError *)error
{
    [error.localizedDescription showAlert];
    if (self.index == 0) {
        [self setUploadingList];
    }else{
        [self setFinishUploadList];
    }
}

-(void)uploadBackgroundSessionCompletion
{
    NSLog(@"uploadBackgroundSessionCompletion");
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.uploadList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWUploadTableViewCell * cell = (DWUploadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWUploadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.uploadModel = [self.uploadList objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    DWUploadModel * uploadModel = [self.uploadList objectAtIndex:indexPath.row];
    switch (uploadModel.state) {
        case DWUploadStateUploading:
            [self.manager suspendWithUploadModel:uploadModel];
            break;
        case DWUploadStateReadying:
            [self.manager suspendWithUploadModel:uploadModel];
            break;
        case DWUploadStatePause:
            [self.manager resumeWithUploadModel:uploadModel];
            if ([uploadModel.otherInfo objectForKey:@"NetworkFailure"] && [[uploadModel.otherInfo objectForKey:@"NetworkFailure"] boolValue]) {
                //判断是否是因为网络故障原因造成的暂停
                NSMutableDictionary * otherInfo = [uploadModel.otherInfo mutableCopy];
                [otherInfo removeObjectForKey:@"NetworkFailure"];
                uploadModel.otherInfo = otherInfo;
            }
            break;
        case DWUploadStateNone:
            [@"请调用startWithUploadModel:方法" showAlert];
            break;
        case DWUploadStateFail:
            [@"上传失败，请重试" showAlert];
            break;
        case DWUploadStateFinish:
            [@"上传已完成" showAlert];
            break;
        default:
            break;
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWUploadModel * uploadModel = [self.uploadList objectAtIndex:indexPath.row];
    [self.manager deleteWithUploadModel:uploadModel];
    
    if (self.index == 0) {
        [self setUploadingList];
    }else{
        [self setFinishUploadList];
    }
}

#pragma mark - init
-(void)initUI
{
    self.title = @"上传管理";
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"icon_upload.png"] forState:UIControlStateNormal];
    addButton.frame = CGRectMake(0, 0, 40, 40);
    [addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addItem;
    
    NSArray * titles = @[@"上传中",@"已完成"];
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
    self.tableView.rowHeight = 87;

    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.equalTo(@39);
        make.bottom.equalTo(@(-115));
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
    
    self.totolButton.hidden = NO;
}


@end
