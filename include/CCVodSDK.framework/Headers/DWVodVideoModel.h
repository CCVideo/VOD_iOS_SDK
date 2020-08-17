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
    
/**
 *  @brief 视频id
 */
@property(nonatomic, strong, readonly)NSString * videoId;

/**
 *  @brief 视频标题
 */
@property(nonatomic, strong, readonly)NSString * title;

/**
 *  @brief 视频状态，0代表可用，否则代表不可用
 */
@property(nonatomic, assign, readonly)NSInteger status;

/**
 *  @brief 视频状态描述，若视频不可用，具体描述原因
 */
@property(nonatomic, strong, readonly)NSString * statusInfo;

/**
 *  @brief 默认清晰度
 */
@property(nonatomic, strong, readonly)NSString * defaultquality;

/**
 *  @brief 分享URL
 */
@property(nonatomic, strong, readonly)NSString * shareurl;

/**
 *  @brief 视频清晰度
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoQualityModel *> * videoQualities;

/**
 *  @brief 音频清晰度
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoQualityModel *> * radioQualities;

/**
 *  @brief 授权验证信息字典
 */
@property(nonatomic, strong, readonly)DWVideoAuthorizeModel * authorize;

/**
 *  @brief 是否原片播放
 */
@property(nonatomic, assign, readonly)BOOL isRealTime;

/**
 *  @brief 是否支持VR，1表示播放VR视频，0表示普通
 */
@property(nonatomic, assign, readonly)NSInteger vrmode;

/**
 *  @brief 视频打点数据
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoMarkModel *> * videomarks;

/**
 *  @brief 视频问答数据
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoQuestionModel *> * questions;

/**
 *  @brief 字幕类型，-1 无字幕 ，0 subtitle, 1 subtitle2, 2 双语
 */
@property(nonatomic, assign, readonly)NSInteger defaultSubtitle;

/**
 *  @brief 字幕1
 */
@property(nonatomic, strong, readonly)DWVideoSubtitleModel * subtitle;

/**
 *  @brief 字幕2
 */
@property(nonatomic, strong, readonly)DWVideoSubtitleModel * subtitle2;

/**
 *  @brief 访客信息收集
 */
@property(nonatomic, strong, readonly)DWVideoVisitorModel * visitor;

/**
 *  @brief 课堂练习
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoExercisesModel *> * exercises;

/**
 *  @brief reason
 */
@property(nonatomic, assign, readonly)int reason;

/**
 *  @brief responseTime
 */
@property(nonatomic, strong, readonly)NSDate * responseTime;

/**
 *  @brief startTime
 */
@property(nonatomic, strong, readonly)NSDate * startTime;

/**
 *  @brief cc账号id
 */
@property(nonatomic, strong, readonly)NSString * CCUserId;

/**
 *  @brief cc账号key
 */
@property(nonatomic, strong, readonly)NSString * CCApiKey;

/**
 *  @brief 是否支持hls
 */
@property(nonatomic, assign, readonly)BOOL hlsSupport;

/**
 *  @brief UPID
 */
@property(nonatomic, strong, readonly)NSString * UPID;

/**
 *  @brief token
 */
@property(nonatomic, strong, readonly)NSString * token;

@end

///清晰度数据模型
@interface DWVideoQualityModel : NSObject

/**
 *  @brief 清晰度定义，具体值@"10" @"20" ..eg
 */
@property(nonatomic, strong, readonly)NSString * quality;

/**
 *  @brief 清晰度描述
 */
@property(nonatomic, strong, readonly)NSString * desp;

/**
 *  @brief 媒体类型，1 视频 2 音频
 */
@property(nonatomic, strong, readonly)NSString * mediaType;

/**
 *  @brief 主线路播放地址
 */
@property(nonatomic, strong, readonly)NSString * playUrl;

/**
 *  @brief 备用线路播放地址
 */
@property(nonatomic, strong, readonly)NSString * sparUrl;

