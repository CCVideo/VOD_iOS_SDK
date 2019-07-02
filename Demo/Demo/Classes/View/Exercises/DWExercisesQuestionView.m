//
//  DWExercisesQuestionView.m
//  Demo
//
//  Created by zwl on 2019/6/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWExercisesQuestionView.h"

#define EXERCISESQUESTIONVIEWWIDTH     (MAX(ScreenWidth, ScreenHeight) - 70)

typedef NS_ENUM(NSUInteger, DWExercisesQuestionType) {
    DWExercisesQuestionTypeSingle, //单选
    DWExercisesQuestionTypeMult, //多选
    DWExercisesQuestionTypeFill  //填空
};

@interface DWExercisesQuestionView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)DWVideoExercisesQuestionModel * questionModel;
@property(nonatomic,assign)DWExercisesQuestionType type;

//类型label
@property(nonatomic,strong)UILabel * typeLabel;
//问题内容label
@property(nonatomic,strong)UILabel * contentLabel;
//解析view
@property(nonatomic,strong)UIView * analysisView;

//选择题
@property(nonatomic,strong)UIView * headerView;
//单选题 / 多选题列表
@property(nonatomic,strong)UITableView * chooseTableView;
//用来存储cell高度
@property(nonatomic,strong)NSMutableArray * cellHeightArray;

@property(nonatomic,strong)UITextField * fillTextField;

@end

@implementation DWExercisesQuestionView

-(instancetype)initWithQuestionModel:(DWVideoExercisesQuestionModel *)questionModel
{
    if (self == [super init]) {
        
        self.questionModel = questionModel;
        if (self.questionModel.type == 0) {
            self.type = DWExercisesQuestionTypeSingle;
            [self initSingleUI];
        }else if (self.questionModel.type == 1){
            self.type = DWExercisesQuestionTypeMult;
            [self initMultUI];
        }else{
            self.type = DWExercisesQuestionTypeFill;
            [self initFillUI];
        }
        
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"DWExercisesQuestionView dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - action
-(void)submitButtonAction
{
    self.submitButton.hidden = YES;
    
    if (self.type == DWExercisesQuestionTypeMult) {
        //多选提交
        self.chooseTableView.allowsSelection = NO;
        [self.chooseTableView reloadData];
        
        [self initMultAnalysisView];
    }
    if (self.type == DWExercisesQuestionTypeFill) {
        //填空提交
        [self endEditing:YES];
        
        [self initFillAnalysisView];
    }
    
    if ([_delegate respondsToSelector:@selector(exercisesQuestionViewDidSubmit:)]) {
        [_delegate exercisesQuestionViewDidSubmit:self];
    }
}

-(void)fillTextFieldValueChangeNotifation
{
    if (self.fillTextField.text.length > 20) {
        [@"最多输入20个字" showAlert];
        self.fillTextField.text = [self.fillTextField.text substringWithRange:NSMakeRange(0, 20)];
    }
    
    DWVideoExercisesQuestionAnswerModel * answerModel = self.questionModel.answers.firstObject;
    answerModel.answerContent = self.fillTextField.text;
    
    self.submitButton.enabled = self.questionModel.isReply;
    if (self.submitButton.enabled) {
        self.submitButton.layer.borderColor = [UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0].CGColor;
    }else{
        self.submitButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

-(void)tapAction
{
    [self endEditing:YES];
}

//计算每行cell高度
-(CGFloat)calHeightWithAnswerModel:(DWVideoExercisesQuestionAnswerModel *)answerModel
{
    CGFloat height = 0;
    UIFont * font = TitleFont(14);
    CGSize size = [DWTools widthWithHeight:EXERCISESQUESTIONVIEWWIDTH - 105 - 60 andFont:font andLabelText:[answerModel.content substringWithRange:NSMakeRange(2, answerModel.content.length - 2)]];

    if (ceil(size.height) < (font.lineHeight * 2)) {
        height = 40 + 15;
    }else{
        height = ceil(size.height) + 19 + 15;
    }
    return height;
}

#pragma mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.questionModel.answers.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.cellHeightArray objectAtIndex:indexPath.row] floatValue];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWExercisesQuestionViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWExercisesQuestionViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.questionModel = self.questionModel;
    }
    if (self.type != DWExercisesQuestionTypeSingle) {
        cell.isSumbit = self.submitButton.hidden;
    }
    cell.answerModel = [self.questionModel.answers objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == DWExercisesQuestionTypeSingle) {
        self.chooseTableView.allowsSelection = NO;
        [self.questionModel.answers enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionAnswerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == indexPath.row) {
                obj.isSelect = YES;
            }
        }];
        
        [self.chooseTableView reloadData];
        [self initSingleAnalysisView];
        
        if ([_delegate respondsToSelector:@selector(exercisesQuestionViewDidSubmit:)]) {
            [_delegate exercisesQuestionViewDidSubmit:self];
        }
    }
    if (self.type == DWExercisesQuestionTypeMult) {
        __weak typeof(self) weakSelf = self;
        [self.questionModel.answers enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionAnswerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == indexPath.row) {
                obj.isSelect = !obj.isSelect;
                [weakSelf.chooseTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        self.submitButton.enabled = self.questionModel.isReply;
        if (self.submitButton.enabled) {
            self.submitButton.layer.borderColor = [UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0].CGColor;
        }else{
            self.submitButton.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }
}

#pragma mark - init
-(void)initSingleUI
{
    //处理cell高度
    __weak typeof(self) weakSelf = self;
    [self.questionModel.answers enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionAnswerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf.cellHeightArray addObject:[NSNumber numberWithFloat:[weakSelf calHeightWithAnswerModel:obj]]];
    }];
    
    [self addSubview:self.chooseTableView];
    [_chooseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    
    [self addSubview:self.headerView];
    
    self.typeLabel.text = @"单选";
    [self.headerView addSubview:self.typeLabel];
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@14);
        make.left.equalTo(@15);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    CGFloat contentWidth = EXERCISESQUESTIONVIEWWIDTH - 15 - 40 - 5 - 15;
    CGFloat contentHeight = [DWTools widthWithHeight:contentWidth andFont:self.contentLabel.font andLabelText:self.questionModel.content].height;
    
    self.contentLabel.text = self.questionModel.content;
    [self.headerView addSubview:self.contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeLabel.mas_right).offset(5);
        make.top.equalTo(self.typeLabel);
        make.width.equalTo(@(contentWidth));
        make.height.equalTo(@(contentHeight));
    }];
    
    self.headerView.frame = CGRectMake(0, 0, EXERCISESQUESTIONVIEWWIDTH, 14 + contentHeight + 13.5);
    self.chooseTableView.tableHeaderView = self.headerView;
}

