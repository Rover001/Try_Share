//
//  SynthesizeSingleton.h
//  loanCustomer
//
//  Created by zhangyinglong on 14/12/16.
//  Copyright (c) 2014年 yinglongzhang. All rights reserved.
//

#pragma once

#if __has_feature(objc_arc)

#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(classname) \
\
+ (classname *)shared##classname;

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
    static dispatch_once_t pred; \
    dispatch_once(&pred, ^{ shared##classname = [[classname alloc] init]; }); \
    return shared##classname; \
}

#else

#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(classname) \
\
+ (classname *)shared##classname;

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname \
{ \
    static dispatch_once_t pred; \
    dispatch_once(&pred, ^{ shared##classname = [[classname alloc] init]; }); \
    return shared##classname; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
    return self; \
} \
\
- (id)retain \
{ \
    return self; \
} \
\
- (NSUInteger)retainCount \
{ \
    return NSUIntegerMax; \
} \
\
- (oneway void)release \
{ \
} \
\
- (id)autorelease \
{ \
    return self; \
}

#endif

