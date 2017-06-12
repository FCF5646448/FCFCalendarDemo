//
//  YSCalendarController.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/7.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "YSCalendarController.h"
#import "NewCollectionViewCalendarLayout.h"
#import "TimeReusableView.h"
#import "DayReusableView.h"
#import "TimeBackground.h"
#import "DayBackground.h"
#import "PointReusableView.h"
#import "VerticalReusableView.h"
#import "HorizontalReusableView.h"
#import "SelectedSectionReusableView.h"
#import "MonthReusableView.h"
#import "NumOfLevelsReusableView.h"
#import "CurrentTimeGridLine.h"
#import "CourseCellectonViewCell.h"

#import "YSCalendarModel.h"
#import "RMMapper.h"
#import "UIColor+Extension.h"

#import "SelectedWeekView.h"
#import "ChoiceCourseView.h"
#import "AFNetworking.h"

#define EARLISTHOURE 8
#define LATESTHOUR 24

@interface AreaObj : NSObject
@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, assign) CGRect rect;//区域范围,
@property (nonatomic, assign) NSIndexPath * indexPath;
@property (nonatomic, strong) NSMutableArray * areaObjArr;//装载区域内的对象
@property (nonatomic, assign) BOOL hasDoubleRect;//是否在重合区域
@property (nonatomic, assign) CGRect originRect;
@end

@implementation AreaObj
@end

@interface YSCalendarController ()<NewCollectionViewCalendarLayoutDelegate,UICollectionViewDataSource,UICollectionViewDelegate,SelectedWeekViewDelegate,UIAlertViewDelegate,ChoiceCourseViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NewCollectionViewCalendarLayout * collectionViewCalendarLayout;

@property (nonatomic, strong) UILabel * monthLabel;
@property (nonatomic, strong) UIImageView * bgImgView;
@property (strong, nonatomic) UIButton * titleBtn;
@property (assign, nonatomic) BOOL flag;//是否有点击让weekview出现

@property (nonatomic, strong) NSMutableDictionary * courseDic;
@property (nonatomic, strong) NSMutableDictionary * sectionCourseDic;
@property (nonatomic, strong) NSMutableArray * areaArray;
@property (nonatomic, strong) NSMutableArray * dayArray;
@property (nonatomic, strong) NSMutableDictionary * timeDic;
@property (nonatomic, strong) NSMutableDictionary * sectionCourse;
@property (nonatomic, strong) SelectedWeekView * selectedWeekView;
@property (nonatomic, strong) ChoiceCourseView * courseView;
@property (nonatomic, strong) NSMutableArray * weekArray;
@property (nonatomic, strong) UIActivityIndicatorView * reloadView;
@end

@implementation YSCalendarController

+ (id)loadFromNib {
    NSArray* arrayNib = [[NSBundle mainBundle] loadNibNamed:@"YSCalendarController" owner:self options:nil];
    return [arrayNib objectAtIndex:0];
}

static NSString * const reuseIdentifier = @"CourseCellectonViewCell";

