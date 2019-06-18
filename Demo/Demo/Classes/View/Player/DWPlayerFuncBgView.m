//
//  DWPlayerFuncBgView.m
//  Demo
//
//  Created by zwl on 2019/4/16.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWPlayerFuncBgView.h"

@interface DWPlayerFuncBgView ()

@property(nonatomic,strong)UIImageView * bgImageView;

@end

@implementation DWPlayerFuncBgView

-(void)setIsBottom:(BOOL)isBottom
{
    _isBottom = isBottom;

    if (isBottom) {
        self.bgImageView.image = [[UIImage imageNamed:@"icon_player_func_bottom_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    }else{
        self.bgImageView.image = [[UIImage imageNamed:@"icon_player_func_top_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    }
}

-(UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc]init];
        [self addSubview:_bgImageView];
        [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _bgImageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
