//
//  DWMainCollectionViewCell.m
//  Demo
//
//  Created by zwl on 2019/4/11.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWMainCollectionViewCell.h"

@interface DWMainCollectionViewCell ()

@property(nonatomic,strong)UIImageView * iconImageView;
@property(nonatomic,strong)UILabel * titleLabel;

@end

@implementation DWMainCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.iconImageView.layer.masksToBounds = YES;
        self.iconImageView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.width.equalTo(self.contentView).offset(-10);
            make.height.equalTo(self.contentView).offset(-10 - 14);
        }];
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.width.equalTo(self.iconImageView);
            make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
            make.bottom.equalTo(@0);
        }];
        
    }
    return self;
}

-(void)setVideoModel:(DWVodModel *)vodModel AndIsLeft:(BOOL)isLeft
{
    if (isLeft) {
        [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
        }];
    }else{
        [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
        }];
    }
    
    if ([vodModel.imageUrl hasPrefix:@"http"]) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:vodModel.imageUrl] placeholderImage:[UIImage imageNamed:@"icon_placeholder.png"]];
    }else{
        self.iconImageView.image = [UIImage imageNamed:vodModel.imageUrl];
    }
    
    NSString * title = vodModel.title;
    NSMutableAttributedString * titleAttr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:TitleFont(14)}];
    self.titleLabel.attributedText = titleAttr;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.layer.cornerRadius = 5;
    }
    return _iconImageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = TitleColor_51;
    }
    return _titleLabel;
}

@end
