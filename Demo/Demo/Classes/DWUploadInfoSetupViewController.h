#import "DWBaseViewController.h"

typedef void(^BackBlock)(BOOL isCancel,NSString * userId,NSString * apiKey,NSString * videoTitle,NSString * videoTag,NSString * videoDescription);

@interface DWUploadInfoSetupViewController : DWBaseViewController

@property (nonatomic,copy)BackBlock backBlock;

- (void)didBackBlock:(BackBlock )block;

@end
