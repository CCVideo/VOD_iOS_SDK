//
//  DWVodPlayTableViewCell.m
//  Demo
//
//  Created by zwl on 2019/4/15.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWVodPlayTableViewCell.h"

@interface DWVodPlayTableViewCell ()

@property(nonatomic,strong)UIImageView * iconImageView;
@property(nonatomic,strong)UILabel * titleLabel;
@property(nonatomic,strong)UILabel * timeLabel;
@property(nonatomic,strong)UIButton * selectButton;
@property(nonatomic,strong)DWVodModel * vodModel;

@end

@implementation DWVodPlayTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
       
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.iconImageView = [[UIImageView alloc]init];
        self.iconImageView.layer.masksToBounds = YES;
        self.iconImageView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.top.equalTo(@7.5);
            make.bottom.equalTo(@(-7.5));
            make.width.equalTo(@160);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = TitleFont(14);
        self.titleLabel.textColor = TitleColor_51;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(10);
            make.right.equalTo(@(-10));
            make.top.equalTo(self.iconImageView).offset(10);
            make.height.equalTo(@14);
        }];
        
        self.timeLabel = [[UILabel alloc]init];
        self.timeLabel.font = TitleFont(13);
        self.timeLabel.textColor = TitleColor_102;
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
            make.height.equalTo(@13);
        }];
        
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectButton setImage:[UIImage imageNamed:@"icon_download_normal.png"] forState:UIControlStateNormal];
        [self.selectButton setImage:[UIImage imageNamed:@"icon_download_select.png"] forState:UIControlStateSelected];
        self.selectButton.hidden = YES;
        [self.selectButton addTarget:self action:@selector(selectButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.selectButton];
        [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.width.and.height.equalTo(@30);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

//-(void)setVodModel:(DWVodModel *)vodModel
-(void)setVodModel:(DWVodModel *)vodModel AndPlaying:(BOOL)isPlaying
{
    _vodModel = vodModel;
    
    if ([self.reuseIdentifier isEqualToString:@"CellStyleDefault"]) {
        
        self.selectButton.hidden = YES;
        
        [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
        }];
    }else{
        
        self.selectButton.hidden = NO;
        
        self.selectButton.selected = vodModel.isSelect;

        [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@50);
        }];
    }
    
    if ([vodModel.imageUrl hasPrefix:@"http"]) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:vodModel.imageUrl] placeholderImage:[UIImage imageNamed:@"icon_placeholder.png"]];
    }else{
        self.iconImageView.image = [UIImage imageNamed:vodModel.imageUrl];
    }
    
    if (isPlaying) {
        self.titleLabel.textColor = [UIColor colorWithRed:255/255.0 green:146/255.0 blue:10/255.0 alpha:1];
    }else{
        self.titleLabel.textColor = TitleColor_51;
    }
    
    self.titleLabel.text = vodModel.title;
    self.timeLabel.text = vodModel.time;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

-(void)selectButtonAction
{
    self.selectButton.selected = !self.selectButton.selected;
    
    self.vodModel.isSelect = self.selectButton.selected;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