NSString * const DayColumnHeaderReuseIdentifier = @"MSDayColumnHeaderReuseIdentifier";
NSString * const TimeRowHeaderReuseIdentifier = @"MSTimeRowHeaderReuseIdentifier";
NSString * const NumOfLevelsReuseIdentifier = @"MSTimeRowHeaderReuseIdentifier";
//NSString * const MonthLabelReuseIdentifier = @"MonthLabelReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.collectionViewCalendarLayout = [[NewCollectionViewCalendarLayout alloc] init];
    self.collectionViewCalendarLayout.delegate = self;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"calendar_controller_bg"]];
    self.reloadView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.reloadView.center = self.view.center;
    [self.view addSubview:self.reloadView];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = NO;
    self.collectionView.userInteractionEnabled = YES;
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    self.collectionView.collectionViewLayout = self.collectionViewCalendarLayout;
    [self.collectionView registerClass:[CourseCellectonViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.collectionView registerClass:DayReusableView.class forSupplementaryViewOfKind:CollectionElementKindDayColumnHeader withReuseIdentifier:DayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:TimeReusableView.class forSupplementaryViewOfKind:CollectionElementKindTimeRowHeader withReuseIdentifier:TimeRowHeaderReuseIdentifier];
    [self.collectionView registerClass:NumOfLevelsReusableView.class forSupplementaryViewOfKind:CollectionElementKindNumOfLevels withReuseIdentifier:NumOfLevelsReuseIdentifier];
    
    self.collectionViewCalendarLayout.timeRowHeaderWidth = TIMEROW_WIDTH;//fcf
    self.collectionViewCalendarLayout.hourHeight = SECTION_HEIGHT;
    self.collectionViewCalendarLayout.sectionWidth = SECTION_WIDTH;
    self.collectionViewCalendarLayout.earlistHour = EARLISTHOURE;
    self.collectionViewCalendarLayout.latestHour = LATESTHOUR;
    
    [self.collectionViewCalendarLayout registerClass:TimeBackground.class forDecorationViewOfKind:CollectionElementKindTimeRowHeaderBackground];
    [self.collectionViewCalendarLayout registerClass:DayBackground.class forDecorationViewOfKind:CollectionElementKindDayColumnHeaderBackground];
    [self.collectionViewCalendarLayout registerClass:PointReusableView.class forDecorationViewOfKind:CollectionElementKindPoint];
    [self.collectionViewCalendarLayout registerClass:VerticalReusableView.class forDecorationViewOfKind:CollectionElementKindVLine];
    [self.collectionViewCalendarLayout registerClass:HorizontalReusableView.class forDecorationViewOfKind:CollectionElementKindHLine];
    [self.collectionViewCalendarLayout registerClass:SelectedSectionReusableView.class forDecorationViewOfKind:CollectionElementKindSelectedView];
    [self.collectionViewCalendarLayout registerClass:CurrentTimeGridLine.class forDecorationViewOfKind:CollectionElementKindCurrentGridLine];
    
    self.sectionCourseDic = [NSMutableDictionary dictionary];
    self.dayArray = [NSMutableArray array];
    self.areaArray = [NSMutableArray array];
    self.weekArray = [NSMutableArray array];
    self.timeDic = [NSMutableDictionary dictionary];
    self.sectionCourse = [NSMutableDictionary dictionary];
    self.courseDic = [NSMutableDictionary dictionary];
    
    
    [self createMonthLabel];
    [self createPopView];
    //add tauch
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTap:)];
    [self.collectionView addGestureRecognizer:tap];
    [self createTitle];
    //将头和修饰图整理好
    [self getMonthBeginAndEndWith:[NSDate date]];
    [self calculateTime];
    [self requestDataSourceWithStartime:nil endTime:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation

{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}

- (void)createMonthLabel
{
    self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,TIMEROW_WIDTH, SECTION_HEIGHT)];
    self.monthLabel.backgroundColor = [UIColor whiteColor];
    self.monthLabel.textAlignment = NSTextAlignmentCenter;
    [self.monthLabel.layer setBorderWidth:1];
    [self.monthLabel.layer setBorderColor:[UIColor colorWithHexString:@"c2d7de"].CGColor];
    self.monthLabel.textColor = [UIColor colorWithHexString:@"88c6e5"];
    self.monthLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.monthLabel];
}

- (void)createPopView
{
    _flag = NO;
    _selectedWeekView = [[SelectedWeekView alloc] init];
    _selectedWeekView.delegate = self;
    [self requestWeekDataSource];
    _courseView = [[ChoiceCourseView alloc] init];
    _courseView.delegate = self;
}



#pragma mark - Request
/*
 这里下载被坑了：
 1:
    在Info.plist中添加NSAppTransportSecurity类型Dictionary。
    在NSAppTransportSecurity下添加NSAllowsArbitraryLoads类型Boolean,值设为YES
 2:
    其他的字段用字典
 3:
    RMMapper的使用
 */
    
