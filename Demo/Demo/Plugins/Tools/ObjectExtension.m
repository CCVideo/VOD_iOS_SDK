//
//  NSString+ObjectExtension.m
//  proselfedu
//
//  Created by zwl on 2018/5/2.
//  Copyright © 2018年 zwl. All rights reserved.
//

#import "ObjectExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ObjectExtension)

-(CGSize)calculateRectWithSize:(CGSize)size Font:(UIFont *)font WithLineSpace:(CGFloat)lineSpace;
{
    NSMutableParagraphStyle * pStyle = [[NSMutableParagraphStyle alloc]init];
    if (lineSpace != 0) {
        pStyle.lineSpacing = lineSpace;
    }
    CGSize returnSize = [self boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:pStyle} context:nil].size;
    
    
    //处理下是不是只有一行 只有一行的话 返回font.height
    if (ceil(returnSize.height) < (font.lineHeight * 2 + lineSpace)) {
        return CGSizeMake(ceil(returnSize.width), font.lineHeight);
    }
    
    return CGSizeMake(ceil(returnSize.width), ceil(returnSize.height));
}

//过滤emoji
-(NSString *)filterEmoji
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString * retString = [regex stringByReplacingMatchesInString:self
                                                               options:0
                                                             range:NSMakeRange(0, self.length)
                                                          withTemplate:@""];
    return retString;
}

//是否包含emoji
-(BOOL)isContainsEmoji
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (matches.count >= 1) {
        return YES;
    }
    return NO;
}

-(void)showAlert
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:DWAPPDELEGATE.window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = self;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:3];
}

@end

@implementation UIColor (ObjectExtension)

-(UIImage*)createImage
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(UIImage*)createImageWithSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(BOOL)isEqualColor:(UIColor *)otherColor
{
    if (CGColorEqualToColor(self.CGColor, otherColor.CGColor)) {
        return YES;
    }
    return NO;
}

@end

@implementation UILabel (ObjectExtension)

-(CGRect)boundingRectForStringRange:(NSRange)range
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[self attributedText]];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:[self bounds].size];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}

@end
