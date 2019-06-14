//
//  DWBatchDownloadChooseView.m
//  Demo
//
//  Created by zwl on 2019/1/23.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWBatchDownloadChooseView.h"
#import "DWBatchDownloadChooseTableViewCell.h"

@interface DWBatchDownloadChooseView () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView * maskView;
@property(nonatomic,strong) UIView * bgView;
@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) UIButton * cancelButton;
@property(nonatomic,strong) UIButton * sureButton;
@property(nonatomic,strong) NSArray * videoIds;

@end

@implementation DWBatchDownloadChooseView

-(instancetype)initWithVideoIds:(NSArray *)videoIds
{
    if (self == [super init]) {
        
        [DWAPPDELEGATE.window addSubview:self];
        self.hidden = YES;
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.superview);
        }];
        
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer * maskTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self.maskView addGestureRecognizer:maskTap];

        //处理数据
        NSMutableArray * dataArray = [NSMutableArray array];
        for (NSString * videoId in [videoIds copy]) {
            [dataArray addObject:[@{@"id":videoId,@"isSelect":@NO} mutableCopy]];
        }
        self.videoIds = dataArray;
        
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self).offset(-80);
//            make.height.equalTo(self).offset(-150);
            make.height.equalTo(@(ScreenHeight / 3.0 * 2));
        }];
        
        [self.bgView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bgView);
            make.top.equalTo(@16);
            make.width.equalTo(self.bgView).offset(-20);
            make.bottom.equalTo(self.bgView).offset(-40 - 16);
        }];
        [self.tableView reloadData];
        
        [self.bgView addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@30);
            make.top.equalTo(self.tableView.mas_bottom).offset(5);
            make.width.equalTo(@100);
            make.left.equalTo(@30);
        }];
        
        [self.bgView addSubview:self.sureButton];
        [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_cancelButton);
            make.top.equalTo(_cancelButton);
            make.width.equalTo(_cancelButton);
            make.right.equalTo(@(-30));
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - action
-(void)show
{
    self.hidden = NO;
}

-(void)dismiss
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self removeFromSuperview];
}

-(void)cancelButtonAction
{
    [self dismiss];
}

-(void)sureButtonAction
{
    //整理数据  输出
    if (self.finishBlock) {
        NSMutableArray * resultArray = [NSMutableArray array];
        [self.videoIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"isSelect"] boolValue]) {
                [resultArray addObject:[obj objectForKey:@"id"]];
            }
        }];
        self.finishBlock(resultArray);
    }
    
    [self dismiss];
}

-(void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationUnknown:{
            NSLog(@"旋转方向未知");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.width.equalTo(self).offset(-80);
                make.height.equalTo(@(ScreenHeight / 3.0 * 2));
            }];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.width.equalTo(self).offset(-80);
                make.height.equalTo(self).offset(-150);
            }];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.width.equalTo(self).offset(-80);
                make.height.equalTo(self).offset(-150);
            }];
        }
            break;
        default:
            break;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videoIds.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWBatchDownloadChooseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[DWBatchDownloadChooseTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }

    NSDictionary * model = [_videoIds objectAtIndex:indexPath.row];
    cell.model = model;
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * model = [_videoIds objectAtIndex:indexPath.row];
    [model setValue:[NSNumber numberWithBool:![[model objectForKey:@"isSelect"] boolValue]] forKey:@"isSelect"];
    if (![[model objectForKey:@"isSelect"] boolValue]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * model = [_videoIds objectAtIndex:indexPath.row];
    [model setValue:[NSNumber numberWithBool:![[model objectForKey:@"isSelect"] boolValue]] forKey:@"isSelect"];
}

#pragma mark - layzload
-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
        _maskView.userInteractionEnabled = YES;
    }
    return _maskView;
}

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5;
    }
    return _bgView;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 44;
        _tableView.allowsMultipleSelection = YES;
    }
    return _tableView;
}

-(UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor:[UIColor redColor]];
        _cancelButton.layer.cornerRadius = 15;
        [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIButton *)sureButton
{
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        _sureButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setBackgroundColor:[UIColor greenColor]];
        _sureButton.layer.cornerRadius = 15;
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
