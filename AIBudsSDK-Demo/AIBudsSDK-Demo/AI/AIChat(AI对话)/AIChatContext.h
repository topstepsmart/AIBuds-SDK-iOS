//
//  AIChatContext.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIChatSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface AIChatContext : NSObject

@property(nonatomic, assign) BOOL isSpeaking;

@property(nonatomic, strong) AIChatSettings *settings;

@property(nonatomic, weak) id<AIBudsAIChatSessionConvertible> currentSession;

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
