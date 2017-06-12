//
//  SLCoverView.m
//  SLCoverFlow
//
//  Created by jiapq on 13-6-19.
//  Copyright (c) 2013年 HNAGroup. All rights reserved.
//

#import "SLCoverView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Extension.h"

#define GlobalScale  0.906

@implementation SLCoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 45*GlobalScale, self.frame.size.width, self.frame.size.height-45*GlobalScale)];
        bgView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
        [bgView.layer setCornerRadius:8.0];
        [bgView.layer setMasksToBounds:YES];
        [self addSubview:bgView];
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-45*GlobalScale, 0, 90*GlobalScale, 90*GlobalScale)];
        [_headImageView.layer setCornerRadius:45*GlobalScale];
        [_headImageView.layer setMasksToBounds:YES];
        [self addSubview:_headImageView];
        
        _teacherNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50*GlobalScale, self.frame.size.width, 21*GlobalScale)];
        _teacherNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _teacherNameLabel.font = [UIFont systemFontOfSize:15];
        _teacherNameLabel.textColor = [UIColor blackColor];
        _teacherNameLabel.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:_teacherNameLabel];
        
        _courseDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(25*GlobalScale, CGRectGetMaxY(_teacherNameLabel.frame)+10, self.frame.size.width-50*GlobalScale, 126*GlobalScale)];
        _courseDetailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _courseDetailLabel.font = [UIFont systemFontOfSize:13];
        _courseDetailLabel.textColor = [UIColor blackColor];
        _courseDetailLabel.textAlignment = NSTextAlignmentLeft;
        _courseDetailLabel.numberOfLines = 6;
        _courseDetailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [bgView addSubview:_courseDetailLabel];
        
        _courseTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(25*GlobalScale, CGRectGetMaxY(_courseDetailLabel.frame)+5,self.frame.size.width-50*GlobalScale , 21*GlobalScale)];
        _courseTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _courseTimeLabel.font = [UIFont systemFontOfSize:13];
        _courseTimeLabel.textColor = [UIColor blackColor];
        _courseTimeLabel.textAlignment = NSTextAlignmentLeft;
        [bgView addSubview:_courseTimeLabel];

        _watchCourseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _watchCourseBtn.frame = CGRectMake(25*GlobalScale, CGRectGetMaxY(_courseTimeLabel.frame)+12, self.frame.size.width-50*GlobalScale, 50*GlobalScale);
        if (bgView.frame.size.height - 30 > CGRectGetMaxY(_watchCourseBtn.frame)) {
            _watchCourseBtn.frame = CGRectMake(25*GlobalScale, bgView.frame.size.height - 25 - (50 * GlobalScale), self.frame.size.width-50*GlobalScale, 50*GlobalScale);
        }
        
        
        [_watchCourseBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_watchCourseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_watchCourseBtn setBackgroundColor:[UIColor colorWithHexString:@"54c552"]];
        [_watchCourseBtn.layer setCornerRadius:4.0];
        [_watchCourseBtn.layer setMasksToBounds:YES];
        [_watchCourseBtn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [bgView addSubview:_watchCourseBtn];
        
    }
    return self;
}

- (void)btnClicked{
    if ([self.delegate respondsToSelector:@selector(coverView:didClicked:)]) {
        [self.delegate coverView:self didClicked:self.crid];
    }
}

@end
