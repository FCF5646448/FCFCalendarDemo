//
//  DayReusableView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/4.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "DayReusableView.h"
#import "UIColor+Extension.h"

@implementation DayReusableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setBorderWidth: (1.0 / [UIScreen mainScreen].scale)];
        [self.layer setBorderColor:[UIColor colorWithHexString:@"c2d7de"].CGColor];
        self.backgroundColor = [UIColor whiteColor];
        self.dayTitle = [UILabel new];
        self.dayTitle.backgroundColor = [UIColor whiteColor];
        self.dayTitle.font = [UIFont systemFontOfSize:11];
        self.dayTitle.textColor = [UIColor colorWithHexString:@"88c6e5"];
        self.dayTitle.textAlignment = NSTextAlignmentCenter;
        self.dayTitle.frame = CGRectMake(0,self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
        [self addSubview:self.dayTitle];
        
        self.dateTitle = [UILabel new];
        self.dateTitle.backgroundColor = [UIColor whiteColor];
        self.dateTitle.font = [UIFont systemFontOfSize:11];
        self.dateTitle.textColor = [UIColor colorWithHexString:@"88c6e5"];
        self.dateTitle.textAlignment = NSTextAlignmentCenter;
        self.dateTitle.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
        [self addSubview:self.dateTitle];
        
    }
    return self;
}

- (void)setDay:(NSDate *)day
{
    _day = day;
    
//    static NSDateFormatter *dateFormatter;
//    if (!dateFormatter) {
//        dateFormatter = [NSDateFormatter new];
//        dateFormatter.dateFormat =@"";
//    }
//    self.dayTitle.text = [dateFormatter stringFromDate:day];
//    dateFormatter.dateFormat =@"d";
//    self.dateTitle.text = [dateFormatter stringFromDate:day];
    
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:day];
    NSArray * weekDayArray = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    self.dayTitle.text = weekDayArray[components.weekday-1];
    self.dateTitle.text = [NSString stringWithFormat:@"%ld",components.day];

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.dateTitle.frame  = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
    self.dayTitle.frame = CGRectMake(0,self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
}


@end
