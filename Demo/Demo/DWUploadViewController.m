#import "DWUploadViewController.h"
#import "DWUploadInfoSetupViewController.h"
#import "DWUploadTableViewCell.h"

#import "DWTools.h"
#import "MJExtension.h"


#import <MobileCoreServices/MobileCoreServices.h>
#include<AssetsLibrary/AssetsLibrary.h>


static NSString *const uploadsArray =@"uploadsArray";

@interface DWUploadViewController () <UITableViewDataSource, UITableViewDelegate,DWUploaderDelegate>


@property (strong, nonatomic)NSString *videoPath;

@property (strong, nonatomic)UITableView *tableView;

@property (nonatomic,strong)NSMutableArray *uploadArray;//上传数组 里面放的是字典
@property (copy, nonatomic)NSString *videoTitle;
@property (copy, nonatomic)NSString *videoTag;
@property (copy, nonatomic)NSString *videoDescription;

@property (nonatomic,strong)DWUploadModel *changeModel;
@property (nonatomic,strong)NSMutableArray *uploadingArray;



@end

@implementation DWUploadViewController

- (NSMutableArray *)uploadingArray{
    
    if (!_uploadingArray) {
        
        _uploadingArray =[NSMutableArray array];
    }
    
    return _uploadingArray;
}

- (NSMutableArray *)uploadArray{
    
    if (!_uploadArray) {
        
        _uploadArray =[NSMutableArray array];
    }
    
    return _uploadArray;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"上传";
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"上传"
                                                        image:[UIImage imageNamed:@"tabbar-upload"]
                                                          tag:0];
        if (IsIOS7) {
            self.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar-upload-selected"];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    
    self.navigationItem.rightBarButtonItem = addItem;
    
   self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-49-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 96;
    [self.view addSubview:self.tableView];
    
   
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getUploadArray];
    NSLog(@"uploadArray:%@",self.uploadArray);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

