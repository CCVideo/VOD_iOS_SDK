//
//  DWAdShouView.h
//  Demo
//
//  Created by zwl on 2019/4/4.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWAdShouView;

NS_ASSUME_NONNULL_BEGIN

@protocol DWAdShouViewDelegate <NSObject>

@optional
-(void)adShowPlayDidFinish:(DWAdShouView*)adShowView AndAdType:(NSInteger)type;
-(void)adShowPlay:(DWAdShouView*)adShowView DidScreenRotate:(BOOL)isFull;

@end

@interface DWAdShouView : UIView

-(void)playAdVideo:(DWVodAdInfoModel *)adInfoModel;

//横竖屏切换
-(void)screenRotate:(BOOL)isFull;

//完成广告
-(void)adFinish;

@property(nonatomic,weak) id <DWAdShouViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
