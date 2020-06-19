//
//  DWBarrageBgView.h
//  Demo
//
//  Created by zwl on 2020/6/9.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

//弹幕相关回调
@protocol DWBarrageBgViewDelegate<NSObject>

/// 发送弹幕
/// @param content 内容
/// @param fc 颜色
-(void)barrageBgViewSendWithContent:(NSString *)content Fc:(NSString *)fc;

/// 开始编辑弹幕
-(void)barrageBgViewBeginEdit;

/// 显示区域变动
-(void)barrageBgViewAreaChange:(CGFloat)area;

///关闭/开启弹幕
-(void)barrageBgViewOpen:(BOOL)isOpen;

@end

@interface DWBarrageBgView : UIView

@property(nonatomic,weak)id<DWBarrageBgViewDelegate> delegate;

//弹幕状态
@property(nonatomic,assign,readonly)BOOL isOpen;

//透明度
@property(nonatomic,assign,readonly)CGFloat barrageAlpha;

//字号
@property(nonatomic,strong,readonly)UIFont * barrageFont;

//速度
@property(nonatomic,assign,readonly)CGFloat barrageSpeed;

//屏幕旋转
-(void)screenRotate:(BOOL)isFull;

//清空文本框
-(void)clearTextField;

@end
