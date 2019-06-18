//
//  DWMemberGeneralButton.m
//  Demo
//
//  Created by zwl on 2019/4/12.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWMemberGeneralButton.h"

@implementation DWMemberGeneralButton

-(instancetype)initWithTitle:(NSString *)buttonTitle
{
    if (self == [super init]) {
        [self setTitle:buttonTitle forState:UIControlStateNormal];
        self.titleLabel.font = TitleFont(15);
        [self setTitleColor:TitleColor_51 forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0] forState:UIControlStateSelected];
        [self setBackgroundImage:[[UIColor colorWithRed:243/255.0 green:244/255.0 blue:245/255.0 alpha:1] createImage] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIColor whiteColor] createImage] forState:UIControlStateSelected];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.layer.borderColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0].CGColor;
    }else{
        self.layer.borderColor = [UIColor whiteColor].CGColor;
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
