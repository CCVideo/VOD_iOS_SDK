//
//  DWSettingFuncButton.m
//  Demo
//
//  Created by zwl on 2019/4/22.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWSettingFuncButton.h"

@implementation DWSettingFuncButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake((self.frame.size.width - 30) / 2.0, 0, 30, 30);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 30 + 3, self.frame.size.width, 13);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
