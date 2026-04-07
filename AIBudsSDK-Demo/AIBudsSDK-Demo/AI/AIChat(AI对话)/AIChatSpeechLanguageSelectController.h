//
//  AIChatSpeechLanguageSelectController.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIChatSpeechLanguageSelectController : UIViewController

- (instancetype)initWithSupportedLanguages:(NSArray<NSString *> *)supportedLanguages defaultLanguage:(NSString *)defaultLanguage completion:(void (^)(NSString *))completion;

@end

NS_ASSUME_NONNULL_END
