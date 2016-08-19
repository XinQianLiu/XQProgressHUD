//
//  XQBeingLoadedHUD.m
//  XQBeingLoadedHud
//
//  Created by 用户 on 16/7/21.
//  Copyright © 2016年 com.xinqianliu. All rights reserved.
//

#import "XQProgressHUD.h"

#define MainThreadAssert() NSAssert([NSThread isMainThread], @"XQProgressHUD needs to be accessed on the main thread.");

static CGFloat const textHeightScalingFactor = 5.3f;
static CGFloat const wideSpacing = 10.0f;
static CGFloat const maximumWidth = 140.0f;
static CGFloat const atTheTopOfTheScalingFactor = 8.5f;
static CGFloat const indicatorViewSpacing = 15.0f;
static CGFloat const maximumTextWidth = 260.0f;
static CGFloat const minimumTextHeight = 20.0f;
static CGFloat const defaultWidth = 120.0f;

#pragma mark -
#pragma mark - XQRootViewController
@interface XQRootViewController : UIViewController

@property (nonatomic, strong) XQProgressHUD *progressHUD;

@end

@implementation XQRootViewController

- (void)loadView
{
    self.view = self.progressHUD;
}

#ifdef DEBUG
- (void)dealloc
{
    NSLog(@"RootViewController Dealloc");
}
#endif
@end



#pragma mark - 
#pragma mark - XQAnimateds
@implementation XQAnimationHelper

+ (CAAnimationGroup *)cyclicRotationAnimationWithDuration:(CFTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    animation.duration = duration / 2.0f;
    animation.repeatCount = 1;
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    animation2.beginTime = duration / 2.0f;
    animation2.duration = duration / 2.0f;
    animation2.repeatCount = 1;
    animation2.fromValue = @0;
    animation2.toValue = @1;
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation2.removedOnCompletion = NO;
    animation2.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation, animation2];
    group.duration = duration;
    group.repeatCount = CGFLOAT_MAX;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    return group;
}

+ (CABasicAnimation *)rotatingAnimationWithDuration:(CFTimeInterval)duration
{
    CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = 0;
    animation.toValue = @(M_PI*2);
    animation.duration = duration;
    animation.timingFunction = linearCurve;
    animation.removedOnCompletion = NO;
    animation.repeatCount = INFINITY;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    return animation;
}

@end



#pragma mark -
#pragma mark - XQAnimatedView
@interface XQAnimationView ()

@property (nonatomic, strong) UIView        *indicatorView;
@property (nonatomic, strong) CAShapeLayer  *outerLayer;
@property (nonatomic, strong) CAShapeLayer  *innerLayer;
@property (nonatomic, strong) CAShapeLayer  *animationLayer;

@end

@implementation XQAnimationView
- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _progress = 0.0f;
    }
    
    return self;
}

#pragma mark - Public methods
- (void)loadAnimateds
{
    if (self.mode == XQProgressHUDModeCyclicRotation) {
        [self setUpOuterLayer];
        [self setUpInnerLayer];
    }
    else if (self.mode == XQProgressHUDModeRotating){
        [self setUpAnimatedLayer];
    }
    else if (self.mode == XQProgressHUDModeIndicator){
        [self setUpIndicatorView];
    }
}

#pragma mark - Private methods
- (CAShapeLayer *)newCircleLayerWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 3 * M_PI_2;
    
    CAShapeLayer    *circle = [CAShapeLayer layer];
    CGPoint         center = CGPointMake(self.radius, self.radius);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                  radius      :radius - (self.radius / 5.0f - self.radius / 12.5f)
                                                  startAngle  :startAngle
                                                  endAngle    :endAngle
                                                  clockwise   :YES];
    
    circle.contentsScale = [UIScreen mainScreen].scale;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = borderColor.CGColor;
    circle.lineCap = kCALineCapRound;
    circle.lineJoin = kCALineJoinBevel;
    circle.strokeStart = 0;
    circle.strokeEnd = 1;
    circle.lineWidth = borderWidth;
    circle.path = path.CGPath;
    
    return circle;
}

- (NSBundle *)bundle
{
    NSBundle    *classBundle = [NSBundle bundleForClass:[XQProgressHUD class]];
    NSURL       *url = [classBundle URLForResource:@"XQProgressHUD" withExtension:@"bundle"];
    NSBundle    *sourceBundle = [NSBundle bundleWithURL:url];
    return sourceBundle;
}

