#import <UIKit/UIKit.h>
#import "DWUploadModel.h"
#import "DWImageTitleButton.h"
#import "DWUploader.h"



@interface DWUploadTableViewCell : UITableViewCell

@property (strong, nonatomic)UIImageView *thumbnailView;
@property (strong, nonatomic)DWImageTitleButton *statusButton;
@property (strong, nonatomic)UILabel *progressLabel;
@property (strong, nonatomic)UILabel *titleLabel;

@property (strong, nonatomic)UIProgressView *progressView;

@property (strong, nonatomic)DWUploader *uploader;




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)setupCell:(DWUploadModel *)model;

- (void)updateCellProgress:(DWUploadModel *)model;

- (void)updateUploadStatus:(DWUploadModel *)model;



@end
