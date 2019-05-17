//
//  DWFeedBackView.m
//  Demo
//
//  Created by luyang on 2018/2/11.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import "DWFeedBackView.h"

@interface DWFeedBackView()

@property (nonatomic,strong)UILabel *responseLabel;
//@property (nonatomic,strong)UILabel *questionLabel;
@property (nonatomic,strong)UITextView *questionTextView;
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIButton *button;

@end

@implementation DWFeedBackView

- (instancetype )initWithFrame:(CGRect)frame{
    
    self =[super initWithFrame:frame];
    if (self) {
        
        
        self.backgroundColor =[UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:0.2];
        
        [self loadSubviews];
    }
    
    return self;
}

- (void)loadSubviews{
    
    UIView *view =[[UIView alloc]init];
    view.layer.cornerRadius =8/2;
    view.layer.masksToBounds =YES;
    view.backgroundColor =[UIColor whiteColor];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(500/2);
        make.height.mas_equalTo(470/2);
        make.center.mas_equalTo(self);
        
    }];
    
    
    
    self.responseLabel =[[UILabel alloc]init];
    self.responseLabel.font =[UIFont systemFontOfSize:16];
    self.responseLabel.textAlignment =NSTextAlignmentCenter;
    [view addSubview:self.responseLabel];
    [self.responseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(128);
        make.height.mas_equalTo(32/2);
        make.centerX.mas_equalTo(view);
        make.top.mas_equalTo(view.mas_top).offset(31/2);
        
    }];
    
//    self.questionLabel =[[UILabel alloc]init];
//    self.questionLabel.font =[UIFont systemFontOfSize:14];
//    self.questionLabel.textColor =[DWTools colorWithHexString:@"#666666"];
//    self.questionLabel.numberOfLines = 0;
//    [view addSubview:self.questionLabel];
//    [self.questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.left.mas_equalTo(view.mas_left).offset(15);
//        make.right.mas_equalTo(view.mas_right).offset(-15);
//        make.top.mas_equalTo(self.responseLabel.mas_bottom).offset(29/2);
//
//    }];
    self.questionTextView = [[UITextView alloc]init];
    self.questionTextView.font = [UIFont systemFontOfSize:14];
    self.questionTextView.textColor = [DWTools colorWithHexString:@"#666666"];
    self.questionTextView.showsVerticalScrollIndicator = NO;
    self.questionTextView.showsHorizontalScrollIndicator = NO;
    self.questionTextView.editable = NO;
    [view addSubview:self.questionTextView];
    [self.questionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view.mas_left).offset(15);
        make.right.mas_equalTo(view.mas_right).offset(-15);
        make.top.mas_equalTo(self.responseLabel.mas_bottom).offset(29/2);
        make.bottom.equalTo(@(-45));
    }];
    
    
    UIView *bootomView =[[UIView alloc]init];
    bootomView.backgroundColor =[DWTools colorWithHexString:@"#f0f8ff"];
    [view addSubview:bootomView];
    [bootomView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.left.right.mas_equalTo(view);
        make.height.mas_equalTo(45);
        
    }];
    
    self.button =[UIButton buttonWithType:UIButtonTypeCustom];
    self.button.backgroundColor =[DWTools colorWithHexString:@"#419bf9"];
    self.button.alpha =0.89;
    [self.button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.mas_equalTo(bootomView);
        make.height.mas_equalTo(60/2);
        make.width.mas_equalTo(180/2);
        
    }];
    
    self.imageView =[[UIImageView alloc]init];
    [view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.mas_equalTo(bootomView.mas_top);
        make.right.mas_equalTo(view);
        make.height.mas_equalTo(146/2);
        make.width.mas_equalTo(182/2);
        
    }];
    
    
    
}

- (void)showResult:(DWQuestionModel *)model withRight:(BOOL )right{
    
    NSString *title;
    NSString *text;
    UIImage *image;
    
    if (right) {
        
       text =@"回答正确";
       title =@"确认";
       image =[UIImage imageNamed:@"right"];
       self.responseLabel.textColor =[DWTools colorWithHexString:@"#17bc2f"];
        
    }else{
        
        text =@"回答错误";
        title =@"返回";
        image =[UIImage imageNamed:@"wrong"];
        self.responseLabel.textColor =[DWTools colorWithHexString:@"#e03a3a"];
    }
    
    
    self.responseLabel.text =text;
    self.imageView.image =image;
    [self.button setTitle:title forState:UIControlStateNormal];
//    self.questionLabel.text =model.explainInfo;
    self.questionTextView.text = model.explainInfo;
    
}

- (void)buttonAction{
    
    if (_feedBackBlock) {
        
        _feedBackBlock();
    }
    
}

- (void)didFeedBackBlock:(FeedBackBlock )block{
    
    _feedBackBlock =block;
}

@end
