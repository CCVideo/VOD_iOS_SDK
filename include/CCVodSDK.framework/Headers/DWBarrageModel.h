//
//  DWBarrageModel.h
//  Demo
//
//  Created by zwl on 2020/6/4.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

///弹幕数据模型
@interface DWBarrageModel : NSObject

/**
 *  @brief 字幕内容
 */
@property(nonatomic,strong,readonly)NSString * content;

/**
 *  @brief 字幕颜色
 */
@property(nonatomic,strong,readonly)NSString * fc;

/**
 *  @brief 播放时间点，单位:毫秒
 */
@property(nonatomic,assign,readonly)NSInteger pt;

/*!
 * @method
 * @abstract 初始化方法
 * @discussion 初始化方法
 * @param content 字幕内容
 * @param fc 字幕颜色，eg:0xffffff
 * @param pt 弹幕时间，单位毫秒
 * @result DWBarrageModel对象
 */
-(instancetype)initWithContent:(NSString *)content Fc:(NSString *)fc Pt:(NSInteger)pt;

@end