@end

///视频打点数据模型
@interface DWVideoMarkModel : NSObject

/**
 *  @brief 打点描述内容
 */
@property(nonatomic, strong, readonly)NSString * markdesc;

/**
 *  @brief 打点时间
 */
@property(nonatomic, assign, readonly)NSInteger marktime;

@end

///视频问答数据模型
@interface DWVideoQuestionModel : NSObject

/**
 *  @brief 问答id
 */
@property(nonatomic, strong, readonly)NSString * questionId;

/**
 *  @brief 问答题目描述
 */
@property(nonatomic, strong, readonly)NSString * content;

/**
 *  @brief 问答出现时间
 */
@property(nonatomic, assign, readonly)NSInteger showTime;

/**
 *  @brief 答案解释
 */
@property(nonatomic, strong, readonly)NSString * explainInfo;

/**
 *  @brief 是否允许跳过
 */
@property(nonatomic, assign, readonly)BOOL jump;

/**
 *  @brief 答错退回时间，-1表示不回退
 */
@property(nonatomic, assign, readonly)NSInteger backSecond;

/**
 *  @brief 选项列表
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoQuestionAnswerModel *> * answers;

/**
 *  @brief 是否多选
 */
@property(nonatomic, assign, readonly)BOOL multipleSelect;

/**
 *  @brief 答错能否继续播放
 */
@property(nonatomic, assign, readonly)BOOL keepPlay;

/**
 *  @brief 是否显示问答
 */
@property(nonatomic, assign)BOOL isShow;

@end

///视频问题选项数据模型
@interface DWVideoQuestionAnswerModel : NSObject

/**
 *  @brief 选项id
 */
@property(nonatomic, strong, readonly)NSString * answerId;

/**
 *  @brief 选项内容描述
 */
@property(nonatomic, strong, readonly)NSString * content;

/**
 *  @brief 是否是正确答案
 */
@property(nonatomic, assign, readonly)BOOL isRight;

@end

///字幕数据模型
@interface DWVideoSubtitleModel : NSObject

/**
 *  @brief 字幕文件地址
 */
@property(nonatomic, strong, readonly)NSString * url;

/**
 *  @brief 字幕字体
 */
@property(nonatomic, strong, readonly)NSString * font;

/**
 *  @brief 字幕字体大小
 */
@property(nonatomic, assign, readonly)CGFloat size;

/**
 *  @brief 字幕字体色值  eg:0xFFFFFF
 */
@property(nonatomic, strong, readonly)NSString * color;

/**
 *  @brief 阴影色值  eg:0x000000
 */
@property(nonatomic, strong, readonly)NSString * surroundColor;

/**
 *  @brief 字幕距离底部的偏移量 百分比
 */
@property(nonatomic, assign, readonly)CGFloat bottom;

/**
 *  @brief 编码格式  utf-8/gbk
 */
@property(nonatomic, strong, readonly)NSString * code;

/**
 *  @brief 字幕名称
 */
@property(nonatomic, strong, readonly)NSString * subtitleName;

/**
 *  @brief 双语字幕中的位置，1:上, 2:下 单字幕时sort=0
 */
@property(nonatomic, assign, readonly)NSInteger sort;

@end

///授权验证信息
@interface DWVideoAuthorizeModel : NSObject

/**
 *  @brief 是否允许完整播放，NO:不允许完整播放 YES:允许完整播放
 */
@property(nonatomic, assign, readonly)BOOL enable;

/**
 *  @brief 视频试看时间，单位:秒
 */
@property(nonatomic, assign, readonly)NSInteger freetime;

/**
 *  @brief 提示内容
 */
@property(nonatomic, strong, readonly)NSString * message;

/**
 *  @brief 跑马灯数据
 */
@property(nonatomic, strong, readonly)NSString * marqueeStr;

@end

//访客信息收集器
@interface DWVideoVisitorModel : NSObject