# pragma mark - processer
- (void)addAction:(UIBarButtonItem *)item
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择"
                                        delegate:self
                               cancelButtonTitle:nil
                          destructiveButtonTitle:@"取消"
                               otherButtonTitles:@"从相册选择", nil];
    
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSLog(@"buttonIndex: %ld", (long)buttonIndex);
    
    switch (buttonIndex) {
        case 0:
            // 取消选择
            return;
            
        case 1:
            // 从相册中选择
            break;
            
        default:
            return;
            break;
    }
    
    DWVideoCompressController *imagePicker = [[DWVideoCompressController alloc] initWithQuality: DWUIImagePickerControllerQualityTypeMedium andSourceType:DWUIImagePickerControllerSourceTypePhotoLibrary andMediaType:DWUIImagePickerControllerMediaTypeMovieAndImage];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:NO completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"info: %@", info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (![mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                        message:@"请选择一个视频文件"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    //此时视频保存在临时路径temp中，建议保存在document中 demo只为示例
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    self.videoPath = [videoURL path];
    
    
    // 跳转到 设置视频标题、标签、简介等信息界面。
    DWUploadInfoSetupViewController *viewController = [[DWUploadInfoSetupViewController alloc] init];
    
    //开始上传
    WeakSelf(self);
    [viewController didBackBlock:^(BOOL isCancel, NSString *videoTitle, NSString *videoTag, NSString *videoDescription) {
        
        //开始上传
        if (!isCancel) {
            
            weakself.videoTitle =videoTitle;
            weakself.videoTag =videoTag;
            weakself.videoDescription =videoDescription;
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

# pragma mark - processer
- (void)startUpload
{
    NSError *error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    DWUploadModel *model = [[DWUploadModel alloc] init];
    model.status = DWUploadStatusUploading;
    model.videoPath = _videoPath;
    model.videoTitle = _videoTitle;
    model.videoTag = _videoTag;
    model.videoDescripton = _videoDescription;
    model.first =@"1";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_videoPath]) {
        
        NSLog(@"路径不对");
        return;
    }
    
    // 文件不存在则不设置
   model.videoFileSize = [DWTools getFileSizeWithPath:self.videoPath Error:&error];
//    if (error) {
//        model.status =UploadStatusLoadLocalFileInvalid;
//        NSLog(@"get videoPath %@ failed: %@", self.videoPath, [error localizedDescription]);
//        model.videoFileSize = 0;
//    }
    
    [self getUploadArray];
    NSInteger uploadIndex =self.uploadArray.count;
    [self.uploadArray addObject:[model mj_keyValues]];
    [self setUploadArray];
    [self.tableView reloadData];
    
    [self uploadStartWithModel:model index:uploadIndex];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self getUploadArray];
    return self.uploadArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"DWUploadViewCorollerCellId";
    DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil){
        cell = [[DWUploadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
       
    }
    
    cell.statusButton.tag =indexPath.row;
    [cell.statusButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSDictionary *dic =self.uploadArray[indexPath.row];
    DWUploadModel *model =[DWUploadModel mj_objectWithKeyValues:dic];
    [cell setupCell:model];
    
    return cell;
}

- (void)statusButtonAction:(UIButton *)btn{
    
    //防止多次连续点击按钮
    btn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        btn.enabled = YES;
    });
    
    [self getUploadArray];
    
    NSInteger index =btn.tag;
    NSDictionary *dic =self.uploadArray[index];
    DWUploadModel *model =[DWUploadModel mj_objectWithKeyValues:dic];
    if (model.status ==DWUploadStatusFinish){
        
        //不处理
        return;
    }
    
    for (DWUploadModel *uploadingModel in self.uploadingArray) {
        
        if ([uploadingModel.videoPath.lastPathComponent isEqualToString:model.videoPath.lastPathComponent]) {
            
            model.status =uploadingModel.status;
            
        }
        
    }
    
    if (model.status ==DWUploadStatusUploading) {
        
        //暂停
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        [cell.uploader pause];
        model.status =DWUploadStatusPause;
        [cell updateCellProgress:model];
        
        for (DWUploadModel *uploadingModel in self.uploadingArray) {
            
            if ([uploadingModel.videoPath.lastPathComponent isEqualToString:model.videoPath.lastPathComponent]) {
                
                uploadingModel.status =DWUploadStatusPause;
                
            }
            
        }
        
        [self saveUploadModelWithModel:model dictionary:dic];
        
    }else{
        
        //pause fail 续传
        [self uploadStartWithModel:model index:index];
    }
    
}

- (void)setUploadArray{
    
    [[NSUserDefaults standardUserDefaults]setObject:self.uploadArray forKey:uploadsArray];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

- (void)getUploadArray{
    
    //上传数组
    self.uploadArray =[[[NSUserDefaults standardUserDefaults] objectForKey:uploadsArray] mutableCopy];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //先停止任务，否则会因为刷新了tableview 导致停止了别的上传进程
        DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.uploader pause];
        //删除视频 自己写得了
        
        [self getUploadArray];
        [self.uploadArray removeObjectAtIndex:indexPath.row];
        [self setUploadArray];
        
        [tableView reloadData];
        
        
    }
}

- (void)videoUploadFailedAlert:(NSString *)info
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:info
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    
    [alert show];
}

