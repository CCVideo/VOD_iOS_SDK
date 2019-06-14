#import <UIKit/UIKit.h>
#import "DWSDK.h"

typedef void(^BackBlock)(BOOL isCancel,NSString *videoTitle,NSString *videoTag,NSString *videoDescription);

@interface DWUploadInfoSetupViewController : UIViewController

@property (copy, nonatomic)NSString *videoTitle;
@property (copy, nonatomic)NSString *videoTag;
@property (copy, nonatomic)NSString *videoDescription;
@property (assign, nonatomic)BOOL isCancel;

@property (nonatomic,copy)BackBlock backBlock;

- (void)didBackBlock:(BackBlock )block;

@end
