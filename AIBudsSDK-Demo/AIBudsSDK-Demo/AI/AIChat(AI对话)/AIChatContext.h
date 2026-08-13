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

@class AIBudsAIChatDataModel;

FOUNDATION_EXPORT NSNotificationName const AIChatDataDidUpdateNotification;
FOUNDATION_EXPORT NSNotificationName const AIChatSessionDidStartNotification;
FOUNDATION_EXPORT NSNotificationName const AIChatSessionDidEndNotification;
FOUNDATION_EXPORT NSNotificationName const AIChatSessionDidFailNotification;
FOUNDATION_EXPORT NSNotificationName const AIChatVadDidStartSpeakingNotification;
FOUNDATION_EXPORT NSNotificationName const AIChatVadDidEndSpeakingNotification;

@interface AIChatContext : NSObject

@property(nonatomic, assign) BOOL isSpeaking;

@property(nonatomic, strong) AIChatSettings *settings;

@property(nonatomic, weak) id<AIBudsAIChatSessionConvertible> currentSession;

/// Records the latest streaming value for each question so a chat screen opened
/// after the callback can still restore the active conversation.
- (void)recordChatData:(AIBudsAIChatDataModel *)chatData;

/// Returns the current conversation in question order.
- (NSArray<AIBudsAIChatDataModel *> *)chatDataSnapshot;

/// Clears messages from the previous session.
- (void)resetChatDataHistory;

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
