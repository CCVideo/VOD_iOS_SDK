//
//  DWQuestionModel.h
//  Demo
//
//  Created by luyang on 2018/2/22.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWQuestionModel : NSObject

@property (nonatomic,copy)NSArray * answers;//选项数组

@property (nonatomic,copy)NSString * showTime;//显示的时间

@property (nonatomic,copy)NSString *id;

@property (nonatomic,copy)NSString * content;//问题
@property (nonatomic,copy)NSString * jump;//是否跳过
@property (nonatomic,copy) NSString * explainInfo;//解释
@property (nonatomic,copy) NSString * backSecond;//回退多少秒

@property (nonatomic,assign)BOOL multipleSelect;//是否多选

@property (nonatomic,assign)BOOL isShow;//是否显示

@property (nonatomic,assign)BOOL unScrubShow;//拖动的时候是否显示


@end
