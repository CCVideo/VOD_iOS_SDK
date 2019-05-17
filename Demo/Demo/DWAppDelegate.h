#import <UIKit/UIKit.h>

#import "DWSDK.h"

@interface DWAppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL isDownloaded;
}
@property (assign, nonatomic)BOOL isDownloaded;
@property (strong, nonatomic)UIWindow *window;

@property (nonatomic,copy)NSString *mediatype;

@end
