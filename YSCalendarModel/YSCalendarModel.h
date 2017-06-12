//
//  YSCalendarModel.h
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/5.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarCourseModel : NSObject
@property (nonatomic, copy) NSString * csid;
@property (nonatomic, copy) NSString * crid;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * endtime;
@property (nonatomic, copy) NSString * startime;
@property (nonatomic, copy) NSString * bgcolor;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * photo;
@property (nonatomic, copy) NSString * stime;
@property (nonatomic, copy) NSString * etime;
@property (nonatomic, copy) NSString * teacher_name;
@property (nonatomic, copy) NSString * type;//视频直播 1
@end

@interface YSCalendarModel : NSObject
@property (nonatomic, strong) NSMutableArray * datas;
@end


@interface CalendarWeekObj : NSObject
@property (nonatomic, copy) NSString * weeks;
@property (nonatomic, copy) NSString * startime;
@property (nonatomic, copy) NSString * endtime;
@property (nonatomic, assign) BOOL thisweek;
@end

@interface YSCalendarWeekModel : NSObject
@property (nonatomic, copy)NSString * returnCode;
@property (nonatomic, copy)NSString * returnMsg;
@property (nonatomic, copy)NSString * PHPSESSID;
@property (nonatomic, strong) NSMutableArray * datas;
@end
