//
//  XQViewController.m
//  XQProgressHUD
//
//  Created by LiuXinQian on 07/28/2016.
//  Copyright (c) 2016 LiuXinQian. All rights reserved.
//

#import "XQViewController.h"
#import <XQProgressHUD/XQProgressHUD.h>

static NSString *const sHUDKey = @"sHUDKey";
static NSString *const sDelayTimeKey = @"sDelayTimeKey";

@interface XQExample : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SEL selector;

@end

@implementation XQExample

+ (instancetype)exampleWithTitle:(NSString *)title selector:(SEL)selector
{
    XQExample *example = [[self class] new];
    example.title = title;
    example.selector = selector;
    return example;
}

@end

@interface XQViewController () <UITableViewDataSource, UITableViewDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSArray <XQExample *> *examples;
@property (nonatomic, strong) XQProgressHUD *hud;

@end

@implementation XQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELLID"];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    self.examples = @[
                      [XQExample exampleWithTitle:@"Indicator mode" selector:@selector(IndicatorModeExample)],
                      [XQExample exampleWithTitle:@"rotating mode" selector:@selector(rotatingModeExample)],
                      [XQExample exampleWithTitle:@"Cyclic rotation mode" selector:@selector(cyclicRotationModeExample)],
                      [XQExample exampleWithTitle:@"Progress mode" selector:@selector(progressModeExample)],
                      [XQExample exampleWithTitle:@"Networking mode" selector:@selector(networkingMode)],
                      [XQExample exampleWithTitle:@"Success mode" selector:@selector(successModeExample)],
                      [XQExample exampleWithTitle:@"Error mode" selector:@selector(errorModeExample)],
                      [XQExample exampleWithTitle:@"With details label" selector:@selector(detailsLabelExample)],
                      [XQExample exampleWithTitle:@"Custom Indicator mode" selector:@selector(customIndicatorModeExample)],
                      [XQExample exampleWithTitle:@"GIF mode" selector:@selector(gifModeExample)],
                      [XQExample exampleWithTitle:@"Text only" selector:@selector(textOnlyExample)]
                      ];
}

- (XQProgressHUD *)hud
{
    if (!_hud) {
        _hud = [XQProgressHUD HUD];
    }
    
    return _hud;
}

#pragma mark - Selectors

- (void)IndicatorModeExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    [hud show];
    [hud dismissAfterDelay:3.0f];
}

- (void)rotatingModeExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeRotating;
    [hud show];
    [hud dismissAfterDelay:3.0f];
}

- (void)cyclicRotationModeExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeCyclicRotation;
    hud.ringRadius = 40.0f;
    hud.size = CGSizeMake(150, 150);
    hud.textFont = [UIFont systemFontOfSize:25.0f];
    hud.text = @"正在加载";
    [hud show];
    [hud dismissAfterDelay:3.0f];
}

- (void)progressModeExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeIndicator;
    hud.text = @"Preparing...";
    hud.suffixPointEnabled = NO;
    hud.progressTintColor = [UIColor redColor];
    hud.textColor = [UIColor redColor];
    [hud show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hud.mode = XQProgressHUDModeProgress;
        hud.suffixPointEnabled = YES;
        hud.text = @"Loading";
        [hud show];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            float progress = 0.0f;
            
            while (progress < 1.0f) {
                progress += 0.01f;
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.progress = progress;
                });
                usleep(50000);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.mode = XQProgressHUDModeIndicator;
                hud.suffixPointEnabled = NO;
                hud.text = @"Cleaning up...";
                [hud show];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    hud.mode = XQProgressHUDModeSuccess;
                    hud.text = @"加载完成!~~";
                    hud.textFont = [UIFont systemFontOfSize:20.0f];
                    [hud show];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        hud.mode = XQProgressHUDModeTextOnly;
                        hud.text = @"组合提示完成";
                        hud.textColor = [UIColor whiteColor];
                        [hud show];
                        [hud dismissAfterDelay:2.0f];
                    });
                });
            });
        });
    });
}

- (void)networkingMode
{
    self.hud.mode = XQProgressHUDModeProgress;
    [self.hud show];
    [self doSomeNetworkWorkWithProgress];
}

- (void)doSomeNetworkWorkWithProgress {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    NSURL *URL = [NSURL URLWithString:@"https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/HT1425/sample_iPod.m4v.zip"];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:URL];
    [task resume];
}

- (void)successModeExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeSuccess;
    hud.text = @"Load the success!";
    [hud show];
    [hud dismissAfterDelay:2.0f];
}

- (void)errorModeExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeError;
    hud.text = @"Load failed!~~";
    hud.textFont = [UIFont systemFontOfSize:18.0f];
    [hud show];
    [hud dismissAfterDelay:2.0f];
}

- (void)detailsLabelExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeIndicator;
    hud.progressTintColor = [UIColor redColor];
    hud.textColor = [UIColor redColor];
    hud.suffixPointEnabled = NO;
    hud.text = @"俺师傅看你的沙发那你阿富汗都是撒娇办法吗坚持不懈看着酒吧上课就打算斗爱吃那就不是怒问老师基本法办法";
    hud.maximumWidth = 160.0f;
    [hud show];
    [hud dismissAfterDelay:2.0f];
}

- (void)customIndicatorModeExample
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeCustomIndicator;
    hud.customIndicator = view;
    hud.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    hud.foregroundColor = [UIColor whiteColor];
    hud.foregroundBorderColor = [UIColor redColor];
    hud.foregroundBorderWidth = 2.0f;
    hud.foregroundCornerRaidus = 10.0f;
    hud.size = CGSizeMake(150.0f, 150.0f);
    hud.ringRadius = 40.0f;
    hud.textFont = [UIFont systemFontOfSize:22.0f];
    hud.yOffset = 240.0f;
    hud.textColor = [UIColor redColor];
    hud.text = @"Custome";
    hud.suffixPointAnimationDuration = 0.5f;
    hud.userInteractionEnabled = NO;
    hud.didDismissHandler = ^(){
        NSLog(@"HUD Completion");
    };
    [hud show];
    [hud dismissAfterDelay:5.0f];
}

- (void)gifModeExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeGIF;
    hud.gifImageName = @"u8";
    hud.size = CGSizeMake(150.0f, 150.0f);
    [hud show];
    [hud dismissAfterDelay:5.0f];
}

- (void)textOnlyExample
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.mode = XQProgressHUDModeTextOnly;
    hud.text = @"Text only Text only Text only Text only Text only";
    hud.maximumWidth = 200.0f;
    [hud show];
    [hud dismissAfterDelay:2.0f];
}

#pragma mark - UITableViewDelegate && UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.examples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELLID" forIndexPath:indexPath];
    
    XQExample *example = self.examples[indexPath.row];
    cell.textLabel.text = example.title;
    cell.textLabel.textColor = self.view.tintColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [cell.textLabel.textColor colorWithAlphaComponent:0.1f];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XQExample *example = self.examples[indexPath.row];
    [self performSelector:example.selector];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // Do something with the data at location...
    
    // Update the UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.mode = XQProgressHUDModeSuccess;
        self.hud.text = NSLocalizedString(@"Completed", @"HUD completed title");
        [self.hud show];
        [self.hud dismissAfterDelay:2.0f];
        self.hud = nil;
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    
    // Update the UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.progress = progress;
    });
}
@end
