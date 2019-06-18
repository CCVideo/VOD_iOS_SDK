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
@property (nonatomic,strong)UITextView *questionTextView;
@property (nonatomic,strong)UIImageView *imageView;

@property(nonatomic,strong)UIButton * backButton;
@property(nonatomic,strong)UIButton * resumeButton;
@property(nonatomic,strong)UIView * bootomView;

@end

@implementation DWFeedBackView

-(instancetype)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:0.2];
        [self loadSubviews];
    }
    
    return self;
}

- (void)loadSubviews
{
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
    
    self.bootomView =[[UIView alloc]init];
    self.bootomView.backgroundColor =[DWTools colorWithHexString:@"#f0f8ff"];
    [view addSubview:self.bootomView];
    [self.bootomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(view);
        make.height.mas_equalTo(45);
    }];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.layer.borderWidth = 0.5;
    [self.backButton setTitle:@"回看知识点" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.backButton.layer.borderColor = [DWTools colorWithHexString:@"#419bf9"].CGColor;
    [self.backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.backButton];
    
    self.resumeButton =[UIButton buttonWithType:UIButtonTypeCustom];
    self.resumeButton.backgroundColor = [DWTools colorWithHexString:@"#419bf9"];
    [self.resumeButton setTitle:@"继续播放" forState:UIControlStateNormal];
    self.resumeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.resumeButton.alpha =0.89;
    [self.resumeButton addTarget:self action:@selector(resumeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.resumeButton];

    self.imageView =[[UIImageView alloc]init];
    [view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bootomView.mas_top);
        make.right.mas_equalTo(view);
        make.height.mas_equalTo(146/2);
        make.width.mas_equalTo(182/2);
    }];
 
}

- (void)showResult:(DWVideoQuestionModel *)model withRight:(BOOL )right
{
    if (model.keepPlay) {
        if (model.backSecond == -1) {
            if (right) {
                [self.resumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.center.equalTo(self.bootomView);
                }];
            }else{
                [self.resumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.center.equalTo(self.bootomView);
                }];
            }
        }else{
            if (right) {
                [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.centerY.equalTo(self.bootomView);
                    make.right.equalTo(self.bootomView.mas_centerX).offset(-10);
                }];
                
                [self.resumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.centerY.equalTo(self.bootomView);
                    make.left.equalTo(self.bootomView.mas_centerX).offset(10);
                }];
            }else{
                [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.centerY.equalTo(self.bootomView);
                    make.right.equalTo(self.bootomView.mas_centerX).offset(-10);
                }];
                
                [self.resumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.centerY.equalTo(self.bootomView);
                    make.left.equalTo(self.bootomView.mas_centerX).offset(10);
                }];
            }
        }
    }else{
        if (model.backSecond != -1) {
            if (right) {
                [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.centerY.equalTo(self.bootomView);
                    make.right.equalTo(self.bootomView.mas_centerX).offset(-10);
                }];
                
                [self.resumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.centerY.equalTo(self.bootomView);
                    make.left.equalTo(self.bootomView.mas_centerX).offset(10);
                }];
            }else{
                [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@30);
                    make.width.equalTo(@90);
                    make.center.equalTo(self.bootomView);
                }];
            }
        }
    }
    
    if (right) {
        self.responseLabel.text = @"回答正确";
        self.imageView.image = [UIImage imageNamed:@"right"];
        self.responseLabel.textColor =[DWTools colorWithHexString:@"#17bc2f"];
        
    }else{
        self.responseLabel.text = @"回答错误";
        self.imageView.image = [UIImage imageNamed:@"wrong"];
        self.responseLabel.textColor =[DWTools colorWithHexString:@"#e03a3a"];
    }
    self.questionTextView.text = model.explainInfo;

}

-(void)backButtonAction
{
    if (self.backBlock) {
        self.backBlock();
    }
}

-(void)resumeButtonAction
{
    if (self.resumeBlock) {
        self.resumeBlock();
    }
}

@end
