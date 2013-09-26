//
//  KVNFutureTests.m
//  KVNAsync
//
//  Created by Kevin Smith on 8/21/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KVNFuture.h"
#import "KVNPromise.h"
#import "KVNDispatch.h"

@interface KVNFutureTests : XCTestCase

@end

@implementation KVNFutureTests

- (void)testMapCombinator {
    KVNPromise *promise = [KVNPromise promise];

    id (^addOneMapper)(NSNumber *) = ^(NSNumber *startValue) {
        return @(startValue.integerValue + 1);
    };

    KVNFuture *mappedFuture = [promise.future map:addOneMapper];
    [promise succeed:@1];

    [mappedFuture onCompletion:^(id value, NSError *error) {
        XCTAssertEqualObjects(@2, value, @"2 == 2");
        XCTAssertNil(error, @"error should be nil");
    }];
}

- (void)testMapCombinatorWithInitialError {
    KVNPromise *promise = [KVNPromise promise];

    id (^addOneMapper)(NSNumber *) = ^(NSNumber *startValue) {
        return @(startValue.integerValue + 1);
    };

    KVNFuture *mappedFuture = [promise.future map:addOneMapper];
    NSError *failedError = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
    [promise fail:failedError];

    [mappedFuture onCompletion:^(id value, NSError *error) {
        XCTAssertNil(value, @"value should be nil");
        XCTAssertEqualObjects(failedError, error, @"errors should equal");
    }];
}

- (void)testFlatMapCombinator {
    KVNPromise *promise = [KVNPromise promise];

    KVNFuture * (^addOneMapper)(NSNumber *) = ^(NSNumber *start) {
        KVNPromise *promise = [KVNPromise promise];
        [promise succeed:@(start.integerValue + 1)];
        return promise.future;
    };

    KVNFuture *mappedFuture = [promise.future flatMap:addOneMapper];
    [promise succeed:@1];

    [mappedFuture onCompletion:^(id value, NSError *error) {
        XCTAssertEqualObjects(@2, value, @"2 == 2");
        XCTAssertNil(error, @"error should be nil");
    }];
}

- (void)testFlatMapCombinatorWithMappedError {
    KVNPromise *promise = [KVNPromise promise];

    NSError *failedError = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
    KVNFuture * (^addOneMapper)(NSNumber *) = ^(NSNumber *start) {
        KVNPromise *promise = [KVNPromise promise];
        [promise fail:failedError];
        return promise.future;
    };

    KVNFuture *mappedFuture = [promise.future flatMap:addOneMapper];
    [promise succeed:@1];

    [mappedFuture onCompletion:^(id value, NSError *error) {
        XCTAssertNil(value, @"value should be nil");
        XCTAssertEqualObjects(failedError, error, @"errors should equal");
    }];
}

- (void)testFilterCombinator {
    dispatch_group_t test_group = dispatch_group_create();
    dispatch_group_enter(test_group);
    
    KVNFuture *originalFuture = kvn_dispatch_async(NULL, ^(KVNDispatchContext *context) {
        [context succeed:@43];
        dispatch_group_leave(test_group);
    });

    [[originalFuture filter:^BOOL(id valueToFilter) {
        return [valueToFilter integerValue] > 24;
    }] onSuccess:^(id value) {
        XCTAssertEqualObjects(@43, @43, @"should get value since it passes filter");
    }];

    dispatch_group_wait(test_group, DISPATCH_TIME_FOREVER);
}

- (void)testOnAll {
    dispatch_group_t test_group = dispatch_group_create();

    dispatch_group_enter(test_group);
    KVNFuture *futureOne = kvn_dispatch_async(NULL, ^(KVNDispatchContext *context) {
        [context succeed:@1];
        dispatch_group_leave(test_group);
    });
    dispatch_group_enter(test_group);
    KVNFuture *futureTwo = kvn_dispatch_async(NULL, ^(KVNDispatchContext *context) {
        [context succeed:@2];
        dispatch_group_leave(test_group);
    });

    KVNFuture *allFuture = [KVNFuture all:@[futureOne, futureTwo]];

    [allFuture onCompletion:^(id value, NSError *error) {
        XCTAssertNil(error, @"error should be nil");
        NSArray *valueArr = (NSArray *)value;
        BOOL containsOne = [valueArr containsObject:@1];
        BOOL containtsTwo = [valueArr containsObject:@2];
        XCTAssertTrue(containsOne, @"");
        XCTAssertTrue(containtsTwo, @"");
    }];

    dispatch_group_wait(test_group, DISPATCH_TIME_FOREVER);
}

@end
