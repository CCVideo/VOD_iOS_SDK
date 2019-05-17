//
//  DWOfflineModel.h
//  Demo
//
//  Created by luyang on 2017/4/19.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDownloadModel.h"

@interface DWOfflineModel : NSObject

@property (nonatomic,copy)NSString *definition;
@property (nonatomic,copy)NSString *desp;
@property (nonatomic,copy)NSString *playurl;
@property (nonatomic,copy)NSString *mediatype;

@property (nonatomic,copy)NSString *videoId;

@property (nonatomic,copy)NSString *progressText;//下载文字
@property (nonatomic,copy)NSString *finishText;//已完成的文字

@property (nonatomic, assign)CGFloat progress;//进度

@property (nonatomic,copy)NSString *videoPath;//路径

@property (nonatomic,assign)DWDownloadState state;//下载状态
//加密token  加密必用   非加密可以不用
@property (nonatomic,copy)NSString *token;


@property (nonatomic,assign)BOOL isDelete;//是否删除
@property (nonatomic,assign)BOOL isUnValite;//url是否失效 YES失效 NO有效

@property (nonatomic,strong)NSData *resumeData;


@property (nonatomic,assign)BOOL isPause;

@end
