//
//  DWAudioPlayView.m
//  Demo
//
//  Created by luyang on 2017/11/9.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import "DWAudioPlayView.h"


@interface DWAudioPlayView()

//滑动条是否滑动
@property (nonatomic,assign)BOOL isAudioSlidering;

@end

@implementation DWAudioPlayView

- (instancetype )initWithFrame:(CGRect)frame{
   
    self =[super initWithFrame:frame];
    if (self) {
        
        [self loadSubviews];
    }
    
    return self;
}

- (void)loadSubviews{
    
    _imageView =[[UIImageView alloc]init];
    _imageView.image =[UIImage imageNamed:@"bgImage"];
    [self addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(self);
    }];
    
    _backBtn =[self creatButtonWithImageName:@"player-back-button.png" selector:@selector(audioBackAction:)];
    [self addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.height.width.mas_equalTo(25);
        make.left.mas_equalTo(self.mas_left).offset(12);
        make.top.mas_equalTo(self.mas_top).offset(7);
        
        
    }];
    
    _titleLabel =[[UILabel alloc]init];
    _titleLabel.text =@"我是音频";
    _titleLabel.font =[UIFont systemFontOfSize:13];
    _titleLabel.textColor =[UIColor whiteColor];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(_backBtn.mas_right);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(512/2);
        make.centerY.mas_equalTo(_backBtn);
    }];
    
    
    _downloadBtn =[self creatButtonWithImageName:@"download_ic" selector:@selector(audioDownloadAction:)];
    [self addSubview:_downloadBtn];
    [_downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.width.mas_equalTo(30);
        make.centerY.mas_equalTo(_backBtn);
        make.right.mas_equalTo(self.mas_right).offset(-12);
        
        
    }];
    
    _rateBtn =[self creatButtonWithImageName:@"" selector:@selector(audioRateAction:)];
    _rateBtn.tag =101;
    _rateBtn.layer.cornerRadius =2;
    _rateBtn.layer.masksToBounds =YES;
    [self addSubview:_rateBtn];
    [_rateBtn setTitle:@"语速X1.0" forState:UIControlStateNormal];
    _rateBtn.titleLabel.font =[UIFont systemFontOfSize:12];
    [_rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(124/2);
        make.height.mas_equalTo(50/2);
        make.top.mas_equalTo(self.mas_top).offset(134/2);
        make.centerX.mas_equalTo(self);
        
        
    }];

