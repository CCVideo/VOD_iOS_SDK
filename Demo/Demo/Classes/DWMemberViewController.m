//
//  DWMemberViewController.m
//  Demo
//
//  Created by zwl on 2019/4/12.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWMemberViewController.h"
#import "DWMemberGeneralButton.h"

@interface DWMemberViewController ()

@property(nonatomic,weak)DWConfigurationManager * configurationManager;

@property(nonatomic,strong)UIScrollView * bgScrollView;
@property(nonatomic,strong)UIView * infoBgView; //个人信息
@property(nonatomic,strong)UITextField * userIDTextField; //CC_userid
@property(nonatomic,strong)UITextField * apiKeyTextField; //CC_apikey
@property(nonatomic,strong)UIView * veriBgView; //授权验证
@property(nonatomic,strong)UITextField * veriTextField; //授权验证码
//@property(nonatomic,strong)UIView * playBgView; //播放模式
//@property(nonatomic,strong)UIView * downloadBgView; //下载模式
@property(nonatomic,strong)UIView * adBgView; //广告功能

@end

@implementation DWMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.configurationManager = [DWConfigurationManager sharedInstance];
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeAction) name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - action
-(void)endEditTapAction
{
    [self.view endEditing:YES];
}

-(void)adModelButtonAction:(DWMemberGeneralButton *)button
{
    // 300 + i
    if (self.configurationManager.isOpenAd && button.tag == 300) {
        return;
    }
    if (!self.configurationManager.isOpenAd && button.tag == 301) {
        return;
    }
    
    button.selected = !button.selected;
    
    NSInteger frontIndex = button.tag == 300 ? 301 : 300;
    DWMemberGeneralButton * frontButton = (DWMemberGeneralButton *)[_bgScrollView viewWithTag:frontIndex];
    frontButton.selected = NO;
    self.configurationManager.isOpenAd = !self.configurationManager.isOpenAd;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.configurationManager.isOpenAd] forKey:@"isOpenAD"];
}

-(void)textFieldDidChangeAction
{
    if (self.userIDTextField.isFirstResponder) {
        //修改userID
        self.configurationManager.DWAccount_userId = self.userIDTextField.text;
    }
    if (self.apiKeyTextField.isFirstResponder) {
        //修改apikey
        self.configurationManager.DWAccount_apikey = self.apiKeyTextField.text;
    }
    if (self.veriTextField.isFirstResponder) {
        //修改授权验证码
        self.configurationManager.verification = self.veriTextField.text;
    }
}

