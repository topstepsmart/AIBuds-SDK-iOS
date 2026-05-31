//
//  SimultaneousInterpretationContext.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-05-25.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "SimultaneousInterpretationContext.h"

@implementation SimultaneousInterpretationContext

+ (instancetype)sharedInstance {
    static SimultaneousInterpretationContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SimultaneousInterpretationContext alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
