//
//  NewCollectionViewCalendarLayout.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/4.
//  Copyright © 2016年 yusi. All rights reserved.
//

/*
 http://xtcel.com/wordpress/?p=91 这是别人的博客，可以借鉴一下
 这里NSCache第一次使用：http://www.jianshu.com/p/5e69e211b161
 
 1、自定义UICollectionLayout
	layout类中，三个被依次调用的方法是：
	1)、prepareLayout:准备所有view的layoutAttribute的信息
	2)、collectionViewContentSize:计算content size,显然这一步得在prepare之后进行
	3)、layoutAttributesForElementsInRect:返回在可见区域的view的layoutAttribute信息
 2、enumerateIndexesUsingBlock，遍历数组
 3、这里最应该注意的就是zIndex。修饰图DecorationView和SupplementaryView的层级关系就是由它决定的，之所以左侧的时间和上部的日期能够停留在那里也是因为它们底部各有一层层次更低的view，使得向左或向右滚动的时候，时间和日期不会滚到外面去
 4、filteredArrayUsingPredicate这个东西之前没用过，需要进一步了解
 5、花费时间最多的还是时间
 */

#import "NewCollectionViewCalendarLayout.h"


NSString * const CollectionElementKindTimeRowHeader = @"CollectionElementKindTimeRow";
NSString * const CollectionElementKindDayColumnHeader = @"CollectionElementKindDayHeader";
NSString * const CollectionElementKindTimeRowHeaderBackground = @"CollectionElementKindTimeRowHeaderBackground";
NSString * const CollectionElementKindDayColumnHeaderBackground = @"CollectionElementKindDayColumnHeaderBackground";
NSString * const CollectionElementKindPoint = @"CollectionElementKindPoint";

NSString * const CollectionElementKindVLine = @"CollectionElementKindVLine";
NSString * const CollectionElementKindHLine = @"CollectionElementKindHLine";

NSString * const CollectionElementKindSelectedView = @"CollectionElementKindSelectedView";
NSString * const CollectionElementKindMonthLabel = @"CollectionElementKindMonthLabel";
NSString * const CollectionElementKindNumOfLevels = @"CollectionElementKindNumOfLevels";
NSString * const CollectionElementKindCurrentGridLine = @"CollectionElementKindCurrentGridLine";


NSUInteger const MSCollectionMinOverlayZ = 1000.0; // Allows for 900 items in a section without z overlap issues
NSUInteger const MSCollectionMinCellZ = 100.0;  // Allows for 100 items in a section's background
NSUInteger const MSCollectionMinBackgroundZ = 0.0;


@interface  NewCollectionViewCalendarLayout()
    @property (nonatomic, assign) BOOL needsToPopulateAttributesForAllSections;
    @property (nonatomic, strong) NSMutableDictionary *timeRowHeaderAttributes;
    @property (nonatomic, strong) NSMutableDictionary *dayColumnHeaderAttributes;
    @property (nonatomic, strong) NSMutableDictionary *itemAttributes;
    @property (nonatomic, strong) NSMutableArray *allAttributes;
    
    @property (nonatomic, strong) NSCache * cachedStartTimeDateComponents;
    @property (nonatomic, strong) NSCache * cachedEndTimeDateComponents;
    
    // Registered Decoration Classes
    @property (nonatomic, strong) NSMutableDictionary *registeredDecorationClasses;
    @property (nonatomic, strong) NSMutableDictionary *timeRowHeaderBackgroundAttributes;
    @property (nonatomic, strong) NSMutableDictionary *dayColumnHeaderBackgroundAttributes;
    @property (nonatomic, strong) NSMutableDictionary *pointAttributes;
    
    @property (nonatomic, strong) NSMutableDictionary *veticalLineAttributes;
    @property (nonatomic, strong) NSMutableDictionary *horizontalLineAttributes;
    
    @property (nonatomic, strong) NSMutableDictionary *selectedSectionView;
    @property (nonatomic, strong) NSMutableDictionary *monthLabel;
    @property (nonatomic, strong) NSMutableDictionary *currentTimeGridLineAttributes;
    @property (nonatomic, strong) NSMutableDictionary *numOfLevelsAttributes;
    
    @end

