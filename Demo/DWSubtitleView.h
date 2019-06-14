//
//  DWSubtitleView.h
//  Demo
//
//  Created by zwl on 2019/1/7.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWSubtitleView : UIView

//根据字幕生成view
-(instancetype)initWithSubtitleDict:(NSDictionary *)subtitleDict;

///切换字幕 0双语 1主字幕 2副字幕 3关闭字幕 (在双语字幕的情况下， sort == 2 的字幕这里暂定为主字幕)
-(void)switchSubtitleStyle:(NSInteger)style;

//根据播放时间 显示字幕
-(void)setSubtitleWithTime:(NSTimeInterval)currentPlaybackTime;

@end

NS_ASSUME_NONNULL_END
