//
//  AIChatContext.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIChatContext.h"

NSNotificationName const AIChatDataDidUpdateNotification = @"AIChatDataDidUpdateNotification";
NSNotificationName const AIChatSessionDidStartNotification = @"AIChatSessionDidStartNotification";
NSNotificationName const AIChatSessionDidEndNotification = @"AIChatSessionDidEndNotification";
NSNotificationName const AIChatSessionDidFailNotification = @"AIChatSessionDidFailNotification";
NSNotificationName const AIChatVadDidStartSpeakingNotification = @"VadStartSpeakingNotification";
NSNotificationName const AIChatVadDidEndSpeakingNotification = @"VadEndSpeakingNotification";

@interface AIChatContext ()

@property(nonatomic, strong) NSMutableArray<NSString *> *chatDataOrder;
@property(nonatomic, strong) NSMutableDictionary<NSString *, AIBudsAIChatDataModel *> *latestChatData;

@end

@implementation AIChatContext

+ (instancetype)sharedInstance {
    static AIChatContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AIChatContext alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSpeaking = NO;
        self.settings = [AIChatSettings defaultSettings];
        self.chatDataOrder = [NSMutableArray array];
        self.latestChatData = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)recordChatData:(AIBudsAIChatDataModel *)chatData {
    XLOG_INFO(@"%@", APP_LOG_STRING(@"[ChatData] %@", chatData));
    if (!chatData) {
        return;
    }
    // StarBurst may emit a trailing bookkeeping model with both fields empty.
    // It must not replace the completed turn kept for UI restoration.
    if (chatData.question.length == 0 && chatData.answer.length == 0) {
        return;
    }
    NSString *identifier = chatData.questionId.length > 0
        ? chatData.questionId
        : (chatData.requestId.length > 0
            ? chatData.requestId
            : [NSString stringWithFormat:@"%ld", (long)chatData.sequence]);
    @synchronized (self) {
        if (!self.latestChatData[identifier]) {
            [self.chatDataOrder addObject:identifier];
        }
        self.latestChatData[identifier] = chatData;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AIChatDataDidUpdateNotification object:chatData];
}

- (NSArray<AIBudsAIChatDataModel *> *)chatDataSnapshot {
    @synchronized (self) {
        NSMutableArray<AIBudsAIChatDataModel *> *snapshot = [NSMutableArray arrayWithCapacity:self.chatDataOrder.count];
        for (NSString *identifier in self.chatDataOrder) {
            AIBudsAIChatDataModel *chatData = self.latestChatData[identifier];
            if (chatData) {
                [snapshot addObject:chatData];
            }
        }
        return [snapshot copy];
    }
}

- (void)resetChatDataHistory {
    @synchronized (self) {
        [self.chatDataOrder removeAllObjects];
        [self.latestChatData removeAllObjects];
    }
}
@end