- (void)requestWeekDataSource
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json",@"text/html", nil];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    manager.requestSerializer.HTTPShouldHandleCookies = NO;
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString * requestUrl = @"http://edu.yusi.tv/?urlparam=mobile3058/my/getweek&verb=3090300&channel=appstore_phone&yusic002=ios&fa=439A47EE-B783-4DF1-9920-234D1CA263FD&fv=2E93C899-6C0D-4E28-BAD1-DD0209E66623&app_v=3.9.3&PHPSESSID=26rmvp45g7sq67a25ouhqeii7r8962amaqHFnmm-TlmucaW6XnYvW3Meha2tqamqWcInZq9aedJE.k";
    
    [manager GET:requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation.request.URL);
        if ([responseObject isKindOfClass:[NSString class]]) {
            UIAlertView * alerview = [[UIAlertView alloc] initWithTitle:@"服务器返回数据异常" message:@"服务器返回数据异常" delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"sure", nil];
            [alerview show];
            return;
            
        }else {
            NSDictionary *httpData = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:0 error:NULL];
            YSCalendarWeekModel * model = (YSCalendarWeekModel *)[RMMapper objectWithClass:[YSCalendarWeekModel class] fromDictionary:httpData];
            
            for (int i=0; i<model.datas.count; i++) {
                CalendarWeekObj * obj = model.datas[i];
                if (obj.thisweek) {
                    _selectedWeekView.currentWeekIndex = i;
                    [self setCurrentTitle:obj.weeks];
                }
                [self.weekArray addObject:obj];
            }
            if (self.weekArray.count>0) {
                _selectedWeekView.dataSource = [NSMutableArray arrayWithArray:self.weekArray];
            }
            
            if (self.flag && _selectedWeekView.isShow) {
                [_selectedWeekView showPop];
            }

            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)requestDataSourceWithStartime:(NSString *)starTime endTime:(NSString *)endTime
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json",@"text/html", nil];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    manager.requestSerializer.HTTPShouldHandleCookies = NO;

    NSMutableDictionary * params = [NSMutableDictionary dictionary];