#pragma mark - Set up view hierarchy
- (void)setUpOuterLayer
{
    _outerLayer = [self newCircleLayerWithRadius:self.radius borderWidth:self.radius / 5.0f borderColor:self.trackTintColor];
    [self.layer addSublayer:_outerLayer];
}

- (void)setUpInnerLayer
{
    _innerLayer = [self newCircleLayerWithRadius:self.radius borderWidth:self.radius / 12.5f borderColor:self.progressTintColor];
    [_innerLayer addAnimation:[XQAnimationHelper cyclicRotationAnimationWithDuration:self.animationDuration] forKey:nil];
    [self.outerLayer addSublayer:_innerLayer];
}

- (void)setUpAnimatedLayer
{
    CGPoint         arcCenter = CGPointMake(self.radius, self.radius);
    CGRect          rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
    UIBezierPath    *path = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                     radius      :self.radius - self.radius / 12.5f
                                                     startAngle  :M_PI * 3 / 2
                                                     endAngle    :M_PI / 2 + M_PI * 5
                                                     clockwise   :YES];
    
    _animationLayer = [CAShapeLayer layer];
    _animationLayer.contentsScale = [UIScreen mainScreen].scale;
    _animationLayer.frame = rect;
    _animationLayer.fillColor = [UIColor clearColor].CGColor;
    _animationLayer.strokeColor = self.progressTintColor.CGColor;
    _animationLayer.lineWidth = self.radius / 12.5f;
    _animationLayer.lineCap = kCALineCapRound;
    _animationLayer.lineJoin = kCALineJoinBevel;
    _animationLayer.path = path.CGPath;
    
    CALayer     *maskLayer = [CALayer layer];
    NSBundle    *imageBundle = [self bundle];
    NSString    *resourcePath = [imageBundle pathForResource:@"angle-mask" ofType:@"png"];
    maskLayer.contents = (id)[UIImage imageWithContentsOfFile:resourcePath].CGImage;
    maskLayer.frame = _animationLayer.bounds;
    _animationLayer.mask = maskLayer;
    [_animationLayer.mask addAnimation:[XQAnimationHelper rotatingAnimationWithDuration:_animationDuration] forKey:nil];
    [self.layer addSublayer:_animationLayer];
}