#pragma mark - init
-(void)initUI
{
    self.title = @"个人中心";
    
    //bgScrollView
    self.bgScrollView = [[UIScrollView alloc]init];
    [self.view addSubview:self.bgScrollView];
    [_bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UITapGestureRecognizer * sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditTapAction)];
    [self.bgScrollView addGestureRecognizer:sTap];
    
    //个人信息
    self.infoBgView = [[UIView alloc]init];
    [self.bgScrollView addSubview:self.infoBgView];
    [_infoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@(14 + 15 + 15 + 20 + 15));
    }];
    
    UILabel * infoTsLabel = [[UILabel alloc]init];
    infoTsLabel.text = @"个人信息";
    infoTsLabel.font = TitleFont(14);
    infoTsLabel.textColor = TitleColor_102;
    infoTsLabel.textAlignment = NSTextAlignmentLeft;
    [self.infoBgView addSubview:infoTsLabel];
    [infoTsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@(-10));
        make.top.equalTo(@0);
        make.height.equalTo(@14);
    }];
    
    NSArray * titles = @[@"User ID",@"API Key"];
    for (int i = 0; i < titles.count; i++) {
        UILabel * tsLabel = [[UILabel alloc]init];
        tsLabel.text = [titles objectAtIndex:i];
        tsLabel.font = TitleFont(15);
        tsLabel.textColor = TitleColor_51;
        tsLabel.textAlignment = NSTextAlignmentLeft;
        [self.infoBgView addSubview:tsLabel];
        [tsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(infoTsLabel);
            make.width.equalTo(@90);
            make.height.equalTo(@15);
            make.top.equalTo(infoTsLabel.mas_bottom).offset(15 + (20 + 15) * i);
        }];
        
        UITextField * textField = [[UITextField alloc]init];
        textField.font = TitleFont(15);
        textField.textColor = TitleColor_51;
        textField.textAlignment = NSTextAlignmentLeft;
        NSMutableAttributedString * placeholderAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"请输入%@",[titles objectAtIndex:i]] attributes: @{NSFontAttributeName:TitleFont(15),NSForegroundColorAttributeName:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0]}];
        textField.attributedPlaceholder = placeholderAttr;
        [self.infoBgView addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tsLabel.mas_right).offset(4);
            make.right.equalTo(@(-10));
            make.height.equalTo(tsLabel);
            make.centerY.equalTo(tsLabel);
        }];
        
        if (i == 0) {
            textField.text = self.configurationManager.DWAccount_userId;
            self.userIDTextField = textField;
        }else if (i == 1){
            textField.text = self.configurationManager.DWAccount_apikey;
            self.apiKeyTextField = textField;
        }
    }
    
    //授权验证
    self.veriBgView = [[UIView alloc]init];
    [self.bgScrollView addSubview:self.veriBgView];
    [_veriBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_infoBgView.mas_bottom).offset(35);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@(14 + 15 + 15));
    }];
    
    UILabel * veriTsLabel = [[UILabel alloc]init];
    veriTsLabel.text = @"授权码";
    veriTsLabel.font = TitleFont(14);
    veriTsLabel.textColor = TitleColor_102;
    veriTsLabel.textAlignment = NSTextAlignmentLeft;
    [self.veriBgView addSubview:veriTsLabel];
    [veriTsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@(-10));
        make.top.equalTo(@0);
        make.height.equalTo(@14);
    }];
    
    self.veriTextField = [[UITextField alloc]init];
    self.veriTextField.font = TitleFont(15);
    self.veriTextField.textColor = TitleColor_51;
    self.veriTextField.textAlignment = NSTextAlignmentLeft;
    self.veriTextField.text = self.configurationManager.verification;
    NSMutableAttributedString * placeholderAttr = [[NSMutableAttributedString alloc] initWithString:@"点击输入授权码" attributes: @{NSFontAttributeName:TitleFont(15),NSForegroundColorAttributeName:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0]}];
    self.veriTextField.attributedPlaceholder = placeholderAttr;
    [self.veriBgView addSubview:self.veriTextField];
    [_veriTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(veriTsLabel);
        make.right.equalTo(veriTsLabel);
        make.height.equalTo(@15);
        make.top.equalTo(veriTsLabel.mas_bottom).offset(15);
    }];
    
    CGFloat generalButtonWidth = (ScreenWidth - 10 * 3 - 20 * 2) / 3.0;
    
    //广告功能
    self.adBgView = [[UIView alloc]init];
    [self.bgScrollView addSubview:self.adBgView];
    [_adBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_downloadBgView.mas_bottom).offset(35);
        make.top.equalTo(_veriBgView.mas_bottom).offset(35);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@(14 + 15 + 30));
    }];
    
    UILabel * adTsLabel = [[UILabel alloc]init];
    adTsLabel.text = @"广告模式";
    adTsLabel.font = TitleFont(14);
    adTsLabel.textColor = TitleColor_102;
    adTsLabel.textAlignment = NSTextAlignmentLeft;
    [self.adBgView addSubview:adTsLabel];
    [adTsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@(-10));
        make.top.equalTo(@0);
        make.height.equalTo(@14);
    }];
    
    titles = @[@"开启",@"关闭"];
    for (int i = 0; i < titles.count; i++) {
        DWMemberGeneralButton * button = [[DWMemberGeneralButton alloc]initWithTitle:[titles objectAtIndex:i]];
        button.tag = 300 + i;
        [button addTarget:self action:@selector(adModelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.adBgView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(10 + (generalButtonWidth + 20) * i));
            make.top.equalTo(adTsLabel.mas_bottom).offset(15);
            make.height.equalTo(@30);
            make.width.equalTo(@(generalButtonWidth));
        }];
        
        if (self.configurationManager.isOpenAd) {
            if (i == 0) {
                button.selected = YES;
            }
        }else{
            if (i == 1) {
                button.selected = YES;
            }
        }
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