//    _progressView =[[UIProgressView alloc]initWithFrame:CGRectMake((ScreenWidth -620/2)/2,self.center.y, 620/2, 30)];
    _progressView = [[UIProgressView alloc]init];
    _progressView.progressTintColor =[DWTools colorWithHexString:@"#999999"];
    _progressView.trackTintColor =[UIColor whiteColor];
    [self addSubview:_progressView];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(620/2));
        make.height.equalTo(@1);
    }];
    
    _audioSlider =[[UISlider alloc]init];
    [self addSubview:_audioSlider];
    _audioSlider.minimumValue = 0.0f;
    _audioSlider.maximumValue = 1.0f;
    _audioSlider.value = 0.0f;
    _audioSlider.continuous = NO;

    [_audioSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [_audioSlider setMinimumTrackTintColor:[DWTools colorWithHexString:@"#ff6633"]];
    [ _audioSlider setThumbImage:[UIImage imageNamed:@"player-slider-handle"]
                              forState:UIControlStateNormal];
    
    [_audioSlider addTarget:self action:@selector(durationSliderMoving:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
  
   [ _audioSlider addTarget:self action:@selector(durationSliderEnded:) forControlEvents:   UIControlEventTouchCancel];

    [ _audioSlider addTarget:self action:@selector(durationSliderBegan:) forControlEvents:UIControlEventTouchDown];
    
    
    [_audioSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(620/2);
        make.height.mas_equalTo(30);
        make.center.mas_equalTo(self);
        
    }];
    
   
   
    
    _playLabel =[[UILabel alloc]init];
    _playLabel.font =[UIFont systemFontOfSize:11];
    _playLabel.textColor =[UIColor whiteColor];
    _playLabel.text =@"00:00:00";
    [self addSubview:_playLabel];
    [_playLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(_audioSlider.mas_left);
        make.width.mas_equalTo(76);
        make.height.mas_equalTo(12);
        make.top.mas_equalTo(_audioSlider.mas_bottom).offset(25/2);
        
        
    }];
    
    _totalLabel =[[UILabel alloc]init];
    _totalLabel.font =[UIFont systemFontOfSize:11];
    _totalLabel.text =@"00:00:00";
    _totalLabel.textColor =[UIColor whiteColor];
    _totalLabel.textAlignment =NSTextAlignmentRight;
    [self addSubview:_totalLabel];
    [_totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.width.top.mas_equalTo(_playLabel);
        make.right.mas_equalTo(_audioSlider.mas_right);
        
    }];
    
    _playBtn =[self creatButtonWithImageName:@"play" selector:@selector(playBtnAction:)];
    [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    _playBtn.layer.cornerRadius =89/2/2;
    _playBtn.layer.masksToBounds =YES;
    [self addSubview:_playBtn];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.mas_equalTo(self);
        make.height.width.mas_equalTo(89/2);
        make.top.mas_equalTo(_playLabel.mas_bottom).offset(30/2);
        
    }];
    
    _leftView =[[UIView alloc]init];
    _leftView.backgroundColor =[DWTools colorWithHexString:@"#ffffff"];
    _leftView.alpha =0.3;
    [self addSubview:_leftView];
    [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(58/2);
        make.width.mas_equalTo(3/2);
        make.centerY.mas_equalTo(_playBtn);
        make.right.mas_equalTo(_playBtn.mas_left).offset(-70/2);
        
        
    }];
    
    
    _rightView =[[UIView alloc]init];
    _rightView.backgroundColor =[DWTools colorWithHexString:@"#ffffff"];
    _rightView.alpha =0.3;
    [self addSubview:_rightView];
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(58/2);
        make.width.mas_equalTo(3/2);
        make.centerY.mas_equalTo(_playBtn);
        make.left.mas_equalTo(_playBtn.mas_right).offset(70/2);
        
        
    }];
    
    //回退15s
    _fallbackBtn =[self creatButtonWithImageName:@"fallback" selector:@selector(fallbackBtnAction:)];
    _fallbackBtn.layer.cornerRadius =1.5;
    _fallbackBtn.layer.masksToBounds =YES;
    [self addSubview:_fallbackBtn];
    [_fallbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.mas_equalTo(53/2);
        make.width.mas_equalTo(71/2);
        make.centerY.mas_equalTo(_playBtn);
        make.right.mas_equalTo(_leftView.mas_left).offset(-65/2);
        
    }];
    
    //前进15s
    _farwardBtn =[self creatButtonWithImageName:@"farward" selector:@selector(farwardBtnAction:)];
    _farwardBtn.layer.cornerRadius =1.5;
    _farwardBtn.layer.masksToBounds =YES;
    [self addSubview:_farwardBtn];
    [_farwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(53/2);
        make.width.mas_equalTo(71/2);
        make.centerY.mas_equalTo(_playBtn);
        make.left.mas_equalTo(_rightView.mas_right).offset(65/2);
        
    }];
    
    
}

//关闭
- (void)audioBackAction:(UIButton *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(audioPlayViewBackAction)]) {
        
        [_delegate audioPlayViewBackAction];
    }
    
}

- (void)audioDownloadAction:(UIButton *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(audioPlayViewDownloadAction)]) {
        
        [_delegate audioPlayViewDownloadAction];
    }

    
    
}

- (void)audioRateAction:(UIButton *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(audioPlayViewRateAction)]) {
        
        [_delegate audioPlayViewRateAction];
    }

    
    
}

- (void)durationSliderMoving:(UISlider *)slider{
    
    self.isAudioSlidering =NO;
    if (_delegate && [_delegate respondsToSelector:@selector(durationPlayViewSliderMoving)]) {
        
        [_delegate durationPlayViewSliderMoving];
    }
    
   
    
    
}

- (void)durationSliderEnded:(UISlider *)slider{
    
   self.isAudioSlidering =NO;
    
}

- (void)durationSliderBegan:(UISlider *)slider{
    
   self.isAudioSlidering =YES;
}

- (void)playBtnAction:(UIButton *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(playPlayViewBtnAction)]) {
        
        [_delegate playPlayViewBtnAction];
    }
    
    
}

//回退15s
- (void)fallbackBtnAction:(UIButton *)sender{
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(fallbackPlayViewBtnAction)]) {
        
        [_delegate fallbackPlayViewBtnAction];
    }
    
    
}

//前进15s
- (void)farwardBtnAction:(UIButton *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(farwardPlayViewBtnAction)]) {
        
        [_delegate farwardPlayViewBtnAction];
    }
    
}


- (UIButton *)creatButtonWithImageName:(NSString *)imageName selector:(SEL )selector{
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    return btn;
    
}

@end