-(void)initMultUI
{
    __weak typeof(self) weakSelf = self;
    [self.questionModel.answers enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionAnswerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf.cellHeightArray addObject:[NSNumber numberWithFloat:[weakSelf calHeightWithAnswerModel:obj]]];
    }];
    
    [self addSubview:self.chooseTableView];
    [_chooseTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@(-65));
    }];
    
    [self addSubview:self.headerView];
    
    self.typeLabel.text = @"多选";
    [self.headerView addSubview:self.typeLabel];
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@14);
        make.left.equalTo(@15);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    CGFloat contentWidth = EXERCISESQUESTIONVIEWWIDTH - 15 - 40 - 5 - 15;
    CGFloat contentHeight = [DWTools widthWithHeight:contentWidth andFont:self.contentLabel.font andLabelText:self.questionModel.content].height;
    
    self.contentLabel.text = self.questionModel.content;
    [self.headerView addSubview:self.contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeLabel.mas_right).offset(5);
        make.top.equalTo(self.typeLabel);
        make.width.equalTo(@(contentWidth));
        make.height.equalTo(@(contentHeight));
    }];
    
    self.headerView.frame = CGRectMake(0, 0, EXERCISESQUESTIONVIEWWIDTH, 14 + contentHeight + 13.5);
    self.chooseTableView.tableHeaderView = self.headerView;
    
    [self addSubview:self.submitButton];
    [_submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chooseTableView.mas_bottom).offset(20);
        make.centerX.equalTo(self);
        make.width.equalTo(@125);
        make.height.equalTo(@35);
    }];
}

