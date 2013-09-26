//
//  KVNPromiseTests.m
//  KVNPromiseTests
//
//  Created by Kevin Smith on 8/15/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KVNPromise.h"
#import "KVNFuture.h"

@interface KVNPromiseTests : XCTestCase

@property (nonatomic) KVNPromise *promise;

@end

@implementation KVNPromiseTests

- (void)setUp {
    [super setUp];
    self.promise = [KVNPromise promise];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    XCTAssertNotNil(self.promise, @"promise should not be nill");
    XCTAssertNotNil(self.promise.future, @"future should not be nil");
    XCTAssertNil(self.promise.value, @"value should be nil");
}

- (void)testCompleteWithValue {
    [self.promise completeWithValue:@"yo" error:nil];

    XCTAssertEqual(@"yo", self.promise.value, @"value should be what succeeded");
    XCTAssertNil(self.promise.error, @"error should be nil");
}

- (void)testCompleteWithError {
    NSError *error = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
    [self.promise completeWithValue:nil error:error];

    XCTAssertEqual(error, self.promise.error, @"error should be what failed");
    XCTAssertNil(self.promise.value, @"value should be nil");
}

- (void)testCompleteWithFuture {
    KVNPromise *coolPromise = [KVNPromise promise];
    [self.promise completeWith:coolPromise.future];

    [coolPromise completeWithValue:@"inception" error:nil];

    XCTAssertEqual(@"inception", self.promise.value, @"value should be what succeeded");
    XCTAssertNil(self.promise.error, @"error should be nil");
}

- (void)testSucceed {
    [self.promise succeed:@"value"];

    XCTAssertEqual(@"value", self.promise.value, @"value should be what succeeded");
    XCTAssertNil(self.promise.error, @"error should be nil");
}

- (void)testFail {
    NSError *error = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
    [self.promise fail:error];

    XCTAssertEqual(error, self.promise.error, @"error should be what failed");
    XCTAssertNil(self.promise.value, @"value should be nil");
}

- (void)testMultipleComplete {
    [self.promise completeWithValue:@"yo" error:nil];

    XCTAssertThrows({
        [self.promise completeWithValue:@"yo" error:nil];
    }, @"should not be able to complete multiple times");
}

- (void)testMultipleSucceed {
    [self.promise succeed:@"yo"];

    XCTAssertThrows({
        [self.promise succeed:@"wtf"];
    }, @"should not be able to succeed multiple times");
}

- (void)testMultipleFail {
    NSError *error = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
    [self.promise fail:error];

    XCTAssertThrows({
        [self.promise fail:error];
    }, @"should not be able to fail multiple times");
}

#pragma mark Futures

- (void)testFutureSuccess {
    KVNFuture *future = self.promise.future;
    [future onCompletion:^(id value, NSError *error) {
        XCTAssertEqual(@"success", value, @"completion handler should get proper value");
    }];
    [future onSuccess:^(id value) {
        XCTAssertEqual(@"success", value, @"success handler should get proper value");
    }];

    [self.promise succeed:@"success"];
}

@end
