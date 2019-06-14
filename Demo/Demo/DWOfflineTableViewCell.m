#import "DWOfflineTableViewCell.h"
#import "DWTools.h"

@implementation DWOfflineTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier downloadFinish:(BOOL)finish
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (finish) {
            [self createViewForDownloadFinish];
        } else {
            [self createViewForDownloading];
        }
        
        _isFinish =finish;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)createViewForDownloadFinish
{
   // 视频video
    self.videoIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 245, 30)];
    [self.videoIdLabel setNumberOfLines:1];
    self.videoIdLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:self.videoIdLabel];
    
    // 文件大小
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 50, 245, 20)];
    self.progressLabel.font = [UIFont systemFontOfSize:14];
    [self.progressLabel setNumberOfLines:1];
    [self addSubview:self.progressLabel];
    
    self.statusButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.statusButton setFrame:CGRectMake(260, 20, 22, 22)];
    [self.statusButton setUserInteractionEnabled:YES];
    [self.statusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.statusButton setImage:[UIImage imageNamed:@"download-play-button"] forState:UIControlStateNormal];
    [self addSubview:self.statusButton];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

-(void)createViewForDownloading
{
    // 视频video
    self.videoIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 5, 245, 30)];
    self.videoIdLabel.numberOfLines = 1;
    self.videoIdLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:self.videoIdLabel];
    
    // 进度条
    self.progressView = [[UIProgressView alloc]
                                    initWithFrame:CGRectMake(16, 37.5, 245, 10)];
    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
    [self.contentView addSubview:self.progressView];
    
    
    // 文件大小进度
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 55, 245, 20)];
    self.progressLabel.numberOfLines = 1;
    self.progressLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.progressLabel];
    
    //下载状态按钮
    self.statusButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.statusButton setFrame:CGRectMake(270,0,44,44)];
    [self.statusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.statusButton];
    
}

-(void)setupCell:(DWOfflineModel *)model
{
    // 视频标题
    if (model.definition) {
        NSString *labelName = [[NSString alloc] initWithFormat:@"%@-%@",[model videoId],[model definition]];
        NSLog(@"labelName : %@",labelName);

        [self.videoIdLabel setText:labelName];
    } else {
        [self.videoIdLabel setText:[model videoId]];
    }
    
    [self updateCellProgress:model];
    
}


- (void)updateCellProgress:(DWOfflineModel *)model;

{
    self.progressView.progress =model.progress;
    if (_isFinish) {
       
     //   self.progressLabel.text =model.finishText;
       //用相对路径
        NSString *path =[model.videoPath lastPathComponent];
        NSString *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        self.progressLabel.text =[NSString stringWithFormat:@"%.2fM",[DWTools fileSizeAtPath:[documentPath stringByAppendingPathComponent:path]]];
        
    }else{
        
        self.progressLabel.text =model.progressText;
    }
    
    [self updateDownloadStatus:model];//下载状态按钮
}

- (void)updateDownloadStatus:(DWOfflineModel *)model
{
    NSString *filename = nil;
    switch (model.state) {
        case DWDownloadStateReadying:
            filename = @"download-stat-waiting";
            break;
            
        case DWDownloadStateNone:
            filename = @"download-status-down";
          //  filename =@"download-status-hold";
            break;
            
        case DWDownloadStateRunning:
            filename = @"download-status-down";
            break;
            
        case DWDownloadStateSuspended:
            filename = @"download-status-hold";
            break;
            
        case DWDownloadStateFailed:
            filename = @"download-status-fail";
            break;
            
        case  DWDownloadStateCompleted:
            filename = @"download-play-button";
            break;
            
        default:
            break;
    }

    [self.statusButton setBackgroundImage:[UIImage imageNamed:filename] forState:UIControlStateNormal];
}

@end
