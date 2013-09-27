//
//  KVNAsyncOCTests.m
//  KVNAsyncOCTests
//
//  Created by Kevin Smith on 8/28/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNAsync.h"

SpecBegin(KVNPromise)

describe(@"KVNPromise", ^{
    __block KVNPromise *promise = nil;
    beforeEach(^{
        promise = [KVNPromise promise];
    });

    it(@"should have correct default values", ^{
        KVNFuture * future = promise.future;
        expect(future).notTo.beNil();
        id value = promise.value;
        expect(value).to.equal(nil);
    });

    context(@"complete with value, error and future", ^{
        it(@"should work when a value is provided", ^{
            [promise completeWithValue:@"yo" error:nil];

            expect(promise.value).to.equal(@"yo");
            expect(promise.error).to.beNil();
        });
        it(@"should work when an error is provided", ^{
            NSError *error = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
            [promise completeWithValue:nil error:error];

            expect(promise.error).to.equal(error);
            expect(promise.value).to.beNil();
        });
        it(@"should work when a future is provided", ^{
            KVNPromise *coolPromise = [KVNPromise promise];
            [promise completeWith:coolPromise.future];
            [coolPromise completeWithValue:@"inception" error:nil];

            expect(promise.value).to.equal(@"inception");
            expect(promise.error).to.beNil();
        });
        it(@"should not be allowed more than once", ^{
            [promise completeWithValue:@"yo" error:nil];
            expect(^{
                [promise completeWithValue:@"yo yo" error:nil];
            }).to.raise(NSInternalInconsistencyException);

            expect(^{
                [promise completeWith:[KVNPromise promise].future];
            }).to.raise(NSInternalInconsistencyException);
        });
        it(@"should convert value to NSNull if both nil value and error", ^{
            [promise completeWithValue:nil error:nil];
            expect(promise.value).to.equal([NSNull null]);
        });
    });

    context(@"succeed", ^{
        it(@"should set the promise value", ^{
            [promise succeed:@"value"];
            expect(promise.value).to.equal(@"value");
            expect(promise.error).to.beNil();
        });
        it(@"should convert nil to NSNull", ^{
            [promise succeed:nil];
            expect(promise.value).to.equal([NSNull null]);
        });
        it(@"should not be allowed more than once", ^{
            [promise succeed:@"value"];
            expect(^{
                [promise succeed:@"value2"];
            }).to.raise(NSInternalInconsistencyException);
        });
    });

    context(@"fail", ^{
        __block NSError *error = nil;
        beforeEach(^{
            error = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
        });
        it(@"should set the promise error", ^{
            [promise fail:error];
            expect(promise.error).to.equal(error);
            expect(promise.value).to.beNil();
        });
        it(@"should guard against nil", ^{
            expect(^{
                [promise fail:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
        it(@"should not be allowed more than once", ^{
            [promise fail:error];
            expect(^{
                [promise fail:error];
            }).to.raise(NSInternalInconsistencyException);
        });
    });
});

SpecEnd
