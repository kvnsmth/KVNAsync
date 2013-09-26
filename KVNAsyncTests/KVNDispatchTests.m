//
//  KVNDispatchTests.m
//  KVNAsync
//
//  Created by Kevin Smith on 8/21/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KVNDispatch.h"
#import "KVNDispatchContext.h"
#import "KVNFuture.h"
#import "KVNPromise.h"

@interface KVNDispatchTests : XCTestCase

@property (nonatomic) dispatch_group_t testGroup;

@end

@implementation KVNDispatchTests

- (void)setUp {
    [super setUp];

    // this dispatch group is used to make sure the test running process does not
    // stop before all the tests have run (since they run async)
    // NOTE: each test case needs to leave the group when finished testing
    self.testGroup = dispatch_group_create();
    dispatch_group_enter(self.testGroup);
}

- (void)tearDown {
    [super tearDown];
    dispatch_group_wait(self.testGroup, DISPATCH_TIME_FOREVER);
}

- (void)testSuccessfulWork {
    KVNFuture *dispatchFuture = [KVNDispatch dispatchAsync:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                      work:^(KVNDispatchContext *context) {
                                                          NSInteger sum = 2 + 2;
                                                          [context succeed:@(sum)];
                                                      }];

    [dispatchFuture onSuccess:^(id value) {
        XCTAssertEqual(@4, value, @"future should resolve to sum");
        dispatch_group_leave(self.testGroup);
    }];

}

- (void)testDefaultQueueAndSuccess {
    KVNFuture *anotherFuture = kvn_dispatch_async(NULL, ^(KVNDispatchContext *context) {
        // no need to do anyting
    });

    [anotherFuture onSuccess:^(id value) {
        XCTAssertTrue([value boolValue], @"should pass YES when promise is not succeeded");
        dispatch_group_leave(self.testGroup);
    }];
}

- (void)testFailure {
    NSError *controlError = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
    KVNFuture *future = kvn_dispatch_async(NULL, ^(KVNDispatchContext *context) {
        [context fail:controlError];
    });

    [future onCompletion:^(id value, NSError *error) {
        XCTAssertEqual(controlError, error, @"should get control error");
        dispatch_group_leave(self.testGroup);
    }];
}


@end
