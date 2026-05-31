//
//  MagicPetConfigModels.h
//  MagicHelper
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 对齐安卓 `SetVoiceResult`，按服务端 JSON 解析常用字段；未知字段可后续扩展。
@interface MagicPetSetVoiceResult : NSObject
@property (nonatomic, copy) NSString *voice;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 对齐安卓 `GetVoiceResult`
@interface MagicPetGetVoiceResult : NSObject
@property (nonatomic, copy) NSString *voice;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 对齐安卓 `VoiceInfo`
@interface MagicPetVoiceInfo : NSObject
@property (nonatomic, copy) NSString *voice;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *voiceDesc;
@property (nonatomic, copy) NSString *sampleUrl;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

@interface MagicPetSetPersonalityResult : NSObject
@property (nonatomic, copy) NSString *personalityCode;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

@interface MagicPetGetPersonalityResult : NSObject
@property (nonatomic, copy) NSString *personalityCode;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 对齐安卓 `PersonalityInfo`
@interface MagicPetPersonalityInfo : NSObject
@property (nonatomic, copy) NSString *personalityCode;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *personalityDesc;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 对齐安卓 `DevicePetConfig`（可为 null：无配置时服务端返回空 data）
@interface MagicDevicePetConfig : NSObject
@property (nonatomic, copy) NSString *voice;
@property (nonatomic, copy) NSString *personalityCode;
+ (nullable instancetype)modelWithDictionary:(nullable NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
