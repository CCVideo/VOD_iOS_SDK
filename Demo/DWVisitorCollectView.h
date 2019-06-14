//
//  DWVisitorCollectView.h
//  Demo
//
//  Created by zwl on 2019/4/23.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWVisitorCollectViewDelegate <NSObject>

-(void)visitorCollectDidCommit:(NSString *)message;

-(void)visitorCollectDidJump;

-(void)visitorCollectDidCancel;

@end

@interface DWVisitorCollectView : UIView

@property(nonatomic,weak) id<DWVisitorCollectViewDelegate> delegate;

-(instancetype)initWithVisitorDict:(NSDictionary *)visitorDict;

-(void)screenRotate:(BOOL)isFull;

@end

@interface DWVisitorCollectViewTableViewCell : UITableViewCell

@property(nonatomic,strong)UITextField * textField;

@property(nonatomic,strong)NSDictionary * messageDict;

@end

NS_ASSUME_NONNULL_END
