//
//  XQBeingLoadedHUD.m
//  XQBeingLoadedHud
//
//  Created by 用户 on 16/7/21.
//  Copyright © 2016年 com.xinqianliu. All rights reserved.
//

#import "XQProgressHUD.h"

#define MainThreadAssert() NSAssert([NSThread isMainThread], @"菊花要在主线程中显示, 不要在网络请求(多线程)的时候, 在子线程使用");

#pragma mark - XQRootViewController
@interface XQRootViewController : UIViewController

@property (nonatomic, strong) XQProgressHUD *progressHUD;

@end

@implementation XQRootViewController

- (void)loadView
{
    self.view = _progressHUD;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#ifdef __IPHONE_7_0
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}
#endif

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController *viewController = [self.progressHUD.hudWindow currentViewController];
    
    if (viewController) {
        return [viewController supportedInterfaceOrientations];
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIViewController *viewController = [self.progressHUD.hudWindow currentViewController];
    
    if (viewController) {
        return [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    
    return YES;
}

- (BOOL)shouldAutorotate
{
    UIViewController *viewController = [self.progressHUD.hudWindow currentViewController];
    
    if (viewController) {
        return [viewController shouldAutorotate];
    }
    
    return YES;
}

#ifdef __IPHONE_7_0
- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIWindow *window = self.progressHUD.hudWindow;
    
    if (!window) {
        window = [UIApplication sharedApplication].windows[0];
    }
    
    return [[window viewControllerForStatusBarStyle] preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    UIWindow *window = self.progressHUD.hudWindow;
    
    if (!window) {
        window = [UIApplication sharedApplication].windows[0];
    }
    
    return [[window viewControllerForStatusBarHidden] prefersStatusBarHidden];
}

#endif

//#ifdef DEBUG
//- (void)dealloc
//{
//    NSLog(@"RootViewController Dealloc");
//}
//#endif

@end


#pragma mark - XQBeingLoadedHUD
@interface XQProgressHUD ()

@property (nonatomic, strong) XQAnimatedView            *animatedView;
@property (nonatomic, strong) XQBeingLoadedGifImageView *beingLoadedGifImageView;
@property (nonatomic, strong) XQRootViewController      *rootViewController;
@property (nonatomic, strong) NSTimer                   *timeoutTime;

@end

@implementation XQProgressHUD

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

#pragma mark Getters & Setters

- (XQAnimatedViewModel *)animatedViewModel
{
    if (!_animatedViewModel) {
        _animatedViewModel = [[XQAnimatedViewModel alloc] init];
    }
    
    return _animatedViewModel;
}

#pragma mark Private Methods
- (void)configurationWithUserInteraction:(BOOL)userInteraction
{
    // 务必在主线程调用该方法
    MainThreadAssert();
    _hudWindow = [UIApplication sharedApplication].keyWindow;
    
    if (!_rootViewController) {
        _rootViewController = [[XQRootViewController alloc] initWithNibName:nil bundle:nil];
        _rootViewController.progressHUD = self;
    }
    
    if (!_overlayWindow) {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayWindow.opaque = NO;
        _overlayWindow.userInteractionEnabled = userInteraction;
        _overlayWindow.rootViewController = self.rootViewController;
    }
    
    [_overlayWindow makeKeyAndVisible];
}

- (void)addTimerWithTimeInterval:(NSTimeInterval)time
{
    if (time < 0.1f) {
        NSLog(@"warning--> 定时器时间必须大于 0.1f，否则不会起任何作用. 将默认改为 30.f\nfunction--> - (void)addTimerWithTimeInterval:(NSTimeInterval)time");
        time = 30.f;
    }
    
    _timeoutTime = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timeoutTime:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timeoutTime forMode:NSDefaultRunLoopMode];
}

- (void)removeAnimatedView
{
    if (_animatedView) {
        [_animatedView removeFromSuperview];
        [_animatedView removeWeekTimer];
        _animatedView = nil;
    }
}

- (void)removeBeingLoadedGifImageView
{
    if (_beingLoadedGifImageView) {
        [_beingLoadedGifImageView removeFromSuperview];
        _beingLoadedGifImageView = nil;
    }
}

- (void)addAnimatedView
{
    if (!_animatedView) {
        CGFloat width, height;
        width = 200.0f;
        height = 200.0f;
        
        _animatedView = [[XQAnimatedView alloc] initAnimatedViewModel:_animatedViewModel];
        _animatedView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_animatedView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.animatedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.animatedView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self.animatedView addConstraint:[NSLayoutConstraint constraintWithItem:self.animatedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width]];
        [self.animatedView addConstraint:[NSLayoutConstraint constraintWithItem:self.animatedView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height]];
    }
}

