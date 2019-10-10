#import "DWUploadTableViewCell.h"


@interface DWUploadTableViewCell ()

@property (nonatomic,strong)DWUploadModel *model;

@end

@implementation DWUploadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        // 视频缩略图
        self.thumbnailView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.thumbnailView];
        [_thumbnailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(@128);
            make.height.equalTo(@72);
        }];

        // 视频标题
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.textColor = TitleColor_51;
        self.titleLabel.font = TitleFont(14);

        self.titleLabel.numberOfLines = 2;
        [self.contentView addSubview:self.titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.thumbnailView.mas_right).offset(10);
            make.right.equalTo(@(-10));
            make.top.equalTo(self.thumbnailView).offset(5);
            make.height.equalTo(@14);
        }];
        
        CGFloat progressWidth = (ScreenWidth - 10 - 128 - 10 - 10);
        
        self.stateLabel = [[UILabel alloc]init];
        self.stateLabel.textColor = TitleColor_102;
        self.stateLabel.font = TitleFont(13);
        self.stateLabel.text = @"未开始";
        [self.contentView addSubview:self.stateLabel];
        [_stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.width.equalTo(@(progressWidth / 2.0));
            make.bottom.equalTo(self.thumbnailView).offset(-5);
            make.height.equalTo(@13);
        }];
        
        self.scheduleLabel = [[UILabel alloc]init];
        self.scheduleLabel.textColor = TitleColor_102;
        self.scheduleLabel.font = TitleFont(13);
        self.scheduleLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.scheduleLabel];
        [_scheduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.titleLabel);
            make.width.equalTo(@(progressWidth / 2.0));
            make.bottom.equalTo(self.thumbnailView).offset(-5);
            make.height.equalTo(@13);
        }];
        
        self.progressView = [[UIProgressView alloc]init];
        [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.progressTintColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0];
        [self.contentView addSubview:self.progressView];
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.titleLabel);
            make.bottom.equalTo(self.stateLabel.mas_top).offset(-7);
            make.height.equalTo(@3);
        }];
        
    }
    return self;
}

-(void)setUploadModel:(DWUploadModel *)uploadModel
{
    _uploadModel = uploadModel;
    
    if ([uploadModel.otherInfo objectForKey:@"image"]) {
        self.thumbnailView.image = [UIImage imageWithData:[uploadModel.otherInfo objectForKey:@"image"]];
    }else{
        self.thumbnailView.image = [UIImage imageNamed:@"icon_placeholder.png"];
    }
    
    self.titleLabel.text = self.uploadModel.title;
    
    CGFloat titleLabelWidth = (ScreenWidth - 10 - 128 - 10 - 10);
    CGSize size = [DWTools widthWithHeight:titleLabelWidth andFont:self.titleLabel.font andLabelText:self.titleLabel.text];
    if (ceil(size.height) < (self.titleLabel.font.lineHeight * 2)) {
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.thumbnailView).offset(5);
            make.height.equalTo(@16);
        }];
    }else{
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.thumbnailView);
            make.height.equalTo(@40);
        }];
    }
    
    if (self.uploadModel.state == DWUploadStateFinish) {
        self.progressView.hidden = YES;
        self.scheduleLabel.hidden = YES;

        self.stateLabel.text = [NSString stringWithFormat:@"%.2fM",self.uploadModel.fileSize/1024.0/1024.0];
        self.progressView.progress = 1;
    }else{
        //未完成
        self.progressView.hidden = NO;
        self.scheduleLabel.hidden = NO;
        switch (self.uploadModel.state) {
            case DWUploadStateFail:{
                self.stateLabel.text = @"已失败";
                break;
            }
            case DWUploadStateUploading:{
                self.stateLabel.text = @"上传中";
                break;
            }
            case DWUploadStatePause:{
                self.stateLabel.text = @"已暂停";
                break;
            }
            default:
                break;
        }
        
        [self updateCellTotalBytesSent:self.uploadModel.totalSentBytes WithExpectedToSend:self.uploadModel.fileSize];
    }
    
}

-(void)updateCellTotalBytesSent:(int64_t)totalBytesSent WithExpectedToSend:(int64_t)expectedToSend
{
    float uploadedSizeMB = self.uploadModel.totalSentBytes/1024.0/1024.0;
    float fileSizeMB = self.uploadModel.fileSize/1024.0/1024.0;
    self.scheduleLabel.text = [NSString stringWithFormat:@"%0.1fM/%0.1fM", uploadedSizeMB, fileSizeMB];
    self.progressView.progress = uploadedSizeMB / fileSizeMB;
}

@end
