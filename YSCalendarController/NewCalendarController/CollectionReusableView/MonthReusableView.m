//
//  MonthReusableView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/5.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "MonthReusableView.h"
#import "UIColor+Extension.h"

@implementation MonthReusableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setBorderWidth:(1.0 / [UIScreen mainScreen].scale)];
        [self.layer setBorderColor:[UIColor colorWithHexString:@"daeaed"].CGColor];
        
        self.month = [UILabel new];
        self.month.backgroundColor = [UIColor whiteColor];
        self.month.font = [UIFont systemFontOfSize:13];
        self.month.textAlignment = NSTextAlignmentCenter;
        self.month.textColor = [UIColor colorWithHexString:@"88c6e5"];
        self.month.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.month.text = @"1月";
        [self addSubview:self.month];
    }
    return self;
}

@end
