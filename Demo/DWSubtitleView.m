//
//  DWSubtitleView.m
//  Demo
//
//  Created by zwl on 2019/1/7.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWSubtitleView.h"
#import "DWSubtitleAnalysis.h"

typedef enum : NSUInteger {
    DWSubtitleStyleNone,       //无字幕
    DWSubtitleStyleSingle,     //单字幕
    DWSubtitleStyleDouble,     //双字幕
} DWSubtitleStyle;

@interface DWSubtitleView ()

//字幕相关的数据 subtitleDict1永远是下方显示的字幕数据 subtitleDict2可能是nil
//@property(nonatomic,assign)NSInteger defaultSubtitle;
@property(nonatomic,strong)NSDictionary * subtitleDict1;
@property(nonatomic,strong)NSDictionary * subtitleDict2;

//字幕解析器
@property(nonatomic,strong)DWSubtitleAnalysis * subtitleAnalysis1;
@property(nonatomic,strong)DWSubtitleAnalysis * subtitleAnalysis2;

//当前的播放时间
@property(nonatomic,assign)float time;

@property(nonatomic,assign)DWSubtitleStyle style;

//字幕显示样式
@property(nonatomic,assign)NSInteger showStyle;

/*
 
 只有在设置了2种字幕的情况下，才会出现这种双字幕的模式
 如果只设置了一个字幕，则只用 subtitleLabel1
 
 */
@property(nonatomic,strong)UILabel * subtitleLabel1;
@property(nonatomic,strong)UILabel * subtitleLabel2;

//字幕相关设置
@property(nonatomic,strong)NSString * fontName;

@property(nonatomic,strong)UIFont * font1;
@property(nonatomic,strong)UIFont * font2;

@property(nonatomic,strong)UIColor * color;
@property(nonatomic,strong)UIColor * shadowColor;
@property(nonatomic,assign)NSInteger encodeing;

//下方label的bottom
@property(nonatomic,assign)CGFloat position1;
//上方label的bottom
@property(nonatomic,assign)CGFloat position2;

@end

@implementation DWSubtitleView

-(instancetype)initWithSubtitleDict:(NSDictionary *)subtitleDict
{
    if (self == [super init]) {
        
        self.hidden = YES;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.time = 0;
        
        /*
         
         "url":  "http://1-material.bokecc.com/material/1725A8A9604EAE30/3624.srt",
         "font":  "Times New Roman",
         "size":  "42",
         "color":  "0x0000FF",
         "surroundColor":  "0xFF6600",
         "bottom":  "0.23",
         "code":  "utf-8",
         "subtitleName":"中文",                        //字幕名称
         "defaultSubtitle":"双语",                  //默认显示哪个字幕  选值为  subtitleName  的值
         "sort":1                                                  //双语字幕中的位置1:下面2:上面  只有一个字幕时sort=0
         
         */
        
        NSDictionary * subtitleDict1 = [[subtitleDict objectForKey:@"subtitleDic"] objectForKey:@"url"] ? [subtitleDict objectForKey:@"subtitleDic"] : nil;
        NSDictionary * subtitleDict2 = [[subtitleDict objectForKey:@"subtitle2Dic"] objectForKey:@"url"] ? [subtitleDict objectForKey:@"subtitle2Dic"] : nil;
        
        if (!subtitleDict1 && !subtitleDict2) {
            self.style = DWSubtitleStyleNone;
        }else if (subtitleDict1 && subtitleDict2){
            self.subtitleDict1 = subtitleDict1;
            self.subtitleDict2 = subtitleDict2;
            self.style = DWSubtitleStyleDouble;
        }else{
            self.subtitleDict1 = subtitleDict1;
            self.style = DWSubtitleStyleSingle;
        }
        
        //异步解析字幕数据
        [self asyncAnalysisData];
        //设置字幕显示样式
        [self setTextConfiguration];
        //新增字幕label
        [self addSubLabel];
        
        //设置控件默认frame
        [self setDefaultFrame];
       
    }
    return self;
}

