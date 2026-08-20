//
//  ConversationTranslationContext.h
//  AIBudsSDK-Demo
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Holds the active conversation-translation session that consumes device-side PCM audio.
@interface ConversationTranslationContext : NSObject

@property (nonatomic, weak, nullable) id<AIBudsSimultaneousInterpretationSessionConvertible> currentSession;

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
