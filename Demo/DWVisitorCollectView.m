//
//  DWVisitorCollectView.m
//  Demo
//
//  Created by zwl on 2019/4/23.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWVisitorCollectView.h"

@interface DWVisitorCollectView () <UITableViewDelegate,UITableViewDataSource>

/*
 竖屏时，一个textField,改变时，判断当前是第几个，保存数据。    切换下一条时，整个变量保存当前是第几个，然后改文字，继续保存
 
 横屏时，一堆textField，改变时，各自保存数据
 */


@property(nonatomic,strong)NSDictionary * visitorDict; // 问卷具体数据
/**
 @{@"title":@"标题",@"placeholder":@"提示语",@"content":@"输入的内容"}
 */
@property(nonatomic,strong)NSMutableArray * listArray; // 问卷具体数据
@property(nonatomic,assign)BOOL isFull; //当前屏幕状态

@property(nonatomic,strong)UIView * maskView;

//竖屏view
@property(nonatomic,strong)UIView * verticalBgView;
@property(nonatomic,strong)UILabel * titleLabel;
@property(nonatomic,strong)UILabel * placeholderLabel;
@property(nonatomic,strong)UITextField * verticalTextField; //输入框
@property(nonatomic,assign)NSInteger verticalIndex; //当前下表
@property(nonatomic,strong)UIButton * nextButton;
@property(nonatomic,strong)UIButton * frontButton;

//横屏view
@property(nonatomic,strong)UIView * horizontalBgView;
@property(nonatomic,strong)UITableView * horizontalTableView;

@end

@implementation DWVisitorCollectView

-(instancetype)initWithVisitorDict:(NSDictionary *)visitorDict
{
    if (self == [super init]) {
        
        self.isFull = NO;
        self.verticalIndex = 0;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditTapAction)];
        [self addGestureRecognizer:tap];
        
        [self proxyVisitorData:visitorDict];
        [self initUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldValueChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)screenRotate:(BOOL)isFull
{
    self.isFull = isFull;
    
    [self endEditing:YES];
    
    self.verticalBgView.hidden = isFull;
    self.horizontalBgView.hidden = !isFull;
    
    if (self.isFull) {
        [self.horizontalTableView reloadData];
    }else{
        [self verticalChangeUIAndData];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

-(void)dealReturnString
{
    NSMutableArray * returnArray = [NSMutableArray array];
    for (int i = 0; i < self.listArray.count; i++) {
        NSDictionary * messageDict = [self.listArray objectAtIndex:i];
        if ([[messageDict objectForKey:@"content"] isEqualToString:@""]) {
            //存在，未填写数据
            if (self.isFull) {
                UITextField * textField = (UITextField *)[self.horizontalTableView viewWithTag:100 + i];
                [textField becomeFirstResponder];
            }else{
                self.verticalIndex = i;
                [self verticalChangeUIAndData];
            }
  
            return;
        }
        [returnArray addObject:@{@"collector":[messageDict objectForKey:@"title"],@"collectorMes":[messageDict objectForKey:@"content"]}];
    }
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:returnArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.delegate visitorCollectDidCommit:jsonStr];

}

-(void)verticalChangeUIAndData
{
    NSDictionary * messageDict = [self.listArray objectAtIndex:self.verticalIndex];
    
    self.placeholderLabel.text = [messageDict objectForKey:@"title"];
    NSMutableAttributedString * placeholderString = [[NSMutableAttributedString alloc] initWithString:[messageDict objectForKey:@"placeholder"] attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]}];
    self.verticalTextField.attributedPlaceholder = placeholderString;
    self.verticalTextField.text = [messageDict objectForKey:@"content"];

    BOOL jump = [[self.visitorDict objectForKey:@"isJump"] boolValue];
    if (self.verticalIndex == 0) {
        [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        if (jump) {
            [self.frontButton setTitle:@"跳过" forState:UIControlStateNormal];
        }else{
            self.frontButton.hidden = YES;
            
            [_nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.verticalBgView);
                make.top.equalTo(@167);
                make.width.equalTo(@70);
                make.height.equalTo(@25);
            }];
        }
    }else if (self.verticalIndex == self.listArray.count - 1){
        if (jump) {
            
        }else{
            self.frontButton.hidden = NO;
            
            [_nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.verticalBgView.mas_centerX).offset(-10);
                make.top.equalTo(@167);
                make.width.equalTo(@70);
                make.height.equalTo(@25);
            }];
        }
        [self.nextButton setTitle:@"提交" forState:UIControlStateNormal];
    }else{
        if (jump) {
            
        }else{
            self.frontButton.hidden = NO;
            
            [_nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.verticalBgView.mas_centerX).offset(-10);
                make.top.equalTo(@167);
                make.width.equalTo(@70);
                make.height.equalTo(@25);
            }];
        }
        [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [self.frontButton setTitle:@"上一步" forState:UIControlStateNormal];
    }

}

#pragma mark - action
-(void)endEditTapAction
{
    [self endEditing:YES];
}

-(void)leftButtonAction
{
    [self.delegate visitorCollectDidCancel];
}

-(void)verticalNextButtonAction
{
    //下一步 or 提交
    if (self.verticalIndex == self.listArray.count - 1) {
        //提交
        [self dealReturnString];
        
    }else{
        self.verticalIndex++;
        [self verticalChangeUIAndData];
    }
}

-(void)verticalFrontButtonAction
{
    //上一步 or 跳过
    if (self.verticalIndex == 0) {
        //跳过
        [self.delegate visitorCollectDidJump];
    }else{
        self.verticalIndex--;
        [self verticalChangeUIAndData];
    }
}

-(void)horizontalCommitButtonAction
{
    [self dealReturnString];
}

-(void)horizontalJumpButtonAction
{
    [self.delegate visitorCollectDidJump];
}

-(void)headerImageTapAction
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self.visitorDict objectForKey:@"jumpURL"]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.visitorDict objectForKey:@"jumpURL"]]];
    }
}

-(void)textFieldValueChangeNotification:(NSNotification *)noti
{
    if (self.isFull) {
        for (int i = 0; i < self.listArray.count; i++) {
            UITextField * textField = (UITextField *)[self.horizontalTableView viewWithTag:100 + i];
            if (textField.isFirstResponder) {
                NSMutableDictionary * messageDict = [self.listArray objectAtIndex:i];
                [messageDict setValue:textField.text forKey:@"content"];
            }
        }
    }else{
        NSMutableDictionary * messageDict = [self.listArray objectAtIndex:self.verticalIndex];
        [messageDict setValue:self.verticalTextField.text forKey:@"content"];
    }
}

-(void)keyBoardWillShow:(NSNotification *)noti
{
    if (!self.isFull) {
        return;
    }
    
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    [UIView animateWithDuration:0.33 animations:^{
        [_horizontalBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.maskView).offset(-height / 2.0);
        }];
    }];
}

-(void)keyBoardWillHide:(NSNotification *)noti
{
    if (!self.isFull) {
        return;
    }
    
    [UIView animateWithDuration:0.33 animations:^{
        [_horizontalBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.maskView);
        }];
    }];
}

#pragma mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWVisitorCollectViewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWVisitorCollectViewTableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cell"];
    }
    cell.textField.tag = 100 + indexPath.row;
    cell.messageDict = [self.listArray objectAtIndex:indexPath.row];
    return cell;
}

//解析数据
-(void)proxyVisitorData:(NSDictionary *)visitorDict
{
    if (!visitorDict) {
        return;
    }
    
    /*
     {
     "visitorId": "123",//收集器ID
     "title": "访客信息收集样例",//收集器标题
     "appearTime": 85,//出现的时间(s)
     "imageURL": "http://1-material.bokecc.com/material/1725A8A9604EAE30/5089.png",//展现的图片地址
     "jumpURL": "www.baidu.com",//图片的跳转地址
     "visitorMessage": [.      //要收集的信息
     {
     "visitorMes": "姓名",
     "visitorTip": "请输入访客姓名"
     },
     {
     "visitorMes": "电话",
     "visitorTip": "请输入访客电话"
     },
     {
     "visitorMes": "邮箱",
     "visitorTip": "请输入访客的邮箱"
     }
     ],
     "isJump": 0 //是否跳过 0不跳过,1跳过
     }
     */
    self.visitorDict = visitorDict;
    
    self.listArray = [[NSMutableArray alloc]init];

    NSArray * visitorMessageArray = [visitorDict objectForKey:@"visitorMessage"];
    
    for (NSDictionary * messageDict in visitorMessageArray) {
        NSMutableDictionary * mDict = [NSMutableDictionary dictionary];
        [mDict setValue:[messageDict objectForKey:@"visitorMes"] forKey:@"title"];
        [mDict setValue:[messageDict objectForKey:@"visitorTip"] forKey:@"placeholder"];
        [mDict setValue:@"" forKey:@"content"];
        [self.listArray addObject:mDict];
    }
    
}

-(void)initUI
{
    self.maskView = [[UIView alloc]init];
    self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    [self addSubview:self.maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //竖屏
    self.verticalBgView = [[UIView alloc]init];
    [self.maskView addSubview:self.verticalBgView];
    [_verticalBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = [self.visitorDict objectForKey:@"title"];
    [self.verticalBgView addSubview:self.titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@28);
        make.centerX.equalTo(self.verticalBgView);
        make.width.equalTo(@250);
        make.height.equalTo(@19);
    }];
    
    self.placeholderLabel = [[UILabel alloc]init];
    self.placeholderLabel.font = [UIFont systemFontOfSize:12];
    self.placeholderLabel.textColor = [UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1.0];
    self.placeholderLabel.textAlignment = NSTextAlignmentLeft;
    [self.verticalBgView addSubview:self.placeholderLabel];
    [_placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.verticalBgView);
        make.width.equalTo(self.titleLabel);
        make.height.equalTo(@12);
        make.top.equalTo(@74);
    }];
    
    self.verticalTextField = [[UITextField alloc]init];
    self.verticalTextField.backgroundColor = [UIColor whiteColor];
    self.verticalTextField.font = [UIFont systemFontOfSize:12];
    self.verticalTextField.textColor = [UIColor blackColor];
    [self.verticalBgView addSubview:self.verticalTextField];
    [_verticalTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.verticalBgView);
        make.width.equalTo(self.titleLabel);
        make.height.equalTo(@30);
        make.top.equalTo(@91);
    }];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.backgroundColor = [UIColor colorWithRed:85/255.0 green:177/255.0 blue:255/255.0 alpha:1.0];
    [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.nextButton addTarget:self action:@selector(verticalNextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.verticalBgView addSubview:self.nextButton];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.verticalBgView.mas_centerX).offset(-10);
        make.top.equalTo(@167);
        make.width.equalTo(@70);
        make.height.equalTo(@25);
    }];

    self.frontButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.frontButton.backgroundColor = [UIColor clearColor];
    [self.frontButton setTitle:@"上一步" forState:UIControlStateNormal];
    [self.frontButton setTitleColor:[UIColor colorWithRed:85/255.0 green:177/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.frontButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.frontButton.layer.borderColor = [UIColor colorWithRed:85/255.0 green:177/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.frontButton.layer.borderWidth = 1;
    [self.frontButton addTarget:self action:@selector(verticalFrontButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.verticalBgView addSubview:self.frontButton];
    [_frontButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.verticalBgView.mas_centerX).offset(10);
        make.top.equalTo(@167);
        make.width.equalTo(@70);
        make.height.equalTo(@25);
    }];
    
    //给view赋默认值
    [self verticalChangeUIAndData];
    
    //横屏
    self.horizontalBgView = [[UIView alloc]init];
    [self.maskView addSubview:self.horizontalBgView];
    [_horizontalBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.maskView);
        make.centerY.equalTo(self.maskView);
        make.width.equalTo(@310);
        make.height.equalTo(@247);
    }];
    
    UIImageView * horizontalHeaderImageView = [[UIImageView alloc]init];
    horizontalHeaderImageView.userInteractionEnabled = YES;
    [self.horizontalBgView addSubview:horizontalHeaderImageView];
    [horizontalHeaderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@62);
    }];
    
    UITapGestureRecognizer * headerImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerImageTapAction)];
    [horizontalHeaderImageView addGestureRecognizer:headerImageTap];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage * headerImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.visitorDict objectForKey:@"imageURL"]]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            horizontalHeaderImageView.image = headerImage;
        });
    });
    
    self.horizontalTableView = [[UITableView alloc]init];
    self.horizontalTableView.delegate = self;
    self.horizontalTableView.dataSource = self;
    self.horizontalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.horizontalBgView addSubview:self.horizontalTableView];
    [_horizontalTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(horizontalHeaderImageView.mas_bottom);
        make.bottom.equalTo(@(-44));
        make.width.equalTo(self.horizontalBgView);
    }];
    
    UIView * horizontalBottomBgView = [[UIView alloc]init];
    horizontalBottomBgView.backgroundColor = [UIColor colorWithRed:240/255.0 green:248/255.0 blue:255/255.0 alpha:1.0];
    [self.horizontalBgView addSubview:horizontalBottomBgView];
    [horizontalBottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.horizontalTableView.mas_bottom);
        make.bottom.equalTo(@0);
        make.left.equalTo(@0);
        make.width.equalTo(self.horizontalBgView);
    }];
    
    UIButton * horizontalCommitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    horizontalCommitButton.backgroundColor = [UIColor colorWithRed:85/255.0 green:177/255.0 blue:255/255.0 alpha:1.0];
    [horizontalCommitButton setTitle:@"提交" forState:UIControlStateNormal];
    [horizontalCommitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    horizontalCommitButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [horizontalCommitButton addTarget:self action:@selector(horizontalCommitButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [horizontalBottomBgView addSubview:horizontalCommitButton];
    
    
    //如果不能跳过，那么加返回按钮
    BOOL jump = [[self.visitorDict objectForKey:@"isJump"] boolValue];
    if (!jump) {
        [horizontalCommitButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(horizontalBottomBgView.mas_centerX).offset(-10);
            make.centerX.equalTo(horizontalBottomBgView);
            make.centerY.equalTo(horizontalBottomBgView);
            make.width.equalTo(@70);
            make.height.equalTo(@25);
        }];
        
        UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setImage:[UIImage imageNamed:@"player-back-button"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.maskView addSubview:leftButton];
        [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@28);
            make.left.equalTo(@16);
            make.width.and.height.equalTo(@30);
        }];
    }else{
        [horizontalCommitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(horizontalBottomBgView.mas_centerX).offset(-10);
            make.centerY.equalTo(horizontalBottomBgView);
            make.width.equalTo(@70);
            make.height.equalTo(@25);
        }];
        
        UIButton * horizontalJumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        horizontalJumpButton.backgroundColor = [UIColor clearColor];
        [horizontalJumpButton setTitle:@"跳过" forState:UIControlStateNormal];
        [horizontalJumpButton setTitleColor:[UIColor colorWithRed:85/255.0 green:177/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        horizontalJumpButton.titleLabel.font = [UIFont systemFontOfSize:13];
        horizontalJumpButton.layer.borderColor = [UIColor colorWithRed:85/255.0 green:177/255.0 blue:255/255.0 alpha:1.0].CGColor;
        horizontalJumpButton.layer.borderWidth = 1;
        [horizontalJumpButton addTarget:self action:@selector(horizontalJumpButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [horizontalBottomBgView addSubview:horizontalJumpButton];
        [horizontalJumpButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(horizontalBottomBgView.mas_centerX).offset(10);
            make.centerY.equalTo(horizontalBottomBgView);
            make.width.equalTo(@70);
            make.height.equalTo(@25);
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface DWVisitorCollectViewTableViewCell ()

@property(nonatomic,strong)UILabel * placeholderLabel;

@end

@implementation DWVisitorCollectViewTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.placeholderLabel = [[UILabel alloc]init];
        self.placeholderLabel.font = [UIFont systemFontOfSize:12];
        self.placeholderLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        self.placeholderLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.placeholderLabel];
        [_placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.width.equalTo(@60);
            make.height.equalTo(@12);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.textField = [[UITextField alloc]init];
        self.textField.backgroundColor = [UIColor whiteColor];
        self.textField.font = [UIFont systemFontOfSize:12];
        self.textField.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        self.textField.layer.borderWidth = 0.5;
        self.textField.layer.borderColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1].CGColor;
        [self.contentView addSubview:self.textField];
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.placeholderLabel.mas_right).offset(12);
            make.right.equalTo(@(-12));
            make.height.equalTo(@30);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

-(void)setMessageDict:(NSDictionary *)messageDict
{
    _messageDict = messageDict;
    
    self.placeholderLabel.text = [messageDict objectForKey:@"title"];
    NSMutableAttributedString * placeholderString = [[NSMutableAttributedString alloc] initWithString:[messageDict objectForKey:@"placeholder"] attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName: [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]}];
    self.textField.attributedPlaceholder = placeholderString;
    self.textField.text = [messageDict objectForKey:@"content"];

}

@end
