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

/// 初始化方法
/// @param content 字幕内容
/// @param fc 字幕颜色，eg:0xffffff
/// @param pt 弹幕时间，单位毫秒
-(instancetype)initWithContent:(NSString *)content Fc:(NSString *)fc Pt:(NSInteger)pt;

///字幕内容
@property(nonatomic,strong,readonly)NSString * content;

///字幕颜色
@property(nonatomic,strong,readonly)NSString * fc;

///播放时间点，单位:毫秒
@property(nonatomic,assign,readonly)NSInteger pt;

@end