@implementation NewCollectionViewCalendarLayout
    
- (instancetype)init
    {
        self = [super init];
        if (self) {
            self.selectedSection = -1;
            self.sectionWidth = SECTION_WIDTH;
            self.selectedSectionWidth = SECTION_WIDTH;
            self.hourHeight = SECTION_HEIGHT;
            self.timeRowHeaderWidth = TIMEROW_WIDTH;
            self.dayColumnHeaderHeight = SECTION_HEIGHT;
            self.needsToPopulateAttributesForAllSections = YES;
            self.displayHeaderBackgroundAtOrigin = YES;
            self.timeRowHeaderAttributes = [NSMutableDictionary new];
            self.dayColumnHeaderAttributes = [NSMutableDictionary new];
            self.itemAttributes = [NSMutableDictionary new];
            self.allAttributes = [NSMutableArray new];
            //
            self.cachedStartTimeDateComponents = [NSCache new];
            self.cachedEndTimeDateComponents = [NSCache new];
            //
            self.registeredDecorationClasses = [NSMutableDictionary new];
            self.timeRowHeaderBackgroundAttributes = [NSMutableDictionary new];
            self.dayColumnHeaderBackgroundAttributes = [NSMutableDictionary new];
            self.pointAttributes = [NSMutableDictionary new];
            
            self.veticalLineAttributes = [NSMutableDictionary new];
            self.horizontalLineAttributes = [NSMutableDictionary new];
            
            self.selectedSectionView = [NSMutableDictionary new];
            self.monthLabel = [NSMutableDictionary new];
            self.currentTimeGridLineAttributes = [NSMutableDictionary new];
            self.numOfLevelsAttributes = [NSMutableDictionary new];
        }
        return self;
    }
    
- (void)invalidateLayoutCache
    {
        self.needsToPopulateAttributesForAllSections = YES;
        [self.timeRowHeaderAttributes removeAllObjects];
        [self.dayColumnHeaderAttributes removeAllObjects];
        [self.itemAttributes removeAllObjects];
        [self.allAttributes removeAllObjects];
        //
        [self.cachedStartTimeDateComponents removeAllObjects];
        [self.cachedEndTimeDateComponents removeAllObjects];
        
        //
        [self.timeRowHeaderBackgroundAttributes removeAllObjects];
        [self.dayColumnHeaderBackgroundAttributes removeAllObjects];
        [self.pointAttributes removeAllObjects];
        
        [self.veticalLineAttributes removeAllObjects];
        [self.horizontalLineAttributes removeAllObjects];
        
        [self.selectedSectionView removeAllObjects];
        [self.monthLabel removeAllObjects];
        [self.currentTimeGridLineAttributes removeAllObjects];
        [self.numOfLevelsAttributes removeAllObjects];
    }
    
- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
    {
        [self invalidateLayoutCache];
        
        // Update the layout with the new items
        [self prepareLayout];
        
        [super prepareForCollectionViewUpdates:updateItems];
    }
    
- (void)finalizeCollectionViewUpdates
    {
        // This is a hack to prevent the error detailed in :
        // http://stackoverflow.com/questions/12857301/uicollectionview-decoration-and-supplementary-views-can-not-be-moved
        // If this doesn't happen, whenever the collection view has batch updates performed on it, we get multiple instantiations of decoration classes
        for (UIView *subview in self.collectionView.subviews) {
            for (Class decorationViewClass in self.registeredDecorationClasses.allValues) {
                if ([subview isKindOfClass:decorationViewClass]) {
                    [subview removeFromSuperview];
                }
            }
        }
        [self.collectionView reloadData];
    }
    
- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)decorationViewKind
    {
        [super registerClass:viewClass forDecorationViewOfKind:decorationViewKind];
        self.registeredDecorationClasses[decorationViewKind] = viewClass;
    }
    
