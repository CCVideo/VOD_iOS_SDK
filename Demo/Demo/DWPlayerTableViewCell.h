#import <UIKit/UIKit.h>

@interface DWPlayerTableViewCell : UITableViewCell

@property (strong, nonatomic)UILabel *titleLabel;
@property (strong, nonatomic)UIButton *playButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)setupCell:(NSString *)videoId;

@end
