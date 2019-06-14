//
//  DWMessageView.h
//  Demo
//
//  Created by luyang on 2018/8/20.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RepeatBlock)();

typedef void(^BackBlock)();

@interface DWMessageView : UIView

@property (nonatomic,copy)NSString *toastText;

@property (nonatomic,copy)RepeatBlock repeatBlock;

@property (nonatomic,copy)BackBlock backBlock;

- (void)didRepeatBlock:(RepeatBlock)block;

- (void)didBackBlock:(BackBlock )block;

- (void)hiddenRepeatButton;

@end
