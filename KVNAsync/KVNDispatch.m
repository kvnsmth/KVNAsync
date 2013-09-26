//
//  KVNDispatch.m
//  KVNAsync
//
//  Created by Kevin Smith on 8/21/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNDispatch.h"

#import "KVNDispatchContext.h"
#import "KVNFuture.h"

id const KVNDispatchEmptySuccessValue = @"KVNDispatchEmptySuccessValue";

KVNFuture * kvn_dispatch_async(dispatch_queue_t queue, void (^executionBlock)(KVNDispatchContext *context)) {
    return [KVNDispatch dispatchAsync:queue work:executionBlock];
}

@implementation KVNDispatch

+ (KVNFuture *)dispatchAsync:(dispatch_queue_t)queue
                        work:(void (^)(KVNDispatchContext *))executionBlock {
    NSParameterAssert(executionBlock);
    
    if (queue == NULL) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    KVNDispatchContext *dispatchContext = [[KVNDispatchContext alloc] initWithDispatchQueue:queue];
    dispatch_async(queue, ^{
        executionBlock(dispatchContext);

        if (dispatchContext.isFulfilled == NO) {
            [dispatchContext succeed:KVNDispatchEmptySuccessValue];
        }
    });

    return dispatchContext.future;
}

+ (KVNFuture *)dispatchAsync:(void (^)(KVNDispatchContext *))executionBlock {
    return [self dispatchAsync:NULL work:executionBlock];
}

@end
