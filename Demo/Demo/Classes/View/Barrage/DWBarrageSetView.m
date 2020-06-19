//
//  DWBarrageSetView.m
//  Demo
//
//  Created by zwl on 2020/6/10.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import "DWBarrageSetView.h"

@interface DWBarrageSetView ()

//遮罩层
@property(nonatomic,strong)UIView * maskBgView;

//功能视图
@property(nonatomic,strong)UIView * bgView;

@property(nonatomic,strong)UIView * headBgView;
@property(nonatomic,strong)UILabel * titleLabel;
@property(nonatomic,strong)UIButton * closeButton;

//透明度
@property(nonatomic,strong)UILabel * alphaLabel;
@property(nonatomic,strong)UISlider * alphaSlider;
//字号
@property(nonatomic,strong)NSArray * fontsArray;//字号枚举
@property(nonatomic,assign)NSInteger fontIndex;//当前字号下标
@property(nonatomic,strong)NSArray * fontPointsArray;
@property(nonatomic,strong)UILabel * fontLabel;
@property(nonatomic,strong)UISlider * fontSlider;
//速度
@property(nonatomic,strong)NSArray * speedsArray;//显示区域枚举
@property(nonatomic,assign)NSInteger speedIndex;//当前显示区域下标
@property(nonatomic,strong)NSArray * speedPointsArray;
@property(nonatomic,strong)UILabel * speedLabel;
@property(nonatomic,strong)UISlider * speedSlider;
//显示区域
@property(nonatomic,strong)NSArray * areasArray;//显示区域枚举
@property(nonatomic,assign)NSInteger areaIndex;//当前显示区域下标
@property(nonatomic,strong)NSArray * areaPointsArray;
@property(nonatomic,strong)UILabel * areaLabel;
@property(nonatomic,strong)UISlider * areaSlider;

@end

@implementation DWBarrageSetView

static CGFloat headBgHeight = 40;
static CGFloat sliderBgHeight = 76; //20 + 12 + 44

- (instancetype)init
{
    self = [super init];
    if (self) {
            
        self.alpha = 0;
        
        [self initUI];
        [self setDefault];
    }
    return self;
}

-(void)dealloc
{
//    NSLog(@"DWBarrageSetView dealloc");
}

-(void)screenRotate:(BOOL)isFull
{
    [self show];
}

-(void)show
{
    self.alpha = 1;
    
    //判断屏幕状态，用于修改color按钮布局
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        //横屏
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(@0);
            make.right.equalTo(@0);
            make.width.equalTo(@250);
        }];
        
        [self.closeButton setImage:[UIImage imageNamed:@"icon_barrage_set_return.png"] forState:UIControlStateNormal];
        [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self.headBgView);
            make.width.and.height.equalTo(@28);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.closeButton.mas_right).offset(10);
            make.top.and.bottom.equalTo(@0);
            make.width.equalTo(@150);
        }];
        
    }else{
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.equalTo(@0);
            make.width.equalTo(self);
            make.height.equalTo(@(headBgHeight + sliderBgHeight * 4));
        }];
        
        //竖屏
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.top.and.bottom.equalTo(@0);
            make.width.equalTo(@150);
        }];
        
        [self.closeButton setImage:[UIImage imageNamed:@"icon_barrage_set_close.png"] forState:UIControlStateNormal];
        [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-10));
            make.centerY.equalTo(self.headBgView);
            make.width.and.height.equalTo(@28);
        }];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    //修改记录点的位置
    CGFloat fontSpace = (self.fontSlider.frame.size.width - 10) / (CGFloat)(self.fontPointsArray.count - 1);
    [self.fontPointsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView * colorBlockView = (UIView *)obj;
        if (idx == self.fontPointsArray.count - 1) {
            [colorBlockView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@0);
                make.centerY.equalTo(self.fontSlider).offset(0.5);
                make.width.and.height.equalTo(@3);
            }];
        }else{
            [colorBlockView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(fontSpace * idx));
                make.centerY.equalTo(self.fontSlider).offset(0.5);
                make.width.and.height.equalTo(@3);
            }];
        }
    }];
    
    CGFloat speedSpace = (self.speedSlider.frame.size.width - 10) / (CGFloat)(self.speedPointsArray.count - 1);
    [self.speedPointsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView * colorBlockView = (UIView *)obj;
        if (idx == self.speedPointsArray.count - 1) {
            [colorBlockView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@0);
                make.centerY.equalTo(self.speedSlider).offset(0.5);
                make.width.and.height.equalTo(@3);
            }];
        }else{
            [colorBlockView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(speedSpace * idx));
                make.centerY.equalTo(self.speedSlider).offset(0.5);
                make.width.and.height.equalTo(@3);
            }];
        }
    }];
    
    CGFloat areaSpace = (self.areaSlider.frame.size.width - 6) / (CGFloat)(self.areaPointsArray.count - 1);
    [self.areaPointsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView * colorBlockView = (UIView *)obj;
        if (idx == self.areaPointsArray.count - 1) {
            [colorBlockView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@0);
                make.centerY.equalTo(self.areaSlider).offset(0.5);
                make.width.and.height.equalTo(@3);
            }];
        }else{
            [colorBlockView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(areaSpace * idx));
                make.centerY.equalTo(self.areaSlider).offset(0.5);
                make.width.and.height.equalTo(@3);
            }];
        }
    }];
}

