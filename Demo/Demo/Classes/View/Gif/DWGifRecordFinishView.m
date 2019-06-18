//
//  DWGifRecordFinishView.m
//  Demo
//
//  Created by zwl on 2019/5/20.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWGifRecordFinishView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DWGifRecordFinishView ()

@property(nonatomic,strong)UIButton * cancelButton;
@property(nonatomic,strong)UIImageView * gifFirshFrameImageView;
@property(nonatomic,strong)UILabel * successLabel;
@property(nonatomic,strong)UIButton * saveButton;
@property(nonatomic,strong)UILabel * saveLabel;

@property(nonatomic,strong)NSURL * filePath;

@end

@implementation DWGifRecordFinishView

-(instancetype)initWithFilePath:(NSURL *)filePath
{
    if (self == [super init]) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        [self addSubview:self.cancelButton];
        [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@30);
            make.top.equalTo(@60);
            make.right.equalTo(@(-10));
        }];
        
        [self addSubview:self.gifFirshFrameImageView];
        [_gifFirshFrameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@345);
            make.height.equalTo(@194);
            make.top.equalTo(@57);
            make.centerX.equalTo(self);
        }];
        
        [self addSubview:self.successLabel];
        [_successLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.gifFirshFrameImageView);
            make.top.equalTo(self.gifFirshFrameImageView.mas_bottom).offset(10);
            make.height.equalTo(@19);
            make.width.equalTo(@100);
        }];
        
        [self addSubview:self.saveButton];
        [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.gifFirshFrameImageView);
            make.width.and.height.equalTo(@45);
            make.top.equalTo(self.successLabel.mas_bottom).offset(14);
        }];
        
        [self addSubview:self.saveLabel];
        [_saveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.gifFirshFrameImageView);
            make.top.equalTo(self.saveButton.mas_bottom).offset(8);
            make.height.equalTo(@19);
            make.width.equalTo(@100);
        }];
        
        self.filePath = filePath;
        
        //获取gif第一帧
        self.gifFirshFrameImageView.image = [DWTools getImageFromGIFFilePath:[self.filePath absoluteString]];
    }
    return self;
}

#pragma mark - action
-(void)cancelAction
{
    [_delegate GifRecordFinishEndShow:self];
}

-(void)saveButtonAction
{
    self.saveButton.enabled = NO;

    NSData * data = [NSData dataWithContentsOfURL:self.filePath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
        self.saveButton.enabled = YES;

        [@"gif保存成功" showAlert];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_delegate GifRecordFinishEndShow:self];
        });
    }] ;
    
}

#pragma mark - lazy
-(UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _cancelButton.layer.cornerRadius = 15;
        _cancelButton.layer.masksToBounds = YES;
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.backgroundColor =[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
    }
    return _cancelButton;
}

-(UIImageView *)gifFirshFrameImageView
{
    if (!_gifFirshFrameImageView) {
        _gifFirshFrameImageView = [[UIImageView alloc]init];
        _gifFirshFrameImageView.layer.borderWidth = 1;
        _gifFirshFrameImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _gifFirshFrameImageView;
}

-(UILabel *)successLabel
{
    if (!_successLabel) {
        _successLabel = [[UILabel alloc]init];
        _successLabel.text = @"截取成功";
        _successLabel.textColor = [UIColor whiteColor];
        _successLabel.textAlignment = NSTextAlignmentCenter;
        _successLabel.font = TitleFont(13);
    }
    return _successLabel;
}

-(UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setBackgroundImage:[UIImage imageNamed:@"icon_gif_save.png"] forState:UIControlStateNormal];
        _saveButton.layer.masksToBounds = YES;
        _saveButton.layer.borderWidth = 0.5;
        _saveButton.layer.cornerRadius = 22.5;
        _saveButton.layer.borderColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.5].CGColor;
        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

-(UILabel *)saveLabel
{
    if (!_saveLabel) {
        _saveLabel = [[UILabel alloc]init];
        _saveLabel.text = @"保存本地";
        _saveLabel.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _saveLabel.textAlignment = NSTextAlignmentCenter;
        _saveLabel.font = TitleFont(13);
    }
    return _saveLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