-(void)initFillUI
{
    UITapGestureRecognizer * gesTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:gesTap];
    
    self.typeLabel.text = @"填空";
    [self addSubview:self.typeLabel];
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@14);
        make.left.equalTo(@15);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    NSString * answerStr = @" _________ ";
    NSString * questionStr = nil;
    
    CGFloat contentWidth = EXERCISESQUESTIONVIEWWIDTH - 15 - 40 - 5 - 15;

    CGSize contentSize = [DWTools widthWithHeight:CGFLOAT_MAX andFont:self.contentLabel.font andLabelText:self.questionModel.content];
    
    CGSize answerSize = [DWTools widthWithHeight:contentWidth andFont:self.contentLabel.font andLabelText:answerStr];

    NSInteger lineCount = 0;
    NSInteger remainingWidth = 0;
    if (contentSize.width > contentWidth) {
        //前半部分折行
        remainingWidth = (NSInteger)contentSize.width % (NSInteger)contentWidth;
        questionStr = [NSString stringWithFormat:@"%@%@%@",self.questionModel.content,answerStr,self.questionModel.content2];
        lineCount = contentSize.width / contentWidth;
    }else{
        //前半部分未折行
        if (contentSize.width > contentWidth - answerSize.width) {
            //手动折行
            remainingWidth = 0;
            questionStr = [NSString stringWithFormat:@"%@\n%@%@",self.questionModel.content,answerStr,self.questionModel.content2];
            lineCount = contentSize.width / contentWidth + 1;
        }else{
            //未折行
            remainingWidth = contentSize.width;
            questionStr = [NSString stringWithFormat:@"%@%@%@",self.questionModel.content,answerStr,self.questionModel.content2];
            lineCount = 0;
        }
    }
    
    self.contentLabel.userInteractionEnabled = YES;
    self.contentLabel.text = questionStr;
    CGSize questionSize = [DWTools widthWithHeight:contentWidth andFont:self.contentLabel.font andLabelText:self.contentLabel.text];
    [self addSubview:self.contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.typeLabel.mas_right).offset(5);
        make.top.equalTo(self.typeLabel);
        make.width.equalTo(@(contentWidth));
        make.height.equalTo(@(questionSize.height));
    }];
    
    [self.contentLabel addSubview:self.fillTextField];
    
    [_fillTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(remainingWidth + 5));
        make.width.equalTo(@(answerSize.width - 10));
        make.top.equalTo(@(lineCount * self.contentLabel.font.lineHeight));
        make.height.equalTo(@(self.contentLabel.font.lineHeight));
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillTextFieldValueChangeNotifation) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self addSubview:self.submitButton];
    [_submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-10));
        make.centerX.equalTo(self);
        make.width.equalTo(@125);
        make.height.equalTo(@35);
    }];
}

