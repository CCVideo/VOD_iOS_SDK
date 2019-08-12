//
//  DWUploadWaterMarkSettingView.m
//  Demo
//
//  Created by zwl on 2019/8/1.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWUploadWaterMarkSettingView.h"

@interface DWUploadWaterMarkSettingView ()

@property(nonatomic,strong)UIView * maskView;
@property(nonatomic,strong)UIView * bgView;

@end

@implementation DWUploadWaterMarkSettingView

-(instancetype)init
{
    if (self == [super init]) {
        
        [self initUI];
        
    }
    return self;
}

-(void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.top.and.bottom.equalTo(@0);
    }];
}

-(void)dismiss
{
    [self removeFromSuperview];
}

-(NSDictionary *)waterMarkParams
{
    NSDictionary * retDict = @{@"text": ((UITextField *)[self.bgView viewWithTag:100 + 0]).text,
                               @"corner":[NSNumber numberWithInteger:[((UITextField *)[self.bgView viewWithTag:100 + 1]).text integerValue]],
                               @"offsetX":[NSNumber numberWithInteger:[((UITextField *)[self.bgView viewWithTag:100 + 2]).text integerValue]],
                               @"offsetY":[NSNumber numberWithInteger:[((UITextField *)[self.bgView viewWithTag:100 + 3]).text integerValue]],
                               @"fontFamily":[NSNumber numberWithInteger:[((UITextField *)[self.bgView viewWithTag:100 + 4]).text integerValue]],
                               @"fontSize":[NSNumber numberWithInteger:[((UITextField *)[self.bgView viewWithTag:100 + 5]).text integerValue]],
                               @"fontColor":((UITextField *)[self.bgView viewWithTag:100 + 6]).text,
                               @"fontAlpha":[NSNumber numberWithInteger:[((UITextField *)[self.bgView viewWithTag:100 + 7]).text integerValue]]};
    return retDict;
}

#pragma mark - init
-(void)initUI
{
    UITapGestureRecognizer * dismissTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [self addGestureRecognizer:dismissTap];
    
    self.maskView = [[UIView alloc]init];
    self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
    [self addSubview:self.maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    CGFloat textFieldHeight = 44;
    self.bgView = [[UIView alloc]init];
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(@100);
        make.width.equalTo(@(ScreenWidth - 20));
        make.height.equalTo(@(textFieldHeight * 8));
    }];
    
    NSArray * pTitles = @[@"水印内容",@"水印位置(0,左上 1右上 2左下 3右下，默认3)",@"X轴偏移量(要求大于0，默认值5)",@"Y轴偏移量(要求大于0，默认值5)",@"字体类型(0,微软雅黑 1宋体 2黑体，默认0)",@"字体大小([0-100]，默认12)",@"字体颜色(如FFFFFF)",@"字体透明度([0-100],默认100，100为不透明)"];
    NSArray * titles = @[@"",@"0",@"5",@"5",@"0",@"12",@"FFFFFF",@"100"];

    for (int i = 0; i < pTitles.count; i++) {
        UITextField * textField = [[UITextField alloc]init];
        textField.backgroundColor = [UIColor whiteColor];
        textField.placeholder = [pTitles objectAtIndex:i];
        textField.font = TitleFont(14);
        textField.textColor = TitleColor_51;
        textField.tag = 100 + i;
        textField.text = [titles objectAtIndex:i];
        [self.bgView addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.right.equalTo(@(-16));
            make.top.equalTo(@(textFieldHeight * i));
            make.height.equalTo(@(textFieldHeight));
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
