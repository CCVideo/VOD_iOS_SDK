#import "DWDownloadTableViewCell.h"

@implementation DWDownloadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)createView
{
    // 视频videoId
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 270, 40)];
    [self.titleLabel setNumberOfLines:1];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.titleLabel];
    
    // 下载按钮
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.downloadButton setFrame:CGRectMake(270, 10, 40, 40)];
    [self.downloadButton setUserInteractionEnabled:YES];
    [self.downloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.downloadButton setImage:[UIImage imageNamed:@"download-down-button"] forState:UIControlStateNormal];
    [self addSubview:self.downloadButton];
   
    
    
   
}

-(void)setupCell:(NSString *)videoId
{
    [self.titleLabel setText:videoId];
}
@end
