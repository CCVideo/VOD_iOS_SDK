//
//  DWBarrageSendTextCell.m
//  Demo
//
//  Created by zwl on 2020/6/12.
//  Copyright © 2020 com.bokecc.www. All rights reserved.
//

#import "DWBarrageTextCell.h"

@implementation DWBarrageTextCell

-(void)setBarrageDescriptor:(OCBarrageDescriptor *)barrageDescriptor
{    
    [super setBarrageDescriptor:barrageDescriptor];
    
    self.barrageTextDescriptor = (DWBarrageTextDescriptor *)barrageDescriptor;
}

-(void)updateSubviewsData
{
    [super updateSubviewsData];
    
    if (self.barrageTextDescriptor.isSend) {
        NSMutableAttributedString * textAttr = [[NSMutableAttributedString alloc]initWithAttributedString:self.barrageTextDescriptor.attributedText];
        [textAttr replaceCharactersInRange:NSMakeRange(0, self.textDescriptor.attributedText.string.length) withString:[NSString stringWithFormat:@"  %@  ",self.textDescriptor.attributedText.string]];
        [self.textLabel setAttributedText:textAttr];
    }
}

-(void)layoutContentSubviews
{
//    [super layoutContentSubviews];
    NSString * text = self.textDescriptor.attributedText.string;
    if (self.barrageTextDescriptor.isSend) {
        text = [NSString stringWithFormat:@"  %@  ",text];
    }
    
    CGRect textFrame = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[self.textDescriptor.attributedText attributesAtIndex:0 effectiveRange:NULL] context:nil];
    self.textLabel.frame = textFrame;

    if (self.barrageTextDescriptor.isSend) {
        self.textLabel.layer.masksToBounds = YES;
        self.textLabel.backgroundColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.3];
        self.textLabel.layer.cornerRadius = self.textLabel.frame.size.height / 2.0;
    }else{
        //
    }
}

- (void)convertContentToImage {
    UIImage *contentImage = [self.layer convertContentToImageWithSize:self.textLabel.frame.size];
    [self.layer setContents:(__bridge id)contentImage.CGImage];
}

- (void)removeSubViewsAndSublayers {
    [super removeSubViewsAndSublayers];
    
//    self.textLabel = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
