//
//  DWFeedBackView.h
//  Demo
//
//  Created by luyang on 2018/2/11.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWQuestionModel.h"

typedef void(^FeedBackResumeBlock)();
typedef void(^FeedBackBackBlock)();

@interface DWFeedBackView : UIView

- (void)showResult:(DWQuestionModel *)model withRight:(BOOL )right;

@property(nonatomic,copy)FeedBackResumeBlock resumeBlock;
@property(nonatomic,copy)FeedBackBackBlock backBlock;

@end
