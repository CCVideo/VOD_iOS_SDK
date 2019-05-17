//
//  DWAudioPlayView.h
//  Demo
//
//  Created by luyang on 2017/11/9.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWAudioPlayViewDelegate <NSObject>

@optional

- (void)audioPlayViewBackAction;

- (void)audioPlayViewDownloadAction;

- (void)audioPlayViewRateAction;

- (void)durationPlayViewSliderMoving;

- (void)playPlayViewBtnAction;

//回退15s
- (void)fallbackPlayViewBtnAction;

//前进15s
- (void)farwardPlayViewBtnAction;


@end



@interface DWAudioPlayView : UIView

@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIButton *backBtn;

@property (nonatomic,strong)UIButton *downloadBtn;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIButton *farwardBtn;//向前
@property (nonatomic,strong)UIButton *fallbackBtn;//回退
@property (nonatomic,strong)UIView *leftView;
@property (nonatomic,strong)UIView *rightView;

@property (nonatomic,strong)UIButton *playBtn;
@property (nonatomic,strong)UIButton *rateBtn;

@property (nonatomic,strong)UILabel *playLabel;
@property (nonatomic,strong)UILabel *totalLabel;

@property (nonatomic,strong)UISlider *audioSlider;

@property (nonatomic,strong)UIProgressView *progressView;

//滑动条是否滑动
@property (nonatomic,assign,readonly)BOOL isAudioSlidering;


@property (nonatomic,weak)id<DWAudioPlayViewDelegate> delegate;

@end
