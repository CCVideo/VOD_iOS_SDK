#import "DWUploadViewController.h"
#import "DWUploadInfoSetupViewController.h"
#import "DWUploadTableViewCell.h"
#import "MJExtension.h"
#import <MobileCoreServices/MobileCoreServices.h>
#include <AssetsLibrary/AssetsLibrary.h>

static NSString *const uploadsArray =@"uploadsArray";

@interface DWUploadViewController () <UITableViewDataSource, UITableViewDelegate,DWUploaderDelegate>


@property(strong, nonatomic)NSString *videoPath;

@property(strong, nonatomic)UITableView *tableView;

@property(copy, nonatomic)NSString * userID;
@property(copy, nonatomic)NSString * apiKey;
@property(copy, nonatomic)NSString * videoTitle;
@property(copy, nonatomic)NSString * videoTag;
@property(copy, nonatomic)NSString * videoDescription;

@property(nonatomic,strong)NSMutableArray <DWUploader *> * uploaderArray;//存放上传uploader对象
@property(nonatomic,strong)NSMutableArray * uploadModelArray;//上传数组 里面放的是字典
@property(nonatomic,strong)NSMutableArray * uploadingList;
@property(nonatomic,strong)NSMutableArray * uploadFinishList;

@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)UIButton * totolButton;

@property(nonatomic,strong)NSTimer * timer;

@end

@implementation DWUploadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //** !! **
    //温馨提示:演示账号没有开通上传视频的权限，如需测试上传功能，请填写自己的账号信息
    
    self.index = 0;
    
    [self getUploadArray];
    
    [self initUI];
    
    [self initTimerIfNecessary];
}

-(BOOL)canShowTotalButton
{
    return self.uploadingList.count == 0 ? NO : YES;
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
        
        self.totolButton.hidden = ![self canShowTotalButton];
        
    }else{
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@0);
        }];
        
        self.totolButton.hidden = YES;
    }
    
    [_tableView reloadData];
}

-(void)totolButtonButton
{
    if (self.uploadingList.count == 0) {
        return;
    }
    
    self.totolButton.selected = !self.totolButton.selected;
    
    if (self.totolButton.selected) {
        for (DWUploadModel * uploadModel in self.uploadingList) {
            if (uploadModel.status == DWUploadStatusUploading) {
                uploadModel.status = DWUploadStatusPause;
                DWUploader * currentUploader = nil;
                for (DWUploader * uploader in self.uploaderArray) {
                    if ([[uploader.videoPath lastPathComponent] isEqualToString:[uploadModel.videoPath lastPathComponent]]) {
                        currentUploader = uploader;
                        break;
                    }
                }
                //杀app后，可能会出现不存在的情况
                if (currentUploader) {
                    [currentUploader pause];
                }
            }
        }
    }else{
        //续传
        for (DWUploadModel * uploadModel in self.uploadingList) {
            if (uploadModel.status == DWUploadStatusUploading) {
                break;
            }
            DWUploader * currentUploader = nil;
            for (DWUploader * uploader in self.uploaderArray) {
                if ([[uploader.videoPath lastPathComponent] isEqualToString:[uploadModel.videoPath lastPathComponent]]) {
                    currentUploader = uploader;
                    break;
                }
            }
            [self resumeUpload:uploadModel AndUploader:currentUploader];
    
        }
    }
    
   
    [self.tableView reloadData];
}

#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    
    DWVideoCompressController *imagePicker = [[DWVideoCompressController alloc] initWithQuality: DWUIImagePickerControllerQualityTypeMedium andSourceType:DWUIImagePickerControllerSourceTypePhotoLibrary andMediaType:DWUIImagePickerControllerMediaTypeMovie];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:NO completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        [@"请选择视频文件" showAlert];
        return;
    }
    //此时视频保存在临时路径temp中，建议保存在document中 demo只为示例
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    self.videoPath = [videoURL path];
    
    // 跳转到 设置视频标题、标签、简介等信息界面。
    DWUploadInfoSetupViewController *viewController = [[DWUploadInfoSetupViewController alloc] init];
    
    //开始上传
    WeakSelf(self);
    [viewController didBackBlock:^(BOOL isCancel, NSString *userId, NSString *apiKey, NSString *videoTitle, NSString *videoTag, NSString *videoDescription) {
        //开始上传
        if (!isCancel) {
            weakself.userID = userId;
            weakself.apiKey = apiKey;
            weakself.videoTitle = videoTitle;
            weakself.videoTag = videoTag;
            weakself.videoDescription = videoDescription;
            [weakself startUpload];
        }
        
    }];
    
    [self.navigationController pushViewController:viewController animated:NO];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:NO completion:nil];
}

