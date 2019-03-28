//
//  Brouter_iosDemoTests.m
//  Brouter-iosDemoTests
//
//  Created by candy on 2019/3/27.
//  Copyright © 2019 Brouter. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BrouterCore.h"

@interface Brouter_iosDemoTests : XCTestCase
@property (nonatomic, strong) BrouterCore *brouter;
@end

@implementation Brouter_iosDemoTests

- (void)setUp {
    self.brouter = [BrouterCore new];
}

- (void)tearDown {
    self.brouter = nil;
}

- (void)testExample {
    
    NSObject *obj = [NSObject new];
    BrouterRoutePath *path = [self.brouter mapRouteTamplate:nil toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"param should not be nil");
    
    path = [self.brouter mapRouteTamplate:@"broute://foo" toHandler:nil];
    XCTAssert(path==nil,@"param should not be nil");
    
    path = [self.brouter mapRouteTamplate:@"/foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"missing scheme");
    
    path = [self.brouter mapRouteTamplate:@"{broute}://foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"br{oute}://foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"broute:{//}foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"broute://{}foo" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"broute://foo{/bar}" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"broute://foo/{bar" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"broute://foo/bar}" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"broute://foo/{{bar}}" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"invalid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"abc://foo{[0-9]+}" toHandler:^(NSDictionary *params) {
    }];
    XCTAssert(path==nil,@"missing param name");
    
    path = [self.brouter mapRouteTamplate:@"broute://foo?p=20" toHandler:obj];
    XCTAssert(path==nil,@"no queries in route tamplate");
}

- (void)testRouterCoreParse {
    // valid
    NSObject *obj = [NSObject new];
    
    /**/
    BrouterRoutePath *path = [self.brouter mapRouteTamplate:@"broute://foo" toHandler:obj];
    XCTAssert(path!=nil,@"valid route tamplate");
    
    BrouterResponse *res = [self.brouter parseUrl:@"broute://foo"];
    XCTAssert(res.error==nil,@"parse url failed.");
    
    path = [self.brouter mapRouteTamplate:@"broute://{foo}" toHandler:obj];
    XCTAssert(path!=nil,@"valid route tamplate");
    
    
    /**/
    path = [self.brouter mapRouteTamplate:@"broute://foo/{id}" toHandler:obj];
    XCTAssert(path!=nil,@"valid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"broute://foo/{bar:[0-9]+}" toHandler:obj];
    XCTAssert(path!=nil,@"valid route tamplate");
    
    res = [self.brouter parseUrl:@"/foo/123"];
    XCTAssert(res.error != nil,@"parse url failed.");
    
    res = [self.brouter parseUrl:@"broute://foo/123"];
    XCTAssert(res.error==nil,@"parse url failed.");
    XCTAssert(res.params.count==1,@"parse url failed.");
    XCTAssert([res.params[@"bar"] isEqualToString:@"123"],@"parse url failed.");
    
    
    path = [self.brouter mapRouteTamplate:@"abc://{foo:[0-9]+}" toHandler:obj];
    XCTAssert(path!=nil,@"valid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"abc://foo{var}" toHandler:obj];
    XCTAssert(path!=nil,@"valid route tamplate");
    
    path = [self.brouter mapRouteTamplate:@"abc://{foo:[0-9]+}/bar{bar}" toHandler:obj];
    XCTAssert(path!=nil,@"valid route tamplate");
    
    
    
    
    
    
    res = [self.brouter parseUrl:@"abc://foobar"];
    XCTAssert(res.error==nil,@"parse url failed.");
    XCTAssert(res.params.count==1,@"parse url failed.");
    XCTAssert([res.params[@"var"] isEqualToString:@"bar"],@"parse url failed.");
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