- (void)prepareLayout
    {
        [super prepareLayout];
        if (self.needsToPopulateAttributesForAllSections) {
            [self prepareSectionLayoutForSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
            self.needsToPopulateAttributesForAllSections = NO;
        }
        
        BOOL needsToPopulateAllAttribtues = (self.allAttributes.count == 0);
        if (needsToPopulateAllAttribtues) {
            [self.allAttributes addObjectsFromArray:[self.dayColumnHeaderAttributes allValues]];
            [self.allAttributes addObjectsFromArray:[self.dayColumnHeaderBackgroundAttributes allValues]];
            [self.allAttributes addObjectsFromArray:[self.timeRowHeaderAttributes allValues]];
            [self.allAttributes addObjectsFromArray:[self.timeRowHeaderBackgroundAttributes allValues]];
            [self.allAttributes addObjectsFromArray:[self.pointAttributes allValues]];
            
            [self.allAttributes addObjectsFromArray:[self.veticalLineAttributes allValues]];
            [self.allAttributes addObjectsFromArray:[self.horizontalLineAttributes allValues]];
            
            [self.allAttributes addObjectsFromArray:[self.selectedSectionView allValues]];
            [self.allAttributes addObjectsFromArray:[self.itemAttributes allValues]];
            [self.allAttributes addObjectsFromArray:[self.monthLabel allValues]];
            [self.allAttributes addObjectsFromArray:[self.currentTimeGridLineAttributes allValues]];
            [self.allAttributes addObjectsFromArray:[self.numOfLevelsAttributes allValues]];
        }
    }
    
- (CGSize)collectionViewContentSize
    {
        return CGSizeMake(self.sectionWidth*6+self.selectedSectionWidth+self.timeRowHeaderWidth, (_latestHour-_earlistHour+1)*2*self.hourHeight+self.hourHeight);
    }
    
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
    {
        NSMutableIndexSet *visibleSections = [NSMutableIndexSet indexSet];
        [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)] enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            CGRect sectionRect = [self rectForSection:section];
            if (CGRectIntersectsRect(sectionRect, rect)) {
                [visibleSections addIndex:section];
            }
        }];
        
        // Update layout for only the visible sections
        [self prepareSectionLayoutForSections:visibleSections];
        
        //     Return the visible attributes (rect intersection)
        return [self.allAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, NSDictionary *bindings) {
            return CGRectIntersectsRect(rect, layoutAttributes.frame);
        }]];
    }
    
- (CGRect)rectForSection:(NSInteger)section
    {
        CGRect sectionRect;
        CGFloat calendarGridMinX = (self.timeRowHeaderWidth);
        CGFloat sectionWidth = self.sectionWidth;
        CGFloat sectionMinX;
        if(self.selectedSection < section){
            sectionMinX = (calendarGridMinX + (sectionWidth * section) + (self.selectedSectionWidth-self.sectionWidth));
        }else{
            sectionMinX = (calendarGridMinX + sectionWidth * section);
        }
        sectionRect = CGRectMake(sectionMinX, 0.0, sectionWidth, self.collectionViewContentSize.height);
        return sectionRect;
    }
    
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
    {
        // Required for sticky headers
        return YES;
    }
    
