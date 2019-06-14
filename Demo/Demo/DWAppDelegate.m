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
    // 停止 drmServer
//    [self.drmServer stop];
    
    /*
     锁屏时，系统会释放掉线程，所以，当使用使用到 后台播放加密音频功能 时，需要对DWDrmServer对象额外处理。
     如果没有使用到上述功能的话，直接在方法中调用 [self.drmServer stop]; 即可
     */
    
    // 停止 drmServer
    if ([DWPlayerStatusManager deafultManager].isSetAudioUrl) {
        return;
    }

    [self.drmServer stop];
    self.drmServer = nil;
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
    
    // 启动 drmServer
//    self.drmServer = [[DWDrmServer alloc] initWithListenPort:20140];
//    BOOL success = [self.drmServer start];
//    if (!success) {
//        NSLog(@"drmServer 启动失败");
//    }
    
    
    /*
     同applicationWillResignActive方法中的注释，若没有使用到上述功能
     每次初始化新的DWDrmServer对象 即可
     self.drmServer = [[DWDrmServer alloc] initWithListenPort:20140];
     BOOL success = [self.drmServer start];
     if (!success) {
     NSLog(@"drmServer 启动失败");
     }

     */
    
    // 启动 drmServer
    if (!self.drmServer) {
        self.drmServer = [[DWDrmServer alloc] initWithListenPort:20140];
        BOOL success = [self.drmServer start];
        if (!success) {
             NSLog(@"drmServer 启动失败");
        }
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
