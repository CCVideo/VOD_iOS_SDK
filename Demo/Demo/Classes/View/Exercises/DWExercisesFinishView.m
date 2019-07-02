//
//  DWExercisesFinishView.m
//  Demo
//
//  Created by zwl on 2019/6/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWExercisesFinishView.h"

@interface DWExercisesFinishView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)DWVideoExercisesModel * exercisesModel;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)DWExercisesPromptView * promptView;

@end

@implementation DWExercisesFinishView

-(instancetype)initWithExercisesModel:(DWVideoExercisesModel *)exercisesModel
{
    if (self == [super init]) {
        
        self.exercisesModel = exercisesModel;
        
        [self initUI];
    }
    return self;
}

#pragma mark - action
-(void)resumeButtonAction
{
    if ([_delegate respondsToSelector:@selector(exercisesFinishViewResumePlay)]) {
        [_delegate exercisesFinishViewResumePlay];
    }
}

-(void)accuracyButtonAction:(DWExercisesAccuracyButton *)button
{
    // 2000
    button.selected = !button.selected;
    
    if (button.selected) {
        //弹窗
        self.promptView.hidden = NO;
        
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag - 2000 inSection:0]];
        CGRect buttonRect = [self convertRect:button.frame fromView:cell];

        DWVideoExercisesQuestionModel * questionMdoel = [self.exercisesModel.questions objectAtIndex:button.tag - 2000];
        NSString * title = [NSString stringWithFormat:@"居然有%ld%%的人答%@了",questionMdoel.isCorrect ? questionMdoel.accuracy : 100 - questionMdoel.accuracy,questionMdoel.isCorrect ? @"对" : @"错"];
        [self.promptView setTitle:title];
        [_promptView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(buttonRect.origin.y - 42 - 5));
        }];
        
        DWExercisesAccuracyButton * preButton = (DWExercisesAccuracyButton *)[self.tableView viewWithTag:self.promptView.tag - 1000];
        if (preButton && preButton != button) {
            preButton.selected = NO;
        }
        
    }else{
        //清除弹窗
        self.promptView.hidden = YES;
    }
    
    self.promptView.tag = 1000 + button.tag;
}

#pragma mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.exercisesModel.questions.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWExercisesFinishViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWExercisesFinishViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        [cell.accuracyButton addTarget:self action:@selector(accuracyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell setIndex:indexPath.row AndExercisesQuestionModel:[self.exercisesModel.questions objectAtIndex:indexPath.row]];
    cell.accuracyButton.tag = 2000 + indexPath.row;
    return cell;
}

#pragma mark - initUI
-(void)initUI
{
    UILabel * headLabel = [[UILabel alloc]init];
    headLabel.font = TitleFont(15);
    headLabel.textColor = TitleColor_51;
    headLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:headLabel];
    [headLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@15);
        make.top.equalTo(@34);
    }];
    
    UITableView * tableView = [[UITableView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.allowsSelection = NO;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headLabel);
        make.right.equalTo(headLabel);
        make.top.equalTo(headLabel.mas_bottom).offset(22.5);
        make.bottom.equalTo(@(-65));
    }];
    self.tableView = tableView;
    
    UIButton * resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resumeButton setTitle:@"继续播放" forState:UIControlStateNormal];
    resumeButton.titleLabel.font = TitleFont(15);
    [resumeButton setTitleColor:[UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0] forState:UIControlStateNormal];
    resumeButton.layer.cornerRadius = 35 / 2.0;
    resumeButton.layer.borderWidth = 1;
    resumeButton.layer.borderColor = [UIColor colorWithRed:81/255.0 green:168/255.0 blue:242/255.0 alpha:1.0].CGColor;
    [resumeButton addTarget:self action:@selector(resumeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:resumeButton];
    [resumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@125);
        make.height.equalTo(@35);
        make.top.equalTo(tableView.mas_bottom).offset(20);
    }];
    
    __block NSInteger correctNum = 0;
    [self.exercisesModel.questions enumerateObjectsUsingBlock:^(DWVideoExercisesQuestionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isCorrect) {
            correctNum++;
        }
    }];
    NSString * headStr = [NSString stringWithFormat:@"您答对%ld题，共%ld题",correctNum,self.exercisesModel.questions.count];
    NSMutableAttributedString * attr = [[NSMutableAttributedString alloc]initWithString:headStr];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:139/255.0 green:192/255.0 blue:75/255.0 alpha:1.0] range:NSMakeRange(3, 1)];
    [attr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(3, 1)];
    headLabel.attributedText = attr;
    
    [tableView reloadData];
    
    self.promptView = [[DWExercisesPromptView alloc]init];
    [self addSubview:self.promptView];
    self.promptView.hidden = YES;
    [self.promptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.width.equalTo(@169);
        make.right.equalTo(@(-42));
        make.height.equalTo(@42);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface DWExercisesFinishViewCell ()

@property(nonatomic,strong)UILabel * indexLabel;

@end

@implementation DWExercisesFinishViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.indexLabel = [[UILabel alloc]init];
        self.indexLabel.font = TitleFont(15);
        self.indexLabel.textColor = TitleColor_102;
        [self.contentView addSubview:self.indexLabel];
        [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@101);
            make.centerY.equalTo(self);
            make.height.equalTo(@15);
            make.width.equalTo(@40);
        }];
        
        self.accuracyButton = [[DWExercisesAccuracyButton alloc]init];
        [self.contentView addSubview:self.accuracyButton];
        [_accuracyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.indexLabel.mas_right).offset(15);
            make.centerY.equalTo(self);
            make.height.equalTo(@29);
            make.right.equalTo(@(-100));
        }];
        
    }
    return self;
}

