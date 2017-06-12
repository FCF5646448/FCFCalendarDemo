//
//  ChoiceCourseView.h
//  edu-Yusi3
//
//  Created by 冯才凡 on 16/1/8.
//  Copyright © 2016年 yusi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  ChoiceCourseViewDelegate;

@interface ChoiceCourseView : UIView
@property (nonatomic, weak)id delegate;
@property (nonatomic, strong)NSMutableArray * courseArr;
- (void)showView;
- (void)hideView;
@end

@protocol ChoiceCourseViewDelegate <NSObject>
    
-(void)choiceCourseView:(ChoiceCourseView *)view didPressedCourseCrid:(NSString *)crid isLiveClass:(NSString*)isLiveClass;
    
@end
