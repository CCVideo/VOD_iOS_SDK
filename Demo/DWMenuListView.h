//
//  DWMenuListView.h
//  Demo
//
//  Created by zwl on 2018/11/13.
//  Copyright © 2018 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DWMenuListViewDidSelectBlock)(NSInteger index);

@interface DWMenuListView : UIView

-(instancetype)initWithRelativeView:(UIView *)relativeView AndMenuList:(NSArray *)menuList;

-(void)show;
-(void)dismiss;

@property(nonatomic,copy) DWMenuListViewDidSelectBlock didSelectBlock;

@end

NS_ASSUME_NONNULL_END