#pragma mark - public
//切换字幕 0双语 1主字幕 2副字幕 3关闭字幕
-(void)switchSubtitleStyle:(NSInteger)style
{
    self.showStyle = style;
    if (style == 0) {
        
        self.hidden = NO;
        if (_subtitleLabel2) {
            _subtitleLabel2.hidden = NO;
        }
        [self changeControlFrameAndoFont];
        
    }
    if (style == 1) {
        self.hidden = NO;
        //这里label2 用的懒加载，如果没创建，就不要加载了
        if (_subtitleLabel2) {
            _subtitleLabel2.hidden = YES;
        }
        [self changeControlFrameAndoFont];
        
    }
    if (style == 2) {
        self.hidden = NO;
        if (_subtitleLabel2) {
            _subtitleLabel2.hidden = YES;
        }
        [self changeControlFrameAndoFont];

    }
    if (style == 3) {
        self.hidden = YES;
    }

}

-(void)setSubtitleWithTime:(NSTimeInterval)currentPlaybackTime
{
    if (self.showStyle == 0) {
        //双语
        //判断下 根据sort 判断字幕位置 sort = 2 下，sort = 1 上
        
        NSString * newBottomText = nil;
        NSString * newFrontText = nil;
        if ([[self.subtitleDict1 objectForKey:@"sort"] integerValue] == 2) {
            newBottomText = [self.subtitleAnalysis1 searchWithTime:currentPlaybackTime];
            newFrontText = [self.subtitleAnalysis2 searchWithTime:currentPlaybackTime];
        }else{
            newBottomText = [self.subtitleAnalysis2 searchWithTime:currentPlaybackTime];
            newFrontText = [self.subtitleAnalysis1 searchWithTime:currentPlaybackTime];
        }
        
        if ([self.subtitleLabel.text isEqualToString:newBottomText] && [self.subtitleLabel2.text isEqualToString:newFrontText]) {
            return;
        }
        
        self.subtitleLabel.text = newBottomText;
        self.subtitleLabel2.text = newFrontText;
        
        [self changeControlFrameAndoFont];
      
    }
    if (self.showStyle == 1) {
        
        NSString * newBottomText = [self.subtitleAnalysis1 searchWithTime:currentPlaybackTime];

        if ([self.subtitleLabel.text isEqualToString:newBottomText]) {
            return;
        }
        
        self.subtitleLabel.text = newBottomText;
        
        [self changeControlFrameAndoFont];
    }
    if (self.showStyle == 2) {
        
        NSString * newBottomText = [self.subtitleAnalysis2 searchWithTime:currentPlaybackTime];
        
        if ([self.subtitleLabel.text isEqualToString:newBottomText]) {
            return;
        }
        
        self.subtitleLabel.text = newBottomText;
        
        [self changeControlFrameAndoFont];
    }

}

#pragma mark - private
-(void)setTextConfiguration
{
    //label 相关配置
    if (self.style == DWSubtitleStyleNone) {
        return;
    }
    //配置都是一样的
    NSDictionary * confDict = self.subtitleDict1;

    //大小
    self.fontName = [confDict objectForKey:@"font"];
   
    //编码格式
    self.encodeing = [[confDict objectForKey:@"code"] isEqualToString:@"utf-8"] ? 0 : 1;
    
    //颜色
    self.color = [DWTools colorWithHexString:[confDict objectForKey:@"color"]];
    //阴影颜色
    self.shadowColor = [DWTools colorWithHexString:[confDict objectForKey:@"surroundColor"]];
    
    //距离底部偏移
    
    if (self.style == DWSubtitleStyleDouble) {
        
        CGFloat fontSize1 = [[self.subtitleDict1 objectForKey:@"size"] floatValue] / 2.0;
        CGFloat fontSize2 = [[self.subtitleDict2 objectForKey:@"size"] floatValue] / 2.0;
        
        self.font1 = [UIFont fontWithName:self.fontName size:fontSize1] ? [UIFont fontWithName:self.fontName size:fontSize1] : [UIFont systemFontOfSize:fontSize1];
        self.font2 = [UIFont fontWithName:self.fontName size:fontSize2] ? [UIFont fontWithName:self.fontName size:fontSize2] : [UIFont systemFontOfSize:fontSize2];

        self.position1 = [[self.subtitleDict1 objectForKey:@"sort"] integerValue] == 2 ? [[self.subtitleDict1 objectForKey:@"bottom"] floatValue] : [[self.subtitleDict2 objectForKey:@"bottom"] floatValue];
        self.position2 = [[self.subtitleDict1 objectForKey:@"sort"] integerValue] == 2 ? [[self.subtitleDict2 objectForKey:@"bottom"] floatValue] : [[self.subtitleDict1 objectForKey:@"bottom"] floatValue];
        
    }else{
        CGFloat fontSize1 = [[self.subtitleDict1 objectForKey:@"size"] floatValue] / 2.0;

        self.font1 = [UIFont fontWithName:self.fontName size:fontSize1] ? [UIFont fontWithName:self.fontName size:fontSize1] : [UIFont systemFontOfSize:fontSize1];

        self.position1 = [[confDict objectForKey:@"bottom"] floatValue];
    }
}

