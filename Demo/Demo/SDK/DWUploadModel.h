//
//  DWUploadModel.h
//  Demo
//
//  Created by zwl on 2019/8/5.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DWUploadWaterMarkModel;

typedef NS_ENUM(NSUInteger,DWUploadState) {
    DWUploadStateNone     = 0,    //未开始上传
    DWUploadStateReadying,        //准备中
    DWUploadStateUploading,       //上传中
    DWUploadStatePause,           //上传暂停
    DWUploadStateFail,            //上传失败
    DWUploadStateFinish           //上传完成
};

@interface DWUploadModel : NSObject

///上传状态
@property(nonatomic,assign,readonly)DWUploadState state;

///视频标题
@property(nonatomic,strong,readonly)NSString * title;

///视频tag
@property(nonatomic,strong,readonly)NSString * tag;

///视频描述信息
@property(nonatomic,strong,readonly)NSString * desc;

///视频分类
@property(nonatomic,strong,readonly)NSString * categoryId;

///上传进度
@property(nonatomic,assign,readonly)CGFloat progress;

///上传文件总字节数
@property(nonatomic,assign,readonly)int64_t fileSize;

///已上传字节数
@property(nonatomic,assign,readonly)int64_t totalSentBytes;

///本次发送字节数
@property(nonatomic,assign,readonly)int64_t sentBytes;

///自定义参数
@property(nonatomic,copy)NSDictionary * otherInfo;

///视频id
@property(nonatomic,strong,readonly)NSString * videoId;

///回调地址
@property(nonatomic,strong,readonly)NSString * notifyURL;

///是否裁剪 @"1"为裁剪 @“0”不裁剪 不设置默认为不裁剪
@property(nonatomic,copy)NSString * isCrop;

@property(nonatomic,copy)NSString * ew;

///账号id
@property(nonatomic,strong,readonly)NSString * userId;

///视频水印
@property(nonatomic,strong,readonly)DWUploadWaterMarkModel * waterMark;

@end

@interface DWUploadWaterMarkModel : NSObject

///水印文字内容, 1-50个字符，数字、字母、汉字，不填写则文字水印不生效
@property(nonatomic,strong,readonly)NSString * text;

///水印位置0,左上 1右上 2左下 3右下，默认3，非必填
@property(nonatomic,strong,readonly)NSNumber * corner;

///X轴偏移像素值，要求大于0，默认值5,超出视频大小按默认值，非必填
@property(nonatomic,strong,readonly)NSNumber * offsetX;

///offsetY Y轴偏移像素值，要求大于0，默认值5,超出视频大小按默认值，非必填
@property(nonatomic,strong,readonly)NSNumber * offsetY;

//字体类型：0,微软雅黑 1宋体 2黑体，默认0，非必填
@property(nonatomic,strong,readonly)NSNumber * fontFamily;

///字体大小，[0-100]，默认12
@property(nonatomic,strong,readonly)NSNumber * fontSize;

///16进制字体颜色，如#FFFFFF，不能写#号，默认灰色D3D3D3，非必填
@property(nonatomic,strong,readonly)NSString * fontColor;

///透明度，[0-100],默认100，100为不透明，非必填
@property(nonatomic,strong,readonly)NSNumber * fontAlpha;

@end
