//
//  AIChatSettingsController.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIChatSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface AIChatSettingsController : UIViewController

/// Initialize settings controller
- (instancetype)initWithSettings:(AIChatSettings *)settings;

@end

NS_ASSUME_NONNULL_END
