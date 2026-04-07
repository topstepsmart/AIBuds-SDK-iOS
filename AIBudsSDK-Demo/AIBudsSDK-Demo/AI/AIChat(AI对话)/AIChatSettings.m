//
//  AIChatSettings.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIChatSettings.h"

@implementation AIChatSettings

/// Default settings
+ (instancetype)defaultSettings {
    AIChatSettings *settings = [[AIChatSettings alloc] init];
    settings.serviceVendor = AIBudsAIServiceVendorStarBurst;
    settings.sessionCfg = [AIBudsAIChatSessionConfig defaultConfig];
    NSMutableDictionary *mutableOptions = [settings.sessionCfg.additionalOptions mutableCopy] ?: [NSMutableDictionary dictionary];
    mutableOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstAgentId] =  @"ZNT002";
    mutableOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstSpeakerId] =  @"zh_female_tianmeitaozi_mars_bigtts";
    settings.sessionCfg.additionalOptions = [mutableOptions copy];
    return settings;
}

/// Copy settings
- (instancetype)copyWithZone:(NSZone *)zone {
    AIChatSettings *copy = [[AIChatSettings alloc] init];
    copy.serviceVendor = self.serviceVendor;
    copy.sessionCfg = [self.sessionCfg copy];
    return copy;
}
@end