- (void)setUpIndicatorView
{
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [(UIActivityIndicatorView *)_indicatorView setFrame:CGRectMake(0, 0, 40, 40)];
    [(UIActivityIndicatorView *)_indicatorView setColor:_progressTintColor];
    [(UIActivityIndicatorView *)_indicatorView startAnimating];
    [self addSubview:_indicatorView];
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    if (_mode != XQProgressHUDModeProgress) {
        return;
    }
    // Draw background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat lineWidth = self.radius / 12.5f;
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = lineWidth;
    processBackgroundPath.lineCapStyle = kCGLineCapButt;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = (self.bounds.size.width - lineWidth)/2;
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [_trackTintColor set];
    [processBackgroundPath stroke];
    // Draw progress
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    processPath.lineCapStyle = kCGLineCapSquare;
    processPath.lineWidth = lineWidth;
    endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
    [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [_progressTintColor set];
    [processPath stroke];
}

#pragma mark - Setters
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

#ifdef DEBUG
- (void)dealloc
{
    NSLog(@"AnimationView dealloc");
}
#endif

@end



#pragma mark -
#pragma mark - XQProgressHUD

@interface XQProgressHUD ()

@property (nonatomic) UIWindow                      *overlayWindow;
@property (nonatomic, strong) UIView                *xq_backgroundView;
@property (nonatomic, strong) XQAnimationView        *animationView;
@property (nonatomic, strong) XQRootViewController  *rootViewController;
@property (nonatomic, strong) UILabel               *statusLabel;
@property (nonatomic, strong) UILabel               *indicatorLabel;
@property (nonatomic, strong) UILabel               *suffixPointLabel;
@property (nonatomic, strong) UIImageView           *imageView;
@property (nonatomic) NSTimer                       *dismissTimer;
@property (nonatomic, weak) NSTimer                 *suffixPointTimer;
@property (nonatomic, assign) BOOL                  isYOffset;

@end

@implementation XQProgressHUD

#pragma mark - Initialization

+ (instancetype)HUD
{
    XQProgressHUD *hud = [[[self class] alloc] init];
    return hud;
}

- (instancetype)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        self.userInteractionEnabled = YES;
        
        _mode = XQProgressHUDModeIndicator;
        _size = CGSizeMake(120.0f, 90.0f);
        _textColor = [UIColor xq_animationViewDefaultColor];
        _isYOffset = NO;
        _ringRadius = 20.0f;
        _gifImageName = @"u8";
        _trackTintColor = [UIColor whiteColor];
        _progressTintColor = [UIColor xq_animationViewDefaultColor];
        _animationDuration = 1.5f;
        _suffixPointEnabled = YES;
        _foregroundBorderWidth = 0.0f;
        _foregroundBorderColor = [UIColor clearColor];
        _foregroundCornerRaidus = 5.0f;
        _suffixPointAnimationDuration = 0.2f;
        
        // Set up view hierarchy
        _xq_backgroundView = [[UIView alloc] init];
        _xq_backgroundView.backgroundColor = [UIColor xq_hudForegroundColor];
        _xq_backgroundView.layer.cornerRadius = self.foregroundCornerRaidus;
        _xq_backgroundView.layer.borderColor = self.foregroundBorderColor.CGColor;
        _xq_backgroundView.layer.borderWidth = self.foregroundBorderWidth;
        _xq_backgroundView.layer.masksToBounds = YES;
        _xq_backgroundView.hidden = YES;
        _xq_backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_xq_backgroundView];
        
        _indicatorLabel = [[UILabel alloc] init];
        _indicatorLabel.backgroundColor = [UIColor clearColor];
        _indicatorLabel.textAlignment = NSTextAlignmentRight;
        _indicatorLabel.font = [UIFont systemFontOfSize:15.0f];
        _indicatorLabel.textColor = [UIColor xq_animationViewDefaultColor];
        _indicatorLabel.numberOfLines = 1;
        _indicatorLabel.text = @"Loading";
        _indicatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_xq_backgroundView addSubview:_indicatorLabel];
        
        _suffixPointLabel = [[UILabel alloc] init];
        _suffixPointLabel.backgroundColor = [UIColor clearColor];
        _suffixPointLabel.textAlignment = NSTextAlignmentLeft;
        _suffixPointLabel.font = [UIFont systemFontOfSize:15.0f];
        _suffixPointLabel.textColor = [UIColor xq_animationViewDefaultColor];
        _suffixPointLabel.text = @".";
        _suffixPointLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_xq_backgroundView addSubview:_suffixPointLabel];
        
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.masksToBounds = YES;
        _imageView.hidden = YES;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageView];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.layer.cornerRadius = self.foregroundCornerRaidus;
        _statusLabel.layer.borderWidth = self.foregroundBorderWidth;
        _statusLabel.layer.borderColor = self.foregroundBorderColor.CGColor;
        _statusLabel.layer.masksToBounds = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.font = [UIFont systemFontOfSize:15.0f];
        _statusLabel.numberOfLines = 0;
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        _statusLabel.hidden = YES;
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_statusLabel];
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)show
{
    if (!self.rootViewController) {
        self.rootViewController = [[XQRootViewController alloc] initWithNibName:nil bundle:nil];
        self.rootViewController.progressHUD = self;
    }
    
    if (!self.overlayWindow) {
        self.overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.overlayWindow.screen = [UIScreen mainScreen];
        self.overlayWindow.windowLevel = UIWindowLevelNormal;
        self.overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.overlayWindow.opaque = NO;
        self.overlayWindow.userInteractionEnabled = self.userInteractionEnabled;
        self.overlayWindow.rootViewController = self.rootViewController;
    }
    
    self.overlayWindow.hidden = NO;
    
    [self updateIndicators];
    [self setUpViewsLayout];
    
    self.overlayWindow.alpha = 0.0f;
    [UIView animateWithDuration:0.5f animations:^{
        self.overlayWindow.alpha = 1.0f;
    }];
}

- (void)dismiss
{
    [self dismissAfterDelay:0];
}

- (void)dismissAfterDelay:(NSTimeInterval)delay
{
    if (delay > 0) {
        self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(responseToDismissTimer) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.dismissTimer forMode:NSDefaultRunLoopMode];
    }
    else {
        [self responseToDismissTimer];
    }
}

