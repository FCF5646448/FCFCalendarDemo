//
//  PointReusableView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/5.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "PointReusableView.h"
#import "UIColor+Extension.h"

@implementation PointReusableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:self.frame.size.height/2.0];
        [self.layer setMasksToBounds:YES];
        self.backgroundColor = [UIColor colorWithHexString:@"c2d7de"];
    }
    return self;
}
@end
