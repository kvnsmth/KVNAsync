//
//  KVNDispatchContext.m
//  KVNAsync
//
//  Created by Kevin Smith on 8/21/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNDispatchContext.h"

#import "KVNFuture.h"
#import "KVNPromise.h"

@interface KVNDispatchContext ()

@property (nonatomic, readwrite) dispatch_queue_t queue;
@property (nonatomic) KVNPromise *internalPromise;

@end

@implementation KVNDispatchContext

- (id)initWithDispatchQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        self.queue = queue;
        self.internalPromise = [KVNPromise promise];
    }
    return self;
}

#pragma mark KVNPromise protocol

- (KVNFuture *)future { return self.internalPromise.future; }
- (id)value { return self.internalPromise.value; }
- (NSError *)error { return self.internalPromise.error; }
- (BOOL)isFulfilled { return self.internalPromise.isFulfilled; }

- (void)completeWith:(KVNFuture *)future {
    [self.internalPromise completeWith:future];
}
- (void)completeWithValue:(id)value error:(NSError *)error {
    [self.internalPromise completeWithValue:value error:error];
}
- (void)succeed:(id)value {
    [self.internalPromise succeed:value];
}
- (void)fail:(NSError *)error {
    [self.internalPromise fail:error];
}

@end