-(void)setIndex:(NSInteger)index AndExercisesQuestionModel:(DWVideoExercisesQuestionModel *)quesitonModel
{
    self.indexLabel.text = [NSString stringWithFormat:@"第%ld题",index + 1];
    
    [self.accuracyButton setIsRight:quesitonModel.isCorrect AndAccuracy:quesitonModel.accuracy];
}

@end

@interface DWExercisesAccuracyButton ()

@property(nonatomic,strong)DWExercisesAccuracyColorView * bgView;
@property(nonatomic,strong)UILabel * accuracyLabel;
@property(nonatomic,strong)UIImageView * leftImageView;
@property(nonatomic,strong)UIImageView * rightImageView;

@end

@implementation DWExercisesAccuracyButton

-(instancetype)init
{
    if (self == [super init]) {
        
        self.layer.cornerRadius = YES;
        self.layer.cornerRadius = 29 / 2.0;
        self.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        
        self.bgView = [[DWExercisesAccuracyColorView alloc]init];
        self.bgView.layer.cornerRadius = self.layer.cornerRadius;
        [self addSubview:self.bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
            make.height.equalTo(self);
            make.centerY.equalTo(self);
            make.left.equalTo(@0);
        }];
        
        self.leftImageView = [[UIImageView alloc]init];
        self.leftImageView.image = [UIImage imageNamed:@"icon_exercises_statistics_right.png"];
        self.leftImageView.hidden = YES;
        [self addSubview:self.leftImageView];
        [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@2);
            make.centerY.equalTo(self);
            make.width.and.height.equalTo(@24);
        }];
        
        self.accuracyLabel = [[UILabel alloc]init];
        self.accuracyLabel.font = [UIFont boldSystemFontOfSize:13];
        self.accuracyLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.accuracyLabel];
        [_accuracyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@29);
            make.right.equalTo(@(-29));
            make.centerY.equalTo(self);
            make.height.equalTo(self);
        }];
        
        self.rightImageView = [[UIImageView alloc]init];
        self.rightImageView.image = [UIImage imageNamed:@"icon_exercises_statistics_error.png"];
        self.rightImageView.hidden = YES;
        [self addSubview:self.rightImageView];
        [_rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-2));
            make.centerY.equalTo(self);
            make.width.and.height.equalTo(@24);
        }];
        
    }
    return self;
}

-(void)setIsRight:(BOOL)isRight AndAccuracy:(NSInteger)accuracy
{
    CGFloat percentage = (isRight ? accuracy : (100 - accuracy)) / 100.0;
    CGFloat viewWidth = ((MAX(ScreenWidth, ScreenHeight) - 70) - 101 - 40 - 15 - 100) * percentage;
    if (viewWidth < 67) {
        viewWidth = 67;
    }
    
    if (isRight) {
        
        self.accuracyLabel.text = [NSString stringWithFormat:@"%ld%%",accuracy];

        self.bgView.backgroundColor = [UIColor colorWithRed:139/255.0 green:192/255.0 blue:75/255.0 alpha:1.0];
        [_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self);
            make.centerY.equalTo(self);
            make.left.equalTo(@0);
            make.width.equalTo(@(viewWidth));
        }];
        
        self.leftImageView.hidden = NO;
        self.rightImageView.hidden = YES;
        
        self.accuracyLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        
        self.accuracyLabel.text = [NSString stringWithFormat:@"%ld%%",100 - accuracy];

        self.bgView.backgroundColor = [UIColor colorWithRed:228/255.0 green:79/255.0 blue:90/255.0 alpha:1.0];
        [_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self);
            make.centerY.equalTo(self);
            make.right.equalTo(@0);
            make.width.equalTo(@(viewWidth));
        }];
        
        self.leftImageView.hidden = YES;
        self.rightImageView.hidden = NO;
        
        self.accuracyLabel.textAlignment = NSTextAlignmentRight;
    }
}

@end

@interface DWExercisesAccuracyColorView ()

@end

@implementation DWExercisesAccuracyColorView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

@end

@interface DWExercisesPromptView ()

@property(nonatomic,strong)UIView * bgView;
@property(nonatomic,strong)UILabel * titleLabel;

@end

@implementation DWExercisesPromptView

-(instancetype)init
{
    if (self == [super init]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.bgView = [[UIView alloc]init];
        self.bgView.backgroundColor = [UIColor colorWithRed:30/255.0 green:31/255.0 blue:33/255.0 alpha:1.0];
        [self addSubview:self.bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@37);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = TitleFont(15);
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.bgView);
        }];
        
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:30/255.0 green:31/255.0 blue:33/255.0 alpha:0.7].CGColor);
    CGContextMoveToPoint(context, 8, 37);
    CGContextAddLineToPoint(context, 13, 42);
    CGContextAddLineToPoint(context, 18, 37);
    CGContextFillPath(context);
}

@end
