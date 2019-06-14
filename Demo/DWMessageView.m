//
//  DWMessageView.m
//  Demo
//
//  Created by luyang on 2018/8/20.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import "DWMessageView.h"

@interface DWMessageView()

@property (nonatomic,strong)UILabel *label;

@property (nonatomic,strong)UIButton *repeatBtn;


@end

@implementation DWMessageView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self =[super initWithFrame:frame];
    
    if (self) {
        
        [self loadSubviews];
    }
    
    return self;
}

- (void)loadSubviews{
    
    
    self.repeatBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.repeatBtn.backgroundColor =[DWTools colorWithHexString:@"#000000"];
    self.repeatBtn.layer.cornerRadius =15;
    self.repeatBtn.layer.masksToBounds =YES;
    [self.repeatBtn setImage:[UIImage imageNamed:@"repeat"] forState:UIControlStateNormal];
    [self.repeatBtn setTitle:@"  重新试看" forState:UIControlStateNormal];
    self.repeatBtn.titleLabel.font =[UIFont systemFontOfSize:14];
  //  [self.repeatBtn setImageEdgeInsets:UIEdgeInsetsMake(15,6, -8, -6)];
    self.repeatBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.repeatBtn addTarget:self action:@selector(repeatBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.repeatBtn];
    [self.repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-46);
        make.width.mas_equalTo(232/2);
        make.height.mas_equalTo(63/2);
        
        
    }];
    
    
    self.label =[[UILabel alloc]init];
    self.label.font =[UIFont systemFontOfSize:13];
    self.label.textColor =[UIColor whiteColor];
    self.label.textAlignment =NSTextAlignmentCenter;
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(self.mas_left).offset(25);
        make.right.mas_equalTo(self.mas_right).offset(-25);
        make.height.mas_equalTo(184/2);
        make.centerY.mas_equalTo(self);
        
        
    }];
   
   
    UIButton *backButton =[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor =[UIColor clearColor];
    [backButton setTitle:@"  视频标题" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"player-back-button"] forState:UIControlStateNormal];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(backButtonAction)
              forControlEvents:UIControlEventTouchUpInside];
    backButton.frame =CGRectMake(10,10,180, 60);
    [self addSubview:backButton];
    
    
    
}

- (void)setToastText:(NSString *)toastText{
    
    _toastText =toastText;
    self.label.text =toastText;
}

- (void)didRepeatBlock:(RepeatBlock)block{
    
    _repeatBlock =block;
}

- (void)didBackBlock:(BackBlock )block{
    
    _backBlock =block;
}

- (void)repeatBtnAction{
    
    if (_repeatBlock) {
        
        _repeatBlock();
    }
    
}

- (void)backButtonAction{
    
    if (_backBlock) {
        
        _backBlock();
    }
    
}


- (void)hiddenRepeatButton{
    
    self.repeatBtn.hidden =YES;
    
}

@end
