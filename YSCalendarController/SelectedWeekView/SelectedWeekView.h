//
//  SelectedWeekView.h
//  edu-Yusi3
//
//  Created by 冯才凡 on 15/12/30.
//  Copyright © 2015年 yusi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSCalendarModel.h"

#import <UIKit/UIKit.h>
#import "YSCalendarModel.h"

@protocol SelectedWeekViewDelegate;

@interface SelectedWeekView : UIView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger currentWeekIndex;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, assign) BOOL isShow;
- (void)showPop;
- (void)hidePop;
@end

@protocol SelectedWeekViewDelegate <NSObject>
    
- (void)selectedWeekView:(SelectedWeekView *)view didPressedInWeek:(CalendarWeekObj *)obj;
- (void)selectedWeekViewDidSpacePlace:(SelectedWeekView *)view;
    
@end
