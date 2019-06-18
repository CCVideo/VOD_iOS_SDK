//
//  DWQuestionView.m
//  CustomDemo
//
//  Created by luyang on 2018/2/9.
//  Copyright © 2018年 Myself. All rights reserved.
//

#import "DWQuestionView.h"
#import "DWQuestionCell.h"
#import "DWDifferentCell.h"


@interface DWQuestionView()<UITableViewDelegate,UITableViewDataSource>{
    
    UIButton *skipBtn;
    UILabel *questionLabel;
}

@property(nonatomic,strong)UIView * maskView;
@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *btnArray;
@property(nonatomic,strong)NSMutableArray *answerArray;
@property(nonatomic,strong)NSMutableArray *selectArray;

@property(nonatomic,strong)UILabel *toastLabel;
@property(nonatomic,assign)BOOL isRight;

@end

@implementation DWQuestionView

-(instancetype)init
{
    if (self == [super init])
    {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(@0);
            make.bottom.and.right.equalTo(@0);
        }];
        
        self.layer.cornerRadius =8/2;
        self.layer.masksToBounds =YES;
        [self loadSubviews];
    }
    
    return self;
}

#pragma mark - action
-(void)commitAction
{
    
    if (!self.selectArray.count) {
        //提示选择答案
        self.toastLabel.hidden =NO;
        
        return;
    }
    
    NSMutableArray *answerIdsArray =[NSMutableArray array];
    [self.selectArray enumerateObjectsUsingBlock:^(DWVideoQuestionAnswerModel *answerModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [answerIdsArray addObject:answerModel.answerId];
        
    }];
    
    //答案是否正确
    if (self.selectArray.count !=self.answerArray.count) {
        
        if (_questionBlock) {
            
            _questionBlock(answerIdsArray,_isRight);
        }
        
        return;
    }
    
    BOOL right =[self verifyAnswer];
    if (_questionBlock) {
        _questionBlock(answerIdsArray,right);
    }
   
}

//校验答案
-(BOOL)verifyAnswer
{
    [self.selectArray enumerateObjectsUsingBlock:^(DWVideoQuestionAnswerModel *answerModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (answerModel.isRight) {
            self.isRight =YES;
        }else{
            self.isRight =NO;
            *stop =YES;
        }
        
    }];
    return _isRight;
}

-(void)skipAction
{
    //能否跳过
    if (!_questionModel.jump) {
        self.toastLabel.hidden =NO;
    }else{
        _questionModel.isShow = NO;
        if (_skipBlock) {
            _skipBlock();
        }
    }
}

-(void)didQuestionBlock:(QuestionBlock )block
{
    _questionBlock =block;
}

-(void)didSkipBlock:(SkipBlock )block
{
    _skipBlock =block;
}

-(void)setQuestionModel:(DWVideoQuestionModel *)questionModel
{
    _questionModel =questionModel;
    if (_questionModel.jump) {
        [skipBtn setBackgroundColor:[DWTools colorWithHexString:@"#419bf9"]];
    }
    
    [self.tableView reloadData];
}

//返回高度
-(CGSize)heightWithWidth:(CGFloat)width andFont:(CGFloat )font andLabelText:(NSString *)text
{
    NSDictionary *dict =[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:font] forKey:NSFontAttributeName];
    CGRect rect=[text boundingRectWithSize:CGSizeMake(width,CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    
    return rect.size;
}

-(NSInteger)heightWithText:(NSString *)text
{
    if (!text) {
        return 0;
    }
    
    //1、创建一个可变的属性字符串
//    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    //2、匹配字符串
    NSString *regexHttp =@"http(s)?://([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regexHttp options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return 0;
    }
    
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    return resultArray.count;
}

