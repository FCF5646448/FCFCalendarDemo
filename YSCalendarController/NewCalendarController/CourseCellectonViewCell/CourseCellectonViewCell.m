//
//  CourseCellectonViewCell.m
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/7.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import "CourseCellectonViewCell.h"
#import "UIColor+Extension.h"

@interface CourseCellectonViewCell()
@property (nonatomic, strong) UILabel * courseLabel;
@property (nonatomic, strong) UIImageView * headImgView;
@end

@implementation CourseCellectonViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.courseLabel = [UILabel new];
        self.courseLabel.numberOfLines = 0;
        self.courseLabel.backgroundColor = [UIColor clearColor];
        self.courseLabel.font = [UIFont systemFontOfSize:12];
        self.courseLabel.frame = CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4);
        self.courseLabel.text = nil;
//        [self.contentView addSubview:self.courseLabel];
        self.headImgView = [[UIImageView alloc] init];
        self.headImgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.headImgView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:self.headImgView];
    }
    return self;
}

- (void) setBgColor:(NSString *)color
{
//    self.backgroundColor = [UIColor colorWithHexString:color];
//    self.layer.shadowColor = [[UIColor colorWithHexString:color] CGColor];
}

- (void) setCourseName:(NSString *)courseName
{
//    self.courseLabel.text = courseName;
//    CGSize size = [self.courseLabel.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(self.frame.size.width-4, MAXFLOAT)];
//
//    if (size.height<self.frame.size.height-4) {
//        [self.courseLabel setFrame:CGRectMake(2, 2, self.frame.size.width-4, size.height)];
//    }else{
//        [self.courseLabel setFrame:CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4)];
//    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    self.courseLabel.frame = CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4);
//    [self.layer setCornerRadius:4.0];
//    [self.layer setMasksToBounds:YES];
//    [self.layer setBorderWidth:1];
//    [self.layer setBorderColor:[UIColor colorWithHexString:@"eeeeee"].CGColor];
//    
//    CGSize size = [self.courseLabel.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(self.frame.size.width-4, MAXFLOAT)];
//    if (size.height<self.frame.size.height-4) {
//        [self.courseLabel setFrame:CGRectMake(2, 2, self.frame.size.width-4, size.height)];
//    }else{
//        [self.courseLabel setFrame:CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4)];
//    }
    self.headImgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}
    
- (void) setCoursePic:(NSString *)pic{
    NSURL* url = [NSURL URLWithString:pic];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@",error);
            self.headImgView.image = [UIImage imageNamed:@"mine_default_head"];
        }else{
            UIImage * img = [UIImage imageWithData:data];
            self.headImgView.image = img;
        }
    }];
    [dataTask resume];
}

- (void)dealloc
{
    _courseLabel.text = nil;
}

@end
