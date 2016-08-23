//
//  XQProgressHUDTests.m
//  XQProgressHUDTests
//
//  Created by LiuXinQian on 07/28/2016.
//  Copyright (c) 2016 LiuXinQian. All rights reserved.
//

#import <XQProgressHUD/XQProgressHUD.h>

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
    XCTAssertNil(hud.superview);
    XCTAssertEqual(hud.subviews.count, 3);
    XCTAssertEqual(hud.alpha, 1.0f);
    XCTAssertEqualObjects(hud.backgroundColor, [[UIColor whiteColor] colorWithAlphaComponent:0.5f]);
    XCTAssertEqual(hud.mode, XQProgressHUDModeIndicator);
    XCTAssertEqual(hud.size.width, 120.0f);
    XCTAssertEqual(hud.size.height, 90.0f);
    XCTAssertEqualObjects(hud.textColor, [UIColor xq_animationViewDefaultColor]);
    XCTAssertEqual(hud.ringRadius, 20.0f);
    XCTAssertEqualObjects(hud.gifImageName, @"u8");
    XCTAssertEqual(hud.maximumWidth, 140.0f);
    XCTAssertEqualObjects(hud.trackTintColor, [UIColor whiteColor]);
    XCTAssertEqualObjects(hud.progressTintColor, [UIColor xq_animationViewDefaultColor]);
    XCTAssertEqual(hud.animationDuration, 1.5f);
    XCTAssertTrue(hud.suffixPointEnabled);
    XCTAssertEqual(hud.foregroundBorderWidth, 0.0f);
    XCTAssertEqualObjects(hud.foregroundBorderColor, [UIColor clearColor]);
    XCTAssertEqual(hud.foregroundCornerRaidus, 5.0f);
    XCTAssertEqual(hud.suffixPointAnimationDuration, 0.2f);
    XCTAssertEqualObjects(hud.text, @"Loading");
    XCTAssertEqualObjects(hud.textFont, [UIFont systemFontOfSize:15.0f]);
}

- (void)testHUDDidDismissHandlerBlock
{
    XCTestExpectation *handlerExpectation = [self expectationWithDescription:@"The didDismissHandlerBlock: should have been called."];
    XQProgressHUD *hud = [XQProgressHUD HUD];
    hud.didDismissHandler = ^(){
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

