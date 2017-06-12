//
//  TimeReusableView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/4.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "TimeReusableView.h"
#import "UIColor+Extension.h"

@implementation TimeReusableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setBorderWidth:(1.0 / [UIScreen mainScreen].scale)];
        [self.layer setBorderColor:[UIColor colorWithHexString:@"daeaed"].CGColor];
        
        self.title = [UILabel new];
        self.title.backgroundColor = [UIColor whiteColor];
        self.title.font = [UIFont systemFontOfSize:11];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.textColor = [UIColor colorWithHexString:@"88c6e5"];
        self.title.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.title];
    }
    return self;
}
- (void)setTime:(NSDate *)time
{
    _time = time;
    
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:sourceTimeZone];
        dateFormatter.dateFormat = @"HH:mm";
    }
    self.title.text = [dateFormatter stringFromDate:time];
    [self setNeedsLayout];
}

@end
