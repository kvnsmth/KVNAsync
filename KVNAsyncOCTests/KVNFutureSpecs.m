//
//  KVNFutureTests.m
//  KVNAsync
//
//  Created by Kevin Smith on 8/30/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNAsync.h"

SpecBegin(KVNFuture)

describe(@"KVNFuture", ^{
    context(@"success", ^{
        it(@"should call handlers", ^{
            KVNPromise *promise = [KVNPromise promise];

            id success = @"success";
            __block BOOL onCompletionCalled = NO;
            __block BOOL onSuccessCalled = NO;
            __block BOOL onErrorCalled = NO;
            [promise.future onCompletion:^(id value, NSError *error) {
                onCompletionCalled = YES;
                expect(value).to.equal(success);
            }];
            [promise.future onSuccess:^(id value) {
                onSuccessCalled = YES;
                expect(value).to.equal(success);
            }];
            [promise.future onError:^(NSError *error) {
                onErrorCalled = YES;
            }];

            [promise succeed:success];
            expect(onCompletionCalled).to.beTruthy();
            expect(onSuccessCalled).to.beTruthy();
            expect(onErrorCalled).to.beFalsy();
        });
    });

    context(@"failure", ^{
        it(@"should call handlers", ^{
            KVNPromise *promise = [KVNPromise promise];

            NSError *controlError = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
            __block BOOL onCompletionCalled = NO;
            __block BOOL onSuccessCalled = NO;
            __block BOOL onErrorCalled = NO;
            [promise.future onCompletion:^(id value, NSError *error) {
                onCompletionCalled = YES;
                expect(error).to.equal(controlError);
            }];
            [promise.future onSuccess:^(id value) {
                onSuccessCalled = YES;
            }];
            [promise.future onError:^(NSError *error) {
                onErrorCalled = YES;
                expect(error).to.equal(controlError);
            }];

            [promise fail:controlError];
            expect(onCompletionCalled).to.beTruthy();
            expect(onSuccessCalled).to.beFalsy();
            expect(onErrorCalled).to.beTruthy();
        });
    });

    describe(@"all", ^{
        it(@"should return values in the order of the futures", ^(void (^done)(void)){
            KVNPromise *promise1 = [KVNPromise promise];
            KVNPromise *promise2 = [KVNPromise promise];

            KVNFuture *allFuture = [KVNFuture all:@[promise1.future, promise2.future]];

            // succeed out of order
            [promise2 succeed:@2];
            [promise1 succeed:@1];

            NSArray *valuesArray = @[@1, @2];

            [allFuture onSuccess:^(id value) {
                expect(value).to.equal(valuesArray);
                done();
            }];
        });

        it(@"should gather all errors", ^(void (^done)(void)) {
            KVNPromise *promise1 = [KVNPromise promise];
            KVNPromise *promise2 = [KVNPromise promise];

            KVNFuture *allFuture = [KVNFuture all:@[promise1.future, promise2.future]];

            NSError *controlError1 = [NSError errorWithDomain:@"cc.kevinsmith" code:101 userInfo:nil];
            NSError *controlError2 = [NSError errorWithDomain:@"cc.kevinsmith" code:102 userInfo:nil];

            [promise2 fail:controlError2];
            [promise1 fail:controlError1];

            [allFuture onError:^(NSError *error) {
                expect(error).notTo.beNil();

                NSDictionary *userInfo = error.userInfo;
                NSArray *errors = userInfo[@"errors"];
                expect(errors).toNot.beNil();

                expect(errors).to.contain(controlError1);
                expect(errors).to.contain(controlError2);

                done();
            }];
        });
    });

    describe(@"first", ^{
        it(@"should get first success", ^(void (^done)(void)){
            KVNPromise *promise1 = [KVNPromise promise];
            KVNPromise *promise2 = [KVNPromise promise];

            KVNFuture *firstFuture = [KVNFuture all:@[promise1.future, promise2.future]];
            [promise1 succeed:@1];
            [promise2 succeed:@2];

            [firstFuture onSuccess:^(id value) {
                expect(value).to.equal(@1);
                done();
            }];
        });
    });

    describe(@"flatMap", ^{
        it(@"should resolve with the returned future", ^{
            KVNPromise *promise = [KVNPromise promise];

            KVNFuture * (^addOneMapper)(NSNumber *) = ^(NSNumber *start) {
                KVNPromise *promise = [KVNPromise promise];
                [promise succeed:@(start.integerValue + 1)];
                return promise.future;
            };

            KVNFuture *flatMappedFuture = [promise.future flatMap:addOneMapper];
            [promise succeed:@1];

            [flatMappedFuture onCompletion:^(id value, NSError *error) {
                expect(error).to.beNil();
                expect(value).to.equal(@2);
            }];
        });
    });

    describe(@"map", ^{
        it(@"should resolve with the mapped value", ^{
            KVNPromise *promise = [KVNPromise promise];

            id (^addOneMapper)(NSNumber *) = ^(NSNumber *startValue) {
                return @(startValue.integerValue + 1);
            };

            KVNFuture *mappedFuture = [promise.future map:addOneMapper];
            [promise succeed:@1];

            [mappedFuture onCompletion:^(id value, NSError *error) {
                expect(error).to.beNil();
                expect(value).to.equal(@2);
            }];
        });
    });

    describe(@"filter", ^{
        it(@"should allow values that pass the filter through", ^(void (^done)(void)){
            KVNFuture *originalFuture = kvn_dispatch_async(NULL, ^(KVNDispatchContext *context) {
                [context succeed:@43];
            });

            [[originalFuture filter:^BOOL(id valueToFilter) {
                return [valueToFilter integerValue] > 24;
            }] onSuccess:^(id value) {
                expect(value).to.equal(@43);
                done();
            }];
        });
    });

});

SpecEnd