//
//  AIFeatureContext.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIFeatureContext.h"

@implementation AIFeatureContext

+ (instancetype)sharedInstance {
    static AIFeatureContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AIFeatureContext alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serviceVendor = AIBudsAIServiceVendorStarBurst;
    }
    return self;
}

@end
