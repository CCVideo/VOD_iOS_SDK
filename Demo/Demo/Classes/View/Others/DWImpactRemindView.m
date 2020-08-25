//
//  DWImpactRemindView.m
//  Demo
//
//  Created by zwl on 2020/8/18.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import "DWImpactRemindView.h"

@interface DWImpactRemindView ()

@property(nonatomic,strong)UILabel * label;

@end

@implementation DWImpactRemindView

- (instancetype)init
{
    self = [super init];
    if (self) {
    
        self.hidden = YES;
        self.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.9];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3;
        
        self.label = [[UILabel alloc]init];
        self.label.text = @"前方高能预警";
        self.label.font = TitleFont(14);
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
    }
    return self;
}

-(void)show
{
    if (!self.hidden) {
        return;
    }
    
    self.hidden = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self) {
            self.hidden = YES;
        }
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
