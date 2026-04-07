//
//  AIChatContext.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIChatContext.h"

@implementation AIChatContext

+ (instancetype)sharedInstance {
    static AIChatContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AIChatContext alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSpeaking = NO;
        self.settings = [AIChatSettings defaultSettings];
    }
    return self;
}
@end