-(void)addSubLabel
{
    if (self.style == DWSubtitleStyleNone) {
        return;
    }
    [self addSubview:self.subtitleLabel];
    if (self.style == DWSubtitleStyleDouble) {
        [self addSubview:self.subtitleLabel2];
    }
}

-(void)asyncAnalysisData
{
    if (self.style == DWSubtitleStyleNone) {
        return;
    }
    self.subtitleAnalysis1 = [[DWSubtitleAnalysis alloc]initWithSTRURL:[NSURL URLWithString:[self.subtitleDict1 objectForKey:@"url"]]];
    self.subtitleAnalysis1.encodeing = self.encodeing;
    [self.subtitleAnalysis1 parse];
    
    if (self.style == DWSubtitleStyleDouble) {
        self.subtitleAnalysis2 = [[DWSubtitleAnalysis alloc]initWithSTRURL:[NSURL URLWithString:[self.subtitleDict2 objectForKey:@"url"]]];
        self.subtitleAnalysis2.encodeing = self.encodeing;
        [self.subtitleAnalysis2 parse];
    }
}

//设置默认的frame
-(void)setDefaultFrame
{
    if (self.style == DWSubtitleStyleNone) {
        return;
    }
    
    CGFloat max = MAX(ScreenWidth, ScreenHeight);
    CGFloat min = MIN(ScreenWidth, ScreenHeight);
    
    if (self.style == DWSubtitleStyleDouble) {
        self.frame = CGRectMake(50, min * (1 - self.position2) - 0, max - 100, 0);
    }else{
        self.frame = CGRectMake(50, min * (1 - self.position1) - 0, max - 100, 0);
    }
    
    if (self.style == DWSubtitleStyleDouble) {
        self.subtitleLabel2.frame = CGRectMake(0, 0, self.frame.size.width, 0);
        self.subtitleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.subtitleLabel2.frame) + 10, self.subtitleLabel2.frame.size.width, 0);
    }else{
        self.subtitleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 0);
    }

}

