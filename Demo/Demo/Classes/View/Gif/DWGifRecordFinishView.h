//
//  DWGifRecordFinishView.h
//  Demo
//
//  Created by zwl on 2019/5/20.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWGifRecordFinishView;

NS_ASSUME_NONNULL_BEGIN

@protocol DWGifRecordFinishViewDelegate <NSObject>

-(void)GifRecordFinishEndShow:(DWGifRecordFinishView *)recordFinishView;

@end

@interface DWGifRecordFinishView : UIView

-(instancetype)initWithFilePath:(NSURL *)filePath;

@property(nonatomic,weak) id <DWGifRecordFinishViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
