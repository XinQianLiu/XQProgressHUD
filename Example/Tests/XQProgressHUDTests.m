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
}

@end