//    [params setObject:@(3050800) forKey:@"verb"];
//    [params setObject:@"appstore_phone" forKey:@"channel"];
//    
//    [params setObject:@"ios" forKey:@"yusic002"];
//    [params setObject:@"8F099DFC-66D2-4317-B248-61BB3E5FDBCF" forKey:@"fa"];
//    [params setObject:@"CEA19C9B-2E6A-4C0A-A5D9-70198C8782C0" forKey:@"fv"];
//    [params setObject:@"3.5.8" forKey:@"app_v"];
//    
//    [params setObject:@"26cj5e5o5oekm9rtadgch9mh1gc502aqa1nJhcXCcm5KSaJtta1yi2JahaGeXaWVvX9nb0cdykw..L" forKey:@"PHPSESSID"];
    NSString * requestUrl = @"http://edu.yusi.tv/?urlparam=mobile3090/my/schedule&verb=3090300&channel=appstore_phone&yusic002=ios&fa=439A47EE-B783-4DF1-9920-234D1CA263FD&fv=2E93C899-6C0D-4E28-BAD1-DD0209E66623&app_v=3.9.3&PHPSESSID=26rmvp45g7sq67a25ouhqeii7r8962amaqHFnmm-TlmucaW6XnYvW3Meha2tqamqWcInZq9aedJE.k";

    if (starTime != nil) {
        [params setObject:starTime forKey:@"startime"];
    }
    if (endTime != nil) {
        [params setObject:endTime forKey:@"endtime"];
    }
    [self.reloadView startAnimating];
    [manager GET:requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",operation.request.URL);
        if ([responseObject isKindOfClass:[NSString class]]) {
            UIAlertView * alerview = [[UIAlertView alloc] initWithTitle:@"服务器返回数据异常" message:@"服务器返回数据异常" delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"sure", nil];
            [alerview show];
            return;
            
        }else {
            NSDictionary *httpData = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:0 error:NULL];
            YSCalendarModel * model = (YSCalendarModel *)[RMMapper objectWithClass:[YSCalendarModel class] fromDictionary:httpData];
            
            [_courseDic removeAllObjects];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [formatter setTimeZone:sourceTimeZone];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            CGFloat minuteHeight = (SECTION_HEIGHT/30.0);
            for (int i=0; i<7; i++) {
                int item = 0;
                NSMutableArray * sectionCourseArr = [NSMutableArray array];
                for (int j=0; j<model.datas.count; j++) {
                    CalendarCourseModel *  obj = model.datas[j];
                    NSDate * startDate = [formatter dateFromString:obj.startime];
                    NSDate * endDate = [formatter dateFromString:obj.endtime];
                    NSCalendar * calendar = [NSCalendar currentCalendar];
                    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                    NSDateComponents * startComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:startDate];
                    NSDateComponents * endComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:endDate];
                    
                    NSComparisonResult result = [startDate compare:endDate];
                    if (result != NSOrderedAscending || startComponents.hour<8) {
                        continue;
                    }
                    
                    NSInteger index=0;
                    if (startComponents.weekday-1==0) {
                        index = 6;
                    }else{
                        index = startComponents.weekday-1-1;
                    }
                    if (index == i) {
                        //有item
                        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:index];
                        [_courseDic setObject:obj forKey:indexPath];
                        
                            //将所有课程映射成矩形
                            CGFloat minX = TIMEROW_WIDTH+SECTION_WIDTH*i;
                            CGFloat starHourMinY = ((startComponents.hour - EARLISTHOURE)*2 * SECTION_HEIGHT) + SECTION_HEIGHT;
                            CGFloat starMinuteY = (startComponents.minute) * minuteHeight;
                            CGFloat startHourY = starHourMinY+starMinuteY;//y
                            CGFloat endHourY;//
                            if (startComponents.day!=endComponents.day) {
                                //隔天
                                endHourY = self.collectionViewCalendarLayout.collectionViewContentSize.height;
                            }else{
                                CGFloat endHourMinY = (endComponents.hour - EARLISTHOURE)*2 * SECTION_HEIGHT + SECTION_HEIGHT;
                                CGFloat endMinuteY = (endComponents.minute) * minuteHeight;
                                endHourY = endHourMinY+endMinuteY;
                            }
                            CGRect rect = CGRectMake(minX, startHourY, SECTION_WIDTH, (endHourY-startHourY));
                            AreaObj * areaObj = [[AreaObj alloc] init];
                            areaObj.section = i;
                            areaObj.rect = rect;
                            areaObj.originRect = rect;
                            areaObj.areaObjArr = [NSMutableArray arrayWithObjects:obj, nil];
                            areaObj.indexPath = indexPath;
                            areaObj.hasDoubleRect = NO;
                            [sectionCourseArr addObject:areaObj];
                        
                        item++;
                    }
                }
                [self.sectionCourse setObject:@(item) forKey:@(i)];
                [self.sectionCourseDic setObject:sectionCourseArr forKey:@(i)];
            }
            [self performSelector:@selector(update) withObject:self afterDelay:0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)update
{
    [self.reloadView stopAnimating];
    [self calculateDoubleArea];
    [self.collectionViewCalendarLayout invalidateLayoutCache];
    [self.collectionViewCalendarLayout invalidateLayout];
    [self.collectionView reloadData];
    [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
}

//计算重合区域,未完成
/*
 重合区域的使用方法博客
 http://www.cnblogs.com/xuling/archive/2012/02/09/2343427.html
 */
- (void)calculateDoubleArea
{
    [_areaArray removeAllObjects];
    for (NSUInteger section = 0;section<7 ; section++ ) {
        NSMutableArray * sectionArr = [self.sectionCourseDic objectForKey:@(section)];
        if (sectionArr.count>0) {
            if (sectionArr.count == 1) {
                AreaObj * areObj = sectionArr[0];
                [_areaArray addObject:areObj];
            }else{
                //有多个item,计算重合区域
                for (int i=0; i<sectionArr.count; i++) {
                    int sum = 0;//一共有多少个重合
                    AreaObj * areObjI = sectionArr[i];
                    for (int j=i+1; j<sectionArr.count; j++) {
                        AreaObj * areObjJ = sectionArr[j];
                        if (CGRectIntersectsRect(areObjI.rect,areObjJ.rect)) {
                            //有区域重合,返回合并区域
                            sum++;
                            CGRect newRect = CGRectUnion(areObjI.rect,areObjJ.rect);
                            [areObjI setRect:newRect];
                            areObjI.hasDoubleRect = YES;
                            
                            if (sum<4) {
                                areObjJ.rect = CGRectMake(areObjJ.rect.origin.x+(sum%2)*28, areObjJ.rect.origin.y+(sum/2)*22.5, 28, 22.5);
                            }else{
                                areObjJ.rect = CGRectMake(areObjJ.rect.origin.x+56,  areObjJ.rect.origin.y+22.5, 0.5, 0.5);
                            }
                            areObjJ.hasDoubleRect = YES;
                            [areObjI.areaObjArr addObjectsFromArray:areObjJ.areaObjArr];
                            [sectionArr removeObjectAtIndex:j];
                            [_areaArray addObject:areObjJ];
                            j--;
                            continue;
                        }
                    }
                    
                    if (sum !=0) {
                        areObjI.rect = CGRectMake(areObjI.rect.origin.x, areObjI.rect.origin.y, 28, 22.5);
                    }else{
                        areObjI.rect = CGRectMake(areObjI.rect.origin.x, areObjI.rect.origin.y, 56, 45);
                    }
                    [sectionArr removeObjectAtIndex:i];
                    [_areaArray addObject:areObjI];
                    i--;
                }
            }
        }
    }
}

//获取日期
/*
 [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];的使用
 */
- (void)getMonthBeginAndEndWith:(NSDate *)newDate{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit  NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return;
    }
    [_dayArray removeAllObjects];
    [_dayArray addObject:beginDate];
    NSTimeInterval secondsSpace = 24*60*60;//时间间隔1天
    
    for (int i=0; i<6; i++) {
        NSDate * nextDate = [NSDate dateWithTimeInterval:secondsSpace sinceDate:beginDate];
        [_dayArray addObject:nextDate];
        beginDate  = nextDate;
    }
    
    NSCalendar * currentCalendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents * currentComponents = [currentCalendar components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:beginDate];
    self.monthLabel.text = [NSString stringWithFormat:@"%ld月",currentComponents.month];
}