//答题完毕，创建解析view
-(void)initSingleAnalysisView
{
    [self addSubview:self.analysisView];
    
    UILabel * label = [[UILabel alloc]init];
    label.text = @"试题详解：";
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = TitleColor_51;
    [self.analysisView addSubview:label];
    
    UILabel * yourAnswerLabel = [[UILabel alloc]init];
    yourAnswerLabel.font = [UIFont boldSystemFontOfSize:13];
    yourAnswerLabel.textColor = TitleColor_51;
    [self.analysisView addSubview:yourAnswerLabel];
    
    UILabel * rightAnswerLabel = [[UILabel alloc]init];
    rightAnswerLabel.font = [UIFont boldSystemFontOfSize:13];
    rightAnswerLabel.textColor = [UIColor colorWithRed:139/255.0 green:192/255.0 blue:75/255.0 alpha:1.0];
    [self.analysisView addSubview:rightAnswerLabel];
    
    UILabel * analysisLabel = [[UILabel alloc]init];
    analysisLabel.numberOfLines = 0;
    analysisLabel.font = [UIFont systemFontOfSize:13];
    analysisLabel.textColor = TitleColor_51;
    [self.analysisView addSubview:analysisLabel];
    
    __block NSString * yourAnswer = nil;
    __block NSString * rightAnswer = nil;
    [self.questionModel.answers enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionAnswerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            yourAnswer = [NSString stringWithFormat:@"你的答案：%@ ",[[obj.content substringToIndex:1] uppercaseString]];
        }
        if (obj.isRight) {
            rightAnswer = [NSString stringWithFormat:@"正确答案：%@ ",[[obj.content substringToIndex:1] uppercaseString]];
        }
    }];
    
    NSMutableAttributedString * yAttr = [[NSMutableAttributedString alloc]initWithString:yourAnswer];
    [yAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 5)];
    [yAttr addAttribute:NSForegroundColorAttributeName value:TitleColor_102 range:NSMakeRange(0, 5)];
    yourAnswerLabel.attributedText = yAttr;
    
    NSMutableAttributedString * rAttr = [[NSMutableAttributedString alloc]initWithString:rightAnswer];
    [rAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 5)];
    [rAttr addAttribute:NSForegroundColorAttributeName value:TitleColor_102 range:NSMakeRange(0, 5)];
    rightAnswerLabel.attributedText = rAttr;

    //计算解析的内容所占高度
    NSString * analysis = [NSString stringWithFormat:@"题目解析： %@",self.questionModel.explainInfo];
    CGFloat analysisHeight = 0;
    CGSize size = [DWTools widthWithHeight:EXERCISESQUESTIONVIEWWIDTH - 40 andFont:analysisLabel.font andLabelText:analysis];
    if (ceil(size.height) < (analysisLabel.font.lineHeight * 2)) {
        analysisHeight = 13;
    }else{
        analysisHeight = ceil(size.height);
    }
    
    NSMutableAttributedString * aAttr = [[NSMutableAttributedString alloc]initWithString:analysis];
    [aAttr addAttribute:NSForegroundColorAttributeName value:TitleColor_102 range:NSMakeRange(0, 5)];
    analysisLabel.attributedText = aAttr;

    [_analysisView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.left.and.right.equalTo(@0);
        make.height.equalTo(@(15 + 13 + 15 + 13 + 15 + analysisHeight + 15));
    }];
    
    [_chooseTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-(15 + 13 + 15 + 13 + 15 + analysisHeight + 15)));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(@15);
        make.right.equalTo(@(-20));
        make.height.equalTo(@13);
    }];
    
    [yourAnswerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(label.mas_bottom).offset(15);
        make.height.equalTo(@13);
        make.width.lessThanOrEqualTo(@((EXERCISESQUESTIONVIEWWIDTH - 40 - 40) / 2));
    }];
    
    [rightAnswerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(yourAnswerLabel.mas_right).offset(35);
        make.top.equalTo(yourAnswerLabel);
        make.height.equalTo(yourAnswerLabel);
        make.width.lessThanOrEqualTo(@((EXERCISESQUESTIONVIEWWIDTH - 40 - 40) / 2));
    }];
    
    [analysisLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(yourAnswerLabel.mas_bottom).offset(15);
        make.left.equalTo(@20);
        make.right.equalTo(@(-20));
        make.height.equalTo(@(analysisHeight));
    }];
}

