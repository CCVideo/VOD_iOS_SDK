//
//  DWConfigurationManager.h
//  Demo
//
//  Created by zwl on 2019/4/12.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWConfigurationManager : NSObject

@property(nonatomic,copy)NSString * DWAccount_userId; //cc账号id
@property(nonatomic,copy)NSString * DWAccount_apikey; //cc账号key
@property(nonatomic,copy)NSString * verification; //授权验证码
@property(nonatomic,assign)BOOL isOpenAd; //是否开启广告模式

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
