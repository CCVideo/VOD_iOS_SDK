//
//  DWExercisesView.h
//  Demo
//
//  Created by zwl on 2019/6/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWExercisesViewDelegate <NSObject>

@optional
//提交课堂练习回调
-(void)exercisesViewFinish:(DWVideoExercisesModel *)exercisesModel;

//查看完成，继续播放回调
-(void)exercisesViewFinishResumePlay:(DWVideoExercisesModel *)exercisesModel;


@end

@interface DWExercisesView : UIView

@property(nonatomic,weak) id <DWExercisesViewDelegate> delegate;

//继续播放记录的时间位置
@property(nonatomic,assign)CGFloat lastScrubTime;

-(instancetype)initWithExercisesModel:(DWVideoExercisesModel *)exercisesModel;

//课堂练习，提交成功调用
-(void)exerciseSsumbitSuccess;

-(void)show;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
