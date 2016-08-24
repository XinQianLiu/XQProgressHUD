//
//  XQProgressHUDTests.m
//  XQProgressHUDTests
//
//  Created by LiuXinQian on 07/28/2016.
//  Copyright (c) 2016 LiuXinQian. All rights reserved.
//

#import <XQProgressHUD/XQProgressHUD.h>

#define applicationWindowsCount [UIApplication sharedApplication].windows.count
#define lastWindow [UIApplication sharedApplication].windows.lastObject
#define applicationWindow [UIApplication sharedApplication].keyWindow

#define XQTestHUDIsVisible \
do{\
XCTAssertNotEqualObjects(applicationWindow, lastWindow);\
XCTAssertEqual(applicationWindowsCount, 2);\
XCTAssertNotNil(hud.superview);\
}while(0)

#define XQTestHUDIsHiden \
do{\
XCTAssertEqualObjects(applicationWindow, lastWindow);\
XCTAssertEqual(applicationWindowsCount, 1);\
XCTAssertNil(hud.superview);\
}while(0)

@import XCTest;

@interface XQProgressHUDTests : XCTestCase

@end

@implementation XQProgressHUDTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitialization
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    XCTAssertNotNil(hud);
}

- (void)testShow
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    
    XCTAssertNotNil(hud);
    [hud show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XQTestHUDIsVisible;
    });
}

- (void)testShowWithTimeout
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    
    XCTAssertNotNil(hud);
    
    [UIView animateWithDuration:1.0f animations:^{
        [hud showWithTimeout:2.0f];
    } completion:^(BOOL finished) {
        XQTestHUDIsVisible;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XQTestHUDIsHiden;
        });
    }];
}

- (void)testDismiss
{
    XQProgressHUD *hud = [XQProgressHUD HUD];
    
    XCTAssertNotNil(hud);
    
    [UIView animateWithDuration:1.0f animations:^{
        [hud show];
    } completion:^(BOOL finished) {
        XQTestHUDIsVisible;
        
        [hud dismiss];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XQTestHUDIsHiden;
        });
    }];
}

- (void)testHUDDidDismissHandlerBlock
{
    XCTestExpectation   *handlerExpectation = [self expectationWithDescription:@"The didDismissHandler: should have been called."];
    XQProgressHUD       *hud = [XQProgressHUD HUD];
    XCTAssertNotNil(hud);

    hud.didDismissHandler = ^() {
        [handlerExpectation fulfill];
    };
    [hud showWithTimeout:2.0f];
    [self waitForExpectationsWithTimeout:3.0f handler:nil];
}

- (void)testHUDAnimations
{
    CAAnimationGroup *group = [XQAnimationHelper cyclicRotationAnimationWithDuration:2.0f];
    XCTAssertNotNil(group);
    CAAnimation *animation = [XQAnimationHelper rotatingAnimationWithDuration:2.0f];
    XCTAssertNotNil(animation);
}

- (void)testHUDImageCategory
{
    UIImage *gifImage = [UIImage xq_gifWithName:@"u8"];
    XCTAssertNotNil(gifImage);
    UIImage *image = [UIImage xq_imageWithName:@"error"];
    XCTAssertNotNil(image);
}

@end

