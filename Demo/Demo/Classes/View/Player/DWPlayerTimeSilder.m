//
//  DWPlayerTimeSilder.m
//  BrightnessVolumeView
//
//  Created by zwl on 2020/3/12.
//  Copyright © 2020 admin. All rights reserved.
//

#import "DWPlayerTimeSilder.h"

@interface DWPlayerTimeSilder ()

@property(nonatomic,strong)UILabel * timeLabel;

@property(nonatomic,strong)UIView * progressView;

@end

@implementation DWPlayerTimeSilder

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.timeLabel = [[UILabel alloc]init];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:0.8];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(@0);
            make.width.equalTo(self);
            make.height.equalTo(@12);
        }];
        
        UIView * bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        bgView.layer.masksToBounds = YES;
        bgView.layer.cornerRadius = 1.5;
        [self addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.equalTo(@0);
            make.width.equalTo(self);
            make.height.equalTo(@4);
        }];
        
        self.progressView = [[UIView alloc]init];
        self.progressView.backgroundColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:0.8];
        [bgView addSubview:self.progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.height.equalTo(bgView);
            make.width.equalTo(@0);
        }];
        
    }
    return self;
}

-(void)setDuration:(CGFloat)duration
{
    _duration = duration;
        
    NSString * time = [NSString stringWithFormat:@"00:00 / %@", [DWTools formatSecondsToString:duration]];
    self.timeLabel.text = time;
    
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@0);
    }];
}

-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    NSString * time = [NSString stringWithFormat:@"%@ / %@",[DWTools formatSecondsToString:self.duration * progress],[DWTools formatSecondsToString:self.duration]];
    self.timeLabel.text = time;
    
    //修改进度
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.frame.size.width * progress));
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
