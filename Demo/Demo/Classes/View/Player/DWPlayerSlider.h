//
//  DWPlayerSlider.h
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWPlayerSlider : UISlider

@property(nonatomic,assign)CGFloat bufferValue;

//切换屏幕状态时，重置子视图frame
-(void)resetSubViewFrame;

@end

@interface DWPlayerSliderBufferView : UIView


@end

NS_ASSUME_NONNULL_END
