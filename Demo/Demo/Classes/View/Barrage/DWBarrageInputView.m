//
//  DWBarrageInputView.m
//  Demo
//
//  Created by zwl on 2020/6/10.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import "DWBarrageInputView.h"

@interface DWBarrageInputView () <UITextFieldDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)NSArray * images;
@property(nonatomic,assign)NSInteger colorIndex;
@property(nonatomic,strong)NSArray * colorsArray;
@property(nonatomic,assign)UIEdgeInsets areaInsets;

//记录是否需要隐藏此视图
@property(nonatomic,assign)BOOL isDismiss;

//键盘高度
@property(nonatomic,assign)CGFloat keyboardHeight;

//遮罩层
@property(nonatomic,strong)UIView * maskBgView;

//功能视图
@property(nonatomic,strong)UIView * bgView;
//背景视图
@property(nonatomic,strong)UIView * inputBgView;
@property(nonatomic,strong)UIButton * colorChooseButton;
@property(nonatomic,strong)UITextField * inputTexField;
@property(nonatomic,strong)UIButton * sendButton;
@property(nonatomic,strong)UILabel * numLabel;
//颜色选择视图
@property(nonatomic,strong)UIView * colorChooseBgView;

@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,assign)NSInteger second;

@end

@implementation DWBarrageInputView

static CGFloat colorButtonSize = 27;
static CGFloat inputBgHeight = 45;
static NSInteger maxTextNum = 30;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.alpha = 0;

        self.isDismiss = YES;
        
        self.colorIndex = 0;
        self.images = @[@"icon_barrage_color_01",@"icon_barrage_color_02",@"icon_barrage_color_03",@"icon_barrage_color_04",@"icon_barrage_color_05",@"icon_barrage_color_06",@"icon_barrage_color_07",@"icon_barrage_color_08",@"icon_barrage_color_09",@"icon_barrage_color_10"];
        self.keyboardHeight = 0;
        
        [self initUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
//    NSLog(@"DWBarrageInputView dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self stopTimer];
}


-(void)beginEdit
{
    [self.inputTexField becomeFirstResponder];
}

-(void)screenRotate:(BOOL)isFull
{
    if (isFull) {
        self.inputBgView.backgroundColor = [UIColor colorWithRed:39/255.0 green:40/255.0 blue:42/255.0 alpha:1.0];
        self.colorChooseBgView.backgroundColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:63/255.0 alpha:1.0];
    }else{
        self.inputBgView.backgroundColor = [UIColor whiteColor];
        self.colorChooseBgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }
    
    [self show];
}

-(void)clearTextField
{
    self.inputTexField.text = @"";
    
    self.numLabel.text = [NSString stringWithFormat:@"%ld",maxTextNum - self.inputTexField.text.length];
}

-(void)show
{
    self.alpha = 1;
    
    self.colorChooseButton.selected = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.23 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.colorChooseBgView.hidden = NO;
    });
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.bottom.equalTo(@0);
        make.width.equalTo(self);
        make.height.equalTo(@(self.keyboardHeight + inputBgHeight));
    }];
    
    //判断屏幕状态，用于修改color按钮布局
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self.colorChooseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(self.areaInsets.left + 10));
            make.centerY.equalTo(self.inputBgView);
            make.width.and.height.equalTo(@30);
        }];
        
        [self.colorChooseBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputBgView.mas_bottom);
            make.left.equalTo(@(self.areaInsets.left));
            make.right.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
        
    }else{
        [self.colorChooseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self.inputBgView);
            make.width.and.height.equalTo(@30);
        }];
        
        [self.colorChooseBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.inputBgView.mas_bottom);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
    }
        
    for (int i = 0; i < self.images.count; i++) {
        UIButton * colorButton = (UIButton *)[self.colorChooseBgView viewWithTag:100 + i];
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            //横屏
            CGFloat space = 20;
            [colorButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@42);
                make.left.equalTo(@(space + (space + colorButtonSize) * i));
                make.width.and.height.equalTo(@(colorButtonSize));
            }];
        }else{
            //竖屏
            CGFloat space = (ScreenWidth - colorButtonSize * 7) / 8.0;
            [colorButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@(42 + (15 + colorButtonSize) * (i / 7)));
                make.left.equalTo(@(space + (space + colorButtonSize) * (i % 7)));
                make.width.and.height.equalTo(@(colorButtonSize));
            }];
        }
    }
}

