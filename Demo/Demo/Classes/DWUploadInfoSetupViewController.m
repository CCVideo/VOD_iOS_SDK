#import "DWUploadInfoSetupViewController.h"

@interface DWUploadInfoSetupViewController () <UITextFieldDelegate>

@property(nonatomic,strong)UITextField * userIdTextField;
@property(nonatomic,strong)UITextField * apiKeyTextField;
@property(nonatomic,strong)UITextField * titleTextField;
@property(nonatomic,strong)UITextField * tagTextField;
@property(nonatomic,strong)UITextView * descriptionTextView;

@property(nonatomic,strong)UIScrollView * bgScrollView;

@end

@implementation DWUploadInfoSetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CGRectGetMaxY(self.descriptionTextView.superview.frame) > self.bgScrollView.frame.size.height) {
        self.bgScrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.descriptionTextView.superview.frame) + 20);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - action
-(void)returnButtonAction
{
    if (_backBlock) {
        _backBlock(YES, nil, nil, nil, nil, nil);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)uploadAction:(UIBarButtonItem *)item
{
    if (self.userIdTextField.text.length == 0) {
        [@"请输入User ID" showAlert];
        return;
    }
    
    if (self.apiKeyTextField.text.length == 0) {
        [@"请输入API Key" showAlert];
        return;
    }
    
    if (self.titleTextField.text.length == 0) {
        [@"请输入视频标题" showAlert];
        return;
    }
    
    if (_backBlock) {
        self.backBlock(NO, self.userIdTextField.text, self.apiKeyTextField.text, self.titleTextField.text, self.tagTextField.text, self.descriptionTextView.text);
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)tapEndEditAction
{
    [self.view endEditing:YES];
}

- (void)didBackBlock:(BackBlock )block{
    
    _backBlock = block;
}

-(void)keyboardDidShowNotification:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    UIView * firstResponderBgView = nil;
    if (self.descriptionTextView.isFirstResponder) {
        firstResponderBgView = self.descriptionTextView.superview;
    }else{
        for (int i = 0; i <= 3; i++) {
            UITextField * textField = (UITextField *)[self.bgScrollView viewWithTag:100 + i];
            if (textField.isFirstResponder) {
                firstResponderBgView = textField.superview;
                break;
            }
        }
    }
    CGRect frame = [firstResponderBgView convertRect:firstResponderBgView.bounds toView:self.bgScrollView];
    if (CGRectGetMaxY(frame) > CGRectGetMaxY(self.bgScrollView.frame) - height) {
        [UIView animateWithDuration:0.33 animations:^{
            self.bgScrollView.contentOffset = CGPointMake(0, height);
        }];
    }
}

-(void)keyboardDidHideNotification:(NSNotification *)noti
{
    [UIView animateWithDuration:0.33 animations:^{
        self.bgScrollView.contentOffset = CGPointMake(0, 0);
    }];
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - init
-(void)initUI
{
    self.title = @"填写视频信息";
    
    UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(uploadAction:)];
    
    self.navigationItem.rightBarButtonItem = uploadItem;
    
    self.bgScrollView = [[UIScrollView alloc]init];
    self.bgScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.bgScrollView];
    [_bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEndEditAction)];
    [self.bgScrollView addGestureRecognizer:tap];
    
    UILabel * tsLabel = [[UILabel alloc]init];
    tsLabel.text = @"温馨提示:演示账号没有开通上传视频的权限，如需测试上传功能，请填写自己的账号信息";
    tsLabel.font = TitleFont(16);
    tsLabel.numberOfLines = 0;
    tsLabel.textColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0];
    [self.bgScrollView addSubview:tsLabel];
    [tsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@20);
        make.width.equalTo(@(ScreenWidth - 20));
        make.height.equalTo(@60);
    }];
    
    UIView * lastView = nil;
    NSArray * titles = @[@"请输入User ID",@"请输入API Key",@"请输入视频标题",@"请输入标签",@"请输入视频简介"];
    for (int i = 0; i < titles.count; i++) {
        UILabel * titleLabel = [[UILabel alloc]init];
        titleLabel.text = [titles objectAtIndex:i];
        titleLabel.font = TitleFont(14);
        titleLabel.textColor = TitleColor_51;
        [self.bgScrollView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.right.equalTo(@(-10));
//            make.top.equalTo(@(20 + (14 + 10 + 39 + 25) * i));
            make.top.equalTo(tsLabel.mas_bottom).offset(20 + (14 + 10 + 39 + 25) * i);
            make.height.equalTo(@14);
        }];
        
        UIView * bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor colorWithRed:243/255.0 green:244/255.0 blue:245/255.0 alpha:1.0];
        [self.bgScrollView addSubview:bgView];
        CGFloat bgViewHeight = 0;
        if (i == titles.count - 1) {
            bgViewHeight = 205;
            
            lastView = bgView;
        }else{
            bgViewHeight = 39;
        }

        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.width.equalTo(@(ScreenWidth - 20));
            make.top.equalTo(titleLabel.mas_bottom).offset(10);
            make.height.equalTo(@(bgViewHeight));
        }];
        
        if (i == titles.count - 1) {
            self.descriptionTextView = [[UITextView alloc]init];
            self.descriptionTextView.font = TitleFont(14);
            self.descriptionTextView.textColor = TitleColor_51;
            self.descriptionTextView.backgroundColor = bgView.backgroundColor;
            [bgView addSubview:self.descriptionTextView];
            [_descriptionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
                make.right.equalTo(@(-10));
                make.top.equalTo(@10);
                make.bottom.equalTo(@(-10));
            }];
            
        }else{
            UITextField * textfield = [[UITextField alloc]init];
            textfield.placeholder = [titles objectAtIndex:i];
            textfield.textColor = TitleColor_51;
            textfield.font = TitleFont(14);
            textfield.delegate = self;
            textfield.tag = 100 + i;
            textfield.clearButtonMode = UITextFieldViewModeUnlessEditing;
            [bgView addSubview:textfield];
            [textfield mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
                make.right.equalTo(@(-10));
                make.top.and.bottom.equalTo(@0);
            }];
            
            if (i == 0) {
                self.userIdTextField = textfield;
            }
            if (i == 1) {
                self.apiKeyTextField = textfield;
            }
            if (i == 2) {
                self.titleTextField = textfield;
            }
            if (i == 3) {
                self.tagTextField = textfield;
            }
        }
    }
    
}

@end
