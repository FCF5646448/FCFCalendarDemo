//
//  NumOfLevelsReusableView.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/8.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "NumOfLevelsReusableView.h"

@implementation NumOfLevelsReusableView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = [UILabel new];
        self.title.backgroundColor = [UIColor redColor];
        self.title.font = [UIFont systemFontOfSize:13];
        
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.textColor = [UIColor whiteColor];//colorWithHexString:@"88c6e5"];
        self.title.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.title];
    }
    return self;
}

-(void)setNum:(NSInteger)num
{
    self.title.text = [NSString stringWithFormat:@"%ld",num];
}

-(void)layoutSubviews
{
    [self.title.layer setCornerRadius:self.frame.size.height/2.0];
    [self.title.layer setMasksToBounds:YES];
//    [self.layer setBorderWidth:1.0];
//    [self.layer setBorderColor:[UIColor colorWithHexString:@"daeaed"].CGColor];
}
@end