# pragma mark - func
- (void)startUpload
{
    NSError *error = nil;
    
    DWUploadModel *model = [[DWUploadModel alloc] init];
    model.status = DWUploadStatusUploading;
    model.userID = _userID;
    model.apiKey = _apiKey;
    model.videoPath = _videoPath;
    model.videoTitle = _videoTitle;
    model.videoTag = _videoTag;
    model.videoDescripton = _videoDescription;
    model.first = @"1";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_videoPath]) {
        [@"上传路径有误" showAlert];
        return;
    }
    // 文件不存在则不设置
    model.videoFileSize = [DWTools getFileSizeWithPath:self.videoPath Error:&error];

    DWUploader *uploader;
    uploader = [[DWUploader alloc] initWithUserId:model.userID
                                           andKey:model.apiKey
                                 uploadVideoTitle:model.videoTitle
                                 videoDescription:model.videoDescripton
                                         videoTag:model.videoTag
                                        videoPath:model.videoPath
                                        notifyURL:@"http://www.bokecc.com/"];
    
    //若需添加视频动态水印，请取消注释并修改参数即可
//    [uploader insertWaterMarkWithText:@"视频动态水印"
//                               Corner:@0
//                              OffsetX:@5
//                              OffsetY:@5
//                           FontFamily:@0
//                             FontSize:@20
//                            FontColor:@"FF00FF"
//                            FontAlpha:@90];
    
    __weak typeof(self) weakSelf = self;
    uploader.delegate =self;
    uploader.progressBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {

        //不断的保存进度
        @autoreleasepool {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[weakSelf.uploadingList indexOfObject:model] inSection:0];
                DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
                model.videoUploadProgress = progress;
                model.videoUploadedSize = totalBytesWritten;
                model.first = @"2";
                model.status = DWUploadStatusUploading;
                [cell updateCell];
            });
        }
        
        [weakSelf initTimerIfNecessary];

    };
    
    uploader.finishBlock = ^() {
        
        model.status = DWUploadStatusFinish;
        [weakSelf setUploadArray];
        [weakSelf.tableView reloadData];
    };
    
    uploader.failBlock = ^(NSError *error) {
        
        model.status = DWUploadStatusFail;
        //余下逻辑根据项目需求处理
        [weakSelf setUploadArray];

        [weakSelf.tableView reloadData];

        [@"上传失败" showAlert];
    };
    
    uploader.videoContextForRetryBlock = ^(NSDictionary *videoContext) {
        
        model.uploadContext = videoContext;
        [weakSelf setUploadArray];
        
    };
    
    //开始上传
    uploader.timeoutSeconds = 20;
    [uploader start];
    
    [self.uploaderArray addObject:uploader];
    [self.uploadModelArray addObject:model];

    self.totolButton.hidden = ![self canShowTotalButton];

    [self setUploadArray];
    [self.tableView reloadData];
}

-(void)resumeUpload:(DWUploadModel *)model AndUploader:(DWUploader *)uploader
{
    if (!uploader) {
        //杀死过app，重新开始上传
        uploader = [[DWUploader alloc] initWithUserId:model.userID
                                                      andKey:model.apiKey
                                            uploadVideoTitle:model.videoTitle
                                            videoDescription:model.videoDescripton
                                                    videoTag:model.videoTag
                                                   videoPath:model.videoPath
                                                   notifyURL:@"http://www.bokecc.com/"];
        
        [self.uploaderArray addObject:uploader];
        
        [uploader start];
        
        __weak typeof(self) weakSelf = self;
        uploader.delegate = self;
        uploader.progressBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
            //不断的保存进度
            @autoreleasepool {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[weakSelf.uploadingList indexOfObject:model] inSection:0];
                    DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[weakSelf.tableView cellForRowAtIndexPath:indexPath];
                    model.videoUploadProgress = progress;
                    model.videoUploadedSize = totalBytesWritten;
                    model.first = @"2";
                    model.status = DWUploadStatusUploading;
                    [cell updateCell];
                });
                
            }
            [weakSelf initTimerIfNecessary];
        };
        
        uploader.finishBlock = ^() {
            model.status = DWUploadStatusFinish;
            [weakSelf setUploadArray];
            [weakSelf.tableView reloadData];
        };
        
        uploader.failBlock = ^(NSError *error) {
            model.status = DWUploadStatusFail;
            //余下逻辑根据项目需求处理
            [weakSelf.tableView reloadData];
            [weakSelf setUploadArray];
            [@"上传失败" showAlert];
        };
        
        uploader.videoContextForRetryBlock = ^(NSDictionary *videoContext) {
            model.uploadContext = videoContext;
            [weakSelf setUploadArray];
            
        };
        
        uploader.timeoutSeconds = 20;
        
    }else{
        [uploader resume];
    }
    
}

