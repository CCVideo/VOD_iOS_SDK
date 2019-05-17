//
//  DWNetworkMonitorViewController.m
//  Demo
//
//  Created by zwl on 2018/11/13.
//  Copyright © 2018 com.bokecc.www. All rights reserved.
//

#import "DWNetworkMonitorViewController.h"
#import "DWNetworkMonitor.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface DWNetworkMonitorViewController ()

//@property(nonatomic,strong)dispatch_queue_t queue;
//@property(nonatomic,assign)CFRunLoopRef networkMonitorRunloop;
//标题
@property(nonatomic,strong)UILabel * titleLabel;
//文本框
@property(nonatomic,strong)UITextView * textView;
@property(nonatomic,strong)UIButton * copyInfoButton;
@property(nonatomic,strong)UIButton * repeatTestButton;

//ping
@property(nonatomic,strong)DWNetworkMonitor * networkMonitor;

@property(nonatomic,strong) NSMutableString * allTextOutput;
@property(nonatomic,strong) NSString * vid;
//开始网络测试 等等等 状态描述
@property(nonatomic,strong) NSString * networkDescription;
@property(nonatomic,strong) Reachability * reachability;
@property(nonatomic,strong) NSString * networkStatus;
@property(nonatomic,strong) NSString * localIP;
//@property(nonatomic,strong) NSString * city;
@property(nonatomic,strong) NSString * hostName;
@property(nonatomic,strong) NSArray * packets;
//判断是否需要ping 节点
@property(nonatomic,assign) BOOL isPingNode;

@end

@implementation DWNetworkMonitorViewController

-(instancetype)initWithVideoId:(NSString *)vid
{
    if (self == [super init]) {
                
        //增加网络状态监听
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
        NetworkStatus status = [_reachability currentReachabilityStatus];
        switch (status) {
            case NotReachable:{
                self.networkStatus = @"未知";
            }
                break;
            case ReachableViaWiFi:{
                self.networkStatus = @"WIFI";
            }
                break;
            case ReachableViaWWAN:{
                self.networkStatus = @"流量";
            }
                break;
            default:
                break;
        }

        self.isPingNode = NO;
        self.allTextOutput = [[NSMutableString alloc]init];
        self.vid = [vid copy];
        self.networkDescription = @"开始检测网络...";
        self.title = @"网络检测";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPingNotification) name:UIApplicationWillResignActiveNotification object:nil];
        
    }
    return self;
}

-(void)stopPingNotification
{
    //进入后台，ping会断开连接，这里停止检测
    if (self.networkMonitor.isPinging) {
        [self.networkMonitor stopPing];
    }
    self.networkMonitor = nil;
}

//销毁
-(void)destroyNoti
{
    if (self.networkMonitor.isPinging) {
        [self.networkMonitor stopPing];
    }
    self.networkMonitor = nil;
    
    [self.reachability stopNotifier];
    self.reachability = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton * returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.frame = CGRectMake(0, 0, 44, 44);
    [returnButton setImage:[UIImage imageNamed:@"player-back-button_black"] forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(returnButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:returnButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.right.equalTo(@(-15));
        make.top.equalTo(@100);
        make.height.equalTo(@15);
    }];
    
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(40 - 10);
        make.left.equalTo(@(15 - 4));
        make.right.equalTo(@(-15 + 4));
        make.bottom.equalTo(@(-35 - 40 - 20));
    }];
    
    [self.view addSubview:self.copyInfoButton];
    [self.copyInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-35));
        make.width.equalTo(@150);
        make.height.equalTo(@40);
        make.right.equalTo(self.view.mas_centerX).offset(-10);
    }];
    
    [self.view addSubview:self.repeatTestButton];
    [self.repeatTestButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_copyInfoButton);
        make.width.and.height.equalTo(_copyInfoButton);
        make.left.equalTo(self.view.mas_centerX).offset(10);
    }];
    
    //设置基础数据显示
    NSMutableAttributedString * tAttrString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"视频ID %@",self.vid]];
    [tAttrString addAttribute:NSForegroundColorAttributeName value:[DWTools colorWithHexString:@"#333333"] range:NSMakeRange(5, self.vid.length)];
    self.titleLabel.attributedText = tAttrString;
    
    [self appendString:[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"测试信息\nVideoID:%@\n%@\n当前网络是:%@\n本地出口ip:%@\nping %@\n",self.vid,self.networkDescription,self.networkStatus,self.localIP,self.hostName]]];
    
    [self start];
  
}

