//
//  XQViewController.m
//  XQProgressHUD
//
//  Created by LiuXinQian on 07/28/2016.
//  Copyright (c) 2016 LiuXinQian. All rights reserved.
//

#import "XQViewController.h"
#import "XQTestViewController.h"
#import <XQProgressHUD/XQProgressHUD.h>

@interface XQViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) XQProgressHUD  *hud;
@end

@implementation XQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_hud) {
        [_hud dismiss];
        _hud = nil;
    }
}

#pragma mark - UITableViewDelegate && UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELLID" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Display The Animation View";
            break;
        case 1:
            cell.textLabel.text = @"Animation View For Load The Timeout";
            break;
        case 2:
            cell.textLabel.text = @"The Custom Style Animation View";
            break;
        case 3:
            cell.textLabel.text = @"Display GIF Figure";
            break;
        case 4:
            cell.textLabel.text = @"GIF Figure For Load The Timeout";
            break;
        case 5:
            cell.textLabel.text = @"User Interaction Enabled";
            break;
        case 6:
            cell.textLabel.text = @"To Test ViewController";
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [self.hud show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.hud dismiss];
            });
            break;
        }
        case 1:
        {
            [self.hud showAnimationViewOfTimeout:5.0f userInteraction:YES timeoutBlock:^(XQProgressHUD *hud) {
                [self.hud dismiss];
                //                self.hud = nil
            }];
            break;
        }
        case 2:
        {
            self.hud.animatedViewModel.isPointLabel = NO;
            self.hud.animatedViewModel.outerLayerStrokeColor = [UIColor whiteColor];
            self.hud.animatedViewModel.innerLayerStrokeColor = [UIColor redColor];
            self.hud.animatedViewModel.titleText = @"正在玩命加载中";
            self.hud.animatedViewModel.titleTextColor = [UIColor blackColor];
            self.hud.animatedViewModel.selfBackgroundColor = [UIColor cyanColor];
            self.hud.animatedViewModel.selfLayerBorderColor = [UIColor redColor];
            [self.hud showAnimationViewOfTimeout:5.0f userInteraction:YES timeoutBlock:^(XQProgressHUD *hud) {
                [self.hud dismiss];
                //                self.hud = nil;
            }];
            break;
        }
        case 3:
        {
            //            [self.hud showGifImageViewOfGifNamed:nil userInteraction:YES];
            [self.hud showGif];
            break;
        }
        case 4:
        {
            [self.hud showGifImageViewOfGifNamed:nil Timeout:5.0f userInteraction:YES timeoutBlock:^(XQProgressHUD *hud) {
                [self.hud dismiss];
                //                self.hud = nil;
            }];
            break;
        }
        case 5:
        {
            [self.hud showAnimationViewOfUserInteraction:NO];
            break;
        }
        case 6:
        {
            XQTestViewController *vc = [[XQTestViewController alloc] init];
            [self presentViewController:vc animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Getters
- (XQProgressHUD *)hud
{
    if (!_hud) {
        _hud = [[XQProgressHUD alloc] init];
    }
    
    return _hud;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
