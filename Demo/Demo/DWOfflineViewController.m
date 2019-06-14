//
//  DWOfflineViewController.m
//  Demo
//
//  Created by luyang on 2017/4/19.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import "DWOfflineViewController.h"
#import "DWTableView.h"
#import "DWOfflineTableViewCell.h"
#import "DWOfflineModel.h"

#import "DWDownloadSessionManager.h"
#import "DWDownloadUtility.h"
#import "DWCustomPlayerViewController.h"

#import "MJExtension.h"
#import "DWTools.h"

@interface DWOfflineViewController (){

    

}

@property (strong, nonatomic)DWTableView *downloadFinishTableView;
@property (strong, nonatomic)DWTableView *downloadingTableView;
@property (strong, nonatomic)UISegmentedControl *segmentedControl;

@property (nonatomic,copy)NSString *documentDirectory;

@property (nonatomic,assign)BOOL isValidate;

@property (nonatomic,strong)DWOfflineModel *model1;

@property (nonatomic,copy)NSString *playurl;//新的URL

@property (nonatomic,strong)DWOfflineModel *downingModel;



@property (nonatomic,assign)BOOL isPause;//是否暂停

@property (nonatomic,strong)NSData *resumeData;


@end

@implementation DWOfflineViewController



- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    

}


- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];

}

- (void)dealloc{

    
  [[NSNotificationCenter defaultCenter]removeObserver:self];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTableView:) name:@"changeDownload" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTableView:) name:@"finishDownload" object:nil];
    
  
    NSArray *titles = @[@"已完成", @"下载中"];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:titles];
    
    CGRect segmentedFrame = CGRectZero;
    if (@available(iOS 11.0, *)) {
        CGFloat a =  [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        if (a > 0) {
            segmentedFrame = CGRectMake(self.view.frame.size.width/2 - 150, 69 + 24, 300, 44);
        }else{
            segmentedFrame = CGRectMake(self.view.frame.size.width/2 - 150, 69, 300, 44);
        }
    } else {
        segmentedFrame = CGRectMake(self.view.frame.size.width/2 - 150, 69, 300, 44);
    }
    self.segmentedControl.frame = segmentedFrame;
//    self.segmentedControl.frame = CGRectMake(self.view.frame.size.width/2 - 150, 69, 300, 44);
    
    // 初始界面为："下载完成"
    self.segmentedControl.selectedSegmentIndex = 1;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    self.downingArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downingArray"] mutableCopy];
    self.finishArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"finishDicArray"] mutableCopy];

    // 加载下载中tableView 和 下载已完成tableView
    [self loadDownloadingTableView];
    [self loadDownloadFinishTableView];
    
    if (_showDowningTable) {
        
        self.downloadingTableView.hidden =NO;
        self.downloadFinishTableView.hidden =YES;
        self.segmentedControl.selectedSegmentIndex = 1;
        
    }else if (_showFinishTableHidden) {
        
        self.downloadingTableView.hidden =YES;
        self.downloadFinishTableView.hidden =NO;
        self.segmentedControl.selectedSegmentIndex = 0;

    }else{
    
        self.downloadFinishTableView.hidden = YES;
        self.downloadingTableView.hidden = NO;
        self.segmentedControl.selectedSegmentIndex = 1;

    }
    
}

- (void)changeTableView:(NSNotification *)noti{
    
    @autoreleasepool {
    
        self.downingArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downingArray"] mutableCopy];
        _model1 =noti.object;
        
        for (int i =0; i<self.downingArray.count; i++) {
            
            DWOfflineModel *model2 =[DWOfflineModel mj_objectWithKeyValues:self.downingArray[i]];
            
            if ([_model1.playurl isEqualToString:model2.playurl]) {
                
                NSIndexPath *indexPath =[NSIndexPath indexPathForRow:i inSection:0];
                
                DWOfflineTableViewCell *cell = (DWOfflineTableViewCell *)[self.downloadingTableView cellForRowAtIndexPath:indexPath];
                
                [cell updateCellProgress:_model1];
                
                //不断的保存
                [self.downingArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([[obj objectForKey:@"playurl"] isEqualToString:_model1.playurl]) {
                        
                        *stop =YES;
                        NSMutableDictionary *dic =[obj mutableCopy];
                        [dic setObject:[NSString stringWithFormat:@"%ld",DWDownloadStateSuspended]?:@""  forKey:@"state"];
                        [dic setObject:_model1.progressText?:@"" forKey:@"progressText"];
                        [dic setObject:[NSString stringWithFormat:@"%f",_model1.progress]?:@"" forKey:@"progress"];
                        [self.downingArray replaceObjectAtIndex:idx withObject:dic];
                        [[NSUserDefaults standardUserDefaults] setObject:self.downingArray forKey:@"downingArray"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                    
                }];
                
            }
    
        }

    }
    
}

- (void)finishTableView:(NSNotification *)noti{

    
    self.downingArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downingArray"] mutableCopy];
    self.finishArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"finishDicArray"] mutableCopy];
    
    [self.downloadFinishTableView reloadData];
    [self.downloadingTableView reloadData];
    
}




