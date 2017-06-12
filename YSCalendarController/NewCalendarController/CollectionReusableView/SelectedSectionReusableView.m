//
//  SelectedSectionReusableView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/5.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "SelectedSectionReusableView.h"
#import "UIColor+Extension.h"

@implementation SelectedSectionReusableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
    }
    return self;
}
@end
