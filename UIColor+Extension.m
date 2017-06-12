//
//  UIColor+Extension.m
//  CollectionView_ScrollViewDemo
//
//  Created by 冯才凡 on 15/12/28.
//  Copyright © 2015年 Shayne FCF. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)
+ (UIColor *) colorWithHexString:(NSString *)hexString{
    return [self colorWithHexString:hexString alpha:1.0];
}

+ (UIColor *) colorWithHexString:(NSString *)hexString alpha:(float)alpha{
    NSScanner * scanner = [NSScanner scannerWithString:hexString];
    unsigned rgb = 0;
    if ([scanner scanHexInt:&rgb]) {
        return [self colorWithRGB:rgb alpha:alpha];
    }
    return [UIColor clearColor];
}

+ (UIColor *) colorWithRGB:(NSInteger)rgb alpha:(float)alpha{
    return [UIColor colorWithRed:(float)((rgb & 0xFF0000) >> 16) / 255.0
                           green:(float) ((rgb & 0x00FF00) >> 8) / 255.0f
                            blue:(float) (rgb & 0x0000FF) / 255.0
                           alpha:alpha];
}
@end
