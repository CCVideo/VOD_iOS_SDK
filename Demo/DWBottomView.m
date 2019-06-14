//
//  DWBottomView.m
//  Demo
//
//  Created by luyang on 2017/11/9.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import "DWBottomView.h"

@interface DWBottomView()

@end


@implementation DWBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self =[super initWithFrame:frame];
    
    if (self) {
      
        
        _height =frame.size.height;
        _width =frame.size.width;
        _index = 0;
        [self loadSubviews];
    }
    
    return self;
    
}

- (void)loadSubviews{
    
    _videoBtn =[self creatButtonWithTitle:@"视频播放" selector:@selector(videoPlay:) frame:CGRectMake((_width/2-53)/2, 13,53, 13)];
    _videoBtn.selected =YES;
    
    _audioBtn =[self creatButtonWithTitle:@"音频播放" selector:@selector(audioPlay:) frame:CGRectMake((_width/2-53)/2+_width/2, 13,53, 13)];
    
    _verticalView =[[UIView alloc]initWithFrame:CGRectMake((_width -1)/2, 10, 0.5, 19)];
    _verticalView.backgroundColor =[DWTools colorWithHexString:@"#ffffff"];
    _verticalView.alpha =0.3;
    [self addSubview:_verticalView];
    
    _horizontallyView =[[UIView alloc]init];
    _horizontallyView.backgroundColor =[DWTools colorWithHexString:@"#ffffff"];
  //  _horizontallyView.alpha =0.4;
    [self addSubview:_horizontallyView];
    [_horizontallyView mas_remakeConstraints:^(MASConstraintMaker *make) {
      
        make.top.mas_equalTo(_videoBtn.mas_bottom).offset(4.5);
        make.left.right.mas_equalTo(_videoBtn);
        make.height.mas_equalTo(1);
        
    }];
    
    
    
}



- (void)videoPlay:(UIButton *)sender{
    
    _audioBtn.selected =NO;
    _videoBtn.selected =YES;
    
    _index = 0;
    
    [self remakeConstraints:sender];
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoBottomViewPlayAction)]) {
        
        [_delegate videoBottomViewPlayAction];
        
    }
}



- (void)audioPlay:(UIButton *)sender{
    
    _audioBtn.selected =YES;
    _videoBtn.selected =NO;
    
    _index = 1;
    
    [self remakeConstraints:sender];
    
    if (_delegate && [_delegate respondsToSelector:@selector(audioBottomViewPlayAction)]) {
        
        [_delegate audioBottomViewPlayAction];
        
    }
    
    
}

- (void)remakeConstraints:(UIButton *)sender{
    
    [_horizontallyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(sender.mas_bottom).offset(4.5);
        make.left.right.mas_equalTo(sender);
        make.height.mas_equalTo(1);
        
    }];
    
    
}

- (UIButton *)creatButtonWithTitle:(NSString *)title selector:(SEL )selector frame:(CGRect )frame{
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font =[UIFont systemFontOfSize:12];
  //  btn.alpha =0.5;
    btn.frame =frame;
    [self addSubview:btn];
    
    return btn;
    
}


@end