-(void)initMultAnalysisView
{
    [self addSubview:self.analysisView];
    
    UILabel * label = [[UILabel alloc]init];
    label.text = @"试题详解：";
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = TitleColor_51;
    [self.analysisView addSubview:label];
    
    UILabel * yourAnswerLabel = [[UILabel alloc]init];
    yourAnswerLabel.font = [UIFont boldSystemFontOfSize:13];
    yourAnswerLabel.textColor = TitleColor_51;
    [self.analysisView addSubview:yourAnswerLabel];
    
    UILabel * rightAnswerLabel = [[UILabel alloc]init];
    rightAnswerLabel.font = [UIFont boldSystemFontOfSize:13];
    rightAnswerLabel.textColor = [UIColor colorWithRed:139/255.0 green:192/255.0 blue:75/255.0 alpha:1.0];
    [self.analysisView addSubview:rightAnswerLabel];
    
    UILabel * analysisLabel = [[UILabel alloc]init];
    analysisLabel.numberOfLines = 0;
    analysisLabel.font = [UIFont systemFontOfSize:13];
    analysisLabel.textColor = TitleColor_51;
    [self.analysisView addSubview:analysisLabel];
    
    NSMutableArray * yourMArray = [NSMutableArray array];
    NSMutableArray * rightMArray = [NSMutableArray array];
    [self.questionModel.answers enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionAnswerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            [yourMArray addObject:[[obj.content substringToIndex:1] uppercaseString]];
        }
        if (obj.isRight) {
            [rightMArray addObject:[[obj.content substringToIndex:1] uppercaseString]];
        }
    }];
    
    NSString * yourAnswer = [NSString stringWithFormat:@"你的答案：%@",[yourMArray componentsJoinedByString:@" "]];
    NSString * rightAnswer = [NSString stringWithFormat:@"正确答案：%@",[rightMArray componentsJoinedByString:@" "]];
    
    NSMutableAttributedString * yAttr = [[NSMutableAttributedString alloc]initWithString:yourAnswer];
    [yAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 5)];
    [yAttr addAttribute:NSForegroundColorAttributeName value:TitleColor_102 range:NSMakeRange(0, 5)];
    yourAnswerLabel.attributedText = yAttr;
    
    NSMutableAttributedString * rAttr = [[NSMutableAttributedString alloc]initWithString:rightAnswer];
    [rAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 5)];
    [rAttr addAttribute:NSForegroundColorAttributeName value:TitleColor_102 range:NSMakeRange(0, 5)];
    rightAnswerLabel.attributedText = rAttr;
    
    //计算解析的内容所占高度
    NSString * analysis = [NSString stringWithFormat:@"题目解析： %@",self.questionModel.explainInfo];
    CGFloat analysisHeight = 0;
    CGSize size = [DWTools widthWithHeight:EXERCISESQUESTIONVIEWWIDTH - 40 andFont:analysisLabel.font andLabelText:analysis];
    if (ceil(size.height) < (analysisLabel.font.lineHeight * 2)) {
        analysisHeight = 13;
    }else{
        analysisHeight = ceil(size.height);
    }
    
    NSMutableAttributedString * aAttr = [[NSMutableAttributedString alloc]initWithString:analysis];
    [aAttr addAttribute:NSForegroundColorAttributeName value:TitleColor_102 range:NSMakeRange(0, 5)];
    analysisLabel.attributedText = aAttr;
    
    [_analysisView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.left.and.right.equalTo(@0);
        make.height.equalTo(@(15 + 13 + 15 + 13 + 15 + analysisHeight + 15));
    }];
    
    [_chooseTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-(15 + 13 + 15 + 13 + 15 + analysisHeight + 15)));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(@15);
        make.right.equalTo(@(-20));
        make.height.equalTo(@13);
    }];
    
    [yourAnswerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(label.mas_bottom).offset(15);
        make.height.equalTo(@13);
        make.width.lessThanOrEqualTo(@((EXERCISESQUESTIONVIEWWIDTH - 40 - 40) / 2));
    }];
    
    [rightAnswerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(yourAnswerLabel.mas_right).offset(35);
        make.top.equalTo(yourAnswerLabel);
        make.height.equalTo(yourAnswerLabel);
        make.width.lessThanOrEqualTo(@((EXERCISESQUESTIONVIEWWIDTH - 40 - 40) / 2));
    }];
    
    [analysisLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(yourAnswerLabel.mas_bottom).offset(15);
        make.left.equalTo(@20);
        make.right.equalTo(@(-20));
        make.height.equalTo(@(analysisHeight));
    }];
}