-(void)dismiss
{
    self.alpha = 0;

    if ([self.delegate respondsToSelector:@selector(barrageSetViewDidDismiss)]) {
        [self.delegate barrageSetViewDidDismiss];
    }
}

#pragma mark - action
-(void)closeButtonAction
{
    [self dismiss];
}

-(void)sliderValueChange:(UISlider *)slider
{
    if (slider == self.alphaSlider) {
        self.alphaLabel.text = [NSString stringWithFormat:@"%.0f%%",self.alphaSlider.value * 100];
        
        if ([self.delegate respondsToSelector:@selector(barrageSetViewAlphaChange:)]) {
            [self.delegate barrageSetViewAlphaChange:slider.value];
        }
    }
}

-(void)sliderMoveEnd:(UISlider *)slider
{
    CGFloat p = slider.value;
    if (slider == self.fontSlider) {
        if (p <= 0.125) {
            slider.value = 0;
            self.fontIndex = 0;
        }else if (p > 0.125 && p <= 0.375){
            slider.value = 0.25;
            self.fontIndex = 1;
        }else if (p > 0.375 && p <= 0.625){
            slider.value = 0.5;
            self.fontIndex = 2;
        }else if (p > 0.625 && p <= 0.875){
            slider.value = 0.75;
            self.fontIndex = 3;
        }else{
            slider.value = 1;
            self.fontIndex = 4;
        }
        self.fontLabel.text = [self.fontsArray objectAtIndex:self.fontIndex];
        
        if ([self.delegate respondsToSelector:@selector(barrageSetViewFontChange:)]) {
            [self.delegate barrageSetViewFontChange:self.fontIndex];
        }
    }
    
    if (slider == self.speedSlider) {
        if (p <= 0.125) {
            slider.value = 0;
            self.speedIndex = 0;
        }else if (p > 0.125 && p <= 0.375){
            slider.value = 0.25;
            self.speedIndex = 1;
        }else if (p > 0.375 && p <= 0.625){
            slider.value = 0.5;
            self.speedIndex = 2;
        }else if (p > 0.625 && p <= 0.875){
            slider.value = 0.75;
            self.speedIndex = 3;
        }else{
            slider.value = 1;
            self.speedIndex = 4;
        }
        self.speedLabel.text = [self.speedsArray objectAtIndex:self.speedIndex];

        if ([self.delegate respondsToSelector:@selector(barrageSetViewSpeedChange:)]) {
            [self.delegate barrageSetViewSpeedChange:self.speedIndex];
        }
    }
    
    if (slider == self.areaSlider) {
        if (p <= 0.166667) {
            slider.value = 0;
            self.areaIndex = 0;
        }else if (p > 0.166667 && p <= 0.5){
            slider.value = 0.333333;
            self.areaIndex = 1;
        }else if (p > 0.5 && p <= 0.833333){
            slider.value = 0.666667;
            self.areaIndex = 2;
        }else{
            slider.value = 1;
            self.areaIndex = 3;
        }
        self.areaLabel.text = [self.areasArray objectAtIndex:self.areaIndex];

        if ([self.delegate respondsToSelector:@selector(barrageSetViewAreaChange:)]) {
            [self.delegate barrageSetViewAreaChange:self.areaIndex];
        }
    }
}

#pragma mark - init
-(void)initUI
{
    [self addSubview:self.maskBgView];
    [self.maskBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [self.maskBgView addGestureRecognizer:tap];
    
    [self addSubview:self.bgView];
    
    //弹幕设置
    [self.bgView addSubview:self.headBgView];
    [self.headBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.height.equalTo(@(headBgHeight));
        make.left.and.right.equalTo(@0);
    }];
    
    [self.headBgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.and.bottom.equalTo(@0);
        make.width.equalTo(@150);
    }];
    
    [self.headBgView addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-10));
        make.centerY.equalTo(self.headBgView);
        make.width.and.height.equalTo(@28);
    }];
    
    //具体调节进度
    NSArray * titles = @[@"不透明度",@"字号",@"速度",@"显示区域"];
