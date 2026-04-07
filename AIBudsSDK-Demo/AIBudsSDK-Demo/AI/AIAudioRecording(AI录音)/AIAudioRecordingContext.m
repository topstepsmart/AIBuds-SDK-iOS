//
//  AIAudioRecordingContext.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIAudioRecordingContext.h"

@implementation AIAudioRecordingContext

+ (instancetype)sharedInstance {
    static AIAudioRecordingContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AIAudioRecordingContext alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentSession = nil;
    }
    return self;
}

@end
