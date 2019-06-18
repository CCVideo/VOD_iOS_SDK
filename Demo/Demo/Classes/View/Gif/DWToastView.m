//
//  DWToastView.m
//  Demo
//
//  Created by luyang on 2017/9/26.
//  Copyright © 2017年 com.bokecc.www. All rights reserved.
//

#import "DWToastView.h"

//Toast背景颜色
#define ToastBackgroundColor [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75]

@interface DWToastView()

@property (nonatomic,strong)UILabel *textLabel;

@property (nonatomic,strong)UIImageView *imageView;

@end

@implementation DWToastView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self =[super initWithFrame:frame];
    
    if (self) {
        
        [self loadSubviews];
    }

    return self;
    
}

- (void)loadSubviews{
    
    NSString *text = @"录制3秒,即可分享";
    UIFont *font = [UIFont systemFontOfSize:13];
    NSDictionary * dict=[NSDictionary dictionaryWithObject: font forKey:NSFontAttributeName];
    CGRect rect=[text boundingRectWithSize:CGSizeMake(250,CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];

    _imageView =[[UIImageView alloc]init];
    _imageView.layer.cornerRadius = 3.5;
    _imageView.layer.masksToBounds =YES;
    _imageView.backgroundColor =[UIColor orangeColor];
    [self addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.centerY.equalTo(self);
        make.width.and.height.equalTo(@7);
    }];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = font;
    _textLabel.text = text;
    _textLabel.numberOfLines = 0;
    [self addSubview:_textLabel];
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imageView.mas_right).offset(6);
        make.right.equalTo(@0);
        make.centerY.equalTo(self);
        make.height.equalTo(self);
    }];
  
    self.backgroundColor =ToastBackgroundColor;
    self.layer.cornerRadius =15;
    self.layer.masksToBounds =YES;
 
}

- (void)changeTextAndColor
{
    _textLabel.text =@"点击停止录制,即可分享";
    _imageView.backgroundColor =[UIColor greenColor];
    
    self.frame = CGRectMake(0, self.frame.origin.y, 180, 30);
    self.center = CGPointMake(self.superview.center.x, self.center.y);
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)recoverTextAndColor
{
    _textLabel.text = @"录制3秒,即可分享";
    _imageView.backgroundColor =[UIColor orangeColor];
    
    self.frame = CGRectMake(0, self.frame.origin.y, 150, 30);
    self.center = CGPointMake(self.superview.center.x, self.center.y);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
