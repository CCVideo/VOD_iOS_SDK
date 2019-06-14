//
//  DWErrorCode.h
//  Demo
//
//  Created by zwl on 2018/10/18.
//  Copyright © 2018 com.bokecc.www. All rights reserved.
//

#ifndef DWErrorCode_h
#define DWErrorCode_h

/*
 error code
 播放相关的 100 +
 下载相关的 200 +
 上传相关的 300 +
 网络相关的 400 +
 */

//playinfo接口返回请求失败
#define ERROR_REQUEST    (100)
//视频不可用
#define ERROR_VIDEO      (101)
//视频状态  处理中
#define ERROR_VIDEO_PROCESSING      (102)
//视频状态  已删除
#define ERROR_VIDEO_DELETE      (103)
//视频转码失败
#define ERROR_VIDEO_TRANFAILURE      (104)
//视频状态未知错误
#define ERROR_VIDEO_UNKNOW        (105)
//创建AVPlayer 失败
#define ERROR_AVPLAYER_CREATE        (130)
//未知播放错误
#define ERROR_VIDEOPLAY_UNKNOW        (131)
//截取GIF时，未调用关联方法
#define ERROR_GIF_UNASSOCIATION       (170)
//批量下载参数有误
#define ERROR_BATCHDOWNLOAD_PARAMS    (240)
//xml解析失败
#define ERROR_XML_ERROR               (300)
//断电续传参数错误
#define ERROR_UPLOAD_PARAMS           (301)
//用户剩余空间不足
#define ERROR_UPLOAD_NOTENOUGHCAPACITY          (302)
//用户服务终止
#define ERROR_UPLOAD_SERVICEEXPIRED    (303)
//服务器处理错误
#define ERROR_UPLOAD_PROCESSFAIL       (304)
//访问过于频繁
#define ERROR_UPLOAD_TOOMANYACCESS     (305)
//用户服务无权限
#define ERROR_UPLOAD_NOTPERMISSION     (306)
//上传失败
#define ERROR_UPLOAD_FAIL              (399)

//网络资源暂时不可用
#define ERROR_INTERNET   (400)

#endif /* DWErrorCode_h */
