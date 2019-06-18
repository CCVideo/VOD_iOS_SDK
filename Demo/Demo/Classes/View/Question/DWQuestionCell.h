//
//  DWQuestionCell.h
//  Demo
//
//  Created by luyang on 2018/2/9.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectBlock)(UIButton *btn,BOOL select);

@interface DWQuestionCell : UITableViewCell

@property (nonatomic,strong)DWVideoQuestionAnswerModel *answerModel;

@property (nonatomic,copy)SelectBlock selectBlock;
@property (nonatomic,assign)NSInteger row;

- (void)didSelectBlock:(SelectBlock )block;
- (void)updateQuestion:(DWVideoQuestionAnswerModel *)answerModel withMultipleSelect:(BOOL )multipleSelect;



@end
