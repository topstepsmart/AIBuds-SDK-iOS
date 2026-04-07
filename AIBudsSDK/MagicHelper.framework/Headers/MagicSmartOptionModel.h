//
//  MagicSmartOptionModel.h
//  MagicHelper
//
//  Created by ymz on 2025/9/19.
//

#import <Foundation/Foundation.h>
#import "AILanguageCodeUtil.h"

NS_ASSUME_NONNULL_BEGIN

/// 智能体code
typedef NS_ENUM(NSInteger, MagicLLMCode) {
    /// 眼镜
    MagicLLMCodeGlass = 0,
    /// 玩具
    MagicLLMCodeToy,
};

@interface SmartOptionExt: NSObject

///当前经纬度
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

/// 经纬度对应的地址
@property (nonatomic, strong) NSString *address;
@end

@interface MagicSmartOptionModel : NSObject

/// 语言，默认中文（zn-CH）
@property (nonatomic, strong) NSString *language;

///输入音频格式，默认pcm
@property (nonatomic, strong) NSString *input_audio_format;

///输出音频格式，默认pcm
@property (nonatomic, strong) NSString *output_audio_format;

///ASR类型, 默认aliyun
@property (nonatomic, strong) NSString *asr_type;

///是否开启vad, 默认开启YES
@property (nonatomic, assign) BOOL enable_vad;

///最大静默时长单位ms, 默认600
@property (nonatomic, assign) NSInteger max_sentence_silence;

///tts类型, 默认aliyun
@property (nonatomic, strong) NSString *tts_type;

///音色, 默认siyue
@property (nonatomic, strong) NSString *voice;

///音量, 默认50, 范围0~100, 可设置
@property (nonatomic, assign) NSInteger volume;

///音调, 默认0, 范围0~100, 可设置
@property (nonatomic, assign) NSInteger pitch_rate;

///语速, 默认0, 范围0~100, 可设置
@property (nonatomic, assign) NSInteger speech_rate;

///是否开启联网搜索, 默认开启YES
@property (nonatomic, assign) BOOL enable_search;

///智能体配置code, 默认3
@property (nonatomic, strong) NSString *llm_chat_code;

///视觉智能体code, 默认4
@property (nonatomic, strong) NSString *vllm_chat_code;

///是否开启意图识别, 默认开启YES
@property (nonatomic, assign) BOOL enable_intent;

///意图版本, 默认v4
@property (nonatomic, strong) NSString *intent_version;

///意图配置code, 默认basic_intent_config
@property (nonatomic, strong) NSString *intentConfigCode;

/// 额外参数
@property (nonatomic, strong, nullable) SmartOptionExt *ext;

/// 构建model
/// - Parameters:
///   - language: 语言code
///   - voice: 语言对应的音色，不传会使用默认的
///   - intentConfigCode: 意图配置code, 默认basic_intent_config
///   - llmCode: 智能体code
+ (MagicSmartOptionModel *)generateModelWithLanguage:(AILanguageCode)language
                                               voice:(nullable NSString *)voice
                                    intentConfigCode:(nullable NSString *)intentConfigCode
                                             llmCode:(MagicLLMCode)llmCode;

@end

NS_ASSUME_NONNULL_END
