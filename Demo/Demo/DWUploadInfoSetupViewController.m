#import "DWUploadInfoSetupViewController.h"

@interface DWUploadInfoSetupViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic)UITextField *titleTextField;
@property (strong, nonatomic)UITextField *tagTextField;
@property (strong, nonatomic)UITextField *descriptionTextField;
@property (strong, nonatomic)UITextView *descriptionTextView;

@property (strong, nonatomic)UITableView *tableView;

@end

@implementation DWUploadInfoSetupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"填写视频信息";
    }
    
    return self;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)]; UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadAction:)];
    
    self.navigationItem.rightBarButtonItem = uploadItem;
    self.navigationItem.leftBarButtonItem = cancelItem;
    CGFloat max = MAX(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat min = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGRect frame = CGRectMake(0, 0, max, min);
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 84;
    }
    
    return 46;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"DWUploadInfoSetupViewControllerCellId";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        switch (indexPath.row) {
            case 0:
                self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
                self.titleTextField.placeholder = @"标题 ";
                self.titleTextField.delegate = self;
                self.titleTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
                [cell.contentView addSubview:self.titleTextField];
                break;
                
            case 1:
                self.tagTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
                self.tagTextField.placeholder = @"标签";
                self.tagTextField.delegate = self;
                self.titleTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
                [cell.contentView addSubview:self.tagTextField];
                break;
                
            case 2:
                self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 84)];
                [cell.contentView addSubview:self.descriptionTextView];
                self.descriptionTextView.textAlignment  = NSTextAlignmentLeft;
                self.descriptionTextView.text = @"视频简介";
                self.descriptionTextView.font = [UIFont systemFontOfSize:14];
                break;
                
            default:
                break;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

# pragma mark - processer

- (void)cancelAction:(UIBarButtonItem *)item
{
    self.isCancel = YES;
    if (_backBlock) {
        
        _backBlock(YES,nil,nil,nil);
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)uploadAction:(UIBarButtonItem *)item
{
    self.videoTitle = self.titleTextField.text;
    self.videoTag = self.tagTextField.text;
    self.videoDescription = self.descriptionTextField.text;
    
    if (self.videoTitle == nil
        || [self.videoTitle length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"还没写视频标题(⊙o⊙)哦"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    if (_backBlock) {
        
        _backBlock(NO,_videoTitle,_videoTag,_videoDescription);
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didBackBlock:(BackBlock )block{
    
    _backBlock =block;
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 点击view空白处时，关闭键盘
    [self.titleTextField resignFirstResponder];
    [self.tagTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
}

@end
