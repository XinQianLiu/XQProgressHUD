//
//  XQAnimatedView.h
//  XQBeingLoadedHud
//
//  Created by 用户 on 16/7/23.
//  Copyright © 2016年 com.xinqianliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XQAnimateds.h"
#import "UIColor+XQColor.h"

@interface XQAnimatedViewModel : NSObject

@property (nonatomic, strong) UIColor   *outerLayerStrokeColor; // Default：[UIColor colorWithRed:0.36 green:0.60 blue:0.81 alpha:1.00]
@property (nonatomic, strong) UIColor   *innerLayerStrokeColor; // Default: whiteColor
@property (nonatomic, strong) UIColor   *selfLayerBorderColor;  // Default：[UIColor colorWithRed:0.36 green:0.60 blue:0.81 alpha:1.00]
@property (nonatomic, strong) UIColor   *selfBackgroundColor;   // Default：whiteColor
@property (nonatomic, strong) UIColor   *titleTextColor;        // Default：[UIColor colorWithRed:0.36 green:0.60 blue:0.81 alpha:1.00]
@property (nonatomic, copy) NSString    *titleText;             // "正在加载"
@property (nonatomic, assign) BOOL      isPointLabel;           // Default：YES , YES To Enable , NO For The Disabled

@end

@interface XQAnimatedView : UIView
- (instancetype)initAnimatedViewModel:(XQAnimatedViewModel *)model;

/**
 *  Remove Timer
 */
- (void)removeWeekTimer;
@end
