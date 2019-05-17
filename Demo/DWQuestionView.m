//
//  DWQuestionView.m
//  CustomDemo
//
//  Created by luyang on 2018/2/9.
//  Copyright © 2018年 Myself. All rights reserved.
//

#import "DWQuestionView.h"
#import "DWQuestionCell.h"
#import "DWAnswerModel.h"
#import "DWDifferentCell.h"


@interface DWQuestionView()<UITableViewDelegate,UITableViewDataSource>{
    
    UIButton *skipBtn;
    UILabel *questionLabel;
}

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,assign)CGFloat tableViewWidth;
@property (nonatomic,assign)CGFloat tableViewHeight;

@property (nonatomic,strong)NSMutableArray *btnArray;
@property (nonatomic,strong)NSMutableArray *answerArray;
@property (nonatomic,strong)NSMutableArray *selectArray;

@property (nonatomic,strong)UILabel *toastLabel;

@property (nonatomic,assign)BOOL isRight;

@end

@implementation DWQuestionView

- (NSMutableArray *)answerArray{
    
    if (!_answerArray) {
        
        _answerArray =[NSMutableArray array];
    }
    
    return _answerArray;
}


- (NSMutableArray *)selectArray{
    
    if(!_selectArray){
        
        _selectArray =[NSMutableArray array];
        
    }
    
    return _selectArray;
}

- (NSMutableArray *)btnArray{
    
    if (!_btnArray) {
        
        _btnArray =[NSMutableArray array];
    }
    
    return _btnArray;
}

- (instancetype )initWithFrame:(CGRect)frame{
    
    self =[super initWithFrame:frame];
    if (self) {
        
        self.tableViewWidth =frame.size.width;
        self.tableViewHeight =frame.size.height;
        self.layer.cornerRadius =8/2;
        self.layer.masksToBounds =YES;
        [self loadSubviews];
    }
    
    return self;
}

- (void)loadSubviews{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,self.tableViewWidth,self.tableViewHeight-90/2) style:UITableViewStylePlain];
   
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
  
   // self.tableView.allowsMultipleSelection =YES;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.showsVerticalScrollIndicator =YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    
    //尾部视图
    UIView *footerView =[[UIView alloc]init];
    footerView.backgroundColor =[DWTools colorWithHexString:@"#f0f8ff"];
    [self addSubview:footerView];
    [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.left.centerX.mas_equalTo(self.tableView);
        make.top.mas_equalTo(self.tableView.mas_bottom);
        make.height.mas_equalTo(45);
        
    }];
    
    UIButton *commitBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn setBackgroundColor:[DWTools colorWithHexString:@"#419bf9"]];
    [footerView addSubview:commitBtn];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(footerView.mas_centerX).offset(25);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(footerView.mas_bottom).offset(-15/2);
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

- (void)commitAction{
    
    if (!self.selectArray.count) {
        //提示选择答案
        self.toastLabel.hidden =NO;
        
        return;
    }
    
    NSMutableArray *answerIdsArray =[NSMutableArray array];
    [self.selectArray enumerateObjectsUsingBlock:^(DWAnswerModel *answerModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [answerIdsArray addObject:answerModel.id];
        
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
- (BOOL )verifyAnswer{
    
    
    [self.selectArray enumerateObjectsUsingBlock:^(DWAnswerModel *answerModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([answerModel.right boolValue]) {
            
           self.isRight =YES;
            
        }else{
            
            self.isRight =NO;
            *stop =YES;
        }
        
        
    }];
    
    return _isRight;
    
}

- (void)skipAction{
    
    //能否跳过
    if (![_questionModel.jump boolValue]) {
        
        self.toastLabel.hidden =NO;
        
        
    }else{
    
     if (_skipBlock) {
        
         _skipBlock();
      }
        
    }
    
}

- (void)didQuestionBlock:(QuestionBlock )block{
    
    _questionBlock =block;
}


- (void)didSkipBlock:(SkipBlock )block{
    
    _skipBlock =block;
}

- (void)setQuestionModel:(DWQuestionModel *)questionModel{
    
    _questionModel =questionModel;
    if ([_questionModel.jump boolValue]) {
        
        [skipBtn setBackgroundColor:[DWTools colorWithHexString:@"#419bf9"]];
    }
    
    [self.tableView reloadData];
}

//返回高度
- (CGSize)heightWithWidth:(CGFloat)width andFont:(CGFloat )font andLabelText:(NSString *)text{
    
    NSDictionary *dict =[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:font] forKey:NSFontAttributeName];
    CGRect rect=[text boundingRectWithSize:CGSizeMake(width,CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    
    return rect.size;
}

- (NSInteger )heightWithText:(NSString *)text{
    
    if (!text) {
        
        return 0;
    }
    
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
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

#pragma mark------UITableViewDelegate-----
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  //视情况处理
    if (indexPath.row ==0) {

        //看有没有图片
        NSInteger count =[self heightWithText:_questionModel.content];

        if (count >0) {

            return count*60+60+10;

        }else{
            
            //计算高度
            CGSize size =[self heightWithWidth:self.tableViewWidth-30 andFont:14 andLabelText:_questionModel.content];

//           return size.height+10;
            return 15 + 16 + 21 + size.height+10;
        }

    }else{

        DWAnswerModel *answerModel =_questionModel.answers[indexPath.row-1];
        NSInteger answerCount =[self heightWithText:answerModel.content];
        if (answerCount >0) {

            return answerCount*60+10;


        }else{

            //计算高度
//            CGSize size =[self heightWithWidth:self.tableViewWidth-30 andFont:14 andLabelText:answerModel.content];
//
//            return size.height;
            return 60+10;
        }

    }
    
    
}

#pragma mark------UITableViewDataSource------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
   return _questionModel.answers.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"cellIdentifier";
    static NSString *CellDifferent =@"cellDifferent";
    
    if (indexPath.row ==0) {
        
        DWDifferentCell *differentCell =[tableView dequeueReusableCellWithIdentifier:CellDifferent];
        if (!differentCell) {
            differentCell =[[DWDifferentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellDifferent];
            differentCell.selectionStyle =  UITableViewCellSelectionStyleNone;
        }
        differentCell.tableViewWidth =self.tableViewWidth;
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
    
    //单选or多选
    for (DWAnswerModel *model in _questionModel.answers) {
        
        if ([model.right boolValue]) {
            
            [self.answerArray addObject:model];
        }
        
    }
    BOOL multipleSelect;
    if (self.answerArray.count >1) {
        
        multipleSelect =YES;//多选
    }else{
        multipleSelect =NO;//单选
    }
    
    
    DWAnswerModel *answerModel =_questionModel.answers[indexPath.row-1];
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



@end
