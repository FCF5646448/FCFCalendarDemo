//
//  HorizontalReusableView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/7/26.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "HorizontalReusableView.h"
#import "UIColor+Extension.h"

@implementation HorizontalReusableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"c2d7de"];
    }
    return self;
}
@end
