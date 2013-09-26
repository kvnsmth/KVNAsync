//
//  KVNFuture.h
//  KVNAsync
//
//  Created by Kevin Smith on 8/19/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

typedef enum {
    KVNFutureStateIncomplete = 0,
    KVNFutureStateSucceeded,
    KVNFutureStateFailed,
    KVNFutureStateCancelled
} KVNFutureState;

@interface KVNFuture : NSObject

+ (instancetype)future;

@property (nonatomic, readonly) id value;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) KVNFutureState state;

/**
 Cancels the resolution of this future value or error.

 @discussion Resets value and error to nil. If this future has previously been
 resolved, these values will disappear after cancellation.
 */
- (void)cancel;

/**
 @name Resolution handlers
 */
- (void)onCompletion:(void (^)(id value, NSError *error))handleCompletion;
- (void)onSuccess:(void (^)(id value))handleSuccess;
- (void)onError:(void (^)(NSError *error))handleError;

/**
 @name Combinator methods
 */

/**
 Returns a future that completes when the all futures in `futures` complete. The value of the returned
 future will contain an array of all the values in the order that `futures` enumerates in a for loop. 
 If there are any errors, the returned future will fail with an error that has all the errors 
 encountered collected as an array in the userInfo under the `errors` key; order for errors is undefined.
 */
+ (KVNFuture *)all:(id<NSFastEnumeration>)futures;

/**
 @see `all:` for discussion.

 @param notifyQueue: queue to notify completion
 */
+ (KVNFuture *)all:(id<NSFastEnumeration>)futures dispatch:(dispatch_queue_t)notifyQueue;

/**
 Returns a future that completes when the first future in `futures` completes, either with value or error.
 */
+ (KVNFuture *)first:(id<NSFastEnumeration>)futures;

/**
 Returns a future that will hold the value of a future returned by `valueMapBlock`.

 @discussion Once the receiver is resolved, its value will be passed to `valueMapBlock`.
 */
- (KVNFuture *)flatMap:(KVNFuture * (^)(id resolvedValue))valueMapBlock;
/**
 Returns a future that will hold the value returned from `valueMapBlock`.

 @discussion Once the receiver is resolved, its value will be passed to `valueMapBlock`.
 */
- (KVNFuture *)map:(id (^)(id resolvedValue))valueMapBlock;

/**
 Returns a future that will succeed with `valueToFilter` only if YES is returned
 from `valuePassesFilterBlock`.

 @discussion If receiver fails, the returned future WILL NOT also fail.
 */
- (KVNFuture *)filter:(BOOL (^)(id valueToFilter))valuePassesFilterBlock;


@end
