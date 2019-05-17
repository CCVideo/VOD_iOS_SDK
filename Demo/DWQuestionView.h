//
//  DWQuestionView.h
//  CustomDemo
//
//  Created by luyang on 2018/2/9.
//  Copyright © 2018年 Myself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWQuestionModel.h"

typedef void(^QuestionBlock)(NSMutableArray *answerIdsArray,BOOL right);
typedef void(^SkipBlock)();

@interface DWQuestionView : UIView

@property (nonatomic,strong)DWQuestionModel *questionModel;
@property (nonatomic,copy)QuestionBlock questionBlock;
@property (nonatomic,copy)SkipBlock skipBlock;

- (void)didQuestionBlock:(QuestionBlock )block;

- (void)didSkipBlock:(SkipBlock )block;

@end
