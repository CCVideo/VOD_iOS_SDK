//
//  DWFeedBackView.h
//  Demo
//
//  Created by luyang on 2018/2/11.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWQuestionModel.h"

typedef void(^FeedBackBlock)();

@interface DWFeedBackView : UIView

@property (nonatomic,copy)FeedBackBlock feedBackBlock;

- (void)showResult:(DWQuestionModel *)model withRight:(BOOL )right;

- (void)didFeedBackBlock:(FeedBackBlock )block;

@end
