#import "DWPlayerViewController.h"
#import "DWPlayerTableViewCell.h"
#import "DWCustomPlayerViewController.h"



@interface DWPlayerViewController ()<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIAlertViewDelegate>{
    
    NSString *videoId;
    NSInteger indexPath;
    UIButton *btn;
    UITextField *myTextField;
    
}

@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic)NSArray *videoIds;
@property (nonatomic,strong)UIButton *inputButtton;
@property (nonatomic,copy)NSString *verifyCode;

@end

@implementation DWPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"播放";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"播放"
                                                        image:[UIImage imageNamed:@"tabbar-play"]
                                                          tag:0];
        if (IsIOS7) {
            self.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar-play-selected"];
        }
    }
    
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [btn setTitle:@"输入" forState:UIControlStateNormal];
    myTextField.hidden =YES;
    myTextField.text =nil;
    [myTextField resignFirstResponder];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    [self generateTestData];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    if (!IsIOS7) {
        // 20 为电池栏高度
        // 44 为导航栏高度
        // 49 为标签栏的高度
        frame.size.height = frame.size.height - 20 - 44 - 49;
    }
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.0f;
    [self.view addSubview:self.tableView];
    NSLog(@"self.view.frame:%@ self.tableView.frame: %@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.tableView.frame));
    
    [self loadInputButton];
    
    //右上角 手输入vid
    [self inputVidButton];
}

- (void)loadInputButton{
    
    btn =[UIButton buttonWithType:UIButtonTypeCustom];
    
//    btn.frame =CGRectMake(5,0,90,44);
    btn.frame =CGRectMake(0,0,44,44);
    btn.titleLabel.textAlignment =NSTextAlignmentCenter;
    btn.layer.cornerRadius =5;
    btn.layer.masksToBounds =YES;
    [btn setTitle:@"输入" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font =[UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(inputDeviceAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.navigationBar addSubview:btn];
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)inputVidButton
{
    UIBarButtonItem * vidButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"输入vid" style:UIBarButtonItemStyleDone target:self action:@selector(inputVidButtonAction)];
    self.navigationItem.rightBarButtonItem = vidButtonItem;
}

- (void)inputDeviceAction{
    
    if (!myTextField) {
        
        myTextField = [[UITextField alloc]initWithFrame:CGRectMake((ScreenWidth-260)/2,200,260, 50)];
        
        myTextField.backgroundColor = [UIColor lightGrayColor];
        
        //设置边框样式，只有设置了才会显示边框样式
        myTextField.hidden =NO;
        myTextField.borderStyle =UITextBorderStyleRoundedRect;
        myTextField.textAlignment = NSTextAlignmentLeft;
        //  myTextField.keyboardType =UIKeyboardTypePhonePad;
        myTextField.delegate =self;
        [self.view addSubview:myTextField];
        
        
    }else{
        
        myTextField.hidden =NO;
    }
    
   
    
    
}

-(void)inputVidButtonAction
{
    UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"输入vid" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    av.tag = 10086;
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *txtName = [av textFieldAtIndex:0];
    txtName.placeholder = @"请输入vid";
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10086) {
        //输入vid
        UITextField *txtName = [alertView textFieldAtIndex:0];
        NSLog(@"clickedButtonAtIndex %@",txtName.text);
        
        if (txtName.text.length == 0) {
            return;
        }
        
        if (buttonIndex == 1) {
            
            if (self.videoIds.count == 0) {
                self.videoIds = @[txtName.text];
            }else{
                NSMutableArray * ids = [NSMutableArray arrayWithArray:self.videoIds];
                [ids addObject:txtName.text];
                self.videoIds = ids;
            }
          
            [self.tableView reloadData];
        }
    }
}

# pragma mark - processer

- (void)generateTestData
{
    //TODO: 待播放视频ID，可根据需求自定义
    self.videoIds = @[];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    //返回一个BOOL值，YES代表允许编辑，NO不允许编辑.
    
    return YES;
    
}

//是否可以点击return按钮
-(BOOL)textFieldShouldReturn:(UITextField *)textField

{
    //返回一个BOOL值，指明是否允许在按下回车键时结束编辑
    self.verifyCode =textField.text;
    [self turnNext];
    return YES;
    
}

- (void)turnNext{
    
    
    [btn setTitle:[NSString stringWithFormat:@"输入%@",myTextField.text] forState:UIControlStateNormal];
    [myTextField resignFirstResponder];
    myTextField.hidden=YES;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.videoIds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"DWPlayerViewCorollerCellId";
    
    NSString *videoid = self.videoIds[indexPath.row];
    
    DWPlayerTableViewCell *cell = (DWPlayerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[DWPlayerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell.playButton addTarget:self action:@selector(playerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.playButton.tag = indexPath.row;
    }
    
    [cell setupCell:videoid];
    
    return cell;
}

- (void)playerButtonAction:(UIButton *)button
{
    indexPath = button.tag;
    videoId = self.videoIds[indexPath];
    self.verifyCode =myTextField.text;
    /*
    UIAlertController *playAlert = [UIAlertController alertControllerWithTitle:@"选择播放模式" message:nil preferredStyle:  UIAlertControllerStyleActionSheet];

    [playAlert addAction:[UIAlertAction actionWithTitle:@"普通版" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        //注意：根据项目需求来决定是否需要用单例来创建
        DWCustomPlayerViewController *player = [[DWCustomPlayerViewController alloc]init];
        player.playMode = NO;
        player.videoId = videoId;
        player.videos = self.videoIds;
        player.indexpath = indexPath;
     //   player.verificationCode =[NSString stringWithFormat:@"%ld",indexPath];
        player.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:player animated:NO];
        

    }]];
    [playAlert addAction:[UIAlertAction actionWithTitle:@"广告版" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        DWCustomPlayerViewController *player = [DWCustomPlayerViewController sharedInstance];
        player.playMode = YES;
        player.videoId = videoId;
        
        player.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:player animated:NO];

    }]];
    [playAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }]];
    [self presentViewController:playAlert animated:true completion:nil];
    */
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择播放模式" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"普通版", nil];
    
    [sheet addButtonWithTitle:@"广告版"];
    [sheet showInView:self.view];
    
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex ==1) {
        
        //注意：根据项目需求来决定是否需要用单例来创建
        DWCustomPlayerViewController *player = [[DWCustomPlayerViewController alloc]init];
        player.playMode = NO;
        player.videoId = videoId;
        player.videos = self.videoIds;
        player.indexpath = indexPath;
        player.verificationCode =_verifyCode;
        player.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:player animated:NO];
        
    }else if (buttonIndex ==2){
        
        
        DWCustomPlayerViewController *player = [[DWCustomPlayerViewController alloc]init];
        player.playMode = YES;
        player.videoId = videoId;
        player.verificationCode =_verifyCode;
        player.videos = self.videoIds;
        player.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:player animated:NO];
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