#pragma mark - Private methods
- (void)updateIndicators
{
    if (self.mode == XQProgressHUDModeNone) {
        return;
    }
    
    switch (self.mode) {
        case XQProgressHUDModeIndicator:
        case XQProgressHUDModeCyclicRotation:
        case XQProgressHUDModeRotating:
        case XQProgressHUDModeProgress:
        case XQProgressHUDModeCustomIndicator:
        case XQProgressHUDModeSuccess:
        case XQProgressHUDModeError:
        
            self.imageView.hidden = YES;
            self.statusLabel.hidden = YES;
            self.xq_backgroundView.hidden = NO;
            
            if (self.animationView) {
                [self.animationView removeFromSuperview];
                self.animationView = nil;
            }
            
            _animationView = [[XQAnimationView alloc] init];
            _animationView.mode = self.mode;
            _animationView.radius = self.ringRadius;
            _animationView.trackTintColor = self.trackTintColor;
            _animationView.progressTintColor = self.progressTintColor;
            _animationView.animationDuration = self.animationDuration;
            _animationView.translatesAutoresizingMaskIntoConstraints = NO;
            [_animationView loadAnimateds];
            [self.xq_backgroundView addSubview:_animationView];
            
            if (self.mode == XQProgressHUDModeSuccess) {
                self.suffixPointEnabled = NO;
                UIImageView *imageView = [self loadCustomIndicatorName:@"success"];
                self.customIndicator = imageView;
                [self.animationView addSubview:_customIndicator];
            }
            else if (self.mode == XQProgressHUDModeError) {
                self.suffixPointEnabled = NO;
                UIImageView *imageView = [self loadCustomIndicatorName:@"error"];
                self.customIndicator = imageView;
                [self.animationView addSubview:_customIndicator];
            }
            else if (self.mode == XQProgressHUDModeCustomIndicator){
                [self.animationView addSubview:_customIndicator];
            }
            break;
            
        case XQProgressHUDModeGIF:
            self.xq_backgroundView.hidden = YES;
            self.statusLabel.hidden = YES;
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage loadingGifWithName:self.gifImageName];
            break;
            
        case XQProgressHUDModeTextOnly:
            self.xq_backgroundView.hidden = YES;
            self.imageView.hidden = YES;
            self.statusLabel.hidden = NO;
            break;
            
        default:
            break;
    }
}