//统计时间
/*
 注意的地方：
 1:NSCalendar的使用
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];使用当前时间
 2:NSDateComponents的使用
 3:NSDateFormatter的使用：格式@"yyyy-MM-dd HH:mm:ss"固定
 4:http://edsioon.me/about-nsdate/日期相关
 */
- (void)calculateTime
{
    [self.timeDic removeAllObjects];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents * components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:[NSDate date]];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate * earlistDate = [calendar dateFromComponents:components];
    
    NSDate * startDate = [NSDate dateWithTimeInterval:8*60*60 sinceDate:earlistDate];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.timeDic setObject:startDate forKey:indexPath];
    
    NSTimeInterval secondsInCourse = 30*60;
    NSInteger item = 1;
    for (int i=EARLISTHOURE*60*60; i<=LATESTHOUR*60*60; i+=secondsInCourse) {
        NSDate * nextDate = [NSDate dateWithTimeInterval:secondsInCourse sinceDate:startDate];
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        [self.timeDic setObject:nextDate forKey:indexPath];
        item++;
        startDate = nextDate;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 7;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger num  = [[self.sectionCourse objectForKey:@(section)] integerValue];
    return num;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    CourseCellectonViewCell * collectionCell = (CourseCellectonViewCell *)cell;
    CalendarCourseModel *  obj = [_courseDic objectForKey:indexPath];
    [collectionCell setCourseName:obj.title];
    if (obj.bgcolor!=nil && ![obj.bgcolor isEqualToString:@""]) {
        [collectionCell setBgColor:obj.bgcolor];
    }else{
        [collectionCell setBgColor:@"4cdbeb"];
    }
    [collectionCell setCoursePic:obj.photo];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == CollectionElementKindDayColumnHeader) {
        DayReusableView *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:DayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day = [self.collectionViewCalendarLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        dayColumnHeader.day = day;
        view = dayColumnHeader;
        
    } else if (kind == CollectionElementKindTimeRowHeader) {
        TimeReusableView *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:TimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        
        NSDate * date = [_timeDic objectForKey:indexPath];
        
        timeRowHeader.time = date;
        
        view = timeRowHeader;
    }else if (kind == CollectionElementKindNumOfLevels){
        NumOfLevelsReusableView * numOfLevels = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NumOfLevelsReuseIdentifier forIndexPath:indexPath];
        NSDictionary * tempDic = [self.collectionViewCalendarLayout numOfLevelsAtIndexPath:indexPath];
        if ([tempDic objectForKey:@"numLevels"]) {
            NSUInteger num = [[tempDic objectForKey:@"numLevels"] integerValue];
            numOfLevels.num = num;
        }
        view = numOfLevels;
    }
    return view;
}

