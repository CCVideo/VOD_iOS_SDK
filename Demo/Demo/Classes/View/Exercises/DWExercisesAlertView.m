//
//  DWExercisesAlertView.m
//  Demo
//
//  Created by zwl on 2019/6/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWExercisesAlertView.h"

@implementation DWExercisesAlertView

-(instancetype)init
{
    if (self == [super init]) {
        
//        self.lastTime = 0;
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        
        UIView * bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 4;
        [self addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@285);
            make.height.equalTo(@165);
        }];
        
        UILabel * label = [[UILabel alloc]init];
        label.text = @"请先完成练习";
        label.font = TitleFont(15);
        label.textColor = TitleColor_51;
        label.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@50);
            make.centerX.equalTo(bgView);
            make.width.equalTo(bgView);
            make.height.equalTo(@15);
        }];
        
        UIButton * returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [returnButton setTitle:@"返回听课" forState:UIControlStateNormal];
        [returnButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1] forState:UIControlStateNormal];
        returnButton.titleLabel.font = TitleFont(15);
        returnButton.layer.cornerRadius = 20;
        returnButton.layer.borderColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1].CGColor;
        returnButton.layer.borderWidth = 1;
        [returnButton addTarget:self action:@selector(returnButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:returnButton];
        [returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@(-20));
            make.right.equalTo(bgView.mas_centerX).offset(-7.5);
            make.width.equalTo(@105);
            make.height.equalTo(@40);
        }];
        
        UIButton * nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton setTitle:@"直接做题" forState:UIControlStateNormal];
        [nextButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1] forState:UIControlStateNormal];
        nextButton.titleLabel.font = TitleFont(15);
        nextButton.layer.cornerRadius = 20;
        nextButton.layer.borderColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1].CGColor;
        nextButton.layer.borderWidth = 1;
        [nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:nextButton];
        [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@(-20));
            make.left.equalTo(bgView.mas_centerX).offset(7.5);
            make.width.equalTo(@105);
            make.height.equalTo(@40);
        }];        
    }
    return self;
}

-(void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.and.bottom.equalTo(@0);
    }];
}

-(void)dismiss
{
    [self removeFromSuperview];
}

-(void)returnButtonAction
{
    if ([self.delegate respondsToSelector:@selector(exercisesAlertViewReturn)]) {
        [self.delegate exercisesAlertViewReturn];
    }
}

-(void)nextButtonAction
{
    if ([self.delegate respondsToSelector:@selector(exercisesAlertViewAnswer)]) {
        [self.delegate exercisesAlertViewAnswer];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
