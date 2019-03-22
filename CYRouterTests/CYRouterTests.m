//
//  CYRouterTests.m
//  CYRouterTests
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BrouterCore.h"


@interface CYRouterTests : XCTestCase
@property (nonatomic, strong) BrouterCore *brouter;
@end

@implementation CYRouterTests

- (void)setUp {
    [super setUp];
    self.brouter = [BrouterCore new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    self.brouter = nil;
    [super tearDown];
}

- (void)testRouterCoreRegister {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    BroutePath *path = [self.brouter route:nil toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"param should not be nil");
    
    path = [self.brouter route:@"/foo" toHandler:nil];
    XCTAssert(path==nil,@"param should not be nil");
    
    path = [self.brouter route:@"/foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"no scheme");
    
    path = [self.brouter route:@"{broute}://foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter route:@"br{oute}://foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter route:@"broute:{//}foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter route:@"broute://{}foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter route:@"broute://foo{/bar}" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter route:@"broute://foo/{bar" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter route:@"broute://foo/bar}" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");

    path = [self.brouter route:@"broute://foo/{{bar}}" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    // valid
    path = [self.brouter route:@"broute://{foo}" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path!=nil,@"valid route tamplate");

    path = [self.brouter route:@"broute://foo?p=20" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path!=nil,@"valid route tamplate");
    
    
    

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
