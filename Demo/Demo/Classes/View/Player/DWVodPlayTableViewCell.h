//
//  DWVodPlayTableViewCell.h
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DWVodPlayTableViewCell : UITableViewCell

-(void)setVodModel:(DWVodModel *)vodModel AndPlaying:(BOOL)isPlaying;

//@property(nonatomic,strong)DWVodModel * vodModel;

@end

NS_ASSUME_NONNULL_END
