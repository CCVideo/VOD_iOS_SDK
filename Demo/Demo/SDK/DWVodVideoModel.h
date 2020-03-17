//
//  DWPlayerVideoModel.h
//  Demo
//
//  Created by zwl on 2019/3/25.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DWVideoQualityModel;
@class DWVideoMarkModel;
@class DWVideoQuestionModel;
@class DWVideoQuestionAnswerModel;
@class DWVideoSubtitleModel;
@class DWVideoAuthorizeModel;
@class DWVideoVisitorModel;
@class DWVideoVisitorMessageModel;
@class DWVideoExercisesModel;
@class DWVideoExercisesQuestionModel;
@class DWVideoExercisesQuestionAnswerModel;

///视频数据模型
@interface DWVodVideoModel : NSObject

///视频 id
@property (nonatomic, strong, readonly) NSString * videoId;

///视频标题
@property (nonatomic, strong, readonly) NSString * title;

///视频状态  为0代表可用，否则代表不可用。
@property (nonatomic, assign, readonly) NSInteger status;

///视频状态描述 若视频不可用，具体描述原因
@property (nonatomic, strong, readonly) NSString * statusInfo;

///默认清晰度
@property (nonatomic, strong, readonly) NSString * defaultquality;

///分享URL
@property (nonatomic, strong, readonly) NSString * shareurl;

///视频清晰度
@property (nonatomic, strong, readonly) NSArray <DWVideoQualityModel *> * videoQualities;

///音频清晰度
@property (nonatomic, strong, readonly) NSArray <DWVideoQualityModel *> * radioQualities;

///授权验证信息字典
@property (nonatomic, strong, readonly) DWVideoAuthorizeModel * authorize;

///是否原片播放
@property (nonatomic, assign, readonly) BOOL isRealTime;

///是否支持VR  1表示播放VR视频，0表示普通
@property (nonatomic, assign, readonly) NSInteger vrmode;

///视频打点数据
@property (nonatomic, strong, readonly) NSArray <DWVideoMarkModel *> * videomarks;

///视频问答数据
@property (nonatomic, strong, readonly) NSArray <DWVideoQuestionModel *> * questions;

//字幕
///取值含义 -1 无字幕 ，0:subtitle, 1:subtitle2, 2:双语
@property (nonatomic, assign, readonly) NSInteger defaultSubtitle;
///字幕1
@property (nonatomic, strong, readonly) DWVideoSubtitleModel * subtitle;
///字幕2
@property (nonatomic, strong, readonly) DWVideoSubtitleModel * subtitle2;

///访客信息收集
@property (nonatomic, strong, readonly) DWVideoVisitorModel * visitor;

///课堂练习
@property (nonatomic, strong, readonly) NSArray <DWVideoExercisesModel *> * exercises;

@property (nonatomic, assign, readonly) int reason;

@property (nonatomic, strong, readonly) NSDate * responseTime;

@property (nonatomic, strong, readonly) NSDate * startTime;

///cc账号id
@property (nonatomic, strong, readonly) NSString * CCUserId;

///cc账号key
@property (nonatomic, strong, readonly) NSString * CCApiKey;

///是否支持hls
@property (nonatomic, assign, readonly) BOOL hlsSupport;

///UPID
@property (nonatomic, strong, readonly) NSString * UPID;

///token
@property (nonatomic, strong, readonly) NSString * token;

@end

///清晰度数据模型
@interface DWVideoQualityModel : NSObject

///清晰度定义  具体值 @"10" @"20" ..eg
@property (nonatomic, strong, readonly) NSString * quality;

///清晰度描述
@property (nonatomic, strong, readonly) NSString * desp;

///媒体类型 1 视频  2 音频
@property (nonatomic, strong, readonly) NSString * mediaType;

///播放地址  主线路
@property (nonatomic, strong, readonly) NSString * playUrl;

///播放地址  备用线路
@property (nonatomic, strong, readonly) NSString * sparUrl;

@end

///视频打点数据模型
@interface DWVideoMarkModel : NSObject

///打点描述内容
@property (nonatomic, strong, readonly)NSString * markdesc;

///打点时间
@property (nonatomic, assign, readonly)NSInteger marktime;

@end

///视频问答数据模型
@interface DWVideoQuestionModel : NSObject

///问答id
@property (nonatomic, strong, readonly)NSString * questionId;

///问答题目描述
@property (nonatomic, strong, readonly)NSString * content;

///问答出现时间
@property (nonatomic, assign, readonly)NSInteger showTime;

///答案解释
@property (nonatomic, strong, readonly)NSString * explainInfo;

///是否允许跳过
@property (nonatomic, assign, readonly)BOOL jump;

///答错退回时间 -1表示不回退
@property (nonatomic, assign, readonly)NSInteger backSecond;

///选项列表
@property (nonatomic, strong, readonly)NSArray <DWVideoQuestionAnswerModel *> * answers;

///是否多选
@property (nonatomic, assign, readonly)BOOL multipleSelect;

///答错能否继续播放
@property (nonatomic, assign, readonly)BOOL keepPlay;

