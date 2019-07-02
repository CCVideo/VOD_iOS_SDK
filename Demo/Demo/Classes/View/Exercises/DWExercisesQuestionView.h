//
//  DWExercisesQuestionView.h
//  Demo
//
//  Created by zwl on 2019/6/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DWExercisesQuestionView;

@protocol DWExercisesQuestionViewDelegate <NSObject>

@optional

-(void)exercisesQuestionViewDidSubmit:(DWExercisesQuestionView *)questionView;

@end

@interface DWExercisesQuestionView : UIView

@property(nonatomic,strong)UIButton * submitButton;

@property(nonatomic,weak) id <DWExercisesQuestionViewDelegate> delegate;

-(instancetype)initWithQuestionModel:(DWVideoExercisesQuestionModel *)questionModel;

@end

@interface DWExercisesQuestionViewCell : UITableViewCell

//用来处理答题状态
@property(nonatomic,weak)DWVideoExercisesQuestionModel * questionModel;

//多选题，填空题。 是否已提交
@property(nonatomic,assign)BOOL isSumbit;

@property(nonatomic,strong)DWVideoExercisesQuestionAnswerModel * answerModel;

@end

NS_ASSUME_NONNULL_END