- (void)prepareSectionLayoutForSections:(NSIndexSet *)sectionIndexes
    {
        if (self.collectionView.numberOfSections == 0) {
            return;
        }
        BOOL needsToPopulateItemAttributes = (self.itemAttributes.count == 0);
        
        CGFloat minuteHeight = (self.hourHeight/30.0);//1分钟的高度
        NSInteger earliestHour = _earlistHour;
        NSInteger lastHour = _latestHour;
        BOOL hasPressedSection = (self.selectedSectionWidth != self.sectionWidth) ? YES : NO;
        
        //timeBg
        CGFloat timeRowHeaderMinX = fmaxf(self.collectionView.contentOffset.x, 0.0);//0
        BOOL timeRowHeaderFloating = ((timeRowHeaderMinX != 0) || self.displayHeaderBackgroundAtOrigin);
        
        NSIndexPath *timeRowHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewLayoutAttributes *timeRowHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:timeRowHeaderBackgroundIndexPath ofKind:CollectionElementKindTimeRowHeaderBackground withItemCache:self.timeRowHeaderBackgroundAttributes];
        // Frame
        CGFloat timeRowHeaderBackgroundHeight = self.collectionView.frame.size.height;//568
        CGFloat timeRowHeaderBackgroundWidth = self.collectionView.frame.size.width;//320
        CGFloat timeRowHeaderBackgroundMinX = (timeRowHeaderMinX - timeRowHeaderBackgroundWidth + self.timeRowHeaderWidth);//self.timeRowHeaderWidth==34  -286-0
        CGFloat timeRowHeaderBackgroundMinY = self.collectionView.contentOffset.y;//0
        timeRowHeaderBackgroundAttributes.frame = CGRectMake(timeRowHeaderBackgroundMinX, timeRowHeaderBackgroundMinY, timeRowHeaderBackgroundWidth, timeRowHeaderBackgroundHeight);//(-286,0,320,568)-0;
        
        // Floating
        timeRowHeaderBackgroundAttributes.hidden = !timeRowHeaderFloating;//no
        timeRowHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindTimeRowHeaderBackground floating:timeRowHeaderFloating];//zIndex代表层次关系 1005-0
        
        //dayBg
        CGFloat dayColumnHeaderMinY = fmaxf(self.collectionView.contentOffset.y, 0.0);//(0,0)
        BOOL dayColumnHeaderFloating = ((dayColumnHeaderMinY != 0) || self.displayHeaderBackgroundAtOrigin);
        
        NSIndexPath *dayColumnHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewLayoutAttributes *dayColumnHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:dayColumnHeaderBackgroundIndexPath ofKind:CollectionElementKindDayColumnHeaderBackground withItemCache:self.dayColumnHeaderBackgroundAttributes];
        // Frame
        CGFloat dayColumnHeaderBackgroundHeight = (self.dayColumnHeaderHeight + ((self.collectionView.contentOffset.y < 0.0) ? ABS(self.collectionView.contentOffset.y) : 0.0));//(45+((0<0.0)?ABS(0)))
        dayColumnHeaderBackgroundAttributes.frame = (CGRect){self.collectionView.contentOffset, {self.collectionView.frame.size.width, dayColumnHeaderBackgroundHeight}};//(0,0,320,45)
        // Floating
        dayColumnHeaderBackgroundAttributes.hidden = !dayColumnHeaderFloating;
        dayColumnHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindDayColumnHeaderBackground floating:dayColumnHeaderFloating];//1008-0;
        
        //time
        NSUInteger timeRowHeaderIndex = 0;
        for (NSInteger hour = earliestHour; hour<lastHour*2; hour++) {
            NSIndexPath *timeRowHeaderIndexPath = [NSIndexPath indexPathForItem:timeRowHeaderIndex inSection:0];
            UICollectionViewLayoutAttributes *timeRowHeaderAttributes = [self layoutAttributesSupplementaryViewAtIndexPath:timeRowHeaderIndexPath ofKind:CollectionElementKindTimeRowHeader withItemCache:self.timeRowHeaderAttributes];
            CGFloat titleRowHeaderMinY = (45 + (self.hourHeight * (hour - earliestHour)));
            
            timeRowHeaderAttributes.frame = CGRectMake(timeRowHeaderMinX, titleRowHeaderMinY, self.timeRowHeaderWidth, self.hourHeight);//(0,y,34,45)
            timeRowHeaderAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindTimeRowHeader floating:timeRowHeaderFloating];
            timeRowHeaderIndex++;
        }
        
        //item
        [sectionIndexes enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
            CGFloat sectionWidth = self.sectionWidth;
            CGFloat sectionMinX = self.timeRowHeaderWidth + (sectionWidth * section);//34
            
            if (self.selectedSection == section){
                sectionWidth = self.selectedSectionWidth;
            }else if (self.selectedSection < section){
                sectionMinX = sectionMinX+(self.selectedSectionWidth-self.sectionWidth);
            }
            
            //dayItem
            UICollectionViewLayoutAttributes *dayColumnHeaderAttributes = [self layoutAttributesSupplementaryViewAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] ofKind:CollectionElementKindDayColumnHeader withItemCache:self.dayColumnHeaderAttributes];
            
            dayColumnHeaderAttributes.frame = CGRectMake(sectionMinX, dayColumnHeaderMinY, sectionWidth, self.dayColumnHeaderHeight);//(sx,0,56,45)
            dayColumnHeaderAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindDayColumnHeader floating:dayColumnHeaderFloating];
            
            if (needsToPopulateItemAttributes) {
                //item
                NSMutableArray * sectionitemAttributes = [NSMutableArray new];
                for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
                    NSIndexPath * itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
                    UICollectionViewLayoutAttributes * itemAttributes = [self layoutAttributesForCellAtIndexPath:itemIndexPath withItemCache:self.itemAttributes];
                    [sectionitemAttributes addObject:itemAttributes];
                    
                    //                 NSDateComponents * itemStartTime = [self startTimerForIndexPath:itemIndexPath];
                    //                [itemStartTime setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                    //                NSDateComponents * itemEndTime = [self endTimerForIndexPath:itemIndexPath];
                    //                [itemEndTime setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                    //
                    //                CGFloat starHourMinY = ((itemStartTime.hour - earliestHour)*2 * self.hourHeight)+self.hourHeight;//((9-5)*45)-0
                    //                CGFloat starMinuteY = (itemStartTime.minute) * minuteHeight;
                    //                CGFloat startHourY = starHourMinY+starMinuteY;//y
                    //                CGFloat endHourY;//
                    //                if (itemStartTime.day!=itemEndTime.day) {
                    //                    //隔天
                    //                    endHourY = self.collectionViewContentSize.height;
                    //                }else{
                    //                    CGFloat endHourMinY = (itemEndTime.hour - earliestHour)*2 * self.hourHeight + self.hourHeight;
                    //                    CGFloat endMinuteY = (itemEndTime.minute) * minuteHeight;
                    //                    endHourY = endHourMinY+endMinuteY;
                    //                }
                    
                    //                itemAttributes.frame = CGRectMake(sectionMinX, startHourY , sectionWidth, (endHourY-startHourY));
                    itemAttributes.frame = [self rectOfItemAtIndexPath:itemIndexPath];
                    itemAttributes.zIndex = [self zIndexForElementKind:nil];
                }
            }
            
            //point
            //        if (section < (self.collectionView.numberOfSections-1)) {
            //            for (NSInteger hour = earliestHour; hour<(lastHour*2-1); hour++) {
            //                NSIndexPath *pointIndexPath = [NSIndexPath indexPathForItem:hour inSection:section];
            //                UICollectionViewLayoutAttributes *pointAttributes = [self layoutAttributesForDecorationViewAtIndexPath:pointIndexPath ofKind:CollectionElementKindPoint withItemCache:self.pointAttributes];
            //
            //                CGFloat minX = sectionMinX + sectionWidth-1;//+self.timeRowHeaderWidth
            //                CGFloat minY = (self.hourHeight + (self.hourHeight * (hour - earliestHour)))+(self.hourHeight-1);
            //                pointAttributes.frame = CGRectMake(minX, minY, 2, 2);//2
            //                pointAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindPoint];
            //            }
            //        }
            
            //竖线
            for (NSInteger hour = earliestHour; hour<lastHour*2-1;hour++) {
                // Vertical Gridline
                NSIndexPath * verticalIndexPatch = [NSIndexPath indexPathForItem:hour inSection:section];
                UICollectionViewLayoutAttributes * verticalLineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalIndexPatch ofKind:CollectionElementKindVLine withItemCache:self.veticalLineAttributes];
                CGFloat minX = sectionMinX;
                CGFloat minY = (self.hourHeight + (self.hourHeight * (hour - earliestHour)));
                verticalLineAttributes.frame = CGRectMake(minX, minY, 0.5, self.hourHeight);//
                verticalLineAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindVLine];
            }
            
            //横线
            for (NSInteger hour = earliestHour; hour<lastHour*2-1;hour++) {
                // horizontal Gridline
                NSIndexPath * horizontalIndexPatch = [NSIndexPath indexPathForItem:hour inSection:section];
                UICollectionViewLayoutAttributes * horizontalLineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:horizontalIndexPatch ofKind:CollectionElementKindHLine withItemCache:self.horizontalLineAttributes];
                CGFloat minX = sectionMinX;
                CGFloat minY = (self.hourHeight + (self.hourHeight * (hour - earliestHour)));
                horizontalLineAttributes.frame = CGRectMake(minX, minY, sectionWidth, 0.5);//self.hourHeight
                horizontalLineAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindHLine];
            }
            
            
            //selectedView
            if (hasPressedSection && self.selectedSection == section) {
                for (NSInteger hour = earliestHour; hour<=lastHour*2; hour++) {
                    NSIndexPath * selectedSectionViewIndexPath = [NSIndexPath indexPathForItem:hour inSection:section];
                    UICollectionViewLayoutAttributes *selectedSectionViewAttributes = [self layoutAttributesForDecorationViewAtIndexPath:selectedSectionViewIndexPath ofKind:CollectionElementKindSelectedView withItemCache:self.selectedSectionView];
                    CGFloat minX = sectionMinX;
                    CGFloat minY = (self.hourHeight + (self.hourHeight * (hour - earliestHour)));
                    
                    selectedSectionViewAttributes.frame = CGRectMake(minX, minY, sectionWidth, self.hourHeight);
                    //                timeRowHeaderAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindTimeRowHeader floating:timeRowHeaderFloating];
                }
            }
            
            //numOfLevels
            for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
                //            NSIndexPath * numOfLevelsViewIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
                //            NSDictionary * tempDic = [self numOfLevelsAtIndexPath:numOfLevelsViewIndexPath];
                //
                //            if ([tempDic objectForKey:@"originY"]) {
                //                UICollectionViewLayoutAttributes *numOfLevelsViewAttributes = [self layoutAttributesSupplementaryViewAtIndexPath:numOfLevelsViewIndexPath ofKind:CollectionElementKindNumOfLevels withItemCache:self.numOfLevelsAttributes];
                //                CGFloat minX = sectionMinX-15/2.0;
                //                CGFloat minY = [[tempDic objectForKey:@"originY"] floatValue]-15/2.0;
                //                numOfLevelsViewAttributes.frame = CGRectMake(minX, minY, 15, 15);
                //                numOfLevelsViewAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindNumOfLevels];
                //            }
            }
        }];
        //monthLabel
        
        NSIndexPath * monthLabelIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewLayoutAttributes *monthLabelAttributes = [self layoutAttributesForDecorationViewAtIndexPath:monthLabelIndexPath ofKind:CollectionElementKindMonthLabel withItemCache:self.monthLabel];
        // Frame
        
        monthLabelAttributes.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.timeRowHeaderWidth, self.hourHeight);
        // Floating
        dayColumnHeaderBackgroundAttributes.zIndex = 3000;
        
        //current time line
        
        NSIndexPath *currentTimeGridlineIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UICollectionViewLayoutAttributes *currentTimeGridlineAttributes =
        [self layoutAttributesForDecorationViewAtIndexPath:currentTimeGridlineIndexPath ofKind:CollectionElementKindCurrentGridLine withItemCache:self.currentTimeGridLineAttributes];
        
        NSCalendar * calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSDate *date = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: date];
        NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
        NSDateComponents *itemCurrentTime = [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:localeDate];
        
        if (itemCurrentTime.hour>earliestHour) {
            CGFloat starHourMinY = ((itemCurrentTime.hour - earliestHour)*2 * self.hourHeight)+self.hourHeight;//((9-5)*45)-0
            CGFloat starMinuteY = (itemCurrentTime.minute) * minuteHeight;
            CGFloat startCurrentY = starHourMinY+starMinuteY;
            currentTimeGridlineAttributes.frame = CGRectMake(self.timeRowHeaderWidth-2, startCurrentY, self.collectionViewContentSize.width, 1);
        }
        
        currentTimeGridlineAttributes.zIndex = [self zIndexForElementKind:CollectionElementKindCurrentGridLine];
    }
    
