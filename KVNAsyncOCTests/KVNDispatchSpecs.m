//
//  KVNDispatchSpecs.m
//  KVNAsync
//
//  Created by Kevin Smith on 9/18/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNAsync.h"

SpecBegin(KVNDispatch)

describe(@"KVNDispatch", ^{

    it(@"should succeed on a provided queue when dispatch context succeeds", ^(void (^done)()){
        KVNFuture *dispatchFuture = [KVNDispatch dispatchAsync:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                          work:^(KVNDispatchContext *context) {
                                                              NSInteger sum = 2 + 2;
                                                              [context succeed:@(sum)];
                                                          }];

        [dispatchFuture onSuccess:^(id value) {
            expect(value).to.equal(@4);
            done();
        }];
    });

    it(@"should succeed on a default queue when no queue is provided", ^(void (^done)()) {
        KVNFuture *dispatchFuture = [KVNDispatch dispatchAsync:NULL
                                                          work:^(KVNDispatchContext *context) {
                                                              NSInteger sum = 2 + 2;
                                                              [context succeed:@(sum)];
                                                          }];

        [dispatchFuture onSuccess:^(id value) {
            expect(value).to.equal(@4);
            done();
        }];
    });

    it(@"should succeed with a value if the work block does not provide one", ^(void(^done)()) {
        KVNFuture *dispatchFuture = [KVNDispatch dispatchAsync:^(KVNDispatchContext *context) {
            // do nothing on purpose
        }];

        [dispatchFuture onSuccess:^(id value) {
            expect(value).to.equal(KVNDispatchEmptySuccessValue);
            done();
        }];
    });

    it(@"should fail when dispatch context fails", ^(void(^done)()) {
        NSError *controlError = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
        KVNFuture *future = kvn_dispatch_async(NULL, ^(KVNDispatchContext *context) {
            [context fail:controlError];
        });

        [future onCompletion:^(id value, NSError *error) {
            expect(value).to.beNil();
            expect(error).to.equal(controlError);
            done();
        }];
    });
});

SpecEnd