- (void)setUploadArray
{
    //将model转化成NSDictionary保存
    NSMutableArray * dictArray = [NSMutableArray array];
    for (DWUploadModel * uploadModel in self.uploadModelArray) {
        NSDictionary * dict = [uploadModel mj_keyValues];
        [dictArray addObject:dict];
    }
    [[NSUserDefaults standardUserDefaults]setObject:dictArray forKey:uploadsArray];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)getUploadArray
{
    //获取保存下来的model
    NSArray * dictArray = [[NSUserDefaults standardUserDefaults] objectForKey:uploadsArray];
    for (NSDictionary * dict in dictArray) {
        DWUploadModel * model = [DWUploadModel mj_objectWithKeyValues:dict];
        if (model.status == DWUploadStatusUploading) {
            model.status = DWUploadStatusPause;
        }
        [self.uploadModelArray addObject:model];
    }
}

-(void)initTimerIfNecessary
{
    //这里只是示例，具体逻辑根据自己业务需求做调整
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(saveUploadArrayTimerAction) userInfo:nil repeats:YES];
}

-(void)saveUploadArrayTimerAction
{
    BOOL isContinue = NO;
    for (DWUploadModel * model in self.uploadingList) {
        if (model.status == DWUploadStatusUploading) {
            isContinue = YES;
        }
    }
    if (!isContinue) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self setUploadArray];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.index == 0) {
        return self.uploadingList.count;
    }else{
        return self.uploadFinishList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWUploadTableViewCell * cell = (DWUploadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWUploadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSArray * array = nil;
    if (self.index == 0) {
        array = self.uploadingList;
    }else{
        array = self.uploadFinishList;
    }
    
    cell.uploadModel = [array objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.index != 0) {
        return;
    }

    DWUploadModel *model = [self.uploadingList objectAtIndex:indexPath.row];
    DWUploader * currentUploader = nil;
    for (DWUploader * uploader in self.uploaderArray) {
        if ([[uploader.videoPath lastPathComponent] isEqualToString:[model.videoPath lastPathComponent]]) {
            currentUploader = uploader;
            break;
        }
    }
    
    DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (model.status == DWUploadStatusUploading) {
        //暂停
        [currentUploader pause];
        model.status = DWUploadStatusPause;
        cell.uploadModel = model;
    }else{
        //pause fail 续传
        [self resumeUpload:model AndUploader:currentUploader];
    
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSMutableArray * array;
        if (self.index == 0) {
            array = self.uploadingList;
        }else{
            array = self.uploadFinishList;
        }
        DWUploadModel * model = [array objectAtIndex:indexPath.row];
        DWUploader * currentUploader = nil;
        for (DWUploader * uploader in self.uploaderArray) {
            if ([[uploader.videoPath lastPathComponent] isEqualToString:[model.videoPath lastPathComponent]]) {
                currentUploader = uploader;
            }
        }
        
        if (currentUploader) {
            if (model.status == DWUploadStatusUploading) {
                [currentUploader pause];
            }
            
            [self.uploaderArray removeObject:currentUploader];
        }else{
            
        }
      
        [self.uploadModelArray removeObject:model];
        self.totolButton.hidden = ![self canShowTotalButton];
        [self setUploadArray];
        [tableView reloadData];
        
    }
}

#pragma mark-----DWUploaderDelegate
//checkupload第一次请求成功的回调
- (void)checkUploadWithFilePath:(NSString  *)filePath
{
    [self setUploadArray];
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

-(NSMutableArray<DWUploader *> *)uploaderArray
{
    if (!_uploaderArray) {
        _uploaderArray = [[NSMutableArray alloc]init];
    }
    return _uploaderArray;
}

- (NSMutableArray *)uploadModelArray
{
    if (!_uploadModelArray) {
        _uploadModelArray =[NSMutableArray array];
    }
    return _uploadModelArray;
}

-(NSMutableArray *)uploadingList
{
    NSMutableArray * array = [NSMutableArray array];
    for (DWUploadModel * model in self.uploadModelArray) {
        if (model.status != DWUploadStatusFinish) {
            [array addObject:model];
        }
    }
    return array;
}

- (NSMutableArray *)uploadFinishList
{
    NSMutableArray * array = [NSMutableArray array];
    for (DWUploadModel * model in self.uploadModelArray) {
        if (model.status == DWUploadStatusFinish) {
            [array addObject:model];
        }
    }
    return array;
}

@end