-(void)initFillAnalysisView
{
    self.fillTextField.enabled = NO;
    if (self.questionModel.isCorrect) {
        self.fillTextField.textColor = [UIColor colorWithRed:139/255.0 green:192/255.0 blue:75/255.0 alpha:1.0];
    }else{
        NSMutableAttributedString * fillAttr = [[NSMutableAttributedString alloc]initWithString:self.questionModel.answers.firstObject.answerContent];
        [fillAttr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0 green:79/255.0 blue:90/255.0 alpha:1.0] range:NSMakeRange(0, self.questionModel.answers.firstObject.answerContent.length)];
        [fillAttr addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(0, self.questionModel.answers.firstObject.answerContent.length)];
        [fillAttr addAttribute:NSStrikethroughColorAttributeName value:[UIColor colorWithRed:228/255.0 green:79/255.0 blue:90/255.0 alpha:1.0] range:NSMakeRange(0, self.questionModel.answers.firstObject.answerContent.length)];
        self.fillTextField.attributedText = fillAttr;
    }
    
    [self addSubview:self.analysisView];
    
    UILabel * label = [[UILabel alloc]init];
    label.text = @"试题详解：";
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = TitleColor_51;
    [self.analysisView addSubview:label];
    
    UILabel * answerLabel = [[UILabel alloc]init];
    answerLabel.font = [UIFont boldSystemFontOfSize:13];
    answerLabel.textColor = TitleColor_102;
    answerLabel.numberOfLines = 0;
    [self.analysisView addSubview:answerLabel];
    
    UILabel * analysisLabel = [[UILabel alloc]init];
    analysisLabel.numberOfLines = 0;
    analysisLabel.font = [UIFont systemFontOfSize:13];
    analysisLabel.textColor = TitleColor_51;
    [self.analysisView addSubview:analysisLabel];
    
    NSString * spaceStr = @"     ";
    NSString * answerStr = [NSString stringWithFormat:@"你的答案：%@%@正确答案：%@",self.questionModel.answers.firstObject.answerContent,spaceStr,self.questionModel.answers.firstObject.content];
    //计算答案的内容所占高度
    CGFloat answerHeight = 0;
    CGSize answerSize = [DWTools widthWithHeight:EXERCISESQUESTIONVIEWWIDTH - 40 andFont:answerLabel.font andLabelText:answerStr];
    if (ceil(answerSize.height) < (answerLabel.font.lineHeight * 2)) {
        answerHeight = 13;
    }else{
        answerHeight = ceil(answerSize.height);
    }
    NSMutableAttributedString * answerAttr = [[NSMutableAttributedString alloc]initWithString:answerStr];
    [answerAttr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(5, self.questionModel.answers.firstObject.answerContent.length)];
    [answerAttr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(5, self.questionModel.answers.firstObject.answerContent.length)];
    [answerAttr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(5 + self.questionModel.answers.firstObject.answerContent.length + spaceStr.length + 5, self.questionModel.answers.firstObject.content.length)];
    [answerAttr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:139/255.0 green:192/255.0 blue:75/255.0 alpha:1.0] range:NSMakeRange(5 + self.questionModel.answers.firstObject.answerContent.length + spaceStr.length + 5, self.questionModel.answers.firstObject.content.length)];
    answerLabel.attributedText = answerAttr;
    
    //计算解析的内容所占高度
    NSString * analysis = [NSString stringWithFormat:@"题目解析： %@",self.questionModel.explainInfo];
    CGFloat analysisHeight = 0;
    CGSize analysisSize = [DWTools widthWithHeight:EXERCISESQUESTIONVIEWWIDTH - 40 andFont:analysisLabel.font andLabelText:analysis];
    if (ceil(analysisSize.height) < (analysisLabel.font.lineHeight * 2)) {
        analysisHeight = 13;
    }else{
        analysisHeight = ceil(analysisSize.height);
    }
    NSMutableAttributedString * aAttr = [[NSMutableAttributedString alloc]initWithString:analysis];
    [aAttr addAttribute:NSForegroundColorAttributeName value:TitleColor_102 range:NSMakeRange(0, 5)];
    analysisLabel.attributedText = aAttr;
    
    [_analysisView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.left.and.right.equalTo(@0);
        make.height.equalTo(@(15 + 13 + 15 + answerHeight + 15 + analysisHeight + 15));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(@15);
        make.right.equalTo(@(-20));
        make.height.equalTo(@13);
    }];
    
    [answerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(label.mas_bottom).offset(15);
        make.right.equalTo(@(-20));
        make.height.equalTo(@(answerHeight));
    }];
    
    [analysisLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(answerLabel.mas_bottom).offset(15);
        make.left.equalTo(@20);
        make.right.equalTo(@(-20));
        make.height.equalTo(@(analysisHeight));
    }];
}

