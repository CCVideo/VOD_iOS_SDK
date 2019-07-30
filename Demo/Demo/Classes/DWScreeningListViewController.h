//
//  DWScreeningListViewController.h
//  Demo
//
//  Created by zwl on 2019/7/9.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWBaseViewController.h"
@class DWUPnPDevice;

NS_ASSUME_NONNULL_BEGIN

@protocol DWScreeningListViewControllerDelegate <NSObject>

-(void)screeningReturnButtonAction;

-(void)screeningListDidSelectAction:(DWUPnPDevice *)device AndPlayUrl:(NSString *)playUrl;

@end

@interface DWScreeningListViewController : DWBaseViewController

@property(nonatomic,weak) id <DWScreeningListViewControllerDelegate> delegate;

@property(nonatomic,copy)NSString * playUrl;

@end

NS_ASSUME_NONNULL_END
