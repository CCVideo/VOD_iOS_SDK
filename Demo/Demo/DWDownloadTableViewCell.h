#import <UIKit/UIKit.h>

@interface DWDownloadTableViewCell : UITableViewCell

@property (strong, nonatomic)UILabel *titleLabel;
@property (strong, nonatomic)UIButton *downloadButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)setupCell:(NSString *)videoId;

@end
