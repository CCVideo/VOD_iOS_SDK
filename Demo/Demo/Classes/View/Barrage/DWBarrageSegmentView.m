//
//  DWBarrageSegmentView.m
//  Demo
//
//  Created by zwl on 2020/6/9.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import "DWBarrageSegmentView.h"

@interface DWBarrageSegmentView ()

//线
@property(nonatomic,strong)UIView * line;
//开启关闭按钮
@property(nonatomic,strong)UIButton * openButton;
//设置按钮
@property(nonatomic,strong)UIButton * setButton;

@end

@implementation DWBarrageSegmentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
        
        [self changeModelWithClose:NO];
    }
    return self;
}

-(void)changeModelWithClose:(BOOL)close
{
    self.openButton.selected = close;
    if (!close) {
        if (self.superview) {
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@100);
            }];
        }
        
        self.setButton.hidden = NO;
        self.line.hidden = NO;
        
        [self.openButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self);
            make.width.and.height.equalTo(@30);
        }];
        
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@0.5);
            make.height.equalTo(self);
        }];
        
        [self.setButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-10));
            make.centerY.equalTo(self);
            make.width.and.height.equalTo(self.openButton);
        }];
        
        self.backgroundColor = [UIColor whiteColor];
        
    }else{
        if (self.superview) {
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@50);
            }];
        }

        self.setButton.hidden = YES;
        self.line.hidden = YES;
        [self.openButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(@30);
        }];
        
        self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }
}

//恢复设置按钮默认状态
-(void)changeSetClose
{
    self.setButton.selected = NO;
}

#pragma mark - action
-(void)openButtonAction
{
    //打开/关闭弹幕
    BOOL open = !self.openButton.selected;
//    self.openButton.selected = !self.openButton.selected;
    
    [self changeModelWithClose:open];
    
    if ([self.delegate respondsToSelector:@selector(barrageSegmentViewOpen:)]) {
        [self.delegate barrageSegmentViewOpen:open];
    }
}

-(void)setButtonAction
{
    //弹幕设置
    self.setButton.selected = !self.setButton.selected;
    
    if ([self.delegate respondsToSelector:@selector(barrageSegmentViewSet:)]) {
        [self.delegate barrageSegmentViewSet:self.setButton.selected];
    }
}

#pragma mark - init
-(void)initUI
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 15;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
    
    [self addSubview:self.openButton];
    [self addSubview:self.line];
    [self addSubview:self.setButton];
}

-(UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    }
    return _line;
}

-(UIButton *)openButton
{
    if (!_openButton) {
        _openButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_open.png"] forState:UIControlStateNormal];
        [_openButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_close.png"] forState:UIControlStateSelected];
        [_openButton addTarget:self action:@selector(openButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _openButton;
}

-(UIButton *)setButton
{
    if (!_setButton) {
        _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_set_normal.png"] forState:UIControlStateNormal];
        [_setButton setBackgroundImage:[UIImage imageNamed:@"icon_barrage_set_select.png"] forState:UIControlStateSelected];
        [_setButton addTarget:self action:@selector(setButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