#pragma mark - delegagte
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _questionModel.answers.count + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //视情况处理
    if (indexPath.row ==0) {
        //看有没有图片
        NSInteger count =[self heightWithText:_questionModel.content];
        if (count >0) {
            return count*60+60+10;
        }else{
            //计算高度
            CGSize size =[self heightWithWidth:self.tableView.frame.size.width andFont:14 andLabelText:_questionModel.content];
            return 15 + 16 + 21 + size.height+10;
        }
    }else{
        DWVideoQuestionAnswerModel *answerModel = _questionModel.answers[indexPath.row-1];
        NSInteger answerCount = [self heightWithText:answerModel.content];
        if (answerCount > 0) {
            return answerCount*60+10;
        }else{
            return 60+10;
        }
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellIdentifier";
    static NSString *CellDifferent =@"cellDifferent";
    
    if (indexPath.row ==0) {
        
        DWDifferentCell *differentCell =[tableView dequeueReusableCellWithIdentifier:CellDifferent];
        if (!differentCell) {
            differentCell =[[DWDifferentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellDifferent];
            differentCell.selectionStyle =  UITableViewCellSelectionStyleNone;
        }

        differentCell.questionModel =_questionModel;
        return differentCell;
    }else{
        DWQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DWQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        }
        //首先要清空答案数组
        [self.answerArray removeAllObjects];

        for (DWVideoQuestionAnswerModel *model in _questionModel.answers) {
            if (model.isRight) {
                [self.answerArray addObject:model];
            }
        }
        BOOL multipleSelect;
        if (self.answerArray.count >1) {
            multipleSelect =YES;//多选
        }else{
            multipleSelect =NO;//单选
        }
       
        DWVideoQuestionAnswerModel *answerModel =_questionModel.answers[indexPath.row-1];
        [cell updateQuestion:answerModel withMultipleSelect:multipleSelect];
        [cell didSelectBlock:^(UIButton *btn,BOOL select) {
            if (select) {
                //单选
                if (!multipleSelect) {
                    UIButton *lastBtn =[self.btnArray firstObject];
                    lastBtn.selected =NO;
                    [self.btnArray removeAllObjects];
                    [self.selectArray removeAllObjects];
                }
                self.toastLabel.hidden =YES;
                [self.btnArray addObject:btn];
                [self.selectArray addObject:answerModel];
            }else{
                [self.btnArray removeObject:btn];
                [self.selectArray removeObject:answerModel];
            }
        }];
        return cell;
    }
    return nil;
}

#pragma mark - init
- (void)loadSubviews
{
    [self addSubview:self.maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.showsVerticalScrollIndicator =YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@300);
        make.height.equalTo(@(310 - 90 / 2));
    }];
    
    //尾部视图
    UIView *footerView =[[UIView alloc]init];
    footerView.backgroundColor =[DWTools colorWithHexString:@"#f0f8ff"];
    [self addSubview:footerView];
    [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.left.equalTo(self.tableView);
        make.top.equalTo(self.tableView.mas_bottom);
        make.height.equalTo(@45);
    }];
    
    UIButton *commitBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn setBackgroundColor:[DWTools colorWithHexString:@"#419bf9"]];
    [footerView addSubview:commitBtn];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView.mas_centerX).offset(25);
        make.width.equalTo(@90);
        make.height.equalTo(@30);
        make.bottom.equalTo(footerView.mas_bottom).offset(-15/2);
    }];
    
    
    skipBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [skipBtn addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    [skipBtn setBackgroundColor:[DWTools colorWithHexString:@"#9198a3"]];
    [footerView addSubview:skipBtn];
    [skipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(footerView.mas_centerX).offset(-25);
        make.width.height.top.mas_equalTo(commitBtn);
    }];
    
    _toastLabel =[[UILabel alloc]init];
    _toastLabel.text =@"请选择答案";
    _toastLabel.textColor =[UIColor whiteColor];
    _toastLabel.font =[UIFont systemFontOfSize:13];
    _toastLabel.textAlignment =NSTextAlignmentCenter;
    _toastLabel.backgroundColor =[UIColor colorWithRed:102/255 green:102/255 blue:102/255 alpha:0.5];
    _toastLabel.layer.cornerRadius =2;
    _toastLabel.layer.masksToBounds =YES;
    _toastLabel.hidden =YES;
    [self addSubview:_toastLabel];
    [_toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(262/2);
        make.height.mas_equalTo(80/2);
    }];
}

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
    }
    return _maskView;
}

- (NSMutableArray *)answerArray
{
    if (!_answerArray) {
        _answerArray =[NSMutableArray array];
    }
    return _answerArray;
}


- (NSMutableArray *)selectArray
{
    if(!_selectArray){
        _selectArray =[NSMutableArray array];
    }
    return _selectArray;
}

- (NSMutableArray *)btnArray
{
    if (!_btnArray) {
        _btnArray =[NSMutableArray array];
    }
    return _btnArray;
}

@end

