//
//  DWConfigurationManager.m
//  Demo
//
//  Created by zwl on 2019/4/12.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWConfigurationManager.h"

@implementation DWConfigurationManager

+ (instancetype)sharedInstance
{
    static id sharedInstance =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance =[[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init
{
    if (self == [super init]) {
        
        //配置默认值 这里
        self.DWAccount_userId = @"391E6E3340A00767";
        self.DWAccount_apikey = @"T8WdOUuvFEiOsou1xjDr4U73v12M7iNa";
        self.isOpenAd = NO;
    }
    return self;
}

@end
