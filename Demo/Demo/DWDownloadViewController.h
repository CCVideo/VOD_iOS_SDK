#import <UIKit/UIKit.h>
#import "DWOfflineModel.h"
#import "DWSDK.h"

@interface DWDownloadViewController : UIViewController<UIActionSheetDelegate>

+ (instancetype)sharedInstance;

//isBegin YES未crash的下载 NO crash后的下载 
- (void)startDownloadWith:(DWOfflineModel *)model videoPath:(NSString *)videoPath isBegin:(BOOL )isBegin;


@end
