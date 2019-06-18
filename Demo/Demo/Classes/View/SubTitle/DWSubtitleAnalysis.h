//
//  DWSubtitleAnalysis.h
//  Demo
//
//  Created by zwl on 2019/1/8.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWSubtitleAnalysis : NSObject

//编码格式   0 utf-8   1 gbk 默认utf-8
@property(nonatomic,assign)NSInteger encodeing;

-(instancetype)initWithSTRURL:(NSURL *)URL;

//开始解析
-(void)parse;

//获取某一时间对应的字幕  未找到 返回nil
-(NSString *)searchWithTime:(NSTimeInterval)currentPlaybackTime;

@end

NS_ASSUME_NONNULL_END
