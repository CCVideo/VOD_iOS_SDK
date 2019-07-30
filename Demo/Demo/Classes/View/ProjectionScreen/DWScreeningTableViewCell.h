//
//  DWScreeningTableViewCell.h
//  Demo
//
//  Created by zwl on 2019/7/9.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWUPnPDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWScreeningTableViewCell : UITableViewCell

@property(nonatomic,strong)DWUPnPDevice * device;

@end

NS_ASSUME_NONNULL_END
