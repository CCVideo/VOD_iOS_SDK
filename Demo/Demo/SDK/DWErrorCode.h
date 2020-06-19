//
//  DWErrorCode.h
//  Demo
//
//  Created by zwl on 2018/10/18.
//  Copyright © 2018 com.bokecc.www. All rights reserved.
//

#ifndef DWErrorCode_h
#define DWErrorCode_h


typedef NS_ENUM(NSUInteger, DWSDK_SERVICE_ERROR) {

    ERROR_INFO_NOTMATCH          = 1000 , //视频参数错误
    ERROR_VIDEO_UNAVAILABLE      = 1001 , //视频不可用
    ERROR_VIDEO_PROCESSING       = 1002 , //视频处理中
    ERROR_VIDEO_DELETE           = 1003 , //视频已删除
    ERROR_VIDEO_TRANFAILURE      = 1004 , //视频转码失败
    ERROR_REQUEST_FAILURE        = 1005 , //网络请求失败
    ERROR_VIDEO_ANALYSIS       = 1006 , //PlayInfo数据解析失败
    ERROR_VIDEO_UNKNOW           = 1007 , //未知错误
    
    ERROR_PLAYERSKIN_VIDEOUNAVAILABLE = 1201 , //视频资源不存在
    ERROR_PLAYERSKIN_LOCALUNAVAILABLE = 1202 , //离线资源不存在
    ERROR_PLAYERSKIN_DISABLEAUTOROTATE = 1203 , //禁止手动旋转
    ERROR_PLAYERSKIN_BUFFEREMPTY = 1204 , //暂无缓冲数据
    ERROR_PLAYERSKIN_BUFFERTIMEOUT = 1205 , //缓冲超时
    ERROR_PLAYERSKIN_LOADTIMEOUT = 1206 , //加载超时

    ERROR_AFINFO_NOTMATCH        = 1301 , //广告参数错误
    ERROR_AFINFO_NOTSERVING      = 1302 , //该用户未投放广告
    ERROR_AFINFO_TYPENOTEXIST    = 1303 , //该用户无type对应类型的广告位
    ERROR_AFINFO_NOTAD           = 1304 , //该用户type类型下无广告
    ERROR_AFINFO_DATA            = 1305 , //数据查询异常
    ERROR_AFINFO_ANALYSIS        = 1306 , //广告数据解析失败
    
    ERROR_BARRAGE_PARAMS         = 1400 , //弹幕参数错误
    ERROR_BARRAGE_ANALYSIS       = 1401 , //弹幕数据解析失败
    
    ERROR_PLAYER_CREATE          = 2000 , //播放器创建失败
    ERROR_VIDEO_PLAYERROR        = 2001 , //播放失败
    ERROR_QUALITY_NOTEXIST       = 2002 , //未查找到清晰度
    ERROR_LOCAL_UNAVAILABLE      = 2003 , //本地资源不可用
    ERROR_PLAYURL_UNAVAILABLE    = 2010 , //播放地址不可用/不存在
    ERROR_GIF_UNASSOCIATION      = 2100 , //GIF未关联播放器
    
    ERROR_EXRCISES_REQUEST       = 2302 , //课堂练习上报失败
    
    ERROR_UPNP_SEARCH            = 2500 , //投屏数据获取失败
    ERROR_UPNP_SUBSCRIPTION      = 2501 , //投屏订阅失败
    
    ERROR_DOWNLOAD_UNAVAILABLE   = 3000 , //网络资源不存在
    ERROR_DOWNLOAD_UNAUTHORIZED  = 3001 , //未获得下载授权
    ERROR_DOWNLOAD_UNSUPPORTM3U8 = 3002 , //暂不支持m3u8视频格式下载
    ERROR_DOWNLOAD_MORETHANMAXCOUNT = 3040, //超过下载最大并发数
    ERROR_DOWNLOAD_ALREADYFAIL   = 3050 , //该任务已失败，请重新下载
    ERROR_DOWNLOAD_MOVEFILE      = 3077 , //下载完成移动文件失败
    ERROR_BATCHDOWNLOAD_NOTMATCH = 3100 , //批量下载参数有误

    ERROR_UPLOAD_NOTMATCH        = 4000 , //上传参数错误
    ERROR_UPLOAD_NOTENOUGHSPACE  = 4001 , //用户剩余空间不足
    ERROR_UPLOAD_SERVICEEXPIRED  = 4002 , //用户服务终止
    ERROR_UPLOAD_PROCESSFAIL     = 4003 , //服务器处理错误
    ERROR_UPLOAD_FREQUENTACCESS  = 4004 , //访问过于频繁
    ERROR_UPLOAD_NOTPERMISSION   = 4005 , //用户服务无权限
    ERROR_UPLOAD_FAIL            = 4100 , //上传失败
    ERROR_UPLOAD_ANALYSIS        = 4150 , //上传数据解析失败
    ERROR_UPLOAD_RECEIVE         = 4301 , //获取上传服务器失败
    ERROR_UPLOAD_FILEDAMAGED     = 4302 , //上传文件已损坏
    ERROR_UPLOAD_UNRECEIVESERVERANSWER = 4400 , //获取服务器回调失败
};

#endif /* DWErrorCode_h */
