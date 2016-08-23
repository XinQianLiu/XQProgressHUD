//
//  XQBeingLoadedHUD.h
//  XQBeingLoadedHud
//
//  Created by 用户 on 16/7/21.
//  Copyright © 2016年 com.xinqianliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

@class XQProgressHUD;

/**
 *  The style of display view
 */
typedef NS_ENUM(NSInteger , XQProgressHUDMode) {
    // There is no view
    XQProgressHUDModeNone,
    // UIActivityIndicatorView
    XQProgressHUDModeIndicator,
    // Rotating style
    XQProgressHUDModeRotating,
    // Cyclic rotation style
    XQProgressHUDModeCyclicRotation,
    // Shows a custom indicator
    XQProgressHUDModeCustomIndicator,
    // Shows a success image view
    XQProgressHUDModeSuccess,
    // Shows a error image view
    XQProgressHUDModeError,
    // Shows a progress view
    XQProgressHUDModeProgress,
    // Shows a GIF image view
    XQProgressHUDModeGIF,
    // Shows only labels
    XQProgressHUDModeTextOnly
};

typedef void(^XQProgressHUDHandler)();

#pragma mark - XQProgressHUD
@interface XQProgressHUD : UIView

+ (instancetype)HUD;

- (void)show;
- (void)showWithTimeout:(NSTimeInterval)time;

- (void)dismiss;

@property (nonatomic, assign) XQProgressHUDMode     mode;                           // Default is XQProgressHUDModeIndicator.
@property (nonatomic, copy) XQProgressHUDHandler    didDismissHandler;
@property (nonatomic) UIView                        *customIndicator;

@property (nonatomic) UIColor                       *foregroundColor;               // Default xq_hudForegroundColor
@property (nonatomic) UIColor                       *foregroundBorderColor;         // Default clearColor
@property (nonatomic, assign) CGFloat               foregroundBorderWidth;          // Default 0.0f
@property (nonatomic, assign) CGFloat               foregroundCornerRaidus;         // Default 5.0f;

@property (nonatomic, copy) NSString                *text;                          // Default "Loading"
@property (nonatomic) UIFont                        *textFont;                      // Default is 15.0f
@property (nonatomic) UIColor                       *textColor;                     // Default xq_animatedViewDefaultColor
@property (nonatomic, copy) NSString                *gifImageName;                  // Default is "u8.gif"
@property (nonatomic, assign) BOOL                  suffixPointEnabled;             // Whether to show "..." or not. Default YES.
@property (nonatomic, assign) CGFloat               suffixPointAnimationDuration;   // Default 0.2f;
@property (nonatomic, assign) CGFloat               yOffset;
@property (nonatomic, assign) CGSize                size;                           // Default is CGSizeMake(120.0f, 90.0f)
@property (nonatomic, assign) CGFloat               maximumWidth;                   // Default is 140.0f, textOnly is 260.0f;

@property (nonatomic) UIColor                       *trackTintColor;                // Default whiteColor
@property (nonatomic) UIColor                       *progressTintColor;             // Default xq_animatedViewDefaultColor
@property (nonatomic, assign) CGFloat               animationDuration;              // Default 1.5f
@property (nonatomic, assign) CGFloat               ringRadius;                     // Default 20.0f
@property (nonatomic, assign) CGFloat               progress;                       // Progress (0.0 to 1.0)

@end


#pragma mark - XQAnimateds
@interface XQAnimationHelper : NSObject;

+ (CAAnimationGroup *)cyclicRotationAnimationWithDuration:(CFTimeInterval)duration;

+ (CABasicAnimation *)rotatingAnimationWithDuration:(CFTimeInterval)duration;

@end;

#pragma mark - XQAnimatedView
@interface XQAnimationView : UIView

- (void)loadAnimateds;

@property (nonatomic, assign) XQProgressHUDMode mode;
@property (nonatomic, strong) UIColor           *trackTintColor;    // default whiteColor
@property (nonatomic, strong) UIColor           *progressTintColor; // default xq_animatedViewDefaultColor
@property (nonatomic, assign) CGFloat           animationDuration;  // default 2.0f
@property (nonatomic, assign) CGFloat           radius;             // default 20.0f
@property (nonatomic, assign) CGFloat           progress;

@end

#pragma mark - UIImage Category
@interface UIImage (XQProgressHUDImage)

// loading Image
+ (UIImage *)xq_imageWithName:(NSString *)named;
// loading Gif
+ (UIImage *)xq_gifWithName:(NSString *)name;

@end

#pragma mark - UIColor Category
@interface UIColor (XQProgressHUDColor)

+ (UIColor *)xq_animationViewDefaultColor;
+ (UIColor *)xq_hudForegroundColor;

@end
