//
//  DWDownloadTableViewCell.m
//  Demo
//
//  Created by zwl on 2019/4/26.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWDownloadTableViewCell.h"

@interface DWDownloadTableViewCell ()

@property(nonatomic,strong)UIImageView * iconImageView;
@property(nonatomic,strong)UILabel * titleLabel;
@property(nonatomic,strong)UIProgressView * progressView;
@property(nonatomic,strong)UILabel * stateLabel;
@property(nonatomic,strong)UILabel * scheduleLabel;

@end

@implementation DWDownloadTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.iconImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(@128);
            make.height.equalTo(@72);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.textColor = TitleColor_51;
        self.titleLabel.font = TitleFont(14);
        self.titleLabel.numberOfLines = 2;
        [self.contentView addSubview:self.titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(10);
            make.right.equalTo(@(-10));
            make.top.equalTo(self.iconImageView).offset(5);
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
            make.bottom.equalTo(self.iconImageView).offset(-5);
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
            make.bottom.equalTo(self.iconImageView).offset(-5);
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

-(void)setDownloadModel:(DWDownloadModel *)downloadModel
{
    _downloadModel = downloadModel;
    
    if ([[downloadModel.othersInfo objectForKey:@"imageUrl"] hasPrefix:@"http"]) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[downloadModel.othersInfo objectForKey:@"imageUrl"]] placeholderImage:[UIImage imageNamed:@"icon_placeholder.png"]];
    }else{
        self.iconImageView.image = [UIImage imageNamed:[downloadModel.othersInfo objectForKey:@"imageUrl"]];
    }
    
    self.titleLabel.text = [downloadModel.othersInfo objectForKey:@"title"];

    CGFloat titleLabelWidth = (ScreenWidth - 10 - 128 - 10 - 10);
    CGSize size = [DWTools widthWithHeight:titleLabelWidth andFont:self.titleLabel.font andLabelText:self.titleLabel.text];
    if (ceil(size.height) < (self.titleLabel.font.lineHeight * 2)) {
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView).offset(5);
            make.height.equalTo(@14);
        }];
    }else{
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView);
            make.height.equalTo(@40);
        }];
    }
    
    if (downloadModel.state == DWDownloadStateCompleted) {
        //完成
        self.progressView.hidden = YES;
        self.scheduleLabel.hidden = YES;
        self.stateLabel.text = [NSString stringWithFormat:@"%.2fM",[DWTools fileSizeAtPath:downloadModel.filePath]];
    }else{
        //未完成
        self.progressView.hidden = NO;
        self.scheduleLabel.hidden = NO;
        
        self.progressView.progress = downloadModel.progress.progress;
        //        CGFloat floatSize =fileSize/1024.0/1024.0;

        self.scheduleLabel.text = [NSString stringWithFormat:@"%.2f%@/%.2f%@",[DWDownloadUtility calculateFileSizeInUnit:downloadModel.progress.totalBytesWritten],[DWDownloadUtility calculateUnit:downloadModel.progress.totalBytesWritten],[DWDownloadUtility calculateFileSizeInUnit:downloadModel.progress.totalBytesExpectedToWrite],[DWDownloadUtility calculateUnit:downloadModel.progress.totalBytesExpectedToWrite]];
        switch (downloadModel.state) {
            case DWDownloadStateNone:{
                self.stateLabel.text = @"未开始";
                break;
            }
            case DWDownloadStateRunning:{
                self.stateLabel.text = [NSString stringWithFormat:@"缓存中%.2f%@/s",[DWDownloadUtility calculateFileSizeInUnit:downloadModel.progress.speed],[DWDownloadUtility calculateUnit:downloadModel.progress.speed]];
                break;
            }
            case DWDownloadStateSuspended:{
                self.stateLabel.text = @"已暂停";
                break;
            }
            case DWDownloadStateReadying:{
                self.stateLabel.text = @"等待中";
                break;
            }
            case DWDownloadStateFailed:{
                self.stateLabel.text = @"已失败";
                break;
            }
            default:
                break;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