- (void)addBeingLoadedGifImageViweWithGifNamed:(NSString *)gifNamed
{
    if (!_beingLoadedGifImageView) {
        CGFloat width, height, cornerRadius;
        width = 200.0f;
        height = 200.0f;
        cornerRadius = 10.0f;
        
        _beingLoadedGifImageView = [[XQBeingLoadedGifImageView alloc] initWithGifNamed:gifNamed];
        _beingLoadedGifImageView.layer.cornerRadius = cornerRadius;
        _beingLoadedGifImageView.layer.masksToBounds = YES;
        _beingLoadedGifImageView.contentMode = UIViewContentModeScaleAspectFill;
        _beingLoadedGifImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_beingLoadedGifImageView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_beingLoadedGifImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_beingLoadedGifImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [_beingLoadedGifImageView addConstraint:[NSLayoutConstraint constraintWithItem:_beingLoadedGifImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width]];
        [_beingLoadedGifImageView addConstraint:[NSLayoutConstraint constraintWithItem:_beingLoadedGifImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height]];
    }
}

#pragma mark - public Methods
- (void)show
{
    [self showAnimationViewOfUserInteraction:YES];
}

// Display The Animation View
- (void)showAnimationViewOfUserInteraction:(BOOL)userInteraction
{
    [self showAnimationViewOfTimeout:CGFLOAT_MAX userInteraction:userInteraction timeoutBlock:nil];
}

// Animation View For Load The Timeout
- (void)showAnimationViewOfTimeout:(NSTimeInterval)time userInteraction:(BOOL)userInteraction timeoutBlock:(TimeoutBlock)timeoutBlock
{
    if (timeoutBlock) {
        _timeoutBlock = timeoutBlock;
    }
    
    [self configurationWithUserInteraction:userInteraction];
    [self addAnimatedView];
    [self addTimerWithTimeInterval:time];
}

// Display Default Gif
- (void)showGif
{
    [self showGifImageViewOfGifNamed:nil userInteraction:YES];
}

// Display GIF Figure
- (void)showGifImageViewOfGifNamed:(NSString *)named userInteraction:(BOOL)userInteraction
{
    [self showGifImageViewOfGifNamed:named Timeout:CGFLOAT_MAX userInteraction:userInteraction timeoutBlock:nil];
}

// GIF Figure For Load The Timeout
- (void)showGifImageViewOfGifNamed:(NSString *)named Timeout:(NSTimeInterval)time userInteraction:(BOOL)userInteraction timeoutBlock:(TimeoutBlock)timeoutBlock
{
    if (timeoutBlock) {
        _timeoutBlock = timeoutBlock;
    }
 
    [self configurationWithUserInteraction:userInteraction];
    [self addBeingLoadedGifImageViweWithGifNamed:named];
    [self addTimerWithTimeInterval:time];
}

// Remove the view
- (void)dismiss
{
    [self removeFromSuperview];
    [self removeAnimatedView];
    [self removeBeingLoadedGifImageView];
    
    if (_animatedViewModel) {
        _animatedViewModel = nil;
    }
    
    if (_rootViewController) {
        _rootViewController = nil;
    }
    
    if (_overlayWindow) {
        [_overlayWindow removeFromSuperview];
        NSMutableArray *windows = (NSMutableArray *)[UIApplication sharedApplication].windows;
        [windows removeObject:_overlayWindow];
        _overlayWindow = nil;
        [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([window isKindOfClass:[UIWindow class]] && (window.windowLevel == UIWindowLevelNormal)) {
                [window makeKeyWindow];
                *stop = YES;
            }
        }];
    }
    
    if (_hudWindow) {
        [_hudWindow removeFromSuperview];
        _hudWindow = nil;
    }
    
    if (_timeoutTime && _timeoutTime.isValid) {
        [_timeoutTime invalidate];
        _timeoutTime = nil;
    }
}

#pragma mark - Action
- (void)timeoutTime:(NSTimer *)timer
{
    if (_timeoutBlock) {
        _timeoutBlock(self);
    }
}

//#ifdef DEBUG
//- (void)dealloc
//{
//    NSLog(@"\nHUD Dealloc");
//}
//#endif
@end
