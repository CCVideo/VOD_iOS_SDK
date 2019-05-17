//
//  DWNetworkMonitorViewController.h
//  Demo
//
//  Created by zwl on 2018/11/13.
//  Copyright © 2018 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWNetworkMonitorViewController : UIViewController

-(instancetype)initWithVideoId:(NSString *)vid;

@property(nonatomic,copy)NSString * currentPlayurl;

@end

NS_ASSUME_NONNULL_END
