//
//  DWMainViewController.m
//  Demo
//
//  Created by zwl on 2019/4/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWMainViewController.h"
#import "DWMainCollectionViewCell.h"
#import "DWMemberViewController.h"
#import "DWVodPlayViewController.h"
#import "DWDownloadManagerViewController.h"
#import "DWUploadViewController.h"

#define VIDEOINFOURL     @"https://p.bokecc.com/demo/videoinfo.json"

@interface DWMainViewController ()

@property(nonatomic,strong)UIImageView * headerImageView;
@property(nonatomic,strong)NSMutableArray * videoList;

@end

@implementation DWMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //header
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    [self.collectionView registerClass:[DWMainCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    // Do any additional setup after loading the view.
    
    //** !! **
    /*
     若需修改视频数据。步骤如下
     1.注释掉reloadNetworkData 网络请求的方法。
     2.修改DWConfigurationManager.m，中的账号ID，APIKey。
     3.在reloadLoaclData，填写自己账号下的具体数据
     */
  
//    [self reloadLoaclData];
    [self reloadNetworkData];
}

-(void)reloadNetworkData
{
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:VIDEOINFOURL];
    
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [@"网络请求失败，请点击重试" showAlert];
            });
            return;
        }
        
        NSString * jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSArray * vodList = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];

//        NSLog(@"%@",vodList);
        for (NSDictionary * vodDict in vodList) {
            DWVodModel * vodModel = [[DWVodModel alloc]init];
            vodModel.videoId = [vodDict objectForKey:@"videoId"];
            vodModel.title = [vodDict objectForKey:@"videoTitle"];
            vodModel.time = [vodDict objectForKey:@"videoTime"];
            vodModel.imageUrl = [vodDict objectForKey:@"videoCover"];
            [self.videoList addObject:vodModel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            DWVodModel * vodModel = self.videoList.firstObject;
            [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:vodModel.imageUrl] placeholderImage:[UIImage imageNamed:@"icon_placeholder.png"]];
            [self.collectionView reloadData];
        });
    }];
    
    [task resume];
}

-(void)reloadLoaclData
{
    //请自行替换数据
    NSArray * videos = @[];
    
    for (int i = 0; i < videos.count; i++) {
        DWVodModel * vodModel = [[DWVodModel alloc]init];
        vodModel.videoId = [videos objectAtIndex:i];
        vodModel.title = [videos objectAtIndex:i];
        vodModel.time = @"展示time";
        vodModel.imageUrl = @"icon_placeholder.png";
        [self.videoList addObject:vodModel];
    }
    
    [self.collectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - action
-(void)userInfoButtonAction
{
    DWMemberViewController * memberVC = [[DWMemberViewController alloc]init];
    [self.navigationController pushViewController:memberVC animated:YES];
}

-(void)uploadButtonAction
{
    DWUploadViewController * uploadVC = [[DWUploadViewController alloc]init];
    [self.navigationController pushViewController:uploadVC animated:YES];
}

-(void)downloadButtonAction
{
    DWDownloadManagerViewController * downloadManagerVC = [[DWDownloadManagerViewController alloc]init];
    [self.navigationController pushViewController:downloadManagerVC animated:YES];
}

-(void)headerImageViewTap
{
    DWVodModel * vodModel = self.videoList.firstObject;
    if (!vodModel) {
        [@"暂无视频数据" showAlert];
        return;
    }

    DWVodPlayViewController * vodPlayVC = [[DWVodPlayViewController alloc]init];
    vodPlayVC.vodModel = vodModel;
    vodPlayVC.vidoeList = self.videoList;
    [self.navigationController pushViewController:vodPlayVC animated:YES];
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.videoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DWMainCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell
    [cell setVideoModel:[self.videoList objectAtIndex:indexPath.row] AndIsLeft:indexPath.row % 2 == 0 ? YES : NO];
        
    return cell;

}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerView" forIndexPath:indexPath];
        
        if (!self.headerImageView) {
            self.headerImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_placeholder"]];
            self.headerImageView.userInteractionEnabled = YES;
            [headerView addSubview:self.headerImageView];
            
            UITapGestureRecognizer * headerImageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerImageViewTap)];
            [self.headerImageView addGestureRecognizer:headerImageViewTap];
            
            [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.left.equalTo(@10);
                make.right.equalTo(@(-10));
                make.bottom.equalTo(@(-10));
            }];
        }

        return headerView;
    }
    
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DWVodModel * vodModel = [self.videoList objectAtIndex:indexPath.row];
    DWVodPlayViewController * vodPlayVC = [[DWVodPlayViewController alloc]init];
    vodPlayVC.vodModel = vodModel;
    vodPlayVC.vidoeList = self.videoList;
    [self.navigationController pushViewController:vodPlayVC animated:YES];
}

#pragma mark - init
-(void)initUI
{
    [self.navigationController.navigationBar setShadowImage:[[UIColor whiteColor] createImage]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:TitleFont(15),NSForegroundColorAttributeName:TitleColor_51}];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //导航功能按钮
    UIButton * userInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [userInfoButton setImage:[UIImage imageNamed:@"icon_photo.png"] forState:UIControlStateNormal];
    userInfoButton.frame = CGRectMake(0, 0, 40, 40);
    [userInfoButton addTarget:self action:@selector(userInfoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:userInfoButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton * uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uploadButton setImage:[UIImage imageNamed:@"icon_upload.png"] forState:UIControlStateNormal];
    uploadButton.frame = CGRectMake(0, 0, 40, 40);
    [uploadButton addTarget:self action:@selector(uploadButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem1 = [[UIBarButtonItem alloc]initWithCustomView:uploadButton];
    
    UIButton * downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadButton setImage:[UIImage imageNamed:@"icon_download.png"] forState:UIControlStateNormal];
    downloadButton.frame = CGRectMake(0, 0, 40, 40);
    [downloadButton addTarget:self action:@selector(downloadButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem2 = [[UIBarButtonItem alloc]initWithCustomView:downloadButton];

    self.navigationItem.rightBarButtonItems = @[rightItem2,rightItem1];
    
}

-(NSMutableArray *)videoList
{
    if (!_videoList) {
        _videoList = [[NSMutableArray alloc]init];
    }
    return _videoList;
}

- (BOOL)shouldAutorotate
{
    return NO;
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
