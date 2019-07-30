//
//  DWScreeningTableViewCell.m
//  Demo
//
//  Created by zwl on 2019/7/9.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWScreeningTableViewCell.h"

@interface DWScreeningTableViewCell ()

@property(nonatomic,strong)UIImageView * iconImageView;
@property(nonatomic,strong)UILabel * titleLabel;

@end

@implementation DWScreeningTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.iconImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_screen_list.png"]];
        [self.contentView addSubview:self.iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(@30);
            make.height.equalTo(@30);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = TitleFont(15);
        self.titleLabel.textColor = TitleColor_51;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(16);
            make.right.equalTo(@(-16));
            make.centerY.equalTo(self.iconImageView);
            make.height.equalTo(@15);
        }];
        
    }
    return self;
}

-(void)setDevice:(DWUPnPDevice *)device
{
    _device = device;
    
    self.titleLabel.text = device.friendlyName;
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