#pragma mark -
//课程开始时间
- (NSDate * )collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:sourceTimeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date;
    CalendarCourseModel *  obj = [_courseDic objectForKey:indexPath];
    date = [formatter dateFromString:obj.startime];
    
    return date;
}

//课程结束时间
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:sourceTimeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date;
    CalendarCourseModel *  obj = [_courseDic objectForKey:indexPath];
    date = [formatter dateFromString:obj.endtime];
    
    return date;
}

//日期
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout dayForSection:(NSInteger)section
{
    NSDate * Date = _dayArray[section];
    return Date;
}

//获取每个重合矩形的信息
- (NSMutableDictionary *)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout getNumLevelsForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionary];
    for (int i=0; i<_areaArray.count; i++) {
        AreaObj * areObj = _areaArray[i];
        if (areObj.indexPath == indexPath && areObj.areaObjArr.count>1) {
            [tempDic setObject:@(areObj.rect.origin.y) forKey:@"originY"];
            [tempDic setObject:@(areObj.areaObjArr.count) forKey:@"numLevels"];
        }
    }
    return tempDic;
}
    
- (CGRect)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout getRectForIndexPath:(NSIndexPath *)indexPath{
    CGRect rect;
    for (int i=0; i<_areaArray.count; i++) {
        AreaObj * areObj = _areaArray[i];
        if (areObj.indexPath == indexPath) {
            rect = areObj.rect;
        }
    }
    return rect;
}

#pragma mark - Pressed
-(void)sigleTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.collectionView];
    NSLog(@"位置：X:%f Y:%f",point.x,point.y);
    NSUInteger section = (point.x - self.collectionViewCalendarLayout.timeRowHeaderWidth)/(self.collectionViewCalendarLayout.sectionWidth);
    if (self.collectionViewCalendarLayout.selectedSection >= 0) {
        //有选中状态
        CGFloat baseWidth = self.collectionViewCalendarLayout.sectionWidth;
        NSInteger sectionIndex = self.collectionViewCalendarLayout.selectedSection;
        CGFloat minXSelectedSection = self.collectionViewCalendarLayout.timeRowHeaderWidth+baseWidth*(sectionIndex);
        CGFloat maxXSelectedSection = minXSelectedSection + self.collectionViewCalendarLayout.selectedSectionWidth;
        if (point.x >= minXSelectedSection && point.x <= maxXSelectedSection){
            section = self.collectionViewCalendarLayout.selectedSection;
        }else if (point.x > maxXSelectedSection){
            section = (point.x - maxXSelectedSection)/baseWidth + sectionIndex+1;
        }
    }
    
    //点击效果
