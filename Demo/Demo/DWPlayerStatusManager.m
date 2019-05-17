//
//  DWPlayerStatusManager.m
//  Demo
//
//  Created by zwl on 2019/2/19.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWPlayerStatusManager.h"

@implementation DWPlayerStatusManager

+(instancetype)deafultManager
{
    static DWPlayerStatusManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DWPlayerStatusManager alloc] init];
    });
    return manager;
}

@end
