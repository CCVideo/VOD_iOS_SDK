//
//  DWExercisesAlertView.h
//  Demo
//
//  Created by zwl on 2019/6/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWExercisesAlertViewDelegate <NSObject>

-(void)exercisesAlertViewReturn;
-(void)exercisesAlertViewAnswer;

@end

@interface DWExercisesAlertView : UIView

//返回听课时记录的d时间点
@property(nonatomic,assign)CGFloat frontScrubTime;

@property(nonatomic,assign)id <DWExercisesAlertViewDelegate> delegate;

-(void)show;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
