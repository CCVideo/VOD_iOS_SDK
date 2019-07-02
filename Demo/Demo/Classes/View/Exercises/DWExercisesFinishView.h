//
//  DWExercisesFinishView.h
//  Demo
//
//  Created by zwl on 2019/6/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWExercisesAccuracyButton;

NS_ASSUME_NONNULL_BEGIN

@protocol DWExercisesFinishViewDelegate <NSObject>

@optional
-(void)exercisesFinishViewResumePlay;

@end

@interface DWExercisesFinishView : UIView

@property(nonatomic,weak) id <DWExercisesFinishViewDelegate> delegate;

-(instancetype)initWithExercisesModel:(DWVideoExercisesModel *)exercisesModel;

@end

@interface DWExercisesFinishViewCell : UITableViewCell

@property(nonatomic,strong)DWExercisesAccuracyButton * accuracyButton;

-(void)setIndex:(NSInteger)index AndExercisesQuestionModel:(DWVideoExercisesQuestionModel *)quesitonModel;

@end

@interface DWExercisesAccuracyButton : UIButton

-(void)setIsRight:(BOOL)isRight AndAccuracy:(NSInteger)accuracy;

@end

@interface DWExercisesAccuracyColorView : UIView

@end

@interface DWExercisesPromptView : UIView

-(void)setTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
