//
//  KVNFuture.m
//  KVNAsync
//
//  Created by Kevin Smith on 8/19/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNFuture.h"
#import "KVNPromise.h"

@interface KVNFuture ()

@property (nonatomic, readwrite) id value;
@property (nonatomic, readwrite) NSError *error;
@property (nonatomic, readwrite) KVNFutureState state;

@property (nonatomic) NSMutableArray *completionHandlers;
@property (nonatomic) NSMutableArray *successHandlers;
@property (nonatomic) NSMutableArray *errorHandlers;

@end

@implementation KVNFuture

+ (instancetype)future {
    return [[self alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        self.state = KVNFutureStateIncomplete;
        self.completionHandlers = [NSMutableArray array];
        self.successHandlers = [NSMutableArray array];
        self.errorHandlers = [NSMutableArray array];
    }
    return self;
}

- (void)setValue:(id)value {
    if (self.state == KVNFutureStateCancelled) return;

    _value = value;
    if (value) {
        self.state = KVNFutureStateSucceeded;
        [self complete];
    }
}

- (void)setError:(NSError *)error {
    if (self.state == KVNFutureStateCancelled) return;

    _error = error;
    if (error) {
        self.state = KVNFutureStateFailed;
        [self complete];
    }
}

- (void)cancel {
    self.state = KVNFutureStateCancelled;
    self.value = nil;
    self.error = nil;
}

- (void)onCompletion:(void (^)(id value, NSError *error))handleCompletion {
    if (self.value || self.error) {
        handleCompletion(self.value, self.error);
    } else {
        [self.completionHandlers addObject:handleCompletion];
    }
}
- (void)onSuccess:(void (^)(id value))handleSuccess {
    if (self.value) {
        handleSuccess(self.value);
    } else {
        [self.successHandlers addObject:handleSuccess];
    }
}
- (void)onError:(void (^)(NSError *error))handleError {
    if (self.error) {
        handleError(self.error);
    } else {
        [self.errorHandlers addObject:handleError];
    }
}

#pragma mark Combinators and Helpers

+ (KVNFuture *)all:(id<NSFastEnumeration>)futures dispatch:(dispatch_queue_t)notifyQueue {
    KVNPromise *allPromise = [KVNPromise promise];

    dispatch_group_t all_group = dispatch_group_create();

    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *errors = [NSMutableArray array];
    NSUInteger index = 0;

    dispatch_queue_t serialAccessQueue = dispatch_queue_create("cc.kevinsmith.KVNAsync.allFutureAccessQueue", DISPATCH_QUEUE_SERIAL);
    for (KVNFuture *future in futures) {
        [values addObject:[NSNull null]]; // fill value array with placeholders
        
        dispatch_group_enter(all_group);
        [future onCompletion:^(id value, NSError *error) {
            dispatch_async(serialAccessQueue, ^{
                if (error) {
                    [errors addObject:error];
                } else {
                    id realValue = value ?: [NSNull null];
                    [values replaceObjectAtIndex:index withObject:realValue];
                }
                dispatch_group_leave(all_group);
            });
        }];
        index++;
    }

    dispatch_group_notify(all_group, notifyQueue, ^{
        if (errors.count > 0) {
            NSError *error = [NSError errorWithDomain:@"cc.kevinsmith.KVNFuture" code:4 userInfo:@{@"errors": errors}];
            [allPromise fail:error];
        } else {
            [allPromise succeed:values];
        }
    });

    return allPromise.future;

}

+ (KVNFuture *)all:(id<NSFastEnumeration>)futures {
    return [self all:futures
            dispatch:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

+ (KVNFuture *)first:(id<NSFastEnumeration>)futures {
    KVNPromise *firstPromise = [KVNPromise promise];
    dispatch_queue_t serialAccessQueue = dispatch_queue_create("cc.kevinsmith.KVNAsync.firstFutureAccessQueue", DISPATCH_QUEUE_SERIAL);

    for (KVNFuture *future in futures) {
        [future onCompletion:^(id value, NSError *error) {
            dispatch_async(serialAccessQueue, ^{
                if (firstPromise.isFulfilled == NO) {
                    [firstPromise completeWithValue:value error:error];
                    // cancel all other futures
                    for (KVNFuture *f in futures) {
                        if ([f isEqual:future]) continue;
                        [f cancel];
                    }
                }
            });
        }];
    }

    return firstPromise.future;
}

- (KVNFuture *)flatMap:(KVNFuture * (^)(id resolvedValue))valueMapBlock {
    KVNPromise *mappedPromise = [KVNPromise promise];
    [self onCompletion:^(id value, NSError *error) {
        if (error) {
            [mappedPromise fail:error];
        } else {
            KVNFuture *mappedFuture = valueMapBlock(value);
            [mappedPromise completeWith:mappedFuture];
        }
    }];
    
    return mappedPromise.future;
}

- (KVNFuture *)map:(id (^)(id resolvedValue))valueMapBlock {
    KVNPromise *mappedPromise = [KVNPromise promise];
    [self onCompletion:^(id value, NSError *error) {
        if (error) {
            [mappedPromise fail:error];
        } else {
            id mappedValue = valueMapBlock(value);
            [mappedPromise succeed:mappedValue];
        }
    }];

    return mappedPromise.future;
}

- (KVNFuture *)filter:(BOOL (^)(id valueToFilter))valuePassesFilterBlock {
    KVNPromise *filterPromise = [KVNPromise promise];

    [self onSuccess:^(id value) {
        if (valuePassesFilterBlock(value)) {
            [filterPromise succeed:value];
        }
    }];

    return filterPromise.future;
}

#pragma mark Private
- (void)complete {
    for (void (^completionHandler)(id, NSError *) in self.completionHandlers) {
        completionHandler(self.value, self.error);
    }
    if (self.value) {
        for (void (^successHandler)(id) in self.successHandlers) {
            successHandler(self.value);
        }
    }
    if (self.error) {
        for (void (^errorHandler)(NSError *) in self.errorHandlers) {
            errorHandler(self.error);
        }
    }
}

@end
