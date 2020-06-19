//
//  DWBarrageBgView.m
//  Demo
//
//  Created by zwl on 2020/6/9.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import "DWBarrageBgView.h"
#import "DWBarrageSegmentView.h"
#import "DWBarrageInputView.h"
#import "DWBarrageSetView.h"

@interface DWBarrageBgView () <DWBarrageSegmentViewDelegate,DWBarrageInputViewDelegate,DWBarrageSetViewDelegate>

//弹幕状态
@property(nonatomic,assign)BOOL isOpen;

//横屏
//开启关闭按钮
@property(nonatomic,strong)UIButton * openButton;
//设置按钮
@property(nonatomic,strong)UIButton * setButton;

//竖屏
@property(nonatomic,strong)DWBarrageSegmentView * segmentView;

//输入状态
@property(nonatomic,strong)UIButton * statusButton;

//弹幕输入控件
@property(nonatomic,strong)DWBarrageInputView * barrageInputView;
//弹幕设置控件
@property(nonatomic,strong)DWBarrageSetView * barrageSetView;

//透明度
@property(nonatomic,assign)CGFloat barrageAlpha;

//字号
@property(nonatomic,strong)UIFont * barrageFont;

//速度
@property(nonatomic,assign)CGFloat barrageSpeed;

//显示区域
//@property(nonatomic,assign)CGFloat barrageArea;

@end

@implementation DWBarrageBgView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //默认值，与DWBarrageSetView同步
        self.barrageAlpha = 1;
        self.barrageFont = TitleFont(16);
        self.barrageSpeed = 5;
        self.isOpen = YES;
//        self.barrageArea = 1;
        
//        self.isInput = NO;
        
        [self initUI];
        [self initBarrageInputView];
        [self initBarrageSetView];
    }
    return self;
}

-(void)dealloc
{
    [self.barrageInputView removeFromSuperview];
    [self.barrageSetView removeFromSuperview];
    
//    NSLog(@"DWBarrageBgView dealloc");
}

//屏幕旋转
-(void)screenRotate:(BOOL)isFull
{
    self.segmentView.hidden = isFull;
    self.openButton.hidden = !isFull;

    if (isFull) {
        self.backgroundColor = [UIColor clearColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
    
    if (self.barrageSetView.alpha != 0) {
        [self.barrageSetView screenRotate:isFull];
    }
}

-(void)clearTextField
{
    [self.barrageInputView clearTextField];
}

#pragma mark - action
-(void)openButtonAction
{
    //打开/关闭弹幕
    self.openButton.selected = !self.openButton.selected;

    self.setButton.hidden = self.openButton.selected;
    self.statusButton.hidden = self.openButton.selected;
    
    [self.segmentView changeModelWithClose:self.openButton.selected];
    
    if ([self.delegate respondsToSelector:@selector(barrageBgViewOpen:)]) {
        [self.delegate barrageBgViewOpen:!self.openButton.selected];
    }
    self.isOpen = !self.openButton.selected;
}

-(void)setButtonAction
{
    //弹幕设置
    self.setButton.selected = !self.setButton.selected;
    
    if (self.setButton.selected) {
        [self.barrageSetView show];
    }
}

-(void)statusButtonAction
{
    //开始编辑
    [self.barrageInputView beginEdit];
    
    if ([self.delegate respondsToSelector:@selector(barrageBgViewBeginEdit)]) {
        [self.delegate barrageBgViewBeginEdit];
    }
    
//    self.isInput = YES;
}

#pragma mark - DWBarrageSegmentViewDelegate
-(void)barrageSegmentViewOpen:(BOOL)isOpen
{
    //打开/关闭弹幕
    self.setButton.hidden = isOpen;
    self.statusButton.hidden = isOpen;
    
    self.openButton.selected = isOpen;
    
    if ([self.delegate respondsToSelector:@selector(barrageBgViewOpen:)]) {
        [self.delegate barrageBgViewOpen:!self.openButton.selected];
    }
    
    self.isOpen = !self.openButton.selected;
}

-(void)barrageSegmentViewSet:(BOOL)isSet
{
    //弹幕设置
    self.setButton.selected = isSet;
    
    if (self.setButton.selected) {
        [self.barrageSetView show];
    }
}

#pragma mark - DWBarrageInputViewDelegate
-(void)barrageInputViewSendWithContent:(NSString *)content Fc:(NSString *)fc
{
    //发送弹幕
    if ([self.delegate respondsToSelector:@selector(barrageBgViewSendWithContent:Fc:)]) {
        [self.delegate barrageBgViewSendWithContent:content Fc:fc];
    }
}

//-(void)barrageInputViewDismiss
//{
////    self.isInput = NO;
//}

#pragma mark - DWBarrageSetViewDelegate
//设置视图消失
-(void)barrageSetViewDidDismiss
{
    [self.segmentView changeSetClose];
    self.setButton.selected = NO;
}

//设置透明度
-(void)barrageSetViewAlphaChange:(CGFloat)alpha
{
    self.barrageAlpha = alpha;
}

//设置字号
-(void)barrageSetViewFontChange:(NSInteger)font
{
    NSArray * fonts = @[TitleFont(12),TitleFont(15),TitleFont(18),TitleFont(21),TitleFont(24)];
    self.barrageFont = [fonts objectAtIndex:font];
}

//设置速度
-(void)barrageSetViewSpeedChange:(NSInteger)speed
{
    NSArray * speeds = @[@1.5,@3,@5,@7,@8.5];
    self.barrageSpeed = [[speeds objectAtIndex:speed] floatValue];
}

//设置显示区域
-(void)barrageSetViewAreaChange:(NSInteger)area
{
    NSArray * areas = @[@(0.2),@(0.3),@(0.5),@(1)];
//    self.barrageArea = [[areas objectAtIndex:area] floatValue];
    if ([self.delegate respondsToSelector:@selector(barrageBgViewAreaChange:)]) {
        [self.delegate barrageBgViewAreaChange:[[areas objectAtIndex:area] floatValue]];
    }
}

#pragma mark - init
-(void)initUI
{    
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.openButton];
    self.openButton.hidden = YES;
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.centerY.equalTo(self);
        make.width.and.height.equalTo(@30);
    }];
    
    [self addSubview:self.setButton];
    [self.setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.openButton.mas_right).offset(20);
        make.centerY.equalTo(self);
        make.width.and.height.equalTo(self.openButton);
    }];
    
    [self addSubview:self.statusButton];
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@120);
        make.right.equalTo(@(-10));
        make.centerY.equalTo(self);
        make.height.equalTo(@(self.statusButton.layer.cornerRadius * 2));
    }];
    
    [self addSubview:self.segmentView];
    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.centerY.equalTo(self);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
}