-(void)dismiss
{
    self.alpha = 0;
    
    self.colorChooseBgView.hidden = YES;

    [self.inputTexField resignFirstResponder];
    
//    if ([self.delegate respondsToSelector:@selector(barrageInputViewDismiss)]) {
//        [self.delegate barrageInputViewDismiss];
//    }
}

-(void)startTimer
{
    [self stopTimer];
    
    self.sendButton.enabled = NO;
    [self.sendButton setTitle:[NSString stringWithFormat:@"%lds",self.second] forState:UIControlStateNormal];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.second = 5;
}

#pragma mark - noti
-(void)keyboardWillShow:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardHeight = keyboardRect.size.height;
    
    [self show];
}

-(void)keyboardWillHidden
{
    if (!self.isDismiss) {
        //编辑颜色
        return;
    }
    [self dismiss];
}

-(void)textFieldDidChange
{
    if (self.inputTexField.text.length > maxTextNum) {
        self.inputTexField.text = [self.inputTexField.text substringWithRange:NSMakeRange(0, maxTextNum)];
            
        UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多输入%ld个字符",maxTextNum] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
    }
    
    self.numLabel.text = [NSString stringWithFormat:@"%ld",maxTextNum - self.inputTexField.text.length];
}


#pragma mark - delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButtonAction];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isContainsEmoji]) {
        return NO;
    }
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self beginEdit];
}

#pragma mark - action
-(void)tapAction
{
    //消键盘，可能还有后续UI的操作
    self.isDismiss = YES;
    
    [self dismiss];
}

-(void)colorButtonAction:(UIButton *)button
{
    //100 + i
    //颜色选中
    if (button.selected) {
        return;
    }
    
    button.selected = !button.selected;
    
    UIButton * frontButton = (UIButton *)[self.colorChooseBgView viewWithTag:100 + self.colorIndex];
    frontButton.selected = NO;
    
    self.colorIndex = button.tag - 100;
}

-(void)colorChooseButtonAction
{
    self.colorChooseButton.selected = !self.colorChooseButton.selected;
    
    self.isDismiss = !self.colorChooseButton.selected;
    
    if (self.colorChooseButton.selected) {
        [self.inputTexField resignFirstResponder];
    }else{
        [self beginEdit];
    }
}

-(void)sendButtonAction
{
    if (!self.sendButton.enabled) {
        return;
    }
    
    if ([self.inputTexField.text isEqualToString:@""]) {
        [@"请输入内容" showAlert];
        return;
    }
    
    [self startTimer];
    
    //返送弹幕 内容 + 颜色
    if ([self.delegate respondsToSelector:@selector(barrageInputViewSendWithContent:Fc:)]) {
        [self.delegate barrageInputViewSendWithContent:self.inputTexField.text Fc:[self.colorsArray objectAtIndex:self.colorIndex]];
    }
}

-(void)timerAction
{
    if (self.second == 0) {
        self.sendButton.enabled = YES;
        [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [self stopTimer];
        return;
    }
    
    [self.sendButton setTitle:[NSString stringWithFormat:@"%lds",self.second] forState:UIControlStateDisabled];
    self.second--;
}

#pragma mark - init
-(void)initUI
{
    [self addSubview:self.maskBgView];
    [self.maskBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.maskBgView addGestureRecognizer:tap];
    
    self.bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    [self addSubview:self.bgView];
    
    [self.bgView addSubview:self.inputBgView];
    [self.inputBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.width.equalTo(self.bgView);
        make.top.equalTo(@0);
        make.height.equalTo(@(inputBgHeight));
    }];

    [self.inputBgView addSubview:self.colorChooseButton];
    [self.colorChooseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.centerY.equalTo(self.inputBgView);
        make.width.and.height.equalTo(@30);
    }];
    
    [self.inputBgView addSubview:self.sendButton];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-10));
        make.centerY.equalTo(self.colorChooseButton);
        make.width.equalTo(@56);
        make.height.equalTo(@30);
    }];
    
    UIView * bgView = [[UIView alloc]init];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 35 / 2.0;
    bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    [self.inputBgView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.colorChooseButton.mas_right).offset(10);
        make.right.equalTo(self.sendButton.mas_left).offset(-10);
        make.centerY.equalTo(self.sendButton);
        make.height.equalTo(@35);
    }];
    
    [bgView addSubview:self.inputTexField];
    [bgView addSubview:self.numLabel];
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-10));
        make.centerY.equalTo(bgView);
        make.width.equalTo(@16);
        make.height.equalTo(@12);
    }];
    [self.inputTexField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.right.equalTo(self.numLabel.mas_left).offset(-10);
        make.height.equalTo(bgView);
        make.centerY.equalTo(bgView);
    }];
    
    
    [self.bgView addSubview:self.colorChooseBgView];
    self.colorChooseBgView.hidden = YES;
    [self.colorChooseBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputBgView.mas_bottom);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    
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
        _bgView.backgroundColor = [UIColor clearColor];
    }
    return _bgView;
}

