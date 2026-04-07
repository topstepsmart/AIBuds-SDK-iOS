//
//  AILanguageUtils.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AILanguageUtils : NSObject

/**
 * 获取语言的本地化显示名称
 * languageCode: 完整的语言代码，如 "zh-CN"
 * iso6391: ISO 639-1 语言代码，如 "zh"
 * iso3166: ISO 3166-1 国家/地区代码，如 "CN"
 */
+ (NSString *)localizedDisplayNameForLanguageCode:(NSString *)languageCode iso6391:(NSString *)iso6391 iso3166:(NSString *)iso3166;

@end

NS_ASSUME_NONNULL_END
