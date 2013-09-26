//
//  KVNPromiseProtocol.h
//  KVNAsync
//
//  Created by Kevin Smith on 8/21/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNFuture.h"

@protocol KVNPromise <NSObject>

@property (nonatomic, readonly) KVNFuture *future;

@property (nonatomic, readonly) BOOL isFulfilled;
@property (nonatomic, readonly) id value;
@property (nonatomic, readonly) NSError *error;

- (void)completeWithValue:(id)value error:(NSError *)error;
- (void)completeWith:(KVNFuture *)future;

- (void)succeed:(id)value;
- (void)fail:(NSError *)error;

@end
