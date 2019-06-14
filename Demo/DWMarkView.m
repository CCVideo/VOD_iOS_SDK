//
//  DWMarkView.m
//  Demo
//
//  Created by luyang on 2018/1/12.
//  Copyright © 2018年 com.bokecc.www. All rights reserved.
//

#import "DWMarkView.h"

#import "DWVideoMarkModel.h"
#import "DWTools.h"
@interface DWMarkView()

@property (nonatomic,assign)CGFloat width;

@property (nonatomic,strong)UILabel *descLabel;

@property (nonatomic,strong)UILabel *timeLabel;

@property (nonatomic,strong)UIImageView *imageView;

@end

@implementation DWMarkView

- (instancetype)init{
    
    self =[super init];
    if (self) {
        
        [self loadSubviews];
    }
    
    return self;
}

- (void)setMarkModel:(DWVideoMarkModel *)markModel{
    
    _markModel =markModel;
    
    [self updateFrame];
    
}

- (void)updateFrame{
    
    NSString *timeStr =[DWTools formatSecondsToString:_markModel.marktime];
    CGSize timeSize =[self widthWithHeight:12 andFont:12 andLabelText:timeStr];
    _timeLabel.text =timeStr;
    _timeLabel.frame =CGRectMake(30/4,8,timeSize.width,timeSize.height);
    
    CGSize size =[self widthWithHeight:12 andFont:12 andLabelText:_markModel.markdesc];
    _descLabel.frame =CGRectMake(CGRectGetMaxX(_timeLabel.frame)+16/4,8, size.width, size.height);
    _descLabel.text =_markModel.markdesc;
    
    _imageView.frame =CGRectMake(CGRectGetMaxX(_descLabel.frame)+5,(30-16)/2,16,16);
    
    self.width =30/4+timeSize.width+16/4+size.width+5+16+25/4;
    
}

- (void)loadSubviews{
    
    
    _descLabel =[[UILabel alloc]init];
    _descLabel.font =[UIFont systemFontOfSize:12];
    _descLabel.textColor =[DWTools colorWithHexString:@"#ffffff"];
    [self addSubview:_descLabel];
    
 
    _timeLabel =[[UILabel alloc]init];
    _timeLabel.font =[UIFont systemFontOfSize:12];
    _timeLabel.textColor =[DWTools colorWithHexString:@"#ffffff"];
    [self addSubview:_timeLabel];
    
    _imageView =[[UIImageView alloc]init];
    _imageView.image =[UIImage imageNamed:@"markplay"];
    _imageView.layer.cornerRadius =16/2;
    _imageView.layer.masksToBounds =YES;
    [self addSubview:_imageView];
    
    
}

/**
 *  计算字符串宽度
 *
 *  @param height 字符串的高度
 *  @param font  字体大小
 *
 *  @return 字符串的尺寸
 */
- (CGSize)widthWithHeight:(CGFloat)height andFont:(CGFloat )font andLabelText:(NSString *)text{
   
    NSDictionary *dict =[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:font] forKey:NSFontAttributeName];
    CGRect rect=[text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    
    return rect.size;
}

@end