//    CGFloat height = 20 + 12 + 44;
    for (int i = 0; i < titles.count; i++) {
        
        UIView * bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:bgView];
        //20 + 12 + 44 (10 + 24 + 10)
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headBgView.mas_bottom).offset(sliderBgHeight * i);
            make.left.and.right.equalTo(@0);
            make.height.equalTo(@(sliderBgHeight));
        }];
        
        UILabel * label = [[UILabel alloc]init];
        label.font = TitleFont(12);
        label.textColor = [UIColor whiteColor];
        label.text = [titles objectAtIndex:i];
        label.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.right.equalTo(@(-15));
            make.top.equalTo(@20);
            make.height.equalTo(@12);
        }];
        
        UISlider * slider = [[UISlider alloc]init];
        [slider setThumbImage:[UIImage imageNamed:@"icon_barrage_set_circle.png"] forState:UIControlStateNormal];
        [slider setMinimumTrackImage:[[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
        [slider setMaximumTrackImage:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.4] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
        [bgView addSubview:slider];
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label);
            make.top.equalTo(label.mas_bottom).offset(10);
            make.right.equalTo(@(-(10 + 28 + 20)));
            make.height.equalTo(@24);
        }];

        UILabel * showLabel = [[UILabel alloc]init];
        showLabel.font = TitleFont(12);
        showLabel.textColor = [UIColor whiteColor];
        showLabel.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:showLabel];
        [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-15));
            make.centerY.equalTo(slider);
            make.left.equalTo(slider.mas_right).offset(10);
            make.height.equalTo(@12);
        }];
        
        if (i == 0) {
            self.alphaLabel = showLabel;
            [slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
            self.alphaSlider = slider;
        }else if (i == 1){
            self.fontLabel = showLabel;
            [self.fontPointsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIView * colorBlockView = (UIView *)obj;
                [slider addSubview:colorBlockView];
            }];
            [slider addTarget:self action:@selector(sliderMoveEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
            self.fontSlider = slider;
        }else if (i == 2){
            self.speedLabel = showLabel;
            [self.speedPointsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIView * colorBlockView = (UIView *)obj;
                [slider addSubview:colorBlockView];
            }];
            [slider addTarget:self action:@selector(sliderMoveEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
            self.speedSlider = slider;
        }else if (i == 3){
            self.areaLabel = showLabel;
            [self.areaPointsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIView * colorBlockView = (UIView *)obj;
                [slider addSubview:colorBlockView];
            }];
            [slider addTarget:self action:@selector(sliderMoveEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
            self.areaSlider = slider;
        }
    }
}

//设置默认值
-(void)setDefault
{
    //透明度
    self.alphaSlider.value = 1;
    self.alphaLabel.text = [NSString stringWithFormat:@"%.0f%%",self.alphaSlider.value * 100];
    
    //字号
    self.fontIndex = 2;
    self.fontSlider.value = 0.5;
    self.fontLabel.text = [self.fontsArray objectAtIndex:self.fontIndex];
    
    //速度
    self.speedIndex = 2;
    self.speedSlider.value = 0.5;
//    self.speedLabel.text = [NSString stringWithFormat:@"%.0f%%",self.speedSlider.value * 100];
    self.speedLabel.text = [self.speedsArray objectAtIndex:self.speedIndex];
    
    //显示区域
    self.areaIndex = 3;
    self.areaSlider.value = 1;
    self.areaLabel.text = [self.areasArray objectAtIndex:self.areaIndex];
}

-(UIView *)maskBgView
{
    if (!_maskBgView) {
        _maskBgView = [[UIView alloc]init];
        _maskBgView.backgroundColor = [UIColor clearColor];
    }
    return _maskBgView;
}

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.8];
    }
    return _bgView;
}

-(UIView *)headBgView
{
    if (!_headBgView) {
        _headBgView = [[UIView alloc]init];
        _headBgView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.8];
    }
    return _headBgView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"弹幕设置";
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = TitleFont(14);
        _titleLabel.textColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0];
    }
    return _titleLabel;
}

-(UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"icon_barrage_set_close.png"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(NSArray *)fontsArray
{
    if (!_fontsArray) {
        _fontsArray = @[@"超小",@"小",@"正常",@"大",@"超大"];
    }
    return _fontsArray;
}

-(NSArray *)fontPointsArray
{
    if (!_fontPointsArray) {
        NSMutableArray * array = [[NSMutableArray alloc]init];
        for (int i = 0; i < 5; i++) {
            UIView * colorBlockView = [[UIView alloc]init];
            colorBlockView.backgroundColor = [UIColor whiteColor];
            [array addObject:colorBlockView];
        }
        _fontPointsArray = array;
    }
    return _fontPointsArray;
}

-(NSArray *)speedsArray{
    if (!_speedsArray) {
        _speedsArray = @[@"超慢",@"慢",@"正常",@"快",@"超快"];
    }
    return _speedsArray;
}

-(NSArray *)speedPointsArray
{
    if (!_speedPointsArray) {
        NSMutableArray * array = [[NSMutableArray alloc]init];
        for (int i = 0; i < 5; i++) {
            UIView * colorBlockView = [[UIView alloc]init];
            colorBlockView.backgroundColor = [UIColor whiteColor];
            [array addObject:colorBlockView];
        }
        _speedPointsArray = array;
    }
    return _speedPointsArray;
}

-(NSArray *)areasArray
{
    if (!_areasArray) {
        _areasArray = @[@"20%",@"30%",@"50%",@"100%"];
    }
    return _areasArray;
}

-(NSArray *)areaPointsArray
{
    if (!_areaPointsArray) {
        NSMutableArray * array = [[NSMutableArray alloc]init];
        for (int i = 0; i < 4; i++) {
            UIView * colorBlockView = [[UIView alloc]init];
            colorBlockView.backgroundColor = [UIColor whiteColor];
            [array addObject:colorBlockView];
        }
        _areaPointsArray = array;
    }
    return _areaPointsArray;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
