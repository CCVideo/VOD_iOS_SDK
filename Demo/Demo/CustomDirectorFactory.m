//
//  CustomDirectorFactory.m
//  MD360Player4iOS
//
//  Created by luyang on 2017/4/24.
//  Copyright © 2017年 ashqal. All rights reserved.
//

#import "CustomDirectorFactory.h"




@implementation CustomDirectorFactory

- (DW360Director*) createDirector:(int) index{
    DW360Director* director = [[DW360Director alloc]init];
    switch (index) {
        case 1:
            [director setEyeX:-2.0f];
            [director setLookX:-2.0f];
            break;
        default:
            break;
    }
    return director;
}

@end
