//
//  DWScreeningBgView.h
//  Demo
//
//  Created by zwl on 2019/7/10.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWUPnPDevice;

NS_ASSUME_NONNULL_BEGIN

@protocol DWScreeningBgViewDelegate <NSObject>

-(void)screeningBgViewCloseAction;

@end

@interface DWScreeningBgView : UIView

@property(nonatomic,weak)id <DWScreeningBgViewDelegate> delegate;

@property(nonatomic,assign)CGFloat seekTime;

@property(nonatomic,strong)NSString * title;

-(instancetype)initWithDevice:(DWUPnPDevice *)device AndPlayUrl:(NSString *)playUrl;

-(void)screenRotate:(BOOL)isFull;

@end

NS_ASSUME_NONNULL_END
