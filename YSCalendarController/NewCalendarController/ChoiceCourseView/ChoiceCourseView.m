//
//  ChoiceCourseView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/8.
//  Copyright © 2016年 yusi. All rights reserved.
//

/*
 SLCoverFlowView
 这是别人的库，谢谢
 */

#import "ChoiceCourseView.h"
#import "SLCoverFlowView.h"
#import "SLCoverView.h"
#import "YSCalendarModel.h"
#import "UIColor+Extension.h"

static const CGFloat SLCoverViewSpace = -35;
static const CGFloat SLCoverViewAngle = 0.756634;//M_PI_4;
static const CGFloat SLCoverViewScale = 0.9;//1.219745;

@interface ChoiceCourseView()<SLCoverFlowViewDataSource,SLCoverViewDelegate>
{
    SLCoverFlowView *_coverFlowView;
    NSString *_isLivingClass;
}
@end

@implementation ChoiceCourseView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _courseArr = [NSMutableArray array];
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
    
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height*432)/736)/2.0;
    _coverFlowView = [[SLCoverFlowView alloc] initWithFrame:CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width, ([UIScreen mainScreen].bounds.size.height*432)/736)];
    _coverFlowView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    _coverFlowView.delegate = self;
    _coverFlowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _coverFlowView.coverSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width*326)/414, ([UIScreen mainScreen].bounds.size.height*432)/736);
    _coverFlowView.coverSpace = SLCoverViewSpace;
    _coverFlowView.coverAngle = SLCoverViewAngle;
    _coverFlowView.coverScale = SLCoverViewScale;
    [self addSubview:_coverFlowView];
}

#pragma mark - SLCoverFlowViewDataSource

- (NSInteger)numberOfCovers:(SLCoverFlowView *)coverFlowView {
    return _courseArr.count;//_colors.count;
}

- (SLCoverView *)coverFlowView:(SLCoverFlowView *)coverFlowView coverViewAtIndex:(NSInteger)index {
    CalendarCourseModel * model = _courseArr[index];
    _isLivingClass = model.type;
    SLCoverView *view = [[SLCoverView alloc] initWithFrame:CGRectMake(0.0, 0.0, ([UIScreen mainScreen].bounds.size.width*326)/414, ([UIScreen mainScreen].bounds.size.height*432)/736)];
    [view.layer setCornerRadius:4.0];
    [view.layer setMasksToBounds:YES];
    
    view.tag = 6000 + [model.crid intValue];
    view.crid = model.crid;
    NSURL* url = [NSURL URLWithString:model.photo];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@",error);
            view.headImageView.image = [UIImage imageNamed:@"mine_default_head"];
        }else{
            UIImage * img = [UIImage imageWithData:data];
            view.headImageView.image = img;
        }
    }];
    [dataTask resume];
    view.teacherNameLabel.text = model.teacher_name;
    view.courseDetailLabel.text = model.content;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:sourceTimeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * date = [formatter dateFromString:model.startime];
    
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    view.courseTimeLabel.text = [NSString stringWithFormat:@"直播时间:%@",[formatter stringFromDate:date]];
    
    view.delegate = self;
    UITapGestureRecognizer * coverVieTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverVieTap:)];
    [view addGestureRecognizer:coverVieTap];
    
    return view;
}

#pragma mark - 
- (void)showView
{
    UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [_coverFlowView reloadData];
    
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - ([UIScreen mainScreen].bounds.size.height*432)/736)/2.0 ;
    [_coverFlowView setFrame:CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width, ([UIScreen mainScreen].bounds.size.height*432)/736)];
    [UIView animateWithDuration:0.3 animations:^{
        _coverFlowView.alpha = 1;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }];
}

- (void)hideView
{
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        _coverFlowView.alpha = 0;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [_courseArr removeAllObjects];
        [self removeFromSuperview];
    }];
}

- (void)coverVieTap:(UIGestureRecognizer *)sender
{
    UIView * selectedView =  sender.view;
    NSInteger index = selectedView.tag - 6000;
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        _coverFlowView.alpha = 0;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [_courseArr removeAllObjects];
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(choiceCourseView:didPressedCourseCrid:isLiveClass:)]) {
            [self.delegate choiceCourseView:self didPressedCourseCrid:[NSString stringWithFormat:@"%ld",index] isLiveClass:_isLivingClass];
            
        }
    }];
}
    
#pragma mark - SLCoverViewDelegate
-(void)coverView:(SLCoverView *)view didClicked:(NSString *)crid{
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        _coverFlowView.alpha = 0;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [_courseArr removeAllObjects];
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(choiceCourseView:didPressedCourseCrid:isLiveClass:)]) {
            [self.delegate choiceCourseView:self didPressedCourseCrid:crid isLiveClass:_isLivingClass];
            
        }
    }];
}

@end
