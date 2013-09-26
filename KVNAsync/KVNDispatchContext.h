//
//  KVNDispatchContext.h
//  KVNAsync
//
//  Created by Kevin Smith on 8/21/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNPromiseProtocol.h"

@interface KVNDispatchContext : NSObject<KVNPromise>

@property (nonatomic, readonly) dispatch_queue_t queue;

- (id)initWithDispatchQueue:(dispatch_queue_t)queue;


@end
