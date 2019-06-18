//
//  DWVodPlayBottomView.m
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWVodPlayBottomView.h"

@interface DWVodPlayBottomView ()

@property(nonatomic,strong)UIButton * downloadButton;
@property(nonatomic,strong)UIButton * sureButton;
@property(nonatomic,strong)UIButton * cancelButton;

@end

@implementation DWVodPlayBottomView

-(instancetype)init
{
    if (self == [super init]) {
        
      
        [self addSubview:self.downloadButton];
        [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@35);
            make.right.equalTo(@(-35));
            make.height.equalTo(@(_downloadButton.layer.cornerRadius * 2));
            make.centerY.equalTo(self);
        }];
        
        CGFloat buttonWidth = (ScreenWidth - 50 * 2 - 15) / 2.0;
        self.sureButton.hidden = YES;
        [self addSubview:self.sureButton];
        [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@50);
            make.centerY.equalTo(self);
            make.height.equalTo(@(_sureButton.layer.cornerRadius * 2));
            make.width.equalTo(@(buttonWidth));
        }];
        
        self.cancelButton.hidden = YES;
        [self addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-50));
            make.centerY.equalTo(self);
            make.height.equalTo(@(_cancelButton.layer.cornerRadius * 2));
            make.width.equalTo(@(buttonWidth));
        }];
        
    }
    return self;
}

#pragma mark - action
-(void)downloadButtonAction
{
    self.downloadButton.hidden = YES;
    self.sureButton.hidden = NO;
    self.cancelButton.hidden = NO;
    
    if ([_delegate respondsToSelector:@selector(vodPlayBottomViewDownloadButtonAction)]) {
        [_delegate vodPlayBottomViewDownloadButtonAction];
    }
}

-(void)sureButtonAction
{
    self.downloadButton.hidden = NO;
    self.sureButton.hidden = YES;
    self.cancelButton.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(vodPlayBottomViewSureButtonAction)]) {
        [_delegate vodPlayBottomViewSureButtonAction];
    }
}

-(void)cancelButtonAction
{
    self.downloadButton.hidden = NO;
    self.sureButton.hidden = YES;
    self.cancelButton.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(vodPlayBottomViewCancelButtonAction)]) {
        [_delegate vodPlayBottomViewCancelButtonAction];
    }
}

#pragma mark - init
-(UIButton *)downloadButton
{
    if (!_downloadButton) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        _downloadButton.titleLabel.font = TitleFont(15);
        [_downloadButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_downloadButton setBackgroundImage:[[UIColor whiteColor] createImage] forState:UIControlStateNormal];
        _downloadButton.layer.masksToBounds = YES;
        _downloadButton.layer.cornerRadius = 20;
        _downloadButton.layer.borderWidth = 1;
        _downloadButton.layer.borderColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0].CGColor;
        [_downloadButton addTarget:self action:@selector(downloadButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

-(UIButton *)sureButton
{
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:@"确认下载" forState:UIControlStateNormal];
        _sureButton.titleLabel.font = TitleFont(15);
        [_sureButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_sureButton setBackgroundImage:[[UIColor whiteColor] createImage] forState:UIControlStateNormal];
        _sureButton.layer.masksToBounds = YES;
        _sureButton.layer.cornerRadius = 20;
        _sureButton.layer.borderWidth = 1;
        _sureButton.layer.borderColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0].CGColor;
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

-(UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = TitleFont(15);
        [_cancelButton setTitleColor:TitleColor_51 forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[[UIColor colorWithRed:243/255.0 green:244/255.0 blue:245/255.0 alpha:1] createImage] forState:UIControlStateNormal];
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.cornerRadius = 20;
        [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
