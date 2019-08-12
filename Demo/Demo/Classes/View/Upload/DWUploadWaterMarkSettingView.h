//
//  DWUploadWaterMarkSettingView.h
//  Demo
//
//  Created by zwl on 2019/8/1.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWUploadWaterMarkSettingView : UIView

@property(nonatomic,strong,readonly)NSDictionary * waterMarkParams;

-(void)show;

@end

NS_ASSUME_NONNULL_END
