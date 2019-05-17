//
//  DWQuestionCell.m
//  Demo
//
//  Created by luyang on 2018/2/9.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import "DWQuestionCell.h"

@interface DWQuestionCell(){
    
    UIButton *btn;
    UILabel *selectLabel;
    UILabel *label;
    UIButton *currentBtn;
    
}

@end


@implementation DWQuestionCell

- (instancetype )initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self =[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self loadSubviews];
        
    }
    
    return self;
}

- (void)loadSubviews{
    
    btn =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
  
    [self.contentView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(30);
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView.mas_left).offset(18);
        
    }];
    
    selectLabel =[[UILabel alloc]init];
    selectLabel.textColor =[DWTools colorWithHexString:@"#666666"];
    selectLabel.font =[UIFont systemFontOfSize:13];
    selectLabel.numberOfLines = 0;
    [self.contentView addSubview:selectLabel];
    [selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {

       make.left.mas_equalTo(btn.mas_right).offset(15);
       make.right.mas_equalTo(self.contentView.mas_right).offset(-37/2);
       make.centerY.top.bottom.mas_equalTo(self.contentView);

    }];
}

- (void)updateQuestion:(DWAnswerModel *)answerModel withMultipleSelect:(BOOL )multipleSelect{
    
    _answerModel =answerModel;
  //  selectLabel.text =answerModel.content;
   
//    answerModel.content =[answerModel.content stringByReplacingOccurrencesOfString:@"{" withString:@""];
//    answerModel.content =[answerModel.content stringByReplacingOccurrencesOfString:@"}" withString:@""];
//      NSString *regexHttp =@"http(s)?://([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";
    NSString *regexHttp = @"\\{[a-zA-z]+://[^\\s]*\\}";

    selectLabel.attributedText =[DWTools exchangeString:regexHttp withText:answerModel.content imageName:nil];
    
    UIImage *image;
    UIImage *selectImage;
    if (multipleSelect) {
        
        image =[UIImage imageNamed:@"multi"];
        selectImage =[UIImage imageNamed:@"multiSelect"];
        
    }else{
        
        image =[UIImage imageNamed:@"single"];
        selectImage =[UIImage imageNamed:@"singleSelect"];
        
        btn.layer.cornerRadius =10;
        btn.layer.masksToBounds =YES;
    }
    
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:selectImage forState:UIControlStateSelected];
}

#pragma mark-----按钮及cell点击事件
- (void)btnSelect:(UIButton *)btn{
    
    btn.selected =!btn.selected;
    if (_selectBlock) {
        
        _selectBlock(btn,btn.selected);
    }
    
 
}

- (void)didSelectBlock:(SelectBlock )block{
    
    _selectBlock =block;
}

@end
