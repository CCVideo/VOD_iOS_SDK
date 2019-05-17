#import <UIKit/UIKit.h>
#import "DWOfflineModel.h"

@interface DWOfflineTableViewCell : UITableViewCell

@property (strong, nonatomic)UIButton *statusButton;
@property (strong, nonatomic)UILabel *progressLabel;
@property (strong, nonatomic)UILabel *videoIdLabel;
@property (strong, nonatomic)UIProgressView *progressView;

@property (nonatomic,assign)BOOL isFinish;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier downloadFinish:(BOOL)finish;

- (void)setupCell:(DWOfflineModel *)model;

- (void)updateCellProgress:(DWOfflineModel *)model;

- (void)updateDownloadStatus:(DWOfflineModel *)model;

@end