#pragma mark - zIndex
- (CGFloat)zIndexForElementKind:(NSString *)elementKind
    {
        return [self zIndexForElementKind:elementKind floating:NO];
    }
    
- (CGFloat)zIndexForElementKind:(NSString *)elementKind floating:(BOOL)floating
    {
        // Time Row Header
        if (elementKind == CollectionElementKindTimeRowHeader) {
            return (MSCollectionMinOverlayZ +  (floating ? 8.0 : 3.0) );
        }
        // Time Row Header Background
        
        else if (elementKind == CollectionElementKindTimeRowHeaderBackground) {
            return (MSCollectionMinOverlayZ + (floating ? 7.0 : 2.0));
        }
        // Day Column Header
        else if (elementKind == CollectionElementKindDayColumnHeader) {
            return (MSCollectionMinOverlayZ +  (floating ? 6.0 : 1.0));
        }
        //     Day Column Header Background
        else if (elementKind == CollectionElementKindDayColumnHeaderBackground) {
            return (MSCollectionMinOverlayZ + (floating ? 5.0 : 0.0));
        }
        // Cell
        else if (elementKind == nil) {
            return MSCollectionMinCellZ+10;
        }
        // Point
        else if (elementKind == CollectionElementKindPoint) {
            return (MSCollectionMinCellZ + 5.0);
        }
        // Current Time Vertical Gridline
        else if (elementKind == CollectionElementKindVLine) {
            return (MSCollectionMinCellZ + 5.0);
        }
        //
        else if (elementKind == CollectionElementKindHLine) {
            return (MSCollectionMinCellZ + 5.0);
        }
        //    // Vertical Gridline
        else if (elementKind == CollectionElementKindSelectedView) {
            return (MSCollectionMinBackgroundZ + 2.0);
        }
        // monthLabel
        else if (elementKind == CollectionElementKindMonthLabel) {
            return MSCollectionMinOverlayZ + (floating ? 9.0 : 4.0);
        }
        //current time
        else if (elementKind == CollectionElementKindCurrentGridLine){
            return (MSCollectionMinCellZ + 7.0);
        }
        //num of levels
        else if (elementKind == CollectionElementKindNumOfLevels){
            return (MSCollectionMinCellZ + 11.0);
        }
        return CGFLOAT_MIN;
    }
    
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
    {
        return self.itemAttributes[indexPath];
    }
    
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
    {
        if (kind == CollectionElementKindDayColumnHeader) {
            return self.dayColumnHeaderAttributes[indexPath];
        }else if (kind == CollectionElementKindTimeRowHeader) {
            return self.timeRowHeaderAttributes[indexPath];
        }else if(kind == CollectionElementKindNumOfLevels) {
            return self.numOfLevelsAttributes[indexPath];
        }
        return nil;
    }
    
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
    {
        if (decorationViewKind == CollectionElementKindPoint) {
            return self.pointAttributes[indexPath];
        }
        
        else if (decorationViewKind == CollectionElementKindVLine){
            return self.veticalLineAttributes[indexPath];
        }
        
        else if (decorationViewKind == CollectionElementKindHLine){
            return self.horizontalLineAttributes[indexPath];
        }
        
        else if (decorationViewKind == CollectionElementKindSelectedView) {
            return self.selectedSectionView[indexPath];
        }
        else if (decorationViewKind == CollectionElementKindMonthLabel) {
            return self.monthLabel[indexPath];
        }
        else if (decorationViewKind == CollectionElementKindCurrentGridLine) {
            return self.currentTimeGridLineAttributes[indexPath];
        }
        else if (decorationViewKind == CollectionElementKindTimeRowHeaderBackground) {
            return self.timeRowHeaderBackgroundAttributes[indexPath];
        }
        else if (decorationViewKind == CollectionElementKindDayColumnHeader) {
            return self.dayColumnHeaderBackgroundAttributes[indexPath];
        }
        return nil;
    }
    
