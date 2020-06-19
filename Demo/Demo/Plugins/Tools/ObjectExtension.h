//
//  NSString+ObjectExtension.h
//  proselfedu
//
//  Created by zwl on 2018/5/2.
//  Copyright © 2018年 zwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ObjectExtension)

//提示框
-(void)showAlert;

//计算文本大小
-(CGSize)calculateRectWithSize:(CGSize)size Font:(UIFont *)font WithLineSpace:(CGFloat)lineSpace;

//过滤emoji
-(NSString *)filterEmoji;

//是否包含emoji
-(BOOL)isContainsEmoji;

@end

@interface UIColor (ObjectExtension)

//色值生成图片
-(UIImage*)createImage;

//根据size生成图片
-(UIImage*)createImageWithSize:(CGSize)size;

///判断色值是否相等
-(BOOL)isEqualColor:(UIColor *)otherColor;

@end

@interface UILabel (ObjectExtension)

-(CGRect)boundingRectForStringRange:(NSRange)range;

@end
