//
//  DWUPnPTransportInfo.h
//  Demo
//
//  Created by zwl on 2019/7/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWUPnPAVPositionInfo : NSObject

///总时长
@property(nonatomic, assign)float trackDuration;

///当前时长
@property(nonatomic, assign)float absTime;

///与absTime无差别
@property(nonatomic, assign)float relTime;

- (void)setArray:(NSArray *)array;

@end


@interface DWUPnPTransportInfo : NSObject

///当前播放状态
@property(nonatomic, copy)NSString * currentTransportState;

///当前状态
@property(nonatomic, copy)NSString * currentTransportStatus;

///当前速率
@property(nonatomic, copy)NSString * currentSpeed;

- (void)setArray:(NSArray *)array;

@end


@interface NSString(UPnP)

+(NSString *)stringWithDurationTime:(float)timeValue;
- (float)durationTime;

@end
