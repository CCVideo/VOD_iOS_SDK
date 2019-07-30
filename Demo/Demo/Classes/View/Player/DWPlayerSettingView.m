//
//  DWPlayerSettingView.m
//  Demo
//
//  Created by zwl on 2019/4/17.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWPlayerSettingView.h"
#import "DWTableChooseModel.h"
#import "DWSettingFuncButton.h"

@interface DWPlayerSettingView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,assign)DWVodSettingStyle style;
@property(nonatomic,strong)UIView * bgView;

@property(nonatomic,strong)UIView * maskView;

@property(nonatomic,strong)NSArray * dataArray;
//DWVodSettingStyleListDefault DWVodSettingStyleListQuality DWVodSettingStyleListChooseSelection
@property(nonatomic,strong)UITableView * listTableView;
//DWVodSettingStyleListTotal
@property(nonatomic,strong)UIScrollView * bgScrollView;
@property(nonatomic,strong)UILabel * sizeLabel;
@property(nonatomic,strong)NSArray * sizeArray;
@property(nonatomic,strong)UILabel * subtitleLabel;
@property(nonatomic,strong)NSArray * subtitleArray;
@property(nonatomic,strong)UISlider * lightSlider;
@property(nonatomic,strong)UISlider * soundSlider;

@end

@implementation DWPlayerSettingView

static NSInteger setListTableHeight = 40;
static NSInteger setSectionListTableHeight = 60;

#pragma mark - public
-(instancetype)initWithStyle:(DWVodSettingStyle)style
{
    if (self == [super init]) {
        
        self.style = style;
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [self initUI];
        
    }
    return self;
}

-(void)setTableList:(NSArray *)listArray
{
    if (!listArray) {
        return;
    }
    
    self.dataArray = listArray;
    CGFloat cellHeight = 0;
    if (self.style == DWVodSettingStyleListChooseSelection) {
        cellHeight = setSectionListTableHeight;
        self.listTableView.frame = CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height);
    }else{
        cellHeight = setListTableHeight;
        CGFloat tableViewHeight = (self.dataArray.count * cellHeight) > self.bgView.frame.size.height ? self.bgView.frame.size.height : self.dataArray.count * cellHeight;
        self.listTableView.frame = CGRectMake(0, (self.bgView.frame.size.height - tableViewHeight) / 2.0, self.bgView.frame.size.width, tableViewHeight);
        if (tableViewHeight == self.bgView.frame.size.height) {
            self.listTableView.scrollEnabled = YES;
        }else{
            self.listTableView.scrollEnabled = NO;
        }
    }

    [self.listTableView reloadData];
}

