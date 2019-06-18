//
//  DWDifferentCell.m
//  Demo
//
//  Created by luyang on 2018/5/9.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import "DWDifferentCell.h"

@interface DWDifferentCell(){
    
    UILabel *questionLabel;
    UIView *rightView;
}

@end

@implementation DWDifferentCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews
{
    UILabel *classLabel =[[UILabel alloc]init];
    classLabel.text =@"课堂练习";
    classLabel.font =[UIFont systemFontOfSize:16];
    classLabel.textAlignment =NSTextAlignmentCenter;
    classLabel.textColor =[DWTools colorWithHexString:@"#52a4fa"];
    [self.contentView addSubview:classLabel];
    [classLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.width.mas_equalTo(128);
        make.height.mas_equalTo(32/2);
        make.centerX.mas_equalTo(self.contentView);
    }];
    
    questionLabel =[[UILabel alloc]init];
    questionLabel.font =[UIFont systemFontOfSize:14];
    questionLabel.textColor =[DWTools colorWithHexString:@"#333333"];
    questionLabel.numberOfLines =0;
    [self.contentView addSubview:questionLabel];
    [questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(classLabel.mas_bottom).offset(21);
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        make.bottom.mas_equalTo(self.contentView);
        
    }];
    
    UIView *leftView =[[UIView alloc]init];
    [self.contentView addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@(45/2));
        make.width.equalTo(@90);
        make.height.equalTo(@1);
    }];
    
    CAGradientLayer *leftLayer = [CAGradientLayer layer];
    leftLayer.frame = CGRectMake(0, 0, 90, 1);
    //设置渐变颜色数组,可以加透明度的渐变
    leftLayer.colors = @[(__bridge id)[DWTools colorWithHexString:@"#ffffff" alpha:0.f].CGColor,(__bridge id)[DWTools colorWithHexString:@"#52a4fa" alpha:1.f].CGColor];
    //设置渐变区域的起始和终止位置（范围为0-1）
    leftLayer.startPoint = CGPointMake(0, 0);
    leftLayer.endPoint = CGPointMake(1, 0);
    //  gradientLayer.locations = @[@0.1,@0.2];
    [leftView.layer addSublayer:leftLayer];
    
}

- (void)setQuestionModel:(DWVideoQuestionModel *)questionModel{
    
    _questionModel =questionModel;
 
    NSString * questionType = questionModel.multipleSelect ? @"多选" : @"单选";

    NSString * content = [NSString stringWithFormat:@"%@ 题目：%@",questionType,_questionModel.content];

    NSString *regexHttp = @"\\{[a-zA-z]+://[^\\s]*\\}";
    NSMutableAttributedString * qAttrString = [DWTools exchangeString:regexHttp withText:content imageName:nil];
    [qAttrString addAttribute:NSBackgroundColorAttributeName value:[DWTools colorWithHexString:@"#51a8f2"] range:NSMakeRange(0, questionType.length)];
    [qAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, questionType.length)];
    questionLabel.attributedText = qAttrString;

    rightView =[[UIView alloc]init];
    [self.contentView addSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-15));
        make.top.equalTo(@(45/2));
        make.width.equalTo(@90);
        make.height.equalTo(@1);
    }];
    CAGradientLayer *rightLayer = [CAGradientLayer layer];
    rightLayer.frame =  CGRectMake(0, 0, 90, 1);;
    rightLayer.colors = @[(__bridge id)[DWTools colorWithHexString:@"#52a4fa" alpha:1.f].CGColor,(__bridge id)[DWTools colorWithHexString:@"#ffffff" alpha:0.f].CGColor];
    rightLayer.startPoint = CGPointMake(0, 0);
    rightLayer.endPoint = CGPointMake(1, 0);
    [rightView.layer addSublayer:rightLayer];
}

@end
