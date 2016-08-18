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

#pragma mark -
#pragma mark - XQProgressHUD
@interface XQProgressHUD : UIView

+ (instancetype)HUD;

- (void)show;

- (void)dismiss;
- (void)dismissAfterDelay:(NSTimeInterval)delay;
- (void)didDissmissHandler:(XQProgressHUDHandler)handler;

@property (nonatomic, assign) XQProgressHUDMode mode;                   // Default is XQProgressHUDModeIndicator.
@property (nonatomic) UIView                    *customIndicator;

@property (nonatomic) UIColor                   *foregroundColor;       // Default xq_hudForegroundColor
@property (nonatomic) UIColor                   *foregroundBorderColor; // Default clearColor
@property (nonatomic, assign) CGFloat           foregroundBorderWidth;  // Default 0.0f
@property (nonatomic, assign) CGFloat           foregroundCornerRaidus; // Default 5.0f;

@property (nonatomic, copy) NSString            *text;                  // Default "Loading"
@property (nonatomic) UIFont                    *textFont;              // Default is 15.0f
@property (nonatomic) UIColor                   *textColor;             // Default xq_animatedViewDefaultColor
@property (nonatomic, copy) NSString            *gifImageName;          // Default is "u8.gif"
@property (nonatomic, assign) BOOL              suffixPointEnabled;     // Whether to show "..." or not. Default YES.
@property (nonatomic, assign) CGFloat           suffixPointAnimatedDuration; // Default 0.2f;
@property (nonatomic, assign) CGFloat           yOffset;                // Set offset.y instead.
@property (nonatomic, assign) CGSize            size;                   // Default is CGSizeMake(120.0f, 90.0f)

@property (nonatomic) UIColor                   *trackTintColor;        // Default whiteColor
@property (nonatomic) UIColor                   *progressTintColor;     // Default xq_animatedViewDefaultColor
@property (nonatomic, assign) CGFloat           animatedDuration;       // Default 1.5f
@property (nonatomic, assign) CGFloat           ringRadius;             // Default 20.0f
@property (nonatomic, assign) CGFloat           progress;               // Progress (0.0 to 1.0)

@end


#pragma mark -
#pragma mark - XQAnimateds
@interface XQProgressHUDAnimatedClass : NSObject;

+ (CAAnimationGroup *)cyclicRotationAnimatedWithDuration:(CFTimeInterval)duration;

+ (CABasicAnimation *)rotatingAnimatedWithDuration:(CFTimeInterval)duration;

@end;



#pragma mark -
#pragma mark - XQAnimatedView
@interface XQAnimatedView : UIView

- (void)loadAnimateds;

@property (nonatomic, assign) XQProgressHUDMode mode;
@property (nonatomic, strong) UIColor           *trackTintColor;    // default whiteColor
@property (nonatomic, strong) UIColor           *progressTintColor; // default xq_animatedViewDefaultColor
@property (nonatomic, assign) CGFloat           animatedDuration;   // default 2.0f
@property (nonatomic, assign) CGFloat           radius;             // default 20.0f
@property (nonatomic, assign) CGFloat           progress;

@end

#pragma mark -
#pragma mark - UIImage Category
@interface UIImage (XQProgressHUDImage)

// loading Image
+ (UIImage *)loadImageWithNamed:(NSString *)named;
// loading Gif
+ (UIImage *)loadingGifWithName:(NSString *)name;

@end



#pragma mark - 
#pragma mark - UIColor Category
@interface UIColor (XQProgressHUDColor)

+ (UIColor *)xq_animatedViewDefaultColor;
+ (UIColor *)xq_hudForegroundColor;

@end
