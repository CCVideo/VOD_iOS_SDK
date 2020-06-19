//
//  DWBarrageSetView.h
//  Demo
//
//  Created by zwl on 2020/6/10.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWBarrageSetViewDelegate <NSObject>

//设置视图消失
-(void)barrageSetViewDidDismiss;

//设置透明度
-(void)barrageSetViewAlphaChange:(CGFloat)alpha;

//设置字号
-(void)barrageSetViewFontChange:(NSInteger)font;

//设置速度
-(void)barrageSetViewSpeedChange:(NSInteger)speed;

//设置显示区域
-(void)barrageSetViewAreaChange:(NSInteger)area;

@end

@interface DWBarrageSetView : UIView

@property(nonatomic,weak)id <DWBarrageSetViewDelegate> delegate;

-(void)screenRotate:(BOOL)isFull;

-(void)show;

@end
