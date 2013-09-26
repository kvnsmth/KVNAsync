//
//  KVNPromise.m
//  KVNPromise
//
//  Created by Kevin Smith on 8/15/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNPromise.h"

#import "KVNFuture.h"
#import "KVNFuture+PromiseAccess.h"

@interface KVNPromise ()

@property (nonatomic, readwrite) BOOL isFulfilled;
@property (nonatomic, readwrite) KVNFuture *future;

@property (nonatomic) KVNFuture * completionFuture;

@end

@implementation KVNPromise

+ (instancetype)promise {
    KVNPromise *promise = [[self alloc] init];
    return promise;
}

- (id)init {
    self = [super init];
    if (self) {
        self.future = [KVNFuture future];
        self.isFulfilled = NO;
    }
    return self;
}

#pragma mark Value/Error properties

- (id)value {
    return self.future.value;
}
- (NSError *)error {
    return self.future.error;
}

#pragma mark Value Fulfillment

- (void)completeWithValue:(id)value error:(NSError *)error {
    [self fulfillWith:value error:error];
}
- (void)completeWith:(KVNFuture *)future {
    NSParameterAssert(future);
    if (self.isFulfilled || self.completionFuture) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"cannot complete a promise more than once"
                               userInfo:nil] raise];
    }
    self.completionFuture = future;

    __weak KVNPromise *weakSelf = self;
    [future onCompletion:^(id value, NSError *error) {
        KVNPromise *strongSelf = weakSelf;
        [strongSelf completeWithValue:value error:error];
    }];
}

- (void)succeed:(id)value {
    [self fulfillWith:value error:nil];
}
- (void)fail:(NSError *)error {
    NSParameterAssert(error);
    [self fulfillWith:nil error:error];
}

#pragma mark - Private

- (void)fulfillWith:(id)value error:(NSError *)error {
    if (self.isFulfilled) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"cannot complete a promise more than once"
                               userInfo:nil] raise];
    }
    if (error == nil && value == nil) {
        value = [NSNull null];
    }
    self.isFulfilled = YES;

    self.future.value = value;
    self.future.error = error;
    self.completionFuture = nil;
}

@end
