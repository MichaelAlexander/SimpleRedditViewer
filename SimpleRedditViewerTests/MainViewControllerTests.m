//
//  MainViewControllerTests.m
//  SimpleRedditViewer
//
//  Created by Michael Alexander on 3/27/14.
//  Copyright (c) 2014 Michael Alexander. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MainViewController.h"

@interface MainViewControllerTests : XCTestCase

@property (nonatomic, strong) MainViewController *testMainViewController;

@end

@implementation MainViewControllerTests

@synthesize testMainViewController;

- (void)setUp
{
    [super setUp];
    testMainViewController = [[MainViewController alloc] init];
}

- (void)tearDown
{
    testMainViewController = nil;
    [super tearDown];
}

- (void)testThatMainViewControllerIsNotNil
{
    XCTAssertNotNil(testMainViewController, @"Main View Controller may not be nil");
}

@end
