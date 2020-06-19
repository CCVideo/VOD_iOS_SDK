//
//  DWBarrageInputView.h
//  Demo
//
//  Created by zwl on 2020/6/10.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWBarrageInputViewDelegate <NSObject>

-(void)barrageInputViewSendWithContent:(NSString *)content Fc:(NSString *)fc;

//-(void)barrageInputViewDismiss;

@end

@interface DWBarrageInputView : UIView

@property(nonatomic,weak)id <DWBarrageInputViewDelegate> delegate;

-(void)beginEdit;

-(void)screenRotate:(BOOL)isFull;

-(void)clearTextField;

@end
