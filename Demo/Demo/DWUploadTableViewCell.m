#import "DWUploadTableViewCell.h"


@interface DWUploadTableViewCell ()

@property (nonatomic,strong)DWUploadModel *model;

@end

@implementation DWUploadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}


-(void)createView
{
    // 视频缩略图
    self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 18, 80, 60)];
    [self addSubview:self.thumbnailView];
    
    // 视频标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 18, 130, 30)];
    [self.titleLabel setNumberOfLines:1];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.titleLabel];
    
    // 文件大小进度
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 53, 130, 20)];
    [self.progressLabel setNumberOfLines:1];
    [self.progressLabel setFont:[UIFont systemFontOfSize:10]];
    [self addSubview:self.progressLabel];
    
    // 进度条宽度
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(110, 78, 130, 10)];
    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [self addSubview:self.progressView];
    
    
    //上传按钮
    self.statusButton = [DWImageTitleButton buttonWithType:UIButtonTypeCustom];
    [self.statusButton setFrame:CGRectMake(254, 32, 60, 60)];
    self.statusButton.adjustsImageWhenHighlighted = YES;
    self.statusButton.showsTouchWhenHighlighted =YES;
    [self.statusButton setUserInteractionEnabled:YES];
    [self.statusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.statusButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:self.statusButton];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}



-(void)setupCell:(DWUploadModel *)model
{
    _model =model;
    //拼接路径
    NSString *tmp =NSTemporaryDirectory();
    model.videoPath =[tmp stringByAppendingPathComponent:[model.videoPath lastPathComponent]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:model.videoPath]) {
        
        // 视频缩略图
        UIImage *image = [DWTools getThumbnailImage:model.videoPath time:1];
        [self.thumbnailView setImage:image]; 
    }
    
    // 视频标题
    [self.titleLabel setText:[model videoTitle]];
    
    // 文件大小进度
    float uploadedSizeMB = [model videoUploadedSize]/1024.0/1024.0;
    float fileSizeMB = [model videoFileSize]/1024.0/1024.0;
    [self.progressLabel setText:[NSString stringWithFormat:@"%0.1fM/%0.1fM", uploadedSizeMB, fileSizeMB]];
    [self.progressLabel setNumberOfLines:1];
    
    // 进度条宽度
    [self.progressView setProgress:[model videoUploadProgress]];
    
    [self showStatusButtonWithUploadModel:model];
}

- (void)showStatusButtonWithUploadModel:(DWUploadModel *)model{
    
    NSString *imageName,*title;
    //防止cell复用  导致再次创建cell时，按钮enabled=NO 的情况
    self.statusButton.enabled = YES;
    
    switch (model.status) {
        case DWUploadStatusFail:
            imageName = @"download-status-fail";
            title = @"失败";
            break;
        case DWUploadStatusFinish:
            imageName = @"upload-status-finish";
            title  = @"完成";
            self.statusButton.enabled = NO;
            break;
            
        case DWUploadStatusUploading:
            imageName = @"upload-status-uploading";
            title = @"上传中";
            break;
        case DWUploadStatusPause:
            imageName = @"download-status-hold";
            title = @"暂停";
            break;
            
        default:
            break;
    }
    
    [self.statusButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
   // [self.statusButton setTitle:title forState:UIControlStateNormal];
    
    
    
}

- (void)updateCellProgressWithProgress:(float)progress andUploadedSize:(NSInteger)uploadedSize fileSize:(NSInteger)fileSize
{
    [self.progressView setProgress:progress];
    
    float uploadedSizeMB = uploadedSize/1024.0/1024.0;
    float fileSizeMB = fileSize/1024.0/1024.0;
    [self.progressLabel setText:[NSString stringWithFormat:@"%0.1fM/%0.1fM", uploadedSizeMB, fileSizeMB]];
}

- (void)updateCellProgress:(DWUploadModel *)model
{
    [self.progressView setProgress:[model videoUploadProgress]];
    
    float uploadedSizeMB = [model videoUploadedSize]/1024.0/1024.0;
    float fileSizeMB = [model videoFileSize]/1024.0/1024.0;
    [self.progressLabel setText:[NSString stringWithFormat:@"%0.1fM/%0.1fM", uploadedSizeMB, fileSizeMB]];
    [self showStatusButtonWithUploadModel:model];
}


- (void)updateUploadStatus:(DWUploadModel *)model
{

    [self showStatusButtonWithUploadModel:model];
    
    [self.progressLabel setText:[NSString stringWithFormat:@"%0.1fM/%0.1fM",model.videoUploadedSize/1024.0/1024.0,model.videoFileSize/1024.0/1024.0]];
}

@end
