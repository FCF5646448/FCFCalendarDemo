//
//  SLCoverView.h
//  SLCoverFlow
//
//  Created by jiapq on 13-6-19.
//  Copyright (c) 2013年 HNAGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  SLCoverViewDelegate;

@interface SLCoverView : UIView
@property (nonatomic, weak)id delegate;
@property (nonatomic, strong) UIImageView * headImageView;
@property (nonatomic, strong) UILabel * teacherNameLabel;
@property (nonatomic, strong) UILabel * courseDetailLabel;
@property (nonatomic, strong) UILabel * courseTimeLabel;
@property (nonatomic, strong) UIButton * watchCourseBtn;
@property (nonatomic, copy) NSString * crid;
@end

@protocol  SLCoverViewDelegate <NSObject>

-(void)coverView:(SLCoverView *)view didClicked:(NSString *)crid;

@end