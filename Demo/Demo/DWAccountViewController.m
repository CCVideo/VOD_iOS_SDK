#import "DWAccountViewController.h"
#import "DWUploadViewController.h"
#import "DWPlayerViewController.h"
#import "DWDownloadViewController.h"
#import "DWImageTitleButton.h"

@interface DWAccountViewController () <UITableViewDelegate, UITableViewDataSource>{
    
    UIButton *btn0;
    UIButton *btn1;
    UIButton *btn2;
}

@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic)NSArray *accountInfo;

@end

@implementation DWAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"账户信息";
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"账户"
                                                        image:[UIImage imageNamed:@"tabbar-user"]
                                                          tag:0];
        
        if (IsIOS7) {
            self.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar-user-selected"];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *userId = @{@"title" : @"User ID", @"content" : DWACCOUNT_USERID};
    NSDictionary *apiKey = @{@"title" : @"API Key", @"content" : DWACCOUNT_APIKEY};
    self.accountInfo = @[userId, apiKey];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.0;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableView];
    
    //1为视频 2为音频 0为视频+音频 若设置该参数默认为视频
    btn0 =[UIButton buttonWithType:UIButtonTypeCustom];
    btn0.frame =CGRectMake(30, 250, 90, 60);
    btn0.layer.cornerRadius =5;
    btn0.layer.masksToBounds =YES;
    [btn0 setTitle:@"视频+音频" forState:UIControlStateNormal];
    [btn0 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn0 setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    btn0.titleLabel.font =[UIFont systemFontOfSize:15];
    [btn0 addTarget:self action:@selector(mediatypeAction0) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn0];
    
    btn1 =[UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame =CGRectMake(150, 250, 60, 60);
    btn1.layer.cornerRadius =5;
    btn1.layer.masksToBounds =YES;
    [btn1 setTitle:@"视频" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    btn1.titleLabel.font =[UIFont systemFontOfSize:15];
    [btn1 addTarget:self action:@selector(mediatypeAction1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    btn2 =[UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame =CGRectMake(240, 250, 60, 60);
    btn2.layer.cornerRadius =5;
    btn2.layer.masksToBounds =YES;
    [btn2 setTitle:@"音频" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    btn2.titleLabel.font =[UIFont systemFontOfSize:15];
    [btn2 addTarget:self action:@selector(mediatypeAction2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];

}

- (void)mediatypeAction0{
    
    btn0.selected =!btn0.selected;
    btn1.selected =NO;
    btn2.selected =NO;
    
    if (btn0.selected) {
        
        DWAPPDELEGATE.mediatype =@"0";
    }
}

- (void)mediatypeAction1{
    
    btn1.selected =!btn1.selected;
    btn0.selected =NO;
    btn2.selected =NO;
    
    if (btn1.selected) {
        
        DWAPPDELEGATE.mediatype =@"1";
    }
    
}

- (void)mediatypeAction2{
    
    btn2.selected =!btn2.selected;
    btn0.selected =NO;
    btn1.selected =NO;
    
    if (btn2.selected) {
        
        DWAPPDELEGATE.mediatype =@"2";
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

# pragma mark - UITableViewDelegate

# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accountInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"DWAccountControllerCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
     if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    NSDictionary *info = [self.accountInfo objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [info objectForKey:@"title"];
    cell.detailTextLabel.text = [info objectForKey:@"content"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0];
    
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    
    return cell;
}


@end