- (void)uploadStartWithModel:(DWUploadModel *)model index:(NSInteger )uploadIndex{
    
    NSDictionary *dic =[model mj_keyValues];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:uploadIndex inSection:0];
    
    //判断是不是在可视区域内
    DWUploadTableViewCell *cell = (DWUploadTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        cell =(DWUploadTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    }
    //上传
    DWUploader *uploader;
//    if (model.uploadContext) {
//
//        uploader =[[DWUploader alloc] initWithVideoContext:[dic objectForKey:@"uploadContext"]];
//
//    }else{
//
//        uploader = [[DWUploader alloc] initWithUserId:DWACCOUNT_USERID
//                                               andKey:DWACCOUNT_APIKEY
//                                     uploadVideoTitle:model.videoTitle
//                                     videoDescription:model.videoDescripton
//                                             videoTag:model.videoTag
//                                            videoPath:model.videoPath
//                                            notifyURL:@"http://www.bokecc.com/"];
//
//    }

    if (model.uploadContext && [model.first integerValue] ==2) {

        uploader =[[DWUploader alloc] initWithVideoContext:[dic objectForKey:@"uploadContext"]];
        
    }else{
        
        uploader = [[DWUploader alloc] initWithUserId:DWACCOUNT_USERID
                                               andKey:DWACCOUNT_APIKEY
                                     uploadVideoTitle:model.videoTitle
                                     videoDescription:model.videoDescripton
                                             videoTag:model.videoTag
                                            videoPath:model.videoPath
                                            notifyURL:@"http://www.bokecc.com/"];
        
    }
    
    uploader.delegate =self;
    uploader.progressBlock = ^(float progress, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
       
        //不断的保存进度
        @autoreleasepool {
          
            model.videoUploadProgress = progress;
            model.videoUploadedSize = totalBytesWritten;
            model.first =@"2";
            model.status =DWUploadStatusUploading;
            [cell updateCellProgress:model];
            //替换
            [self saveUploadModelWithModel:model dictionary:dic];
        }
        
    };
    
    uploader.finishBlock = ^() {
        
        model.status = DWUploadStatusFinish;
        [cell updateUploadStatus:model];
    
        //替换
        [self saveUploadModelWithModel:model dictionary:dic];
        
    };
    
    uploader.failBlock = ^(NSError *error) {
        
        model.status = DWUploadStatusFail;
        [cell updateUploadStatus:model];
        
        [self saveUploadModelWithModel:model dictionary:dic];
        
        for (DWUploadModel *uploadingModel in self.uploadingArray) {
            
            if ([uploadingModel.videoPath.lastPathComponent isEqualToString:model.videoPath.lastPathComponent]) {
                
                uploadingModel.status =DWUploadStatusFail;
                
            }
            
        }
        
        //余下逻辑根据项目需求处理
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败"
//                                                        message:error.localizedDescription
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil, nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"上传失败 errorCode ----%ld",error.code]
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
        
        
       
    };
    

    
    uploader.videoContextForRetryBlock = ^(NSDictionary *videoContext) {

        model.uploadContext = videoContext;
        [self saveUploadModelWithModel:model dictionary:dic];

    };
   
    if (model.uploadContext && [model.first integerValue] ==2) {
     //说明之前有上传过
        [uploader resume];
        
    }else{
    //开始上传
        [uploader start];
    }
    
   uploader.timeoutSeconds = 20;
   cell.uploader =uploader;
   
   [self.uploadingArray addObject:model];
    
    
}

- (void)saveUploadModelWithModel:(DWUploadModel *)model dictionary:(NSDictionary *)dic {
    //替换
    [self getUploadArray];
    [self.uploadArray enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *path1 =[[dictionary objectForKey:@"videoPath"] lastPathComponent];
        NSString *path2 =[[dic objectForKey:@"videoPath"] lastPathComponent];
        
        if ([path1 isEqualToString:path2]) {
            
            NSMutableDictionary *changedDic =[[model mj_keyValues] mutableCopy];
            if (model.status ==DWUploadStatusUploading) {

                [changedDic setObject:[NSString stringWithFormat:@"%ld",DWUploadStatusPause] forKey:@"status"];
            }
            
            model.status =DWUploadStatusUploading;
            [self.uploadArray replaceObjectAtIndex:idx withObject:changedDic];
            [self setUploadArray];
            
            *stop =YES;
        }
        
        
    }];
    
}
#pragma mark-----DWUploaderDelegate
//checkupload第一次请求成功的回调
- (void)checkUploadWithFilePath:(NSString  *)filePath{


    [self getUploadArray];
    [self.uploadArray enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL * _Nonnull stop) {

        NSString *path =[[dictionary objectForKey:@"videoPath"] lastPathComponent];

        if ([filePath.lastPathComponent isEqualToString:path]) {

            NSMutableDictionary *changeDic =[dictionary mutableCopy];
            [changeDic setObject:@"2" forKey:@"first"];

            [self.uploadArray replaceObjectAtIndex:idx withObject:changeDic];
            [self setUploadArray];

            *stop =YES;
        }


    }];


}

@end
