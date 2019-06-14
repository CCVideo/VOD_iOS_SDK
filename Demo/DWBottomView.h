//
//  DWBottomView.h
//  Demo
//
//  Created by luyang on 2017/11/9.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWBottomViewDelegate <NSObject>

@optional

- (void)videoBottomViewPlayAction;

- (void)audioBottomViewPlayAction;

@end



@interface DWBottomView : UIView

@property (nonatomic,assign)CGFloat height;
@property (nonatomic,assign)CGFloat width;

@property (nonatomic,strong)UIView *verticalView;//垂直

@property (nonatomic,strong)UIView *horizontallyView;//水平

@property (nonatomic,strong)UIButton *videoBtn;

@property (nonatomic,strong)UIButton *audioBtn;

@property (nonatomic,assign)NSInteger index;

@property (nonatomic,weak)id <DWBottomViewDelegate> delegate;

- (void)audioPlay:(UIButton *)sender;


@end
