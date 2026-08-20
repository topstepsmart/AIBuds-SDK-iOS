//
//  ConversationTranslationContext.m
//  AIBudsSDK-Demo
//

#import "ConversationTranslationContext.h"

@implementation ConversationTranslationContext

+ (instancetype)sharedInstance {
    static ConversationTranslationContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ConversationTranslationContext alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    return [super init];
}

@end
