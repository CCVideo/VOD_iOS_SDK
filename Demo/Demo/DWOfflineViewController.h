//
//  DWOfflineViewController.h
//  Demo
//
//  Created by luyang on 2017/4/19.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWOfflineModel.h"


typedef void(^DownlaodBlock)(DWOfflineModel *model);
typedef void(^DeleteBlock)(DWOfflineModel *offlineModel,BOOL isDownloading,NSDictionary *dic);

typedef void(^StartDownloadBlock)(DWOfflineModel *model);


@interface DWOfflineViewController : UIViewController

@property (copy, nonatomic)NSString *videoId;

@property (copy, nonatomic)NSString *playUrl;

@property (copy, nonatomic)NSString *definition;

@property (nonatomic,assign)BOOL showDowningTable;

@property (nonatomic,assign)BOOL showFinishTableHidden;


@property (strong,nonatomic)NSMutableArray *downingArray;//要下载的
@property (strong,nonatomic)NSMutableArray *finishArray;//已完成的

@property (nonatomic,copy)DownlaodBlock downloadBlock;
@property (nonatomic,copy)DeleteBlock deleteBlock;
@property (nonatomic,copy)StartDownloadBlock startBlock;



- (void)didDownloadBlock:(DownlaodBlock)block;

- (void)didDeleteBlock:(DeleteBlock )block;

- (void)didStartBlock:(StartDownloadBlock)block;


@end
