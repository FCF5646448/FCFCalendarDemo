//
//  YSCalendarModel.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/5.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "YSCalendarModel.h"
#import "RMMapper.h"

@implementation CalendarCourseModel

@end

@implementation YSCalendarModel
- (NSMutableArray *)datas {
    if ([_datas isEqual:[NSNull null]]) {
        _datas = [NSMutableArray array];
    }
    
    for (NSInteger i = 0; i < _datas.count; i++) {
        if ([[_datas objectAtIndex:i] class] != [CalendarCourseModel class]) {
            NSMutableArray *newArray = [RMMapper mutableArrayOfClass:[CalendarCourseModel class] fromArrayOfDictionary:_datas];
            _datas = newArray;
            break;
        }
    }
    return _datas;
}
@end

@implementation CalendarWeekObj

@end

@implementation YSCalendarWeekModel
- (instancetype)init{
    if (self = [super init]) {
        self.datas = [self datas];
    }
    return self;
}
- (NSMutableArray *)datas {
    if ([_datas isEqual:[NSNull null]]) {
        _datas = [NSMutableArray array];
    }
    
    for (NSInteger i = 0; i < _datas.count; i++) {
        if ([[_datas objectAtIndex:i] class] != [CalendarWeekObj class]) {
            NSMutableArray *newArray = [RMMapper mutableArrayOfClass:[CalendarWeekObj class] fromArrayOfDictionary:_datas];
            _datas = newArray;
            break;
        }
    }
    return _datas;
}

@end
