//
//  NewCollectionViewCalendarLayout.h
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/4.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SECTION_WIDTH  (([UIScreen mainScreen].bounds.size.width > 320)?(56):(56))
#define SECTION_HEIGHT 45
#define TIMEROW_WIDTH (([UIScreen mainScreen].bounds.size.width > 320)?(40):(40))
#define SELECTED_SECTION_WIDTH (([UIScreen mainScreen].bounds.size.width > 320)?(80):(80))

extern NSString * const CollectionElementKindTimeRowHeader;
extern NSString * const CollectionElementKindDayColumnHeader;
extern NSString * const CollectionElementKindTimeRowHeaderBackground;
extern NSString * const CollectionElementKindDayColumnHeaderBackground;
extern NSString * const CollectionElementKindPoint;

extern NSString * const CollectionElementKindVLine;//竖线
extern NSString * const CollectionElementKindHLine;//横线

extern NSString * const CollectionElementKindSelectedView;
extern NSString * const CollectionElementKindMonthLabel;
extern NSString * const CollectionElementKindCurrentGridLine;
extern NSString * const CollectionElementKindNumOfLevels;

@protocol  NewCollectionViewCalendarLayoutDelegate;
/**自定义ColletionLayout*/
@interface NewCollectionViewCalendarLayout : UICollectionViewLayout
    @property (nonatomic, weak) id delegate;
    @property (nonatomic, assign) CGFloat sectionWidth;
    @property (nonatomic, assign) CGFloat selectedSectionWidth;
    @property (nonatomic) CGFloat dayColumnHeaderHeight;
    @property (nonatomic, assign) CGFloat hourHeight;
    @property (nonatomic, assign) CGFloat timeRowHeaderWidth;
    @property (nonatomic) BOOL displayHeaderBackgroundAtOrigin;
    @property (nonatomic, assign) NSInteger selectedSection;
    @property (nonatomic, assign) NSInteger earlistHour;
    @property (nonatomic, assign) NSInteger latestHour;
    @property (nonatomic, assign) BOOL ifCurrentWeek;
    
    //获取顶部日期
- (NSDate *)dateForDayColumnHeaderAtIndexPath:(NSIndexPath *)indexPath;
    //获取左侧时间
- (NSDate *)dateForTimeColumnHeaderAtIndexPath:(NSIndexPath *)indexPath;
    //获取重合区域的数量
- (NSDictionary *)numOfLevelsAtIndexPath:(NSIndexPath *)indexPath;
    //滚动到当前时间
- (void)scrollCollectionViewToClosetSectionToCurrentTimeAnimated:(BOOL)animated;
    //清除缓存
- (void)invalidateLayoutCache;
    
    @end

@protocol NewCollectionViewCalendarLayoutDelegate <NSObject>
    
    //课程开始时间
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
    
    //课程结束时间
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
    
    //获取section对应的日期
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout dayForSection:(NSInteger)section;
    
    //获取每个section中的重合区域的信息，返回的数组里是一个字典，包含了起始位置和重合图层的信息
- (NSMutableDictionary *)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout getNumLevelsForIndexPath:(NSIndexPath *)indexPath;
    
    //获取每个item的rect
- (CGRect)collectionView:(UICollectionView *)collectionView layout:(NewCollectionViewCalendarLayout *)collectionViewLayout getRectForIndexPath:(NSIndexPath *)indexPath;//
@end