//根据text修改frame
-(void)changeControlFrameAndoFont
{
    if (self.style == DWSubtitleStyleNone) {
        //无字幕数据 ，外部调用如果有误的话 return
        return;
    }
    
    CGFloat min = MIN(ScreenWidth, ScreenHeight);
    CGRect selfFrame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, 0);
    
    if (self.showStyle == 0 && self.style == DWSubtitleStyleDouble) {
        //显示双字幕
        
        _subtitleLabel2.font = self.font2;
        _subtitleLabel1.font = self.font1;
        
        CGSize frontSize = [self rectWithSize:CGSizeMake(_subtitleLabel2.frame.size.width, self.font2.lineHeight * 2 + 5) andFont:self.font2 andLabelText:_subtitleLabel2.text];
        CGSize bottomSize = [self rectWithSize:CGSizeMake(_subtitleLabel1.frame.size.width, self.font1.lineHeight * 2 + 5) andFont:self.font1 andLabelText:_subtitleLabel1.text];
        
        selfFrame.origin.y = min * (1 - self.position2) - frontSize.height;
        CGFloat labelSpace = ABS((selfFrame.origin.y + frontSize.height) - ((min * (1 - self.position1) - bottomSize.height)));
        selfFrame.size.height = frontSize.height + labelSpace + bottomSize.height;
        
        _subtitleLabel2.frame = CGRectMake(0, 0, _subtitleLabel2.frame.size.width, frontSize.height);
        _subtitleLabel1.frame = CGRectMake(0, CGRectGetMaxY(_subtitleLabel2.frame) + labelSpace, _subtitleLabel1.frame.size.width, bottomSize.height);
        
    }else{
        //这种情况 后台设置双字幕 只显示单字幕
        CGSize size = CGSizeZero;
        if (self.showStyle == 1) {
            _subtitleLabel1.font = self.font1;
            size = [self rectWithSize:CGSizeMake(_subtitleLabel1.frame.size.width, self.font1.lineHeight * 2 + 5) andFont:self.font1 andLabelText:_subtitleLabel1.text];
        }
        if (self.showStyle == 2) {
            _subtitleLabel1.font = self.font2;
            size = [self rectWithSize:CGSizeMake(_subtitleLabel1.frame.size.width, self.font2.lineHeight * 2 + 5) andFont:self.font2 andLabelText:_subtitleLabel1.text];
        }
        
        _subtitleLabel2.frame = CGRectMake(0, 0, _subtitleLabel2.frame.size.width, 0);
        _subtitleLabel1.frame = CGRectMake(0, CGRectGetMaxY(_subtitleLabel2.frame), _subtitleLabel1.frame.size.width, size.height);
        
        selfFrame.origin.y = min * (1 - self.position1) - size.height;
        selfFrame.size.height = size.height;
    }
    
    if ((self.showStyle == 1 || self.showStyle == 2) && self.style == DWSubtitleStyleSingle) {

        //单字幕 只显示单条字幕
        
        _subtitleLabel1.font = self.font1;
        
        CGSize size = [self rectWithSize:CGSizeMake(_subtitleLabel1.frame.size.width, self.font1.lineHeight * 2 + 5) andFont:self.font1 andLabelText:_subtitleLabel1.text];
        if (self.style == DWSubtitleStyleDouble) {
            _subtitleLabel2.frame = CGRectMake(0, 0, _subtitleLabel2.frame.size.width, 0);
            _subtitleLabel1.frame = CGRectMake(0, CGRectGetMaxY(_subtitleLabel2.frame), _subtitleLabel1.frame.size.width, size.height);
        }else{
            _subtitleLabel1.frame = CGRectMake(0, 0, _subtitleLabel1.frame.size.width, size.height);
        }
        
        selfFrame.origin.y = min * (1 - self.position1) - size.height;
        selfFrame.size.height = size.height;
    }
    
    self.frame = selfFrame;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

-(CGSize)rectWithSize:(CGSize)size andFont:(UIFont *)font andLabelText:(NSString *)text{
    
    if (!text || [text isEqualToString:@""]) {
        return CGSizeZero;
    }
    
    NSDictionary *dict =[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGSize returnSize=[text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    return CGSizeMake(ceil(returnSize.width), ceil(returnSize.height));
}

#pragma mark - lazy
-(UILabel *)subtitleLabel
{
    if (!_subtitleLabel1) {
        _subtitleLabel1 = [[UILabel alloc]init];
//        _subtitleLabel.font = self.font ? self.font : [UIFont systemFontOfSize:self.fontSize];
        _subtitleLabel1.font = self.font1;
        _subtitleLabel1.textColor = self.color;
        _subtitleLabel1.shadowColor = self.shadowColor;
        _subtitleLabel1.shadowOffset = CGSizeMake(1, -1);
        _subtitleLabel1.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel1.numberOfLines = 2;
    }
    return _subtitleLabel1;
}

-(UILabel *)subtitleLabel2
{
    if (!_subtitleLabel2) {
        _subtitleLabel2 = [[UILabel alloc]init];
//        _subtitleLabel2.font = self.font ? self.font : [UIFont systemFontOfSize:self.fontSize];
        _subtitleLabel2.font = self.font2;
        _subtitleLabel2.textColor = self.color;
        _subtitleLabel2.shadowColor = self.shadowColor;
        _subtitleLabel2.shadowOffset = CGSizeMake(1, -1);
        _subtitleLabel2.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel2.numberOfLines = 2;
    }
    return _subtitleLabel2;
}

@end
