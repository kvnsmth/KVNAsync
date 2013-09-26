//
//  KVNDispatch.h
//  KVNAsync
//
//  Created by Kevin Smith on 8/21/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNDispatchContext.h"

FOUNDATION_EXPORT id const KVNDispatchEmptySuccessValue;

@protocol KVNFuture;

extern KVNFuture * kvn_dispatch_async(dispatch_queue_t queue, void (^executionBlock)(KVNDispatchContext *context));

@interface KVNDispatch : NSObject

+ (KVNFuture *)dispatchAsync:(void (^)(KVNDispatchContext *))executionBlock;
+ (KVNFuture *)dispatchAsync:(dispatch_queue_t)queue
                        work:(void (^)(KVNDispatchContext *context))executionBlock;

@end
