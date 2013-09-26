//
//  KVNPromise.h
//  KVNPromise
//
//  Created by Kevin Smith on 8/15/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNPromiseProtocol.h"

@interface KVNPromise : NSObject<KVNPromise>

+ (instancetype)promise;

@end