-(void)setTotalMediaType:(BOOL)isVideo SizeList:(NSArray *)sizeList SubtitleList:(NSArray *)subTitleList DefaultLight:(CGFloat)light AndDefaultSound:(CGFloat)sound
{
    if (self.style != DWVodSettingStyleTotal) {
        return;
    }
    
    DWSettingFuncButton * mediaTypeButton = (DWSettingFuncButton *)[self.bgScrollView viewWithTag:102];
    mediaTypeButton.selected = isVideo;
    
    self.sizeArray = sizeList;
    CGFloat buttonWidth = self.bgView.frame.size.width / 4.0;
    for (int i = 0; i < self.sizeArray.count; i++) {
        UIButton * sizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sizeButton.frame = CGRectMake(buttonWidth * i, CGRectGetMaxY(self.sizeLabel.frame) + 15, buttonWidth, 14);
        sizeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        sizeButton.titleLabel.font = TitleFont(14);
        [sizeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sizeButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0] forState:UIControlStateSelected];
        sizeButton.tag = 200 + i;
        [sizeButton addTarget:self action:@selector(sizeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgScrollView addSubview:sizeButton];
        
        DWTableChooseModel * model = [self.sizeArray objectAtIndex:i];
        [sizeButton setTitle:model.title forState:UIControlStateNormal];
        sizeButton.selected = model.isSelect;
    }
    
    self.subtitleArray = subTitleList;
    for (int i = 0; i < self.subtitleArray.count; i++) {
        UIButton * subtitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        subtitleButton.frame = CGRectMake(buttonWidth * i, CGRectGetMaxY(self.subtitleLabel.frame) + 15, buttonWidth, 14);
        subtitleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleButton.titleLabel.font = TitleFont(14);
        [subtitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [subtitleButton setTitleColor:[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0] forState:UIControlStateSelected];
        subtitleButton.tag = 300 + i;
        [subtitleButton addTarget:self action:@selector(subtitleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgScrollView addSubview:subtitleButton];
        
        DWTableChooseModel * model = [self.subtitleArray objectAtIndex:i];
        [subtitleButton setTitle:model.title forState:UIControlStateNormal];
        subtitleButton.selected = model.isSelect;
    }
    
    //亮度
    UIImageView * lightLowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_setting_light_low.png"]];
    lightLowImageView.frame = CGRectMake(10, 257, 16, 16);
    [self.bgScrollView addSubview:lightLowImageView];

    self.lightSlider.frame = CGRectMake(CGRectGetMaxX(lightLowImageView.frame) + 8, 257, (self.bgView.frame.size.width - (CGRectGetMaxX(lightLowImageView.frame) + 8) * 2), 16);
    self.lightSlider.value = light;
    [self.bgScrollView addSubview:self.lightSlider];

    UIImageView * lightHighImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_setting_light_high.png"]];
    lightHighImageView.frame = CGRectMake(CGRectGetMaxX(self.lightSlider.frame) + 8, 257, 16, 16);
    [self.bgScrollView addSubview:lightHighImageView];
    
    //音量
    UIImageView * soundLowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_setting_sound_low.png"]];
    soundLowImageView.frame = CGRectMake(10, 312, 16, 16);
    [self.bgScrollView addSubview:soundLowImageView];
    
    self.soundSlider.frame = CGRectMake(CGRectGetMaxX(soundLowImageView.frame) + 8, 312, (self.bgView.frame.size.width - (CGRectGetMaxX(soundLowImageView.frame) + 8) * 2), 16);
    self.soundSlider.value = sound;
    [self.bgScrollView addSubview:self.soundSlider];
    
    UIImageView * soundHighImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_setting_sound_high.png"]];
    soundHighImageView.frame = CGRectMake(CGRectGetMaxX(self.soundSlider.frame) + 8, 312, 16, 16);
    [self.bgScrollView addSubview:soundHighImageView];
    
    if (CGRectGetMaxY(self.soundSlider.frame) > self.bgScrollView.frame.size.height) {
        self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.frame.size.width, CGRectGetMaxY(self.soundSlider.frame) + 20);
    }

}

-(void)show
{
    self.hidden = NO;
    
    [UIView animateWithDuration:0.33 animations:^{
        self.bgView.frame = CGRectMake(self.frame.size.width - self.bgView.frame.size.width, 0, self.bgView.frame.size.width, self.bgView.frame.size.height);
    }];
}

-(void)disAppear
{
    [UIView animateWithDuration:0.23 animations:^{
        self.bgView.frame = CGRectMake(self.frame.size.width, 0, self.bgView.frame.size.width , self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - action
-(void)funcButtonAction:(DWSettingFuncButton *)button
{
    // 100 + i
    if (button.tag == 100) {
        //下载
        if ([_delegate respondsToSelector:@selector(playerSettingViewDownloadAction)]) {
            [_delegate playerSettingViewDownloadAction];
        }
    }
    if (button.tag == 101) {
        //投屏
        if ([_delegate respondsToSelector:@selector(playerSettingViewScreeningAction)]) {
            [_delegate playerSettingViewScreeningAction];
        }
    }
    
    if (button.tag == 102) {
        //音视频切换
        button.selected = !button.selected;
        if ([_delegate respondsToSelector:@selector(playerSettingViewMediaTypeAction)]) {
            [_delegate playerSettingViewMediaTypeAction];
        }
    }
    if (button.tag == 103) {
        //网络检测
        if ([_delegate respondsToSelector:@selector(playerSettingViewNetworkMonitorAction)]) {
            [_delegate playerSettingViewNetworkMonitorAction];
        }
    }
}

-(void)sizeButtonAction:(UIButton *)button
{
    // 200 + i
    if (button.selected) {
        return;
    }
    
    [self.sizeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DWTableChooseModel * model = (DWTableChooseModel *)obj;
        if (model.isSelect) {
            UIButton * preButton = (UIButton *)[_bgView viewWithTag:idx + 200];
            preButton.selected = NO;
            model.isSelect = NO;
            *stop = YES;
        }
    }];
    
    button.selected = !button.selected;
    DWTableChooseModel * model = [self.sizeArray objectAtIndex:button.tag - 200];
    model.isSelect = YES;
    
    if ([_delegate respondsToSelector:@selector(playerSettingViewScreenSizeSelect)]) {
        [_delegate playerSettingViewScreenSizeSelect];
    }
}

-(void)subtitleButtonAction:(UIButton *)button
{
    if (button.selected) {
        return;
    }
    
    // 300 + i
    [self.subtitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DWTableChooseModel * model = (DWTableChooseModel *)obj;
        if (model.isSelect) {
            UIButton * preButton = (UIButton *)[_bgView viewWithTag:idx + 300];
            preButton.selected = NO;
            model.isSelect = NO;
            *stop = YES;
        }
    }];
    
    button.selected = !button.selected;
    DWTableChooseModel * model = [self.subtitleArray objectAtIndex:button.tag - 300];
    model.isSelect = YES;
    
    if ([_delegate respondsToSelector:@selector(playerSettingViewSubtitleSelect)]) {
        [_delegate playerSettingViewSubtitleSelect];
    }
}

-(void)lightSliderValueChange
{
    if ([_delegate respondsToSelector:@selector(playerSettingViewScreenLightChange:)]) {
        [_delegate playerSettingViewScreenLightChange:self.lightSlider.value];
    }
}

-(void)soundSliderValueChange
{
    if ([_delegate respondsToSelector:@selector(playerSettingViewSoundChange:)]) {
        [_delegate playerSettingViewSoundChange:self.soundSlider.value];
    }
}

#pragma mark - delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.style == DWVodSettingStyleListSpeed || self.style == DWVodSettingStyleListQuality || self.style == DWVodSettingStyleListChooseSelection) {
        return self.dataArray.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.style == DWVodSettingStyleListSpeed || self.style == DWVodSettingStyleListQuality) {
        return setListTableHeight;
    }
    if (self.style == DWVodSettingStyleListChooseSelection) {
        return setSectionListTableHeight;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.style == DWVodSettingStyleListSpeed || self.style == DWVodSettingStyleListQuality) {
        DWPlayerSettingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseListCell"];
        if (!cell) {
            cell = [[DWPlayerSettingTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ChooseListCell"];
        }
        
        cell.chooseModel = [self.dataArray objectAtIndex:indexPath.row];
        
        return cell;
    }
    if (self.style == DWVodSettingStyleListChooseSelection) {
        DWPlayerSelectionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SelectionListCell"];
        if (!cell) {
            cell = [[DWPlayerSelectionTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SelectionListCell"];
        }
        
        cell.chooseModel = [self.dataArray objectAtIndex:indexPath.row];
        DWVodModel * vodModel = [self.selectionList objectAtIndex:indexPath.row];
        [cell setSectionImage:vodModel.imageUrl];
        
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.style == DWVodSettingStyleListSpeed || self.style == DWVodSettingStyleListQuality) {
        DWTableChooseModel * chooseModel = [self.dataArray objectAtIndex:indexPath.row];
        if (chooseModel.isSelect) {
            return;
        }
    }
    
    if ([_delegate respondsToSelector:@selector(playerSettingViewStyle:AndSelectIndex:)]) {
        [_delegate playerSettingViewStyle:self.style AndSelectIndex:indexPath.row];
    }
}

#pragma mark - init
-(void)initUI
{
    self.maskView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.maskView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disAppear)];
    [self.maskView addGestureRecognizer:tap];
    
    CGFloat bgViewWidth = ScreenWidth / 3.0;
    self.bgView.frame = CGRectMake(self.frame.size.width, 0, bgViewWidth , self.frame.size.height);
    [self addSubview:self.bgView];
    
    if (self.style == DWVodSettingStyleListSpeed || self.style == DWVodSettingStyleListQuality || self.style == DWVodSettingStyleListChooseSelection) {
        self.listTableView = [[UITableView alloc]init];
        self.listTableView.delegate = self;
        self.listTableView.dataSource = self;
        self.listTableView.backgroundColor = [UIColor clearColor];
        self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.bgView addSubview:self.listTableView];
    }else{
        self.bgScrollView.frame = CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height);
        [self.bgView addSubview:self.bgScrollView];
        
        NSArray * titles = @[@"下载",@"投屏",@"视频播放",@"网络检测"];
        NSArray * images = @[@"icon_setting_dwonload.png",@"icon_screen_horizontal.png",@"icon_setting_video.png",@"icon_setting_network.png"];
        CGFloat buttonWidth = 48.0;
        CGFloat space = (self.bgView.frame.size.width - buttonWidth * titles.count - 10 * 2) / 2.0;
        for (int i = 0; i < titles.count; i++) {
            DWSettingFuncButton * button = [DWSettingFuncButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(10 + (buttonWidth + space) * i, 20, buttonWidth, 46);
            [button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[images objectAtIndex:i]] forState:UIControlStateNormal];
            if (i == 2) {
                [button setTitle:@"音频播放" forState:UIControlStateSelected];
                [button setImage:[UIImage imageNamed:@"icon_setting_radio.png"] forState:UIControlStateSelected];
            }
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = TitleFont(12);
            [button setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7] forState:UIControlStateNormal];
            button.tag = 100 + i;
            [button addTarget:self action:@selector(funcButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.bgScrollView addSubview:button];
        }
        
        self.sizeLabel.frame = CGRectMake(10, 103, self.sizeLabel.frame.size.width, self.sizeLabel.frame.size.height);
        [self.bgScrollView addSubview:self.sizeLabel];
        
        self.subtitleLabel.frame = CGRectMake(10, 180, self.subtitleLabel.frame.size.width, self.subtitleLabel.frame.size.height);
        [self.bgScrollView addSubview:self.subtitleLabel];
    }
}

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
    }
    return _maskView;
}

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.8];
    }
    return _bgView;
}