-(void)initBarrageInputView
{
    self.barrageInputView = [[DWBarrageInputView alloc]init];
    self.barrageInputView.delegate = self;
    [DWAPPDELEGATE.window addSubview:self.barrageInputView];
    [_barrageInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(@0);
        make.bottom.and.right.equalTo(@0);
    }];
}

-(void)initBarrageSetView
{
    self.barrageSetView = [[DWBarrageSetView alloc]init];
    self.barrageSetView.delegate = self;
    [DWAPPDELEGATE.window addSubview:self.barrageSetView];
    [_barrageSetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(@0);
        make.bottom.and.right.equalTo(@0);
    }];
}

-(UIButton *)openButton
{
    if (!_openButton) {
        _openButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_open.png"] forState:UIControlStateNormal];
        [_openButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_close_white.png"] forState:UIControlStateSelected];
        [_openButton addTarget:self action:@selector(openButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _openButton;
}

-(UIButton *)setButton
{
    if (!_setButton) {
        _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_set_normal_white.png"] forState:UIControlStateNormal];
        [_setButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_set_select.png"] forState:UIControlStateSelected];
        [_setButton addTarget:self action:@selector(setButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setButton;
}

-(UIButton *)statusButton
{
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusButton setTitle:@"点我发弹幕" forState:UIControlStateNormal];
        [_statusButton setTitle:@"弹幕输入中" forState:UIControlStateSelected];
        _statusButton.titleLabel.font = TitleFont(13);
        [_statusButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
        _statusButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _statusButton.layer.masksToBounds = YES;
        _statusButton.layer.cornerRadius = 15;
        _statusButton.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
        _statusButton.layer.borderWidth = 0.5;
        [_statusButton setBackgroundImage:[[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0] createImage] forState:UIControlStateNormal];
        [_statusButton addTarget:self action:@selector(statusButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _statusButton;
}

-(DWBarrageSegmentView *)segmentView
{
    if (!_segmentView) {
        _segmentView = [[DWBarrageSegmentView alloc]init];
        _segmentView.delegate = self;
    }
    return _segmentView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
