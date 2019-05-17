//
//  DWGIFViewController.m
//  Demo
//
//  Created by luyang on 2017/9/20.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import "DWGIFViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DWGIFManger.h"
#import "MBProgressHUD.h"

static NSString *const gifVideo =@"GifVideo";

static NSString *const gifImage =@"GifImage";

static const NSInteger width =250;
static const NSInteger height =200;

@interface DWGIFViewController ()
@property (nonatomic,strong)UIWebView *webview;

@property (nonatomic,strong)UIButton *downloadBtn;
@property (nonatomic,strong)UILabel *label;

@property (nonatomic,copy)NSString *gifImagePath;

@property (nonatomic,strong)DWGIFManger *gifManager;

@property (nonatomic,strong)MBProgressHUD *hud;



@end

@implementation DWGIFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //创建gifVideo目录文件
    [self createFileIfNotExistWith:gifVideo];
   // 创建gifImage目录文件
    [self createFileIfNotExistWith:gifImage];
    
    [self loadSubbview];
    
    [self makeGifWithVideo];
    
    self.automaticallyAdjustsScrollViewInsets =NO;
    
    _hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.label.text =@"GIF生成中";

    
}

- (void)loadSubbview{
    
    _webview =[[UIWebView alloc]initWithFrame:CGRectMake((ScreenWidth-width)/2,70,width,height)];
    _webview.scalesPageToFit =YES;
    
    _webview.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:_webview];
    
    _downloadBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [_downloadBtn setImage:[UIImage imageNamed:@"download_nor"] forState:UIControlStateNormal];
    _downloadBtn.frame =CGRectMake((ScreenWidth-36)/2,210+10, 36, 36);
    _downloadBtn.layer.cornerRadius =18;
    _downloadBtn.layer.masksToBounds =YES;
    [_downloadBtn addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    _downloadBtn.hidden =YES;
    [self.view addSubview:_downloadBtn];
    
    _label =[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-80)/2,CGRectGetMaxY(_downloadBtn.frame), 80, 17)];
    _label.text =@"保存本地";
    _label.font =[UIFont systemFontOfSize:13];
    _label.textColor =[UIColor colorWithWhite:0 alpha:0.8];
    _label.textAlignment =NSTextAlignmentCenter;
    _label.hidden =YES;
    [self.view addSubview:_label];
    
   
 }

//保存到手机相册
- (void)downloadAction{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSData *data =[NSData dataWithContentsOfFile:_gifImagePath];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if (!error) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"保存成功"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }else{
            
            NSLog(@"%@",error);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存fail" message:error.localizedDescription
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
        
    }];
    
}

- (void)makeGifWithVideo{
    
    _gifManager =[[DWGIFManger alloc]init];
 //   _gifManager.gifSize =GIFSizeVeryLow;
   //先截取视频 再制作成GIF
    [self interceptVideo];
    
  
}

- (void)interceptVideo{
    
    //截取的视频文件路径
    NSString *videoFilePath =[self saveFilePathString:@".mov" andFileName:gifVideo];

    WeakSelf(self);
    [_gifManager interceptVideoAndVideoUrl:_gifDictionary[@"videoURL"] withOutPath:videoFilePath outputFileType:AVFileTypeQuickTimeMovie range:NSMakeRange([_gifDictionary[@"gifStartTime"] integerValue],[_gifDictionary[@"gifTotalTime"] integerValue]) intercept:^(NSError *error, NSURL *outPutURL) {
        
        StrongSelf(self);
        if (!error) {
            
            [self savePhotosAlbum:outPutURL];
            [self creatGifWithVideoFileURL:outPutURL];
            
         }else{
            
            NSLog(@"%@",error);
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"截取fail" message:error.localizedDescription
                                                            delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             
            
        }
        
      }];
    
    
}

- (void)creatGifWithVideoFileURL:(NSURL *)URL{
    
    _gifImagePath =[self saveFilePathString:@".gif" andFileName:gifImage];
    WeakSelf(self);
   [_gifManager createGIFfromURL:URL loopCount:0 delayTime:0.25  gifImagePath:_gifImagePath complete:^(NSError *error, NSURL *GifURL) {
        StrongSelf(self);
       
        [self.hud hideAnimated:YES];
        
        if (!error) {
            
            [self.webview loadRequest:[NSURLRequest requestWithURL:GifURL]];
            self.downloadBtn.hidden =NO;
            self.label.hidden =NO;
           
            
         
            
        }else{
            
            
            NSLog(@"%@",error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"giffail" message:error.localizedDescription
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            
        }
     
        
    }];
    
    
    
}

//文件保存路径
- (NSString *)saveFilePathString:(NSString *)string andFileName:(NSString *)fileName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:fileName];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *filePath = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:string];
    
    return filePath;
    
}

- (void)createFileIfNotExistWith:(NSString *)string{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *folderPath = [path stringByAppendingPathComponent:string];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            
            NSLog(@"创建保存视频文件夹失败");
        }
    }
}


//保存到手机相册
- (void)savePhotosAlbum:(NSURL *)videoPathURL{
    
    
    //必须调用延时的方法 否则可能出现保存失败的情况
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoPathURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:videoPathURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (error) {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"保存失败"
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                         
                         
                     } else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"保存成功"
                                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                         
                         
                         
                         
                     }
                 });
                 
                 
             }];
        }
        
        
        
    });
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

