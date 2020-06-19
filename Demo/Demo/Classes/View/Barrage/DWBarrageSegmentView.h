//
//  DWBarrageSegmentView.h
//  Demo
//
//  Created by zwl on 2020/6/9.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWBarrageSegmentViewDelegate <NSObject>

-(void)barrageSegmentViewOpen:(BOOL)isOpen;

-(void)barrageSegmentViewSet:(BOOL)isSet;

@end

@interface DWBarrageSegmentView : UIView

@property(nonatomic,weak) id <DWBarrageSegmentViewDelegate> delegate;

//设置view样式
-(void)changeModelWithClose:(BOOL)close;

//恢复设置按钮默认状态
-(void)changeSetClose;

@end
