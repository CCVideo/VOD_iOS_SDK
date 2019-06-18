//
//  DWVodAdInfoModel.h
//  Demo
//
//  Created by zwl on 2019/3/27.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DWVodAdMaterialModel;

NS_ASSUME_NONNULL_BEGIN

///广告信息
@interface DWVodAdInfoModel : NSObject

///广告信息获取情况  0:获取成功 非0:获取失败
@property (nonatomic, assign, readonly) NSInteger result;

///广告类型  1 片头广告  2 暂停广告
@property (nonatomic, assign, readonly) NSInteger type;

///广告ID
@property (nonatomic, strong, readonly) NSString * adId;

///广告展示时长
@property (nonatomic, assign, readonly) NSInteger time;

///是否响应点击
@property (nonatomic, assign, readonly) BOOL canClick;

///是否出现跳过广告按钮
@property (nonatomic, assign, readonly) BOOL canSkip;

///跳过时间，单位秒，经过若干秒后显示跳过按钮，0代表立即显示跳过按钮
@property (nonatomic, assign, readonly) NSInteger skipTime;

///广告信息
@property (nonatomic, strong, readonly) NSArray <DWVodAdMaterialModel *> * ads;

@end

///广告素材详情
@interface DWVodAdMaterialModel : NSObject

///素材id
@property (nonatomic, strong, readonly) NSString * materialId;

///素材链接
@property (nonatomic, strong, readonly) NSString * materialUrl;

///跳转链接
@property (nonatomic, strong, readonly) NSString * clickUrl;

@end

NS_ASSUME_NONNULL_END