- (void)setUpViewsLayout
{
    CGFloat width, height, textHeight, top, foregroundWidth, foregroundHeight;
    
    foregroundWidth = self.size.width;
    foregroundHeight = self.size.height;
    
    switch (self.mode) {
        case XQProgressHUDModeIndicator:
        case XQProgressHUDModeProgress:
        case XQProgressHUDModeRotating:
        case XQProgressHUDModeCyclicRotation:
        case XQProgressHUDModeCustomIndicator:
        case XQProgressHUDModeSuccess:
        case XQProgressHUDModeError:
            {
                if (self.suffixPointEnabled) {
                    width = foregroundWidth;
                    height = foregroundHeight;
                    textHeight = height / textHeightScalingFactor;
                }
                else {
                    width = [self size:CGSizeMake(MAXFLOAT, MAXFLOAT) text:self.text font:self.textFont].width + wideSpacing;
                    
                    if (width <= foregroundWidth) {
                        width = foregroundWidth;
                    }
                    else if (foregroundWidth > defaultWidth){
                        width = foregroundWidth;
                    }
                    else{
                        width = maximumWidth;
                    }
                    
                    textHeight = [self size:CGSizeMake(width - wideSpacing, MAXFLOAT) text:self.text font:self.textFont].height + 1;
                    height = textHeight + (foregroundHeight / atTheTopOfTheScalingFactor) + self.ringRadius * 2 + indicatorViewSpacing;
                    
                    if (height <= foregroundHeight) {
                        height = foregroundHeight;
                    }
                }
                
                if (self.mode == XQProgressHUDModeIndicator) {
                    self.ringRadius = 20.0f;
                }
                
                [self.xq_backgroundView removeConstraints:self.xq_backgroundView.constraints];
                [self.animationView removeConstraints:self.animationView.constraints];
                [self.indicatorLabel removeConstraints:self.indicatorLabel.constraints];
                [self.suffixPointLabel removeConstraints:self.suffixPointLabel.constraints];
                [self.customIndicator removeConstraints:self.customIndicator.constraints];
                
                // XQBackgroundViewLayout
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.xq_backgroundView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
                [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.xq_backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width]];
                [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.xq_backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height]];
                
                if (self.isYOffset) {
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.xq_backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:self.yOffset]];
                }
                else {
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.xq_backgroundView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
                }
                
                // AnimatedViewLayout
                top = foregroundHeight / atTheTopOfTheScalingFactor;
                [self.animationView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.ringRadius * 2]];
                [self.animationView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.ringRadius * 2]];
                
                [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.xq_backgroundView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
                [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.animationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.xq_backgroundView attribute:NSLayoutAttributeTop multiplier:1 constant:top]];
                
                // IndicatorLabelLayout
                CGFloat maxX = (foregroundWidth / 2.0f) + (self.ringRadius);
                [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.animationView attribute:NSLayoutAttributeBottom multiplier:1 constant:5.0f]];
                [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.xq_backgroundView attribute:NSLayoutAttributeLeft multiplier:1 constant:5.0f]];
                [self.indicatorLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.suffixPointEnabled ? maxX - wideSpacing : width - wideSpacing]];
                [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutAttributeBottom toItem:self.xq_backgroundView attribute:NSLayoutAttributeBottom multiplier:1 constant:-5]];
                
                // PointLabelLayer
                if (self.suffixPointEnabled) {
                    self.suffixPointLabel.hidden = NO;
                    [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.suffixPointLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutAttributeTop toItem:self.animationView attribute:NSLayoutAttributeBottom multiplier:1 constant:5.0f]];
                    [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.suffixPointLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.xq_backgroundView attribute:NSLayoutAttributeRight multiplier:1 constant:-2.0f]];
                    [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.suffixPointLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.indicatorLabel attribute:NSLayoutAttributeRight multiplier:1 constant:2.0f]];
                    [self.xq_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.suffixPointLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutAttributeBottom toItem:self.xq_backgroundView attribute:NSLayoutAttributeBottom multiplier:1 constant:-5]];
                     [self setUpTheSuffixPointTimer];
                    self.indicatorLabel.textAlignment = NSTextAlignmentRight;
                    self.indicatorLabel.numberOfLines = 1;
                }
                else {
                    self.suffixPointLabel.hidden = YES;
                     [self removeSuffixPointTimer];
                    self.indicatorLabel.textAlignment = NSTextAlignmentCenter;
                    self.indicatorLabel.numberOfLines = 0;
                }
                
                if ((self.mode == XQProgressHUDModeCustomIndicator) || (self.mode == XQProgressHUDModeSuccess) || (self.mode == XQProgressHUDModeError)) {
                    [self.animationView addConstraint:[NSLayoutConstraint constraintWithItem:self.customIndicator attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.animationView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
                    [self.animationView addConstraint:[NSLayoutConstraint constraintWithItem:self.customIndicator attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.animationView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
                    [self.animationView addConstraint:[NSLayoutConstraint constraintWithItem:self.customIndicator attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.animationView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
                    [self.animationView addConstraint:[NSLayoutConstraint constraintWithItem:self.customIndicator attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.animationView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
                }
                
                break;
            }
            
        case XQProgressHUDModeGIF:
            {
                [self.imageView removeConstraints:self.imageView.constraints];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
                [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:foregroundWidth]];
                [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:foregroundHeight]];
                
                if (self.isYOffset) {
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:self.yOffset]];
                } else {
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
                }
                
                break;
            }
            
        case XQProgressHUDModeTextOnly:
            {
                width = [self size:CGSizeMake(MAXFLOAT, MAXFLOAT) text:self.text font:self.textFont].width;
                
                if (width >= maximumTextWidth) {
                    width = maximumTextWidth;
                }
                
                height = [self size:CGSizeMake(width, MAXFLOAT) text:self.text font:self.textFont].height;
                
                if (height <= minimumTextHeight) {
                    height = minimumTextHeight;
                }
                
                [self.statusLabel removeConstraints:self.statusLabel.constraints];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:self.isYOffset ? -(self.yOffset) : -40]];
                [self.statusLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width + 20]];
                [self.statusLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.statusLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:height + 10]];
                break;
            }
    }
}

