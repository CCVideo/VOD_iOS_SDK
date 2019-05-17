//
//  DWBatchDownloadChooseView.h
//  Demo
//
//  Created by zwl on 2019/1/23.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DWBatchDownloadChooseViewFinishBlock)(NSArray * videoIds);

@interface DWBatchDownloadChooseView : UIView

@property(nonatomic,copy)DWBatchDownloadChooseViewFinishBlock finishBlock;

-(instancetype)initWithVideoIds:(NSArray *)videoIds;

-(void)show;

@end

NS_ASSUME_NONNULL_END