#pragma mark - lazyLoad
-(UITableView *)chooseTableView
{
    if (!_chooseTableView) {
        _chooseTableView = [[UITableView alloc]init];
        _chooseTableView.delegate = self;
        _chooseTableView.dataSource = self;
        _chooseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _chooseTableView;
}

-(UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
    }
    return _headerView;
}

-(UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc]init];
        _typeLabel.backgroundColor = [UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0];
        _typeLabel.font = TitleFont(13);
        _typeLabel.textColor = [UIColor whiteColor];
        _typeLabel.layer.cornerRadius = 1;
        _typeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _typeLabel;
}

-(UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.font = TitleFont(15);
        _contentLabel.textColor = TitleColor_51;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

-(UIButton *)submitButton
{
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
        _submitButton.titleLabel.font = TitleFont(15);
        [_submitButton setTitleColor:[UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]  forState:UIControlStateDisabled];
        [_submitButton setBackgroundImage:[[UIColor colorWithRed:243/255.0 green:244/255.0 blue:245/255.0 alpha:1.0] createImage] forState:UIControlStateDisabled];
        [_submitButton setBackgroundImage:[[UIColor whiteColor] createImage] forState:UIControlStateNormal];
        _submitButton.layer.masksToBounds = YES;
        _submitButton.layer.cornerRadius = 35 / 2.0;
        _submitButton.layer.borderWidth = 1;
        _submitButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _submitButton.enabled = NO;
        [_submitButton addTarget:self action:@selector(submitButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

-(UIView *)analysisView
{
    if (!_analysisView) {
        _analysisView = [[UIView alloc]init];
        _analysisView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:247/255.0 alpha:1.0];
    }
    return _analysisView;
}

-(NSMutableArray *)cellHeightArray
{
    if (!_cellHeightArray) {
        _cellHeightArray = [[NSMutableArray alloc]init];
    }
    return _cellHeightArray;
}

-(UITextField *)fillTextField
{
    if (!_fillTextField) {
        _fillTextField = [[UITextField alloc]init];
        _fillTextField.font = TitleFont(15);
        _fillTextField.textColor = [UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0];
        _fillTextField.textAlignment = NSTextAlignmentCenter;
    }
    return _fillTextField;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@interface DWExercisesQuestionViewCell ()

@property(nonatomic,strong)UIView * bgView;
@property(nonatomic,strong)UIImageView * chooseImageView;
@property(nonatomic,strong)UILabel * contentLabel;
@property(nonatomic,strong)UIImageView * isRightImageView;


@end

@implementation DWExercisesQuestionViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.bgView = [[UIView alloc]init];
        self.bgView.backgroundColor = [UIColor colorWithRed:240/255.0 green:241/255.0 blue:242/255.0 alpha:1.0];
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.cornerRadius = 4;
        [self.contentView addSubview:self.bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@65);
            make.right.equalTo(@(-40));
            make.top.equalTo(@7.5);
            make.bottom.equalTo(@(-7.5));
        }];
        
        self.chooseImageView = [[UIImageView alloc]init];
        [self.bgView addSubview:self.chooseImageView];
        [_chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self.bgView);
            make.width.equalTo(@16);
            make.height.equalTo(@22);
        }];
        
        self.contentLabel = [[UILabel alloc]init];
        self.contentLabel.font = TitleFont(14);
        self.contentLabel.numberOfLines = 0;
        //默认值
        self.contentLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        [self.bgView addSubview:self.contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.chooseImageView.mas_right).offset(4);
            make.right.equalTo(@(-30));
            make.centerY.equalTo(self.bgView);
            make.height.equalTo(self.bgView);
        }];
        
        self.isRightImageView = [[UIImageView alloc]init];
        self.isRightImageView.hidden = YES;
        [self.bgView addSubview:self.isRightImageView];
        [_isRightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-5));
            make.width.and.height.equalTo(@20);
            make.centerY.equalTo(self.bgView);
        }];
    }
    return self;
}

