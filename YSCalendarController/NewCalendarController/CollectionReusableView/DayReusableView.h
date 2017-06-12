//
//  DayReusableView.h
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/4.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayReusableView : UICollectionReusableView
@property (nonatomic, strong) UILabel * dayTitle;
@property (nonatomic, strong) UILabel * dateTitle;
@property (nonatomic, strong) NSDate * day;
@end
