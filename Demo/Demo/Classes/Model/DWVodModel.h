//
//  DWVodModel.h
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWVodModel : NSObject

@property(nonatomic,copy)NSString * videoId;

@property(nonatomic,copy)NSString * imageUrl;

@property(nonatomic,copy)NSString * title;

@property(nonatomic,copy)NSString * time;

@property(nonatomic,assign)BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
