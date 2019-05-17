//
//  DWMenuListView.m
//  Demo
//
//  Created by zwl on 2018/11/13.
//  Copyright © 2018 com.bokecc.www. All rights reserved.
//

#import "DWMenuListView.h"

@interface DWMenuListView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView * maskView;
@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) NSArray * listArray;

@end

@implementation DWMenuListView

-(instancetype)initWithRelativeView:(UIView *)relativeView AndMenuList:(NSArray *)menuList;
{
    if (self == [super init]) {
        
        [DWAPPDELEGATE.window addSubview:self];
        self.hidden = YES;
        
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
        [self addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UITapGestureRecognizer * maskTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [self.maskView addGestureRecognizer:maskTap];
        
        self.listArray = [menuList copy];
        
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
        //计算tableview frame
        CGRect relativeFrame = [self convertRect:relativeView.frame fromView:relativeView.superview];

//        ScreenWidth - (ScreenWidth - CGRectGetMaxX(relativeFrame)) - 78
        CGRect tableFrame = CGRectMake(ScreenWidth - (ScreenWidth - CGRectGetMaxX(relativeFrame)) - 78, CGRectGetMaxY(relativeFrame) + 5, 78, self.listArray.count * 30);
        self.tableView.frame = tableFrame;
        [self addSubview:self.tableView];
        [self.tableView reloadData];
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
    [self removeFromSuperview];
}

#pragma mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.backgroundColor = self.tableView.backgroundColor;
    
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = [self.listArray objectAtIndex:indexPath.row];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    if (self.didSelectBlock) {
        self.didSelectBlock(indexPath.row);
    }
    
    [self dismiss];
}

#pragma mark - layzload
-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
    }
    return _maskView;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 30;
        _tableView.layer.masksToBounds = YES;
        _tableView.layer.cornerRadius = 8;
        _tableView.backgroundColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:0.1];
        _tableView.layer.borderColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.1].CGColor;
        _tableView.layer.borderWidth = 1;
    }
    return _tableView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
