//
//  XQAnimateds.m
//  XQBeingLoadedHud
//
//  Created by 用户 on 16/7/23.
//  Copyright © 2016年 com.xinqianliu. All rights reserved.
//

#import "XQAnimateds.h"

@implementation XQAnimateds

#pragma mark - The circle of the animation
+ (CAAnimationGroup *)beingLoadedAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    animation.duration = 1;
    animation.repeatCount = 1;
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    animation2.beginTime = 1;
    animation2.duration = 1;
    animation2.repeatCount = 1;
    animation2.fromValue = @0;
    animation2.toValue = @1;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation2.removedOnCompletion = NO;
    animation2.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation, animation2];
    group.duration = 2;
    group.repeatCount = CGFLOAT_MAX;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    return group;
}

@end