-(UIScrollView *)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc]init];
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.showsVerticalScrollIndicator = NO;
    }
    return _bgScrollView;
}

-(UILabel *)sizeLabel
{
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc]init];
        _sizeLabel.text = @"画面尺寸";
        _sizeLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
        _sizeLabel.font = TitleFont(12);
        [_sizeLabel sizeToFit];
    }
    return _sizeLabel;
}

-(UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.text = @"字幕设置";
        _subtitleLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
        _subtitleLabel.font = TitleFont(12);
        [_subtitleLabel sizeToFit];
    }
    return _subtitleLabel;
}

-(UISlider *)lightSlider
{
    if (!_lightSlider) {
        _lightSlider = [[UISlider alloc]init];
        [_lightSlider setMinimumTrackImage:[[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
        [_lightSlider setMaximumTrackImage:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
        [_lightSlider addTarget:self action:@selector(lightSliderValueChange) forControlEvents:UIControlEventValueChanged];
        [_lightSlider setThumbImage:[UIImage imageNamed:@"icon_play_circle.png"] forState:UIControlStateNormal];
    }
    return _lightSlider;
}

-(UISlider *)soundSlider
{
    if (!_soundSlider) {
        _soundSlider = [[UISlider alloc]init];
        [_soundSlider setMinimumTrackImage:[[UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
        [_soundSlider setMaximumTrackImage:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1] createImageWithSize:CGSizeMake(10, 3)] forState:UIControlStateNormal];
        [_soundSlider addTarget:self action:@selector(soundSliderValueChange) forControlEvents:UIControlEventValueChanged];
        [_soundSlider setThumbImage:[UIImage imageNamed:@"icon_play_circle.png"] forState:UIControlStateNormal];
    }
    return _soundSlider;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

/// ********************************** 邪恶的分割线 **********************************

@interface DWPlayerSettingTableViewCell ()

@property(nonatomic,strong)UILabel * titleLabel;

@end

@implementation DWPlayerSettingTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = TitleFont(15);
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
    }
    return self;
}

-(void)setChooseModel:(DWTableChooseModel *)chooseModel
{
    _chooseModel = chooseModel;
    
    self.titleLabel.text = _chooseModel.title;
    if (_chooseModel.isSelect) {
        self.titleLabel.textColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0];
    }else{
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

@end

/// ********************************** 邪恶的分割线 **********************************

@interface DWPlayerSelectionTableViewCell ()

@property(nonatomic,strong)UIImageView * iconImageView;
@property(nonatomic,strong)UILabel * titleLabel;

@end

@implementation DWPlayerSelectionTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.iconImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.top.equalTo(@7.5);
            make.bottom.equalTo(@(-7.5));
            make.width.equalTo(@80);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = TitleFont(15);
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(11);
            make.right.equalTo(@(-10));
            make.top.equalTo(@5);
            make.bottom.equalTo(@(-5));
        }];
        
    }
    return self;
}

-(void)setChooseModel:(DWTableChooseModel *)chooseModel
{
    _chooseModel = chooseModel;

    self.titleLabel.text = _chooseModel.title;
    if (_chooseModel.isSelect) {
        self.titleLabel.textColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1.0];
    }else{
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

-(void)setSectionImage:(NSString *)imageUrl
{
    if ([imageUrl hasPrefix:@"http"]) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"icon_placeholder.png"]];
    }else{
        self.iconImageView.image = [UIImage imageNamed:imageUrl];
    }
}


@end