/**
 *  @brief 收集器ID
 */
@property(nonatomic, strong, readonly)NSString * visitorId;

/**
 *  @brief 收集器标题
 */
@property(nonatomic, strong, readonly)NSString * title;

/**
 *  @brief 展现的时间，单位:秒
 */
@property(nonatomic, assign, readonly)NSInteger appearTime;

/**
 *  @brief 展现的图片地址
 */
@property(nonatomic, strong, readonly)NSString * imageURL;

/**
 *  @brief 图片的跳转地址
 */
@property(nonatomic, strong, readonly)NSString * jumpURL;

/**
 *  @brief 能否跳过
 */
@property(nonatomic, assign, readonly)BOOL isJump;

/**
 *  @brief 要收集的信息
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoVisitorMessageModel *> * visitorMessages;

/**
 *  @brief 是否显示问答
 */
@property(nonatomic, assign)BOOL isShow;

@end

@interface DWVideoVisitorMessageModel : NSObject

/**
 *  @brief 收集信息含义
 */
@property(nonatomic, strong, readonly)NSString * visitorMes;

/**
 *  @brief 收集信息提示
 */
@property(nonatomic, strong, readonly)NSString * visitorTip;

@end

//课堂练习
@interface DWVideoExercisesModel : NSObject

/**
 *  @brief 课堂练习id
 */
@property(nonatomic, strong, readonly)NSString * exercisesId;

/**
 *  @brief 标题
 */
@property(nonatomic, strong, readonly)NSString * title;

/**
 *  @brief 展现的时间,单位:秒
 */
@property(nonatomic, assign, readonly)NSInteger showTime;

/**
 *  @brief 课堂练习包含的问题列表
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoExercisesQuestionModel *> * questions;

/**
 *  @brief 是否显示课堂练习
 */
@property(nonatomic, assign)BOOL isShow;

@end

//课堂练习问题
@interface DWVideoExercisesQuestionModel : NSObject

/**
 *  @brief 问题id
 */
@property(nonatomic, strong, readonly)NSString * questionId;

/**
 *  @brief 问题解释内容
 */
@property(nonatomic, strong, readonly)NSString * explainInfo;

/**
 *  @brief 问题类型，0:单选 1:多选 2:填空
 */
@property(nonatomic, assign, readonly)NSInteger type;

/**
 *  @brief 问题的标题(填空题的前半段)
 */
@property(nonatomic, strong, readonly)NSString * content;

/**
 *  @brief 问题的标题(填空题后半段，选择题是为nil)
 */
@property(nonatomic, strong, readonly)NSString * content2;

/**
 *  @brief 问题的答案
 */
@property(nonatomic, strong, readonly)NSArray <DWVideoExercisesQuestionAnswerModel *> * answers;

/**
 *  @brief 此问题是否已经作答，YES:已答 NO:未答。注意：选择题，选项选中即为已答。填空题，内容填写即为已答
 */
@property(nonatomic, assign, readonly)BOOL isReply;

/**
 *  @brief 是否答对
 */
@property(nonatomic, assign, readonly)BOOL isCorrect;

/**
 *  @brief 问题正确率
 */
@property(nonatomic, assign)NSInteger accuracy;

@end

//课堂练习问题答案
@interface DWVideoExercisesQuestionAnswerModel : NSObject

/**
 *  @brief 课堂练习问题答案id
 */
@property(nonatomic, strong, readonly)NSString * answerId;

/**
 *  @brief 是否是正确选项
 */
@property(nonatomic, assign, readonly)BOOL isRight;

/**
 *  @brief 选择题：选项的内容，填空题：正确答案
 */
@property(nonatomic, strong, readonly)NSString * content;

/**
 *  @brief 选择题是否选中
 */
@property(nonatomic, assign)BOOL isSelect;

/**
 *  @brief 填空题填写内容
 */
@property(nonatomic, strong)NSString * answerContent;

@end
