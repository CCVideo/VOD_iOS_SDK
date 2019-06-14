#import "DWPlayerTableViewCell.h"

@implementation DWPlayerTableViewCell

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
    
    // 播放按钮
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.playButton setFrame:CGRectMake(270, 10, 40, 40)];
    [self.playButton setUserInteractionEnabled:YES];
    [self.playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"play-playbutton"] forState:UIControlStateNormal];
    [self addSubview:self.playButton];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

-(void)setupCell:(NSString *)videoId
{
    [self.titleLabel setText:videoId];
}

@end
