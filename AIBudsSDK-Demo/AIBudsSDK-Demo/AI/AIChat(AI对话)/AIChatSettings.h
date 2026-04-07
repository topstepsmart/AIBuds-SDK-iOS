//
//  AIChatSettings.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIChatSettings : NSObject <NSCopying>

/// Service vendor
@property(nonatomic, assign) AIBudsAIServiceVendor serviceVendor;

/// Session configuration
@property(nonatomic, strong) AIBudsAIChatSessionConfig *sessionCfg;

/// Default settings
+ (instancetype)defaultSettings;

@end

NS_ASSUME_NONNULL_END
