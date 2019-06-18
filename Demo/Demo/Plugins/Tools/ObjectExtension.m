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


