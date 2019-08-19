#import "DWAppDelegate.h"
#import "DWDownloadSessionManager.h"
#import "DWMainViewController.h"
#import "DWNavigationViewController.h"
#import "DWOfflineModel.h"
#import "MJExtension.h"

#define DWUploadItemPlistFilename @"uploadItems.plist"

@interface DWAppDelegate ()

@end

@implementation DWAppDelegate

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
        
    //后台下载设置
    [[DWDownloadSessionManager manager] configureBackroundSession];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    DWMainViewController * mainVC = [[DWMainViewController alloc]initWithCollectionViewLayout:[self getLayout]];
    DWNavigationViewController * nc = [[DWNavigationViewController alloc]initWithRootViewController:mainVC];
    nc.navigationBar.translucent = NO;
    self.window.rootViewController = nc;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    //根据自己项目原业务逻辑，自行斟酌调用即可。
    [self migrateOldDownloadTaskToNewVersion];
        
    [self.window makeKeyAndVisible];
    
    return YES;
}

//下载任务过渡到新版
-(void)migrateOldDownloadTaskToNewVersion
{
    //!!!仅供参考
    //对于旧版本转移逻辑，请参照自己项目中的业务逻辑来处理，此处只是针对旧版Demo中的下载任务，转移到新版的示例。
    
    //1。首先，需要获取到自己项目中的下载队列。
    NSArray * downingArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"downingArray"];
    
    NSArray * finishDicArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"finishDicArray"];
    
    //2。通过[DWDownloadSessionManager manager]的 migrateDownloadTask:。。。方法，将旧版的下载任务过渡到新版。
    [downingArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DWOfflineModel * model = [DWOfflineModel mj_objectWithKeyValues:obj];
        //未下载完成的视频
        //本地路径请务必传nil
        DWDownloadModel * downloadModel = [[DWDownloadSessionManager manager]
                                           migrateDownloadTask:nil
                                           DownloadUrl:model.playurl
                                           MediaType:model.mediatype
                                           Quality:model.definition Desp:model.desp
                                           VRMode:NO
                                           OthersInfo:@{@"title":model.videoId,@"imageUrl":@"icon_placeholder.png"}
                                           UserId:[DWConfigurationManager sharedInstance].DWAccount_userId
                                           VideoId:model.videoId
                                           TotalBytesWritten:0
                                           TotalBytesExpectedToWrite:0];
        
        //如不开始下载，页面显示的进度根据totalBytesWritten，totalBytesExpectedToWrite参数决定。
        //如果以前没有存储此字段，继续开始下载即可获取到正确的数据。
//        if (downloadModel) {
//            //证明过渡成功，否则返回nil
//            [[DWDownloadSessionManager manager] resumeWithDownloadModel:downloadModel];
//        }
    }];
    
    [finishDicArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DWOfflineModel * model = [DWOfflineModel mj_objectWithKeyValues:obj];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentDirectory = [paths objectAtIndex:0];
        NSString * localPath = [NSString stringWithFormat:@"%@/%@",documentDirectory,[model.videoPath lastPathComponent]];
        
        DWDownloadModel * downloadModel = [[DWDownloadSessionManager manager]
                                           migrateDownloadTask:localPath
                                           DownloadUrl:model.playurl
                                           MediaType:model.mediatype
                                           Quality:model.definition
                                           Desp:model.desp
                                           VRMode:NO
                                           OthersInfo:@{@"title":model.videoId,@"imageUrl":@"icon_placeholder.png"}
                                           UserId:[DWConfigurationManager sharedInstance].DWAccount_userId
                                           VideoId:model.videoId
                                           TotalBytesWritten:0
                                           TotalBytesExpectedToWrite:0];
    }];
    
    //3.下载任务过渡完成后，将原本地保存的下载数据删除掉即可。
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"downingArray"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"finishDicArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    //下载的应该也得 搞个id传进去
    [[DWDownloadSessionManager manager] setBackgroundSession:identifier CompletionHandler:completionHandler];
 
    [[DWUploadSessionManager manager] setUploadSession:identifier CompletionHandler:completionHandler];
}

-(UICollectionViewFlowLayout *)getLayout
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake((ScreenWidth - 5) / 2.0, ScaleHeight((ScreenWidth - 20 - 5) / 2.0, 175 / 98.0) + 10 + 14);
    layout.headerReferenceSize = CGSizeMake(ScreenWidth, ScaleHeight((ScreenWidth - 20),355 / 200.0) + 10);
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 15;
    return layout;
}


@end