///是否显示问答
@property (nonatomic, assign) BOOL isShow;

@end

///视频问题选项数据模型
@interface DWVideoQuestionAnswerModel : NSObject

///选项id
@property (nonatomic, strong, readonly)NSString * answerId;

///选项内容描述
@property (nonatomic, strong, readonly)NSString * content;

///是否是正确答案
@property (nonatomic, assign, readonly)BOOL isRight;

@end

///字幕数据模型
@interface DWVideoSubtitleModel : NSObject

///字幕文件地址
@property (nonatomic, strong, readonly)NSString * url;

///字幕字体
@property (nonatomic, strong, readonly)NSString * font;

///字幕字体大小
@property (nonatomic, assign, readonly)CGFloat size;

///字幕字体色值  eg:0xFFFFFF
@property (nonatomic, strong, readonly)NSString * color;

///阴影色值  eg:0x000000
@property (nonatomic, strong, readonly)NSString * surroundColor;

///字幕距离底部的偏移量 百分比
@property (nonatomic, assign, readonly)CGFloat bottom;

///编码格式  utf-8 / gbk
@property (nonatomic, strong, readonly)NSString * code;

///字幕名称
@property (nonatomic, strong, readonly)NSString * subtitleName;

///双语字幕中的位置 1:上, 2:下 单字幕时sort=0
@property (nonatomic, assign, readonly)NSInteger sort;

@end

///授权验证信息
@interface DWVideoAuthorizeModel : NSObject

///是否允许完整播放 NO:不允许完整播放 YES:允许完整播放
@property (nonatomic, assign, readonly)BOOL enable;

///视频试看时间,单位:秒
@property (nonatomic, assign, readonly)NSInteger freetime;

///提示内容
@property (nonatomic, strong, readonly)NSString * message;

///跑马灯数据
@property (nonatomic, strong, readonly)NSString * marqueeStr;

@end

//访客信息收集器
@interface DWVideoVisitorModel : NSObject

///收集器ID
@property (nonatomic, strong, readonly)NSString * visitorId;

///收集器标题
@property (nonatomic, strong, readonly)NSString * title;

///展现的时间,单位:秒
@property (nonatomic, assign, readonly)NSInteger appearTime;

///展现的图片地址
@property (nonatomic, strong, readonly)NSString * imageURL;

///图片的跳转地址
@property (nonatomic, strong, readonly)NSString * jumpURL;

///能否跳过
@property (nonatomic, assign, readonly)BOOL isJump;

///要收集的信息
@property (nonatomic, strong, readonly)NSArray <DWVideoVisitorMessageModel *> * visitorMessages;

///是否显示问答
@property (nonatomic, assign) BOOL isShow;

@end

@interface DWVideoVisitorMessageModel : NSObject

///收集信息含义
@property (nonatomic, strong, readonly)NSString * visitorMes;

///收集信息提示
@property (nonatomic, strong, readonly)NSString * visitorTip;

@end

//课堂练习
@interface DWVideoExercisesModel : NSObject

///课堂练习id
@property (nonatomic, strong, readonly)NSString * exercisesId;

///标题
@property (nonatomic, strong, readonly)NSString * title;

///展现的时间,单位:秒
@property (nonatomic, assign, readonly)NSInteger showTime;

///课堂练习包含的问题列表
@property (nonatomic, strong, readonly)NSArray <DWVideoExercisesQuestionModel *> * questions;

///是否显示课堂练习
@property (nonatomic, assign) BOOL isShow;

@end

//课堂练习问题
@interface DWVideoExercisesQuestionModel : NSObject

///问题id
@property (nonatomic, strong, readonly)NSString * questionId;

///问题解释内容
@property (nonatomic, strong, readonly)NSString * explainInfo;

///问题类型 0:单选 1:多选 2:填空
@property (nonatomic, assign, readonly)NSInteger type;

///问题的标题 (填空题的前半段)
@property (nonatomic, strong, readonly)NSString * content;

///问题的标题 (填空题后半段，选择题是为nil)
@property (nonatomic, strong, readonly)NSString * content2;

///问题的答案
@property (nonatomic, strong, readonly)NSArray <DWVideoExercisesQuestionAnswerModel *> * answers;

///此问题是否已经作答 YES:已答 NO:未答  注意：选择题，选项选中即为已答。填空题，内容填写即为已答。
@property (nonatomic, assign, readonly)BOOL isReply;

///是否答对
@property (nonatomic, assign, readonly)BOOL isCorrect;

///问题正确率
@property (nonatomic, assign) NSInteger accuracy;

@end

//课堂练习问题答案
@interface DWVideoExercisesQuestionAnswerModel : NSObject

///课堂练习问题答案id
@property (nonatomic, strong, readonly)NSString * answerId;

///是否是正确选项
@property (nonatomic, assign, readonly)BOOL isRight;

///选择题：选项的内容  填空题：正确答案
@property (nonatomic, strong, readonly)NSString * content;

///选择题是否选中
@property (nonatomic, assign) BOOL isSelect;

///填空题填写内容
@property (nonatomic, strong) NSString * answerContent;

@end
