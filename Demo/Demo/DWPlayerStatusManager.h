//
//  DWPlayerStatusManager.h
//  Demo
//
//  Created by zwl on 2019/2/19.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWPlayerStatusManager : NSObject

+(instancetype)deafultManager;

//用于记录音频播放状态，以便操作drmServer
@property(nonatomic,assign)BOOL isSetAudioUrl;

@end

NS_ASSUME_NONNULL_END
