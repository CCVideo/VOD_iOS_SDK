//
//  DWToastView.h
//  Demo
//
//  Created by luyang on 2017/9/26.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWToastView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

//改变原来的文字和颜色
- (void)changeTextAndColor;
//恢复初始的文字和颜色
- (void)recoverTextAndColor;

@end
