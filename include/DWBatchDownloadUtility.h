//
//  DWBatchDownloadUtility.h
//  Demo
//
//  Created by zwl on 2019/1/21.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BatchDownloadUtilityFinishBlock)(NSArray *playInfosArray);
typedef void(^BatchDownloadUtilityErrorBlock)(NSError *error);

@interface DWBatchDownloadUtility : NSObject

//1为视频 2为音频 0为视频+音频 若不传该参数默认为视频
@property (nonatomic,copy)NSString *mediatype;

//不设置 默认为空 
@property (nonatomic,copy)NSString *verificationCode;//授权验证码

//注意！ 回调方法可能不在主线程中，如果在里面进行UI操作，请回到主线程中进行
//视频数据获取出错
@property (nonatomic,copy)BatchDownloadUtilityErrorBlock errorBlock;

//视频数据获取完成  如果没有获取到某个视频的数据，会返回空字典 如@{}
@property (nonatomic,copy)BatchDownloadUtilityFinishBlock finishBlock;

/**
 
 * 初始化  会对视频数据进行去重操作，如果传入数组中有重复的视频id，可能会导致最后输出的视频数据长度跟传入的视频id的数量不一致
 
 *  @param userId      用户ID，不能为nil
 *  @param key         用户秘钥，不能为nil
 *  @param videoIds    视频id数组，不能为nil  最多同时获取10个视频id的播放地址，超出10个按10个获取

 */

-(instancetype)initWithUserId:(NSString *)userId key:(NSString *)key AndVideoIds:(NSArray *)videoIds;

-(void)start;

@end

NS_ASSUME_NONNULL_END
