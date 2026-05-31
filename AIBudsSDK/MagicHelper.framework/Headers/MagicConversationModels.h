//
//  MagicConversationModels.h
//  MagicHelper
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 会话列表项（GET /service/conversation/list）
@interface MagicConversationItem : NSObject
@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, copy) NSString *imUserId;
@property (nonatomic, copy) NSString *imAgentId;
@property (nonatomic, copy) NSString *agentId;
@property (nonatomic, copy) NSString *tenantCode;
@property (nonatomic, copy) NSString *deviceSn;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) NSInteger turnCount;
@property (nonatomic, copy) NSString *lastMessageSummary;
@property (nonatomic, assign) int64_t lastMessageTime;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 消息收发方
@interface MagicMessageFromTo : NSObject
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *type;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 历史消息项（字段 id 映射为 messageId）
@interface MagicConversationMessageItem : NSObject
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *bizType;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) int64_t timestamp;
@property (nonatomic, strong, nullable) MagicMessageFromTo *from;
@property (nonatomic, strong, nullable) MagicMessageFromTo *to;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 历史分页结果
@interface MagicConversationHistoryResult : NSObject
@property (nonatomic, copy) NSArray<MagicConversationMessageItem *> *messages;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) int64_t nextCursorId;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

@interface MagicConversationSearchFrom : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *phoneNo;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *userNick;
@property (nonatomic, copy) NSString *userMark;
@property (nonatomic, copy) NSString *userChannel;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

@interface MagicConversationSearchHitExtInfo : NSObject
@property (nonatomic, copy) NSString *msgNonDisturb;
@property (nonatomic, copy) NSString *bizType;
@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, copy) NSString *sdkType;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

@interface MagicConversationSearchHit : NSObject
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *sessionType;
@property (nonatomic, copy) NSString *sessionName;
@property (nonatomic, copy) NSString *sessionAvatar;
@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, copy) NSString *templateCode;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *searchContent;
@property (nonatomic, strong, nullable) MagicConversationSearchFrom *from;
@property (nonatomic, copy) NSString *resourceType;
@property (nonatomic, copy) NSString *resourceName;
@property (nonatomic, copy) NSString *resourceSize;
@property (nonatomic, assign) int64_t timestamp;
@property (nonatomic, strong, nullable) MagicConversationSearchHitExtInfo *extInfo;
@property (nonatomic, strong, nullable) id quotedInfo;
@property (nonatomic, strong, nullable) id quoteReplyInfo;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

@interface MagicConversationSearchResult : NSObject
@property (nonatomic, copy) NSArray<MagicConversationSearchHit *> *hits;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger totalItemCount;
@property (nonatomic, assign) BOOL hasMore;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

@interface MagicConversationChatRecord : NSObject
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) int64_t timestamp;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

@interface MagicConversationDayItem : NSObject
@property (nonatomic, copy) NSString *imAgentId;
@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, copy) NSArray<MagicConversationChatRecord *> *chatRecords;
@property (nonatomic, assign) NSInteger turnCount;
@property (nonatomic, assign) int64_t lastMessageTime;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 对应接口字段 date/total/data/pageNo/pageSize；其中会话列表使用 conversations 表示 data
@interface MagicConversationListByDayResult : NSObject
@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, copy) NSArray<MagicConversationDayItem *> *conversations;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger pageSize;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