//开始ping
-(void)start
{
//    __weak typeof(self) weakSelf = self;
    //这里根据自己检测逻辑，ping节点即可
    dispatch_queue_t t = dispatch_queue_create("NetworkMonitor.queue.create", NULL);

    dispatch_async(t, ^{
        [self startMainPing];
    });
    
    dispatch_barrier_async(t, ^{
        [self startNodePing];
    });
}

//检测bokecc.com
-(void)startMainPing
{
    DWNetworkMonitor * networkMonitor = [[DWNetworkMonitor alloc]initWithPingHostName:self.hostName];
    networkMonitor.finishBlock = ^(NSArray *packets) {
        
//        __strong typeof(weakSelf) strongSelf = weakSelf;
    
        NSInteger packetNum = 0;
        NSInteger receiveNum = 0;
        double time = 0.0;
        for (DWNetworkMonitoringItem * item in packets) {
            
            packetNum++;
            NSString * pingStr = nil;
            if (item.networkDelay == -1) {
                //丢包 没收到received
                pingStr = [NSString stringWithFormat:@"发送%ld字节至 %@ timeout\n",item.packetBytes,item.addressIP];
            }else{
                receiveNum++;
                NSString * networkDelay = [NSString stringWithFormat:@"%.2f",item.networkDelay];
                time += [networkDelay doubleValue];
                pingStr = [NSString stringWithFormat:@"发送%ld字节至 %@ 耗时 %@ ms\n",item.packetBytes,item.addressIP,networkDelay];
            }
            //            [self.allTextOutput appendString:pingStr];
            [self appendString:pingStr];
        }
        
        [self appendString:[NSString stringWithFormat:@"%ld packets transmitted,%ld received,%ld%% packet loss,time %.2lfms\n",packetNum,receiveNum,(NSInteger)(((packetNum - receiveNum) / (double)packetNum) * 100),time]];
        
        if (receiveNum != 0) {
            //如果ping不通，后面的也不需要执行了
            self.isPingNode = YES;
        }
        
        //            [strongSelf startNodePing];
        
    };
    [networkMonitor startPing];
    self.networkMonitor = networkMonitor;
    CFRunLoopRun();
}

//检测当前节点
-(void)startNodePing
{
//    __weak typeof(self) weakSelf = self;
    //没ping同，或者主节点为检测
    if (!self.isPingNode || !self.networkMonitor) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _repeatTestButton.selected = NO;
        });
        return;
    }

    [self appendString:[NSString stringWithFormat:@"当前播放节点%@\n",self.currentPlayurl]];
    NSURL * url = [NSURL URLWithString:self.currentPlayurl];

    [self appendString:[NSString stringWithFormat:@"正在检查与服务器 %@ 的连接信息\n",url.host]];

    //ping 当前播放路径
    DWNetworkMonitor * networkMonitor = [[DWNetworkMonitor alloc]initWithPingHostName:url.host];
    networkMonitor.finishBlock = ^(NSArray *packets) {
        
        //            __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [self replaceOldStr:self.networkDescription AndNewStr:@"检测完毕"];
        self.networkDescription = @"检测完毕";
        
        NSInteger packetNum = 0;
        NSInteger receiveNum = 0;
        double time = 0.0;
        for (DWNetworkMonitoringItem * item in packets) {
            
            packetNum++;
            NSString * pingStr = nil;
            if (item.networkDelay == -1) {
                //丢包 没收到received
                pingStr = [NSString stringWithFormat:@"发送%ld字节至 %@ timeout\n",item.packetBytes,item.addressIP];
            }else{
                receiveNum++;
                NSString * networkDelay = [NSString stringWithFormat:@"%.2f",item.networkDelay];
                time += [networkDelay doubleValue];
                pingStr = [NSString stringWithFormat:@"发送%ld字节至 %@ 耗时 %@ ms\n",item.packetBytes,item.addressIP,networkDelay];
            }
            [self appendString:pingStr];
        }
        
        [self appendString:[NSString stringWithFormat:@"%ld packets transmitted,%ld received,%ld%% packet loss,time %.2lfms\n",packetNum,receiveNum,(NSInteger)(((packetNum - receiveNum) / (double)packetNum) * 100),time]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.repeatTestButton.selected = NO;
        });
    };
    [networkMonitor startPing];
    self.networkMonitor = networkMonitor;
    CFRunLoopRun();
}

