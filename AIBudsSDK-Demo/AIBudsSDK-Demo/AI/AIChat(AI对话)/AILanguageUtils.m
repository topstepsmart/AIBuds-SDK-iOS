//
//  AILanguageUtils.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AILanguageUtils.h"

@implementation AILanguageUtils

/**
 * 获取语言的本地化显示名称
 * languageCode: 完整的语言代码，如 "zh-CN"
 * iso6391: ISO 639-1 语言代码，如 "zh"
 * iso3166: ISO 3166-1 国家/地区代码，如 "CN"
 */
+ (NSString *)localizedDisplayNameForLanguageCode:(NSString *)languageCode iso6391:(NSString *)iso6391 iso3166:(NSString *)iso3166
{
    if (!iso6391) {
        return languageCode;
    }
    
    // 构建完整的区域标识符
    NSString *localeIdentifier = languageCode;
    if (iso3166 && iso3166.length > 0) {
        localeIdentifier = [NSString stringWithFormat:@"%@_%@", iso6391, iso3166];
    }
    
    // 使用 NSLocale 获取本地化显示名称
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *displayName = [currentLocale displayNameForKey:NSLocaleIdentifier value:localeIdentifier];
    
    // 如果获取失败，尝试只使用语言代码
    if (!displayName || displayName.length == 0) {
        displayName = [currentLocale displayNameForKey:NSLocaleLanguageCode value:iso6391];
    }
    
    // 如果仍然失败，返回原始代码
    if (!displayName || displayName.length == 0) {
        displayName = languageCode;
    }
    
    return displayName;
}
@end
