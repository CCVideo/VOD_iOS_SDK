//
//  DWVodPlayViewController.h
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWVodPlayViewController : DWBaseViewController

@property(nonatomic,strong)DWVodModel * vodModel;//当前播放
@property(nonatomic,strong)NSArray * vidoeList;//选集列表

@property(nonatomic,assign)BOOL landScape;//是否横屏

@end

NS_ASSUME_NONNULL_END