//增加数据显示
-(void)appendString:(NSString *)str
{
    [self.allTextOutput appendString:str];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = self.allTextOutput;
    });
}

//替换显示数据
-(void)replaceOldStr:(NSString *)oldStr AndNewStr:(NSString *)newStr
{
    NSRange range = [self.allTextOutput rangeOfString:oldStr];
    [self.allTextOutput replaceCharactersInRange:range withString:newStr];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = self.allTextOutput;
    });
}

#pragma mark - action
-(void)returnButtonAction
{
    [self destroyNoti];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)networkStateChange
{
    NSString * oldStatus = self.networkStatus;
    NetworkStatus status = [_reachability currentReachabilityStatus];
    switch (status) {
        case NotReachable:{
            self.networkStatus = @"未知";
        }
            break;
        case ReachableViaWiFi:{
            self.networkStatus = @"WIFI";
        }
            break;
        case ReachableViaWWAN:{
            self.networkStatus = @"流量";
        }
            break;
        default:
            break;
    }
    
    [self replaceOldStr:oldStatus AndNewStr:self.networkStatus];
}

-(void)copyInfoButtonAction
{
    //复制信息
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _textView.text;
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"复制成功";
    [hud hideAnimated:YES afterDelay:3];
}

-(void)repeatTestButtonAction
{
    if (_repeatTestButton.selected) {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"正在检测中，请稍后";
        [hud hideAnimated:YES afterDelay:3];
        return;
    }
    
    _repeatTestButton.selected = YES;
    
    //清空文字
    [self.allTextOutput setString:[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"测试信息\nVideoID:%@\n%@\n当前网络是:%@\n本地出口ip:%@\nping %@\n",self.vid,self.networkDescription,self.networkStatus,self.localIP,self.hostName]]];
    self.textView.text = self.allTextOutput;
    
    //重新检测
    [self start];

}
    
#pragma mark - lazyload
//-(dispatch_queue_t)queue
//{
//    if (!_queue) {
//        _queue = dispatch_queue_create("NetworkMonitor.queue.create", NULL);
//    }
//    return _queue;
//}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [DWTools colorWithHexString:@"#ff920a"];
        _titleLabel.text = @"视频ID";
    }
    return _titleLabel;
}

-(UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc]init];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.textColor = [DWTools colorWithHexString:@"#333333"];
        _textView.showsVerticalScrollIndicator = NO;
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.editable = NO;
    }
    return _textView;
}

-(UIButton *)copyInfoButton
{
    if (!_copyInfoButton) {
        _copyInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_copyInfoButton setTitle:@"复制检测信息" forState:UIControlStateNormal];
        [_copyInfoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _copyInfoButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_copyInfoButton setBackgroundImage:[UIImage imageNamed:@"networkMonitor_copy.png"] forState:UIControlStateNormal];
        [_copyInfoButton addTarget:self action:@selector(copyInfoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _copyInfoButton;
}

-(UIButton *)repeatTestButton
{
    if (!_repeatTestButton) {
        _repeatTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatTestButton setTitle:@"重新测试" forState:UIControlStateNormal];
        [_repeatTestButton setTitle:@"测试中" forState:UIControlStateSelected];
        [_repeatTestButton setTitleColor:[DWTools colorWithHexString:@"#ff920a"] forState:UIControlStateNormal];
        _repeatTestButton.titleLabel.font = [UIFont systemFontOfSize:15];
//        [_repeatTestButton setBackgroundImage: forState:UIControlStateNormal];
        _repeatTestButton.layer.masksToBounds = YES;
        _repeatTestButton.layer.cornerRadius = 20;
        _repeatTestButton.layer.borderWidth = 1;
        _repeatTestButton.layer.borderColor = [DWTools colorWithHexString:@"#ff920a"].CGColor;
        _repeatTestButton.selected = YES;
        [_repeatTestButton addTarget:self action:@selector(repeatTestButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _repeatTestButton;
}

-(NSString *)localIP
{
    return [[DWTools getIPAddress] isEqualToString:@"error"] ? @"未获取到ip" : [DWTools getIPAddress];
}

-(NSString *)hostName
{
    return @"p.bokecc.com";
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
