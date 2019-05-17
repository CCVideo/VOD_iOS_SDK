//
//  DWBatchDownloadChooseTableViewCell.m
//  Demo
//
//  Created by zwl on 2019/1/23.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWBatchDownloadChooseTableViewCell.h"

@interface DWBatchDownloadChooseTableViewCell ()

@property(nonatomic,strong)UILabel * titleLabel;

@end

@implementation DWBatchDownloadChooseTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
    }
    return self;
}

-(void)setModel:(NSDictionary *)model
{
    _model = model;
    
    self.titleLabel.text = [model objectForKey:@"id"];
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
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