-(void)setAnswerModel:(DWVideoExercisesQuestionAnswerModel *)answerModel
{
    _answerModel = answerModel;
    
    self.contentLabel.text = [answerModel.content substringWithRange:NSMakeRange(2, answerModel.content.length - 2)];

    if (self.questionModel.type == 0) {
        //单选题
        if (self.questionModel.isReply) {
            //已作答
            if (self.questionModel.isCorrect && answerModel.isSelect) {
                //答对
                //取abc..
                NSString * leftImageSelectName = [NSString stringWithFormat:@"icon_exercises_answer_%@_select.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageSelectName];
                [self setCellStyle:1];
            }else if (!self.questionModel.isCorrect && answerModel.isSelect){
                //答错，错误选项
                //取abc..
                NSString * leftImageSelectName = [NSString stringWithFormat:@"icon_exercises_answer_%@_select.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageSelectName];
                [self setCellStyle:2];
            }else if (!self.questionModel.isCorrect && answerModel.isRight){
                NSString * leftImageSelectName = [NSString stringWithFormat:@"icon_exercises_answer_%@_select.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageSelectName];
                [self setCellStyle:1];
            }else{
                //默认
                //取abc..
                NSString * leftImageNormalName = [NSString stringWithFormat:@"icon_exercises_answer_%@_normal.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageNormalName];
                [self setCellStyle:0];
            }

        }else{
            //未作答
            //默认
            //取abc..
            NSString * leftImageNormalName = [NSString stringWithFormat:@"icon_exercises_answer_%@_normal.png",[[answerModel.content substringToIndex:1] lowercaseString]];
            self.chooseImageView.image = [UIImage imageNamed:leftImageNormalName];
            [self setCellStyle:0];
        }
    }
    
    if (self.questionModel.type == 1) {
        //多选题
        if (self.isSumbit) {
            
            if (answerModel.isRight) {
                //正确选项
                NSString * leftImageSelectName = [NSString stringWithFormat:@"icon_exercises_answer_%@_select.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageSelectName];
                [self setCellStyle:1];
            }else if (!answerModel.isRight && answerModel.isSelect){
                //错选。多选
                NSString * leftImageSelectName = [NSString stringWithFormat:@"icon_exercises_answer_%@_select.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageSelectName];
                [self setCellStyle:2];
            }else{
                NSString * leftImageNormalName = [NSString stringWithFormat:@"icon_exercises_answer_%@_normal.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageNormalName];
                [self setCellStyle:0];
            }
        
        }else{
            //未作答
            if (answerModel.isSelect) {
                //选中
                //蓝色
                NSString * leftImageNormalName = [NSString stringWithFormat:@"icon_exercises_answer_%@_select.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageNormalName];
                [self setCellStyle:3];
            }else{
                //默认
                NSString * leftImageNormalName = [NSString stringWithFormat:@"icon_exercises_answer_%@_normal.png",[[answerModel.content substringToIndex:1] lowercaseString]];
                self.chooseImageView.image = [UIImage imageNamed:leftImageNormalName];
                [self setCellStyle:0];
            }
        }
    }
}

//设置样式  0默认 1绿色 2红 3蓝
-(void)setCellStyle:(NSInteger)index
{
    if (index == 0) {
        self.bgView.backgroundColor = [UIColor colorWithRed:240/255.0 green:241/255.0 blue:242/255.0 alpha:1.0];
        if (self.questionModel.isReply) {
            self.contentLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        }else{
            self.contentLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        }
        self.isRightImageView.hidden = YES;
    }
    if (index == 1) {
        self.bgView.backgroundColor = [UIColor colorWithRed:139/255.0 green:192/255.0 blue:75/255.0 alpha:1.0];
        self.contentLabel.textColor = [UIColor whiteColor];
        self.isRightImageView.hidden = NO;
        self.isRightImageView.image = [UIImage imageNamed:@"icon_exercises_right.png"];
    }
    if (index == 2) {
        self.bgView.backgroundColor = [UIColor colorWithRed:228/255.0 green:79/255.0 blue:90/255.0 alpha:1.0];
        self.contentLabel.textColor = [UIColor whiteColor];
        self.isRightImageView.hidden = NO;
        self.isRightImageView.image = [UIImage imageNamed:@"icon_exercises_error.png"];
    }
    if (index == 3) {
        self.bgView.backgroundColor = [UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0];
        self.contentLabel.textColor = [UIColor whiteColor];
        self.isRightImageView.hidden = YES;
    }
}

@end
