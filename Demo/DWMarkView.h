//
//  DWMarkView.h
//  Demo
//
//  Created by luyang on 2018/1/12.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWVideoMarkModel;

@interface DWMarkView : UIView

@property (nonatomic,strong)DWVideoMarkModel *markModel;
@property (nonatomic,assign,readonly)CGFloat width;



@end
