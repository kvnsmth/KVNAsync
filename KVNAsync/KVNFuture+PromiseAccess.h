//
//  KVNFuture+PromiseAccess.h
//  KVNAsync
//
//  Created by Kevin Smith on 8/19/13.
//  Copyright (c) 2013 Kevin Smith. All rights reserved.
//

#import "KVNFuture.h"

@interface KVNFuture (PromiseAccess)

@property (nonatomic, readwrite) id value;
@property (nonatomic, readwrite) NSError *error;

+ (instancetype)future;

@end
