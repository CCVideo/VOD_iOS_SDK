//
//  DWVodPlayBottomView.h
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWVodPlayBottomViewDelegate <NSObject>

-(void)vodPlayBottomViewDownloadButtonAction;
-(void)vodPlayBottomViewSureButtonAction;
-(void)vodPlayBottomViewCancelButtonAction;

@end

@interface DWVodPlayBottomView : UIView

@property(nonatomic,weak) id <DWVodPlayBottomViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
