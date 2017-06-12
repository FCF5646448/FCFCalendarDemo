//
//  SelectedWeekView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 15/12/30.
//  Copyright © 2015年 yusi. All rights reserved.
//

/*
 这里唯一要注意的问题就是第一次使用这个东西
 selectRowAtIndexPath:indexPath animated:NO  scrollPosition:
 以及选中状态的
 cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
 cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"01b6fb"];
 cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:@"f5f9f2"];
 */

#import "SelectedWeekView.h"
#import "UIColor+Extension.h"
static NSString * const kLPAnimationKeyPopup = @"kLPAnimationKeyPopup";

@interface SelectedWeekView()
    {
        UIView * _popBgView;
        UITableView * _tableView;
        UIView * _toauchView;
        UIImageView * _triangleImg;
    }
    
    @end

@implementation SelectedWeekView
    
    
- (instancetype)init
    {
        self = [super init];
        if (self) {
            _isShow = NO;
            _dataSource = [NSMutableArray array];
            [self createUI];
        }
        return self;
    }
    
- (void)layoutSubviews
    {
        [super layoutSubviews];
        CGFloat popWidth = 216;
        CGFloat popHeight = 254;
        CGFloat x = ([UIScreen mainScreen].bounds.size.width-popWidth)/2;
        [_popBgView setFrame:CGRectMake(x, 64-12, popWidth, popHeight+5)];
        [_tableView setFrame:CGRectMake(0, 5, popWidth, popHeight)];
        [_toauchView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    
- (void)createUI
    {
        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        self.userInteractionEnabled = YES;
        
        _toauchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _toauchView.userInteractionEnabled = YES;
        [self addSubview:_toauchView];
        _toauchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedWeekViewdidPressedSpacePlace)];
        [_toauchView addGestureRecognizer:tap];
        
        CGFloat popWidth = 200;
        CGFloat popHeight = 254;
        CGFloat x = ([UIScreen mainScreen].bounds.size.width-popWidth)/2.0;
        _popBgView = [[UIView alloc] initWithFrame:CGRectMake(x, 64-12, popWidth, popHeight+5)];
        _popBgView.userInteractionEnabled = YES;
        [self addSubview:_popBgView];
        
        _triangleImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle_up"]];
        [_triangleImg setFrame:CGRectMake((200-8)/2.0, 0, 8, 6)];
        _triangleImg.contentMode = UIViewContentModeScaleAspectFit;
        [_popBgView addSubview:_triangleImg];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 5, popWidth, popHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.userInteractionEnabled = YES;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"SelectedWeekCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SelectedWeekCell"];
        [_popBgView addSubview:_tableView];
        [_tableView.layer setCornerRadius:4.0];
        [_tableView.layer setMasksToBounds:YES];
        
    }
    
#pragma mark - UITableviewDelegate UITabelVIewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        return _dataSource.count;
    }
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        return 40;
    }
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        UITableViewCell * cell;
        static NSString * cellName = @"cellName";
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        CalendarWeekObj * obj = _dataSource[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.text = obj.weeks;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"01b6fb"];
        cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:@"f5f9f2"];
        return cell;
    }
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
        CalendarWeekObj * obj = _dataSource[indexPath.row];
        _currentWeekIndex = indexPath.row;
        if ([self.delegate respondsToSelector:@selector(selectedWeekView:didPressedInWeek:)]) {
            [self.delegate selectedWeekView:self didPressedInWeek:obj];
        }
        [self hidePop];
    }
    
- (void)selectedWeekViewdidPressedSpacePlace
    {
        if ([self.delegate respondsToSelector:@selector(selectedWeekViewDidSpacePlace:)]) {
            [self.delegate selectedWeekViewDidSpacePlace:self];
        }
        [self hidePop];
    }
    
- (void)showPop
    {
        _isShow = YES;
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        [keyWindow addSubview:self];
        _tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        _toauchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        _triangleImg.alpha = 0;
        _popBgView.alpha = 0;
        [_tableView reloadData];
        [UIView animateWithDuration:0.3 animations:^{
            _tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
            _tableView.alpha = 1;
            _triangleImg.alpha = 1;
            _popBgView.alpha = 1;
            _toauchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_currentWeekIndex inSection:0];
            [_tableView selectRowAtIndexPath:indexPath animated:NO  scrollPosition:UITableViewScrollPositionBottom];
            
        } completion:^(BOOL finished) {
            [self setNeedsLayout];
        }];
    }
    
- (void)hidePop
    {
        _isShow = NO;
        _tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        _toauchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _triangleImg.alpha = 1;
        _popBgView.alpha = 1;
        _tableView.alpha = 1;
        [UIView animateWithDuration:0.3 animations:^{
            _toauchView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
            _tableView.alpha = 0;
            _triangleImg.alpha = 0;
            _popBgView.alpha = 0;
            _tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
