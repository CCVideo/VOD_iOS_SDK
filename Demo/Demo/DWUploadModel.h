//
//  DWUploadModel.h
//  Demo
//
//  Created by luyang on 2018/3/26.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,DWUploadStatus) {
    DWUploadStatusUploading =0,
    DWUploadStatusPause,
    DWUploadStatusFail,
    DWUploadStatusFinish
};




@interface DWUploadModel : NSObject

@property (nonatomic,copy)NSString *first;//是否是第一次上传 

@property (copy, nonatomic)NSString *videoPath;

@property (copy, nonatomic)NSString *videoTitle;
@property (copy, nonatomic)NSString *videoTag;
@property (copy, nonatomic)NSString *videoDescripton;
@property (assign, nonatomic)CGFloat videoUploadProgress;
@property (assign, nonatomic)CGFloat videoFileSize;
@property (assign, nonatomic)CGFloat videoUploadedSize;
@property (copy, nonatomic)NSDictionary *uploadContext;

@property (assign,nonatomic)DWUploadStatus status;


@end