#pragma mark - layout
    //生成装饰view的函数bakcgroundview、时间点和线、纵向的线、
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache
    {
        UICollectionViewLayoutAttributes *layoutAttributes;
        if (self.registeredDecorationClasses[kind] && !(layoutAttributes = itemCache[indexPath])) {
            layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
            itemCache[indexPath] = layoutAttributes;
        }
        return layoutAttributes;
    }
    
    //左侧补充view、上部的日期view
- (UICollectionViewLayoutAttributes *)layoutAttributesSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache
    {
        UICollectionViewLayoutAttributes *layoutAttributes;
        if (!(layoutAttributes = itemCache[indexPath])) {
            layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
            itemCache[indexPath] = layoutAttributes;
        }
        return layoutAttributes;
    }
    
    //item
- (UICollectionViewLayoutAttributes *)layoutAttributesForCellAtIndexPath:(NSIndexPath *)indexPath withItemCache:(NSMutableDictionary *)itemCache
    {
        UICollectionViewLayoutAttributes *layoutAttributes;
        if (!(layoutAttributes = itemCache[indexPath])) {
            layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemCache[indexPath] = layoutAttributes;
        }
        return layoutAttributes;
    }
    
#pragma mark -
- (NSDateComponents *)startTimerForIndexPath:(NSIndexPath *)indexPath
    {
        if ([self.cachedStartTimeDateComponents objectForKey:indexPath]) {
            return [self.cachedStartTimeDateComponents objectForKey:indexPath];
        }
        NSDate * date = [self.delegate collectionView:self.collectionView layout:self startTimeForItemAtIndexPath:indexPath];
        
        NSCalendar * calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSDateComponents *itemStartTime = [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
        [self.cachedStartTimeDateComponents setObject:itemStartTime forKey:indexPath];
        return itemStartTime;
    }
    
- (NSDateComponents *)endTimerForIndexPath:(NSIndexPath *)indexPath
    {
        if ([self.cachedEndTimeDateComponents objectForKey:indexPath]) {
            return [self.cachedEndTimeDateComponents objectForKey:indexPath];
        }
        
        NSDate *date = [self.delegate collectionView:self.collectionView layout:self endTimeForItemAtIndexPath:indexPath];
        
        NSCalendar * calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSDateComponents *itemEndTime = [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
        [self.cachedEndTimeDateComponents setObject:itemEndTime forKey:indexPath];
        return itemEndTime;
    }
    
#pragma mark Scrolling
    
- (void)scrollCollectionViewToClosetSectionToCurrentTimeAnimated:(BOOL)animated
    {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSDate *date = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: date];
        NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
        NSDateComponents *itemCurrentTime = [calendar components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:localeDate];
        CGFloat yOffset = 0;
        CGFloat minuteHeight = (self.hourHeight/30.0);//1分钟的高度
        if (itemCurrentTime.hour>_earlistHour) {
            CGFloat starHourMinY = ((itemCurrentTime.hour - _earlistHour)*2 * self.hourHeight)+self.hourHeight;//((9-5)*45)-0
            CGFloat starMinuteY = (itemCurrentTime.minute) * minuteHeight;
            CGFloat startCurrentY = starHourMinY+starMinuteY;
            yOffset = startCurrentY-(self.collectionView.frame.size.height/2.0);
        }
        
        CGFloat xOffset = 0;
        CGPoint contentOffset = CGPointMake(xOffset, yOffset);
        // Prevent the content offset from forcing the scroll view content off its bounds
        if (contentOffset.y > (_latestHour-_earlistHour+1)*2*SECTION_HEIGHT) {
            contentOffset.y = (_latestHour-_earlistHour+1)*2*SECTION_HEIGHT;
        }
        if (contentOffset.y < 0.0) {
            contentOffset.y = 0.0;
        }
        if (contentOffset.x > (self.collectionView.contentSize.width - self.collectionView.frame.size.width)) {
            contentOffset.x = (self.collectionView.contentSize.width - self.collectionView.frame.size.width);
        }
        if (contentOffset.x < 0.0) {
            contentOffset.x = 0.0;
        }
        [self.collectionView setContentOffset:contentOffset animated:animated];
    }
    
- (NSDate *)dateForDayColumnHeaderAtIndexPath:(NSIndexPath *)indexPath
    {
        NSDate *day = [self.delegate collectionView:self.collectionView layout:self dayForSection:indexPath.section];
        return day;//[[NSCalendar currentCalendar] startOfDayForDate:day];
    }
    
- (NSDictionary *)numOfLevelsAtIndexPath:(NSIndexPath *)indexPath
    {
        NSMutableDictionary * levelsDic = [self.delegate collectionView:self.collectionView layout:self getNumLevelsForIndexPath:indexPath];
        return levelsDic;
    }
    
- (CGRect)rectOfItemAtIndexPath:(NSIndexPath *)indexPath{
    CGRect rect = [self.delegate collectionView:self.collectionView layout:self getRectForIndexPath:indexPath];
    return rect;
}
    
@end
