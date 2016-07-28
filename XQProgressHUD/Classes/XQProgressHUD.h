//
//  XQBeingLoadedHUD.h
//  XQBeingLoadedHud
//
//  Created by 用户 on 16/7/21.
//  Copyright © 2016年 com.xinqianliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIWindow+SIUtils.h"
#import "XQAnimatedView.h"
#import "XQBeingLoadedGifImageView.h"

@class XQProgressHUD;

/**
 *  View Loading Timeout Feedback
 *
 *  @param hud XQBeingLoadedHUD
 */
typedef void(^TimeoutBlock)(XQProgressHUD *hud);



/**
 *  弹出视图，调用 "dismiss" 方法后，切记释放对象 XQBeingLoadedHUD = nil
 *  @param 例如：  XQBeingLoadedHUD *_hud = [[XQBeingLoadedHUD alloc] init]; [_hud showWithGIFNamed:nil Timeout:5.0f timeoutBlock:^{ NSLog(@"超时了"); _hud = nil; }];
 *  @param  所以子视图布局不可更改
- returns:
 */
@interface XQProgressHUD : UIView

#pragma mark - Public Methods
/**
 *  Remove the view
 */
- (void)dismiss;



#pragma mark - Public Attribute
@property (nonatomic, readonly, strong) UIWindow      *overlayWindow;
@property (nonatomic, readonly, strong) UIWindow      *hudWindow;
@property (nonatomic, readonly, copy) TimeoutBlock    timeoutBlock;// View Loading Timeout Feedback



#pragma mark - XQAnimatedView
@property (nonatomic, strong) XQAnimatedViewModel *animatedViewModel;  // Set the animatedView style

/**
 *  Display Default Animation View
 */
- (void)show;

/**
 *  Display The Animation View
 *
 *  @param userInteraction Whether To Enable User Interaction ，NO To Enable ，YES For The Disabled
 */
- (void)showAnimationViewOfUserInteraction:(BOOL)userInteraction;

/**
 *  Animation View For Load The Timeout
 *
 *  @param time            Set The Timeout , Time >= 0.1f
 *  @param userInteraction Whether To Enable User Interaction ，NO To Enable ，YES For The Disabled
 *  @param timeoutBlock    View Loading Timeout Feedback
 */
- (void)showAnimationViewOfTimeout:(NSTimeInterval)time
                   userInteraction:(BOOL)userInteraction
                      timeoutBlock:(TimeoutBlock)timeoutBlock;



#pragma mark - XQBeingLoadedGifImageView
/**
 *  Display Default Gif
 */
- (void)showGif;

/**
 *  Display GIF Figure
 *
 *  @param named           GIF Name , Default "u8.gif"
 *  @param userInteraction Whether To Enable User Interaction ，NO To Enable ，YES For The Disabled
 */
- (void)showGifImageViewOfGifNamed:(NSString *)named userInteraction:(BOOL)userInteraction;

/**
 *  GIF Figure For Load The Timeout
 *
 *  @param named           GIF Name , Default "u8.gif"
 *  @param time            Set The Timeout , Time >= 0.1f
 *  @param userInteraction Whether To Enable User Interaction ，NO To Enable ，YES For The Disabled
 *  @param timeoutBlock    View Loading Timeout Feedback
 */
- (void)showGifImageViewOfGifNamed:(NSString *)named
                           Timeout:(NSTimeInterval)time
                   userInteraction:(BOOL)userInteraction
                      timeoutBlock:(TimeoutBlock)timeoutBlock;

@end