-(UIView *)inputBgView
{
    if (!_inputBgView) {
        _inputBgView = [[UIView alloc]init];
        _inputBgView.backgroundColor = [UIColor whiteColor];
    }
    return _inputBgView;
}

-(UIView *)colorChooseBgView
{
    if (!_colorChooseBgView) {
        _colorChooseBgView = [[UIView alloc]init];
        _colorChooseBgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        
        UILabel * label = [[UILabel alloc]init];
        label.text = @"弹幕颜色";
        label.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = TitleFont(12);
        [_colorChooseBgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.top.equalTo(@0);
            make.right.equalTo(@(-10));
            make.height.equalTo(@42);
        }];

        for (int i = 0; i < self.images.count; i++) {
            NSString * image = [self.images objectAtIndex:i];
            UIButton * colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [colorButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",image]] forState:UIControlStateNormal];
            [colorButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_select.png",image]] forState:UIControlStateSelected];
            if (i == self.colorIndex) {
                colorButton.selected = YES;
            }
            colorButton.tag = 100 + i;
            [colorButton addTarget:self action:@selector(colorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_colorChooseBgView addSubview:colorButton];
        }
    }
    return _colorChooseBgView;
}

-(UIButton *)colorChooseButton
{
    if (!_colorChooseButton) {
        _colorChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_colorChooseButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_color_normal.png"] forState:UIControlStateNormal];
        [_colorChooseButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_color_select.png"] forState:UIControlStateSelected];
        [_colorChooseButton addTarget:self action:@selector(colorChooseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _colorChooseButton;
}

-(UITextField *)inputTexField
{
    if (!_inputTexField) {
        _inputTexField = [[UITextField alloc]init];
        _inputTexField.font = TitleFont(13);
        _inputTexField.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        _inputTexField.textAlignment = NSTextAlignmentLeft;
        _inputTexField.returnKeyType = UIReturnKeySend;
        _inputTexField.delegate = self;
        NSMutableAttributedString * attr = [[NSMutableAttributedString alloc] initWithString:@"弹幕走一波" attributes:@{NSFontAttributeName: TitleFont(13),NSForegroundColorAttributeName: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]}];
        _inputTexField.attributedPlaceholder = attr;
    }
    return _inputTexField;
}

-(UIButton *)sendButton
{
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.titleLabel.font = TitleFont(15);
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.cornerRadius = 15;
        [_sendButton setBackgroundImage:[[UIColor colorWithRed:255/255.0 green:149/255.0 blue:32/255.0 alpha:1.0] createImage] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

-(UILabel *)numLabel
{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc]init];
        _numLabel.text = [NSString stringWithFormat:@"%ld",maxTextNum];
        _numLabel.font = TitleFont(12);
        _numLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    }
    return _numLabel;
}

-(NSArray *)colorsArray
{
    if (!_colorsArray) {
        _colorsArray = @[@"0xffffff",@"0x999999",@"0xE6151E",@"0x9D22B1",@"0x6738B8",@"0x3D50B6",@"0x03A9F4",@"0x009688",@"0x259B24",@"0x8BC34A"];
    }
    return _colorsArray;
}

-(UIEdgeInsets)areaInsets
{
    if (@available(iOS 11.0, *)) {
        if (!UIEdgeInsetsEqualToEdgeInsets([[UIApplication sharedApplication] delegate].window.safeAreaInsets, UIEdgeInsetsZero)) {
            return [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
        }
    }
    return UIEdgeInsetsMake(20, 10, 0, 10);
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