//    self.collectionViewCalendarLayout.selectedSection = section;
//    self.collectionViewCalendarLayout.selectedSectionWidth = SELECTED_SECTION_WIDTH;
//    [self.collectionViewCalendarLayout invalidateLayoutCache];
//    [self.collectionViewCalendarLayout invalidateLayout];
//    [self.collectionView reloadData];
    
    for (int i=0; i<_areaArray.count; i++) {
        AreaObj * areObj = _areaArray[i];
        if (areObj.section == section) {
            if (CGRectContainsPoint(areObj.rect,point)) {
                if (areObj.areaObjArr.count>1) {
                    //点击的点在合并区域内,
                    if (_courseView!=nil) {
                        [_courseView.courseArr addObjectsFromArray:areObj.areaObjArr];
                        [_courseView showView];
                    }
                    break;
                }else{
                    //点击的点在单独区域内,
                    CalendarCourseModel *  obj = areObj.areaObjArr[0];
                    UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"单独区域" message:obj.crid delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"sure", nil];
                    [alertview show];
                    break;
                }
            }
        }
    }
}

#pragma mark - title
-(void)createTitle
{
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 20)];
    titleView.tag = 50002;
    _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_titleBtn setFrame:CGRectMake((titleView.frame.size.width-20)/2, 0, 20, 20)];
    
    UILabel * titleLabel = [[UILabel alloc] init];
    [titleLabel setFrame:CGRectMake(0, 0, 15, 20)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.tag = 50000;
    [_titleBtn addSubview:titleLabel];
    
    UIImageView * titleImage = [[UIImageView alloc] init];
    titleImage.image = [UIImage imageNamed:@"triangle"];
    [titleImage setFrame:CGRectMake(15, 6, 10,8)];
    titleImage.tag = 50001;
    
    [_titleBtn addSubview:titleImage];
    [_titleBtn addTarget:self action:@selector(titleClicked) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:_titleBtn];
    self.navigationItem.titleView = titleView;
}

- (void)setCurrentTitle:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];//获取字符串的宽高
    [_titleBtn setFrame:CGRectMake((self.navigationItem.titleView.frame.size.width-(size.width+15))/2.0, 0, size.width+10, 20)];
    
    UILabel * titleLabel = (UILabel *)[_titleBtn viewWithTag:50000];
    [titleLabel setFrame:CGRectMake(0, 0, size.width+5, 20)];
    titleLabel.text = str;
    
    UIImageView * titleImage = (UIImageView *)[_titleBtn viewWithTag:50001];
    [titleImage setFrame:CGRectMake(size.width, 6, 10,8)];
}

-(void)titleClicked
{
    UIImageView * titleImage = (UIImageView *)[_titleBtn viewWithTag:50001];
    [UIView animateWithDuration:0.3 animations:^{
        titleImage.transform = CGAffineTransformMakeRotation(M_PI);
        if (self.weekArray.count>0){
            [_selectedWeekView showPop];
        }
    } completion:^(BOOL finished) {
        self.flag = YES;
    }];
}

#pragma mark - 选中周
- (void)selectedWeekView:(SelectedWeekView *)view didPressedInWeek:(CalendarWeekObj *)obj
{
    [self setCurrentTitle:obj.weeks];
    [self changeFlag];
    //
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:sourceTimeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date = [formatter dateFromString:obj.startime];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *selectedComponents = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSString * monthStr = [NSString stringWithFormat:@"%ld月",selectedComponents.month];
    if (![monthStr isEqualToString:self.monthLabel.text]) {
        //不同月
        self.monthLabel.text = monthStr;
    }
    [self getMonthBeginAndEndWith:date];
    [self requestDataSourceWithStartime:obj.startime endTime:obj.endtime];
}

- (void)selectedWeekViewDidSpacePlace:(SelectedWeekView *)view
{
    [self changeFlag];
}

-(void)changeFlag
{
    UIImageView * titleImage = (UIImageView *)[_titleBtn viewWithTag:50001];
    [UIView animateWithDuration:0.3 animations:^{
        titleImage.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        self.flag = NO;
    }];
}

#pragma mark - ChoiceCourseViewDelegate
-(void)choiceCourseView:(ChoiceCourseView *)view didPressedCourseCrid:(NSString *)crid isLiveClass:(NSString *)isLiveClass
{
    UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"重合区域" message:crid delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"sure", nil];
    [alertview show];
}

@end

