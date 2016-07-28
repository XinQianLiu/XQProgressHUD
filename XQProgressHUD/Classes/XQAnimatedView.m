//
//  XQAnimatedView.m
//  XQBeingLoadedHud
//
//  Created by 用户 on 16/7/23.
//  Copyright © 2016年 com.xinqianliu. All rights reserved.
//

#import "XQAnimatedView.h"

static CGFloat const outerLayerRadius = 50.0f;
static CGFloat const outerLayerBorderWidth = 10.0f;
static CGFloat const innerLayerBorderWidth = 3.0f;

@implementation XQAnimatedViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _outerLayerStrokeColor = [UIColor xq_animatedViewDefaultColor];
        _innerLayerStrokeColor = [UIColor whiteColor];
        _selfLayerBorderColor = [UIColor xq_animatedViewDefaultColor];
        _selfBackgroundColor = [UIColor whiteColor];
        _titleTextColor = [UIColor xq_animatedViewDefaultColor];
        _titleText = @"正在加载";
        _isPointLabel = YES;
    }
    
    return self;
}

@end

@interface XQAnimatedView ()

@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *pointLabel;
@property (nonatomic, strong) NSTimer               *weekTimer;
@property (nonatomic, strong) CAShapeLayer          *outerAnimatedLayer;
@property (nonatomic, strong) CAShapeLayer          *innerAnimatedLayer;
@property (nonatomic, strong) XQAnimatedViewModel   *animatedViewModel;


@end

@implementation XQAnimatedView

- (instancetype)initAnimatedViewModel:(XQAnimatedViewModel *)model
{
    self = [super init];
    
    if (self) {
        if (!model) {
            model = [[XQAnimatedViewModel alloc] init];
        }
        
        _animatedViewModel = model;
        self.backgroundColor = _animatedViewModel.selfBackgroundColor;
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 2;
        self.layer.borderColor = _animatedViewModel.selfLayerBorderColor.CGColor;
        [self showView];
    }
    
    return self;
}

- (CAShapeLayer *)newCircleLayerWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 3 * M_PI_2;
    
    CAShapeLayer    *circle = [CAShapeLayer layer];
    CGPoint         center = CGPointMake((200 - 100) / 2 + 50, 80);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                  radius      :radius
                                                  startAngle  :startAngle
                                                  endAngle    :endAngle
                                                  clockwise   :YES];
    
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = borderColor.CGColor;
    circle.lineCap = kCALineCapRound;
    circle.strokeStart = 0;
    circle.strokeEnd = 1;
    circle.lineWidth = borderWidth;
    circle.path = path.CGPath;
    
    return circle;
}

// 显示视图
- (void)showView
{
    [self outerAnimatedLayer];
    [self innerAnimatedLayer];
    [self addTitleLabelLayout];
    
    if (_animatedViewModel.isPointLabel) {
        [self addPointLabelLayout];
        [self setPointLabelText];
    }
}

- (void)setPointLabelText
{
    self.pointLabel.text = @".";
    _weekTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(weekTime:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_weekTimer forMode:NSDefaultRunLoopMode];
}

- (void)weekTime:(NSTimer *)timer
{
    if ([self.pointLabel.text isEqualToString:@"."]) {
        self.pointLabel.text = @". .";
    }
    else if ([self.pointLabel.text isEqualToString:@". ."]) {
        self.pointLabel.text = @". . .";
    }
    else {
        self.pointLabel.text = @".";
    }
}

- (void)removeWeekTimer
{
    if (_weekTimer && _weekTimer.isValid) {
        [_weekTimer invalidate];
        _weekTimer = nil;
    }
}

- (void)addTitleLabelLayout
{
    [self.titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:70]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:_animatedViewModel.isPointLabel ? -70 : -0]];
}

- (void)addPointLabelLayout
{
    [self.pointLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.pointLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:70]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pointLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1 constant:5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pointLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pointLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
}

#pragma mark - Getters && Setters

- (CAShapeLayer *)outerAnimatedLayer
{
    if (!_outerAnimatedLayer) {
        _outerAnimatedLayer = [self newCircleLayerWithRadius:outerLayerRadius borderWidth:outerLayerBorderWidth borderColor:_animatedViewModel.outerLayerStrokeColor];
        [self.layer addSublayer:self.outerAnimatedLayer];
    }
    
    return _outerAnimatedLayer;
}

- (CAShapeLayer *)innerAnimatedLayer
{
    if (!_innerAnimatedLayer) {
        _innerAnimatedLayer = [self newCircleLayerWithRadius:outerLayerRadius borderWidth:innerLayerBorderWidth borderColor:_animatedViewModel.innerLayerStrokeColor];
        [self.layer addSublayer:self.innerAnimatedLayer];
        [self.innerAnimatedLayer addAnimation:[XQAnimateds beingLoadedAnimation] forKey:nil];
    }
    
    return _innerAnimatedLayer;
}

- (UILabel *)pointLabel
{
    if (!_pointLabel) {
        _pointLabel = [[UILabel alloc] init];
        _pointLabel.font = [UIFont systemFontOfSize:25];
        _pointLabel.textAlignment = NSTextAlignmentLeft;
        _pointLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _pointLabel.backgroundColor = [UIColor clearColor];
        _pointLabel.textColor = _animatedViewModel.titleTextColor;
        [self addSubview:_pointLabel];
    }
    
    return _pointLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = _animatedViewModel.titleText;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = _animatedViewModel.titleTextColor;
        _titleLabel.font = [UIFont systemFontOfSize:25];
        _titleLabel.textAlignment = _animatedViewModel.isPointLabel ? (NSTextAlignmentRight) : (NSTextAlignmentCenter);
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

//#ifdef DEBUG
//- (void)dealloc
//{
//    NSLog(@"\nAnimatedView Dealloc");
//}
//#endif

@end
