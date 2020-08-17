#import <UIKit/UIKit.h>

@interface DWUploadTableViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView * thumbnailView;
@property(nonatomic,strong)UILabel * titleLabel;
@property(nonatomic,strong)UIProgressView * progressView;
@property(nonatomic,strong)UILabel * stateLabel;
@property(nonatomic,strong)UILabel * scheduleLabel;

@property(nonatomic,strong)DWUploadModel * uploadModel;

-(void)updateCellTotalBytesSent:(int64_t)totalBytesSent WithExpectedToSend:(int64_t)expectedToSend;

@end
