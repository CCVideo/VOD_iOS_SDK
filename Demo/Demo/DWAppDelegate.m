#import "DWAppDelegate.h"
#import "DWAccountViewController.h"
#import "DWUploadViewController.h"
#import "DWPlayerViewController.h"
#import "DWDownloadViewController.h"

#import "DWDownloadSessionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DWPlayerStatusManager.h"


#define DWDownloadingItemPlistFilename @"downloadingItems.plist"
#define DWDownloadFinishItemPlistFilename @"downloadFinishItems.plist"

#define DWUploadItemPlistFilename @"uploadItems.plist"

@interface DWAppDelegate ()

@property (strong, nonatomic)DWAccountViewController *accountViewController;
@property (strong, nonatomic)DWUploadViewController *uploadViewController;
@property (strong, nonatomic)DWPlayerViewController *playerViewController;
@property (strong, nonatomic)DWDownloadViewController *downloadViewController;
@property (strong, nonatomic)UITabBarController *tabBarController;
@end
@implementation DWAppDelegate

@synthesize isDownloaded;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DWLog setIsDebugHttpLog:YES];
    
    //设置AVAudioSession
    NSError *categoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&categoryError];
    if (!success)
    {
        NSLog(@"Error setting audio session category: %@", categoryError);
    }
    
    NSError *activeError = nil;
    success = [[AVAudioSession sharedInstance] setActive:YES error:&activeError];
    if (!success)
    {
        NSLog(@"Error setting audio session active: %@", activeError);
    }
    
    //是否允许移动流量下载
  //  [DWDownloadSessionManager manager].allowsCellular =NO;
    //后台下载设置
    [[DWDownloadSessionManager manager] configureBackroundSession];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.accountViewController = [[DWAccountViewController alloc] init];
    UINavigationController *accountNavigation = [[UINavigationController alloc] initWithRootViewController:self.accountViewController];
    
    self.uploadViewController = [[DWUploadViewController alloc] init];
    UINavigationController *uploadNavigation = [[UINavigationController alloc] initWithRootViewController:self.uploadViewController];
    
    self.playerViewController = [[DWPlayerViewController alloc] init];
    UINavigationController *playerNavigation = [[UINavigationController alloc] initWithRootViewController:self.playerViewController];
    
   // self.downloadViewController = [[DWDownloadViewController alloc] init];
    self.downloadViewController =[DWDownloadViewController sharedInstance];
    UINavigationController *downloadNavigation = [[UINavigationController alloc] initWithRootViewController:self.downloadViewController];
    
    NSArray *viewControllers = @[
                                 accountNavigation,
                                 uploadNavigation,
                                 playerNavigation,
                                 downloadNavigation];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = viewControllers;
    self.tabBarController.selectedViewController = accountNavigation;
    //    [self.window addSubview:self.tabBarController.view];
    [self.window setRootViewController:self.tabBarController];

    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
      [application beginReceivingRemoteControlEvents]; 
     
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