- (UIImageView *)loadCustomIndicatorName:(NSString *)name
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage loadImageWithNamed:name]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    return imgView;
}

- (void)setUpTheSuffixPointTimer
{
    [self removeSuffixPointTimer];
    self.suffixPointTimer = [NSTimer scheduledTimerWithTimeInterval:self.suffixPointAnimationDuration target:self selector:@selector(weekTime:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.suffixPointTimer forMode:NSDefaultRunLoopMode];
}

- (void)removeSuffixPointTimer
{
    if (self.suffixPointTimer && self.suffixPointTimer.isValid) {
        [self.suffixPointTimer invalidate];
        self.suffixPointTimer = nil;
    }
}

- (void)removeDismissTimer
{
    if (self.dismissTimer && self.dismissTimer.isValid) {
        [self.dismissTimer invalidate];
        self.dismissTimer = nil;
    }
}

- (CGSize)size:(CGSize)size text:(NSString *)text font:(UIFont *)font
{
    CGSize iSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    return iSize;
}

#pragma mark - Action
- (void)responseToDismissTimer
{
    self.overlayWindow.alpha = 1.0f;
    [UIView animateWithDuration:0.5f animations:^{
        self.overlayWindow.alpha = 0;
    } completion:^(BOOL finished) {
        // Remove timer
        [self removeDismissTimer];
        [self removeSuffixPointTimer];
        
        // Dismiss HUD
        _overlayWindow.hidden = YES;
        _overlayWindow = nil;
        _rootViewController = nil;

        // Completion handler
        if (self.didDismissHandler) {
            self.didDismissHandler();
        }
    }];
}

- (void)weekTime:(NSTimer *)timer
{
    if ([self.suffixPointLabel.text isEqualToString:@"."]) {
        self.suffixPointLabel.text = @". .";
    }
    else if ([self.suffixPointLabel.text isEqualToString:@". ."]) {
        self.suffixPointLabel.text = @". . .";
    }
    else {
        self.suffixPointLabel.text = @".";
    }
}

#pragma mark - Getters & Setters
- (void)setForegroundColor:(UIColor *)foregroundColor
{
    MainThreadAssert();
    _foregroundColor = foregroundColor;
    self.xq_backgroundView.backgroundColor = foregroundColor;
    self.statusLabel.backgroundColor = foregroundColor;
}

- (void)setForegroundBorderColor:(UIColor *)foregroundBorderColor
{
    MainThreadAssert();
    self.xq_backgroundView.layer.borderColor = foregroundBorderColor.CGColor;
    self.statusLabel.layer.borderColor = foregroundBorderColor.CGColor;
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    MainThreadAssert();
    _trackTintColor = trackTintColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    MainThreadAssert();
    _textColor = textColor;
    self.indicatorLabel.textColor = textColor;
    self.suffixPointLabel.textColor = textColor;
    self.statusLabel.textColor = textColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    MainThreadAssert();
    _progressTintColor = progressTintColor;
}

- (void)setSize:(CGSize)size
{
    MainThreadAssert();
    _size = size;
}

- (void)setForegroundBorderWidth:(CGFloat)foregroundBorderWidth
{
    MainThreadAssert();
    self.xq_backgroundView.layer.borderWidth = foregroundBorderWidth;
    self.statusLabel.layer.borderWidth = foregroundBorderWidth;
}

- (void)setForegroundCornerRaidus:(CGFloat)foregroundCornerRaidus
{
    MainThreadAssert();
    self.xq_backgroundView.layer.cornerRadius = foregroundCornerRaidus;
    self.statusLabel.layer.cornerRadius = foregroundCornerRaidus;
}

- (void)setAnimationDuration:(CGFloat)animationDuration
{
    MainThreadAssert();
    _animationDuration = animationDuration;
}

- (void)setRingRadius:(CGFloat)ringRadius
{
    MainThreadAssert();
    _ringRadius = ringRadius;
}

- (void)setProgress:(CGFloat)progress
{
    MainThreadAssert();
    _progress = progress;
    
    if (self.mode == XQProgressHUDModeProgress) {
        self.animationView.progress = progress;
    }
}

- (void)setYOffset:(CGFloat)yOffset
{
    MainThreadAssert();
    _yOffset = yOffset;
    _isYOffset = YES;
}

- (NSString *)text
{
    return self.indicatorLabel.text;
}

- (void)setText:(NSString *)text
{
    MainThreadAssert();
    self.indicatorLabel.text = text;
    self.statusLabel.text = text;
}

- (void)setGifImageName:(NSString *)gifImageName
{
    MainThreadAssert();
    _gifImageName = gifImageName;
}

- (UIFont *)textFont
{
    return self.indicatorLabel.font;
}

- (void)setTextFont:(UIFont *)textFont
{
    MainThreadAssert();
    self.indicatorLabel.font = textFont;
    self.suffixPointLabel.font = textFont;
    self.statusLabel.font = textFont;
}

- (void)setCustomIndicator:(UIView *)customIndicator
{
    MainThreadAssert();
    _customIndicator = customIndicator;
    _customIndicator.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setSuffixPointEnabled:(BOOL)suffixPointEnabled
{
    MainThreadAssert();
    _suffixPointEnabled = suffixPointEnabled;
}

- (void)setMode:(XQProgressHUDMode)mode
{
    MainThreadAssert();
    _mode = mode;
}

#ifdef DEBUG
- (void)dealloc
{
    NSLog(@"\nHUD Dealloc");
}
#endif
@end



#pragma mark -
#pragma mark - UIImage Category
@implementation UIImage (XQProgressHUDImage)

+ (UIImage *)loadImageWithNamed:(NSString *)named
{
    NSString *path;
    
    path = [[NSBundle mainBundle] pathForResource:named ofType:@"png"];
    
    if (!path) {
        NSBundle    *bundle = [NSBundle bundleForClass:[XQProgressHUD class]];
        NSURL       *url = [bundle URLForResource:@"XQProgressHUD" withExtension:@"bundle"];
        
        if (url) {
            NSBundle *imgBundle = [NSBundle bundleWithURL:url];
            path = [imgBundle pathForResource:named ofType:@"png"];
        }
    }
    
    NSAssert(path, @"Path must not be nil");
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    path = nil;
    
    if (data) {
        return [UIImage imageWithData:data];
    }
    else {
        return nil;
    }
}

// loading Gif
+ (UIImage *)loadingGifWithName:(NSString *)name
{
    if (!name || [name isEqualToString:@""]) {
        name = @"u8";
    }
    
    NSString *path = nil;
    path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
    
    if (!path) {
        NSBundle    *bundle = [NSBundle bundleForClass:[XQProgressHUD class]];
        NSURL       *url = [bundle URLForResource:@"XQProgressHUD" withExtension:@"bundle"];
        if (url) {
            NSBundle    *gifBundle = [NSBundle bundleWithURL:url];
            path = [gifBundle pathForResource:name ofType:@"gif"];
        }
    }
    
    NSAssert(path != nil, @"Path must not be nil");
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    path = nil;
    
    if (data) {
        return [self animatedGIFWithData:data];
    } else {
        return [UIImage imageNamed:name];
    }
}

// GIFWithData
+ (UIImage *)animatedGIFWithData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef    source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t              count = CGImageSourceGetCount(source);
    UIImage             *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray  *images = [NSMutableArray array];
        NSTimeInterval  duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            duration += [self durationAtIndex:i source:source];
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    return animatedImage;
}

// durationAtIndex
+ (float)durationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source
{
    float           duration = 0.1f;
    CFDictionaryRef cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    NSDictionary    *properties = (__bridge NSDictionary *)cfProperties;
    NSDictionary    *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber        *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTimeUnclampedProp) {
        duration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if (delayTimeProp) {
            duration = [delayTimeProp floatValue];
        }
    }
    
    if (duration < 0.011f) {
        duration = 0.100f;
    }
    
    CFRelease(cfProperties);
    return duration;
}

@end



#pragma mark -
#pragma mark - UIColor Category
@implementation UIColor (XQProgressHUDColor)

+ (UIColor *)xq_animationViewDefaultColor
{
    return [UIColor colorWithRed:0.36 green:0.60 blue:0.81 alpha:1.00];
}

+ (UIColor *)xq_hudForegroundColor
{
    return [UIColor colorWithRed:0.88 green:0.89 blue:0.91 alpha:1.00];
}

@end


