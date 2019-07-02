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

//@property(nonatomic,assign)CGFloat lastTime;

@property(nonatomic,assign)id <DWExercisesAlertViewDelegate> delegate;

-(void)show;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