- (void)loadDownloadingTableView{

        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height + 10;
        if (!IsIOS7) {
            frame.size.height = frame.size.height - self.segmentedControl.frame.size.height - 10 - 20 - 44;
        } else {
            frame.size.height = frame.size.height - frame.origin.y;
        }
        self.downloadingTableView = [[DWTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.downloadingTableView.rowHeight = 80.0f;
    
        
       __weak typeof(self)weakSelf =self;
        
        self.downloadingTableView.tableViewNumberOfRowsInSection = ^NSInteger(UITableView *tableView, NSInteger section) {
            
            
            return weakSelf.downingArray.count;
        }; 
        
        self.downloadingTableView.tableViewCellForRowAtIndexPath = ^UITableViewCell*(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *cellId = @"DWOfflineViewControllerCellId";
            DWOfflineTableViewCell *cell = (DWOfflineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
            
            
            if(cell == nil){
                cell = [[DWOfflineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId downloadFinish:NO];
                // 为 DWUploadTableViewCell 的 statusButton 绑定方法
            }
            
            cell.statusButton.tag = indexPath.row;
            [cell.statusButton addTarget:weakSelf action:@selector(videoDownloadingStatusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            weakSelf.downingArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downingArray"] mutableCopy];
            DWOfflineModel *model =[DWOfflineModel mj_objectWithKeyValues:weakSelf.downingArray[indexPath.row]];
            
           [cell setupCell:model];
           
            return cell;
        };
        
        self.downloadingTableView.numberOfSectionsInTableView = ^NSInteger(UITableView *tableView){
            return 1;
        };
        
        self.downloadingTableView.tableViewCanEditRowAtIndexPath = ^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
            return YES;
        };
        
        self.downloadingTableView.tableViewCommitEditingStyleforRowAtIndexPath = ^(UITableView * tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath) {
            
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                //删除
                
                @try {
                    DWOfflineModel *model =[DWOfflineModel mj_objectWithKeyValues:weakSelf.downingArray[indexPath.row]];
                    model.isDelete =YES;
                    //通知上个页面 保持数据一致
                    if (weakSelf.deleteBlock) {
                        
                        weakSelf.deleteBlock(model,YES,nil);
                    }
                    
                    weakSelf.downingArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downingArray"] mutableCopy];
                    [weakSelf.downingArray removeObject:weakSelf.downingArray[indexPath.row]];
                    [[NSUserDefaults standardUserDefaults] setObject:weakSelf.downingArray forKey:@"downingArray"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [weakSelf.downloadingTableView reloadData];
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
               
            }
        };
        
        [self.downloadingTableView resetDelegate];
        [self.view addSubview:self.downloadingTableView];
}
        
# pragma mark - tableView

- (void)loadDownloadFinishTableView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height + 10;
    if (!IsIOS7) {
        frame.size.height = frame.size.height - self.segmentedControl.frame.size.height - 10 - 20 - 44;
        
    } else {
        frame.size.height = frame.size.height - frame.origin.y;
    }
    self.downloadFinishTableView = [[DWTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.downloadFinishTableView.rowHeight = 80.0f;
    
   
    
   __weak typeof(self)weakSelf =self;
    self.downloadFinishTableView.tableViewNumberOfRowsInSection = ^NSInteger(UITableView *tableView, NSInteger section) {
        
        return weakSelf.finishArray.count;
    };
    
    self.downloadFinishTableView.tableViewCellForRowAtIndexPath = ^UITableViewCell*(UITableView *tableView, NSIndexPath *indexPath) {
        static NSString *cellId = @"DWOfflineViewControllerCellId";
        
      DWOfflineTableViewCell *cell = (DWOfflineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
        if(cell == nil){
            cell = [[DWOfflineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId downloadFinish:YES];
            // 为 DWUploadTableViewCell 的 statusButton 绑定方法
            
        }
        
        [cell.statusButton addTarget:weakSelf action:@selector(videoDownloadFinishStatusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.statusButton.tag = indexPath.row;
        
        
        NSDictionary *dic =weakSelf.finishArray[indexPath.row];
        
        DWOfflineModel *model =[[DWOfflineModel alloc]init];
        model.videoPath =[dic objectForKey:@"videoPath"];
        model.videoId =[dic objectForKey:@"videoId"];
        model.definition = [dic objectForKey:@"definition"];
        model.finishText =[dic objectForKey:@"finishText"];
        model.playurl =[dic objectForKey:@"playurl"];
        model.mediatype = [NSString stringWithFormat:@"%@",[dic objectForKey:@"mediatype"]];
        model.state =DWDownloadStateCompleted;
        
        [cell setupCell:model];
        
        
        return cell;
    };
    
    self.downloadFinishTableView.numberOfSectionsInTableView = ^NSInteger(UITableView *tableView){
        return 1;
    };
    
    self.downloadFinishTableView.tableViewCanEditRowAtIndexPath = ^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
        return YES;
    };
    
    self.downloadFinishTableView.tableViewCommitEditingStyleforRowAtIndexPath = ^(UITableView * tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath) {
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            
            
            //删除
            NSDictionary *dic =weakSelf.finishArray[indexPath.row];
           
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            weakSelf.finishArray =[[defaults objectForKey:@"finishDicArray"] mutableCopy];
            [weakSelf.finishArray removeObject:dic];
            [defaults setObject:weakSelf.finishArray forKey:@"finishDicArray"];
            [defaults synchronize];
            
            [weakSelf.downloadFinishTableView reloadData];
        //通知上个页面 保持数据一致
            if (weakSelf.deleteBlock) {
                
                weakSelf.deleteBlock(nil, NO,dic);
            }

            
        }
    };
    
    [self.downloadFinishTableView resetDelegate];
    [self.view addSubview:self.downloadFinishTableView];
}


//点击下载按钮

- (void)videoDownloadingStatusButtonAction:(UIButton *)button{

   self.downingArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downingArray"] mutableCopy];
    
    if (self.downingArray.count != 0) {
        DWOfflineModel *model =[DWOfflineModel mj_objectWithKeyValues:self.downingArray[button.tag]];
        //判断URL是否失效
        [self validate:model];
    }
    
 //   [self actionModel:model];
 
}


- (void)actionModel:(DWOfflineModel *)model{
    


    if ([_model1.playurl isEqualToString:model.playurl]) {

        model.progress = _model1.progress;
        model.progressText = _model1.progressText;
        model.state = _model1.state;
    }
    
   switch (model.state) {
        case DWDownloadStateReadying:
            
            NSLog(@"等待中");
            
            
            break;
            
        case DWDownloadStateNone:
            NSLog(@"未下载 或 下载删除了");
          
          
            break;
            
        case DWDownloadStateRunning:
            //转为暂停
            if (_downloadBlock) {
                
                _downloadBlock(model);
            }
            
            break;
            
        case DWDownloadStateSuspended:
            //恢复下载
            if (_downloadBlock) {
                
                _downloadBlock(model);
            }
            
            break;
            
        case DWDownloadStateFailed:
            //下载失败 开始下载
            NSLog(@"失败");
            
            break;
            
        case  DWDownloadStateCompleted:
            
            NSLog(@"完成了");
            
            
            break;
            
        default:
            break;
    }

}


/**
 判断URL是否有效
 *取得时间戳与失效时间戳做比对
 *http://d1-33.play.bokecc.com/flvs/cb/QxhEr/hKboX7hTIY-20.pcm?t=1496894440&key=F458F79EF07944EAAF38AC01A4F49CC9&upid=2625321496887240251
 *t=1496894440为失效时间点
 */
-(void)validate:(DWOfflineModel *)model{
    
    
    NSRange range =[model.playurl rangeOfString:@"t="];
    NSRange timeRang =NSMakeRange(range.location+2, 10);
    NSString *oldStr =[model.playurl substringWithRange:timeRang];
    NSLog(@"时间%@",oldStr);
    
    NSDate *date =[NSDate date];
    NSString *timeString =[NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    NSString *nowString =[timeString substringWithRange:NSMakeRange(0, 10)];
    NSLog(@"__%@___%@",oldStr,nowString);
    
    if ([nowString integerValue] >= [oldStr integerValue]) {
        
        NSLog(@"url不可用");
        [self requestPlayInfo:model];
        
    }else{
        
        NSLog(@"url可用");
        //刷新UI 一定要回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self actionModel:model];
            
        });
        
    }
    
    
}

//下载的URL的时效是两小时。两小时后URL失效，先获取新的下载URL以及原先的resumeData 再拼接成新的Data  实现断点续传
- (void)requestPlayInfo:(DWOfflineModel *)model{
    

        //请求视频播放信息  获取下载地址 hlsSupport传@"0"
        DWPlayInfo *playinfo = [[DWPlayInfo alloc] initWithUserId:DWACCOUNT_USERID andVideoId:model.videoId key:DWACCOUNT_APIKEY hlsSupport:@"0"];
        //网络请求超时时间
        playinfo.timeoutSeconds =20;
        playinfo.errorBlock = ^(NSError *error){
            
            NSLog(@"请求资源失败");
          
        };
        
        playinfo.finishBlock = ^(NSDictionary *response){
            
            NSDictionary *playUrls =[DWUtils parsePlayInfoResponse:response];
            
            if (!playUrls) {
                //说明 网络资源暂时不可用
            }
            
            NSArray *defArray =[playUrls objectForKey:@"definitions"];
            [defArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([[obj objectForKey:@"definition"] integerValue] ==[model.definition integerValue]) {
                    
                    *stop =YES;
                   //旧的URL
                    NSString *downloadUrl =model.playurl;
                   //新的URL
                    model.playurl =[obj objectForKey:@"playurl"];
                    
                    NSData *resumeData =[[DWDownloadSessionManager manager] resumeDataFromFileWithFilePath:downloadUrl];
                  
                    // resumeData model.playurl必须有值
                    model.resumeData =[[DWDownloadSessionManager manager] newResumeDataFromOldResumeData:resumeData withURLString:model.playurl];
                    
                    
                    //因为model.playurl变了 所以要替换掉原先的model
                    [self replaceModel:model urlStr:downloadUrl];
                    
                    //回调 重新走下载的方法
                    if (_startBlock) {
                        
                        _startBlock(model);
                    }
                    
                    
                }
                
                
            }];
           
         
            
        };
        [playinfo start];
}


- (void)replaceModel:(DWOfflineModel *)model urlStr:(NSString *)urlStr{

   self.downingArray =[[[NSUserDefaults standardUserDefaults] objectForKey:@"downingArray"] mutableCopy];

    for (int i =0;i < self.downingArray.count;i++) {
    
        NSMutableDictionary *dic =[self.downingArray[i] mutableCopy];
        
        if ([[dic objectForKey:@"playurl"] isEqualToString:urlStr]) {
            
              [dic setObject:model.playurl forKey:@"playurl"];
            
              [self.downingArray replaceObjectAtIndex:i withObject:dic];
            
    
        }
    
 }
    [[NSUserDefaults standardUserDefaults] setObject:self.downingArray forKey:@"downingArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}



//播放
- (void)videoDownloadFinishStatusButtonAction:(UIButton *)button
{
    NSInteger indexPath = button.tag;
    NSDictionary *dic = [self.finishArray objectAtIndex:indexPath];
    
    DWOfflineModel *model =[[DWOfflineModel alloc]init];
    model.videoPath =[dic objectForKey:@"videoPath"];
    model.videoId =[dic objectForKey:@"videoId"];
    model.definition = [dic objectForKey:@"definition"];
    model.finishText =[dic objectForKey:@"finishText"];
    model.playurl =[dic objectForKey:@"playurl"];
    model.mediatype = [NSString stringWithFormat:@"%@",[dic objectForKey:@"mediatype"]];
    
    //如model.videoPath： /var/mobile/Containers/Data/Application/8815A020-CD0F-4C4E-BFAB-F96AEF0C36E3/Documents/1AEE1E611E2B81EC9C33DC5901307461-10.pcm  只需截取文件名：1AEE1E611E2B81EC9C33DC5901307461-10.pcm 播放时拼接成相对路径
    
    DWCustomPlayerViewController *player = [[DWCustomPlayerViewController alloc]init];
    player.localPath = [model.videoPath lastPathComponent];
    player.localMediatype = model.mediatype;
    player.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:player animated:NO];
    
    
}



//segment的点击
- (void)segmentedControlAction:(UISegmentedControl *)segment
{
    NSLog(@"%ld 被点击", (long)[segment selectedSegmentIndex]);
    if ([segment selectedSegmentIndex] == 0) { //已下载
        self.downloadFinishTableView.hidden = NO;
        self.downloadingTableView.hidden = YES;
        
    } else { // 下载中
        self.downloadFinishTableView.hidden = YES;
        self.downloadingTableView.hidden = NO;
    }
}



- (void)didDownloadBlock:(DownlaodBlock)block{

    _downloadBlock =block;
}

- (void)didDeleteBlock:(DeleteBlock )block{

    _deleteBlock =block;
}

- (void)didStartBlock:(StartDownloadBlock)block{

    _startBlock =block;

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
