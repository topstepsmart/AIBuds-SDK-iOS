//
//  MagicSpeechSession.h
//  MagicHelper
//
//  Created by ymz on 2025/7/16.
//

#import <Foundation/Foundation.h>
#import "MagicSmartOptionModel.h"
#import "MagicMemoryData.h"

NS_ASSUME_NONNULL_BEGIN

/// 音频格式
typedef NS_ENUM(NSInteger, MagicAudioType) {
    MagicAudioTypePcm,
    MagicAudioTypeOpus
};

/// 音频输入模式
typedef NS_ENUM(NSInteger, MGAudioInputMode) {
    /// 手动控制输入开始 / 结束 (对应startSpeech -> sendSpeechAudioData -> endSpeech)
    MGAudioInputModeManual = 0,
    /// 持续输入音频
    MGAudioInputModeContinuous = 1,
};

typedef NS_ENUM(NSInteger, MGVADState) {
    /// 初始状态
    MGVADStateSpeechNone = 0,
    /// VAD 检测到语音开始
    MGVADStateSpeechStart = 1,
    /// VAD 检测到语音结束
    MGVADStateSpeechEnd = 2
};


@protocol MagicRecognitionSessionDelegate<NSObject>

@optional
/// 意图理解回调
- (void)onIntentionAction:(NSString *)type params:(NSDictionary *)params;

/// 文本回调
- (void)onMessage:(NSDictionary *)message;
/// 文本回调结束
- (void)onMessageFinished:(NSDictionary *)message;

/// 音频数据回调
- (void)onAudioData:(NSData *)audioData;
/// 音频数据回调结束
- (void)onAudioDataFinished:(NSDictionary *)message;

/// VAD识别结束（检测到用户停止说话，建议停止发送音频）
- (void)onVADCompleted;

/// webSocket开启回调
- (void)onOpen;
/// WebSocket关闭回调
- (void)onClosed:(NSString *)reason;
/// WebSocket错误回调
- (void)onFailure:(NSString *)reason;

/// VAD 状态变化回调（开始 / 结束）
/// 该方法只会在MGAudioInputModeContinuous模式有效
- (void)onVADStateChanged:(MGVADState)state
                timestamp:(NSTimeInterval)timestamp;

/// 定位点的字符串表示
///
/// 格式： "latitude,longitude"
///
/// 说明：
/// - 使用英文逗号 `,` 分隔，不包含空格
/// - 若定位信息不存在或无效，返回 nil
///
/// 示例：
///   "31.230416,121.473701"
///
- (nullable NSString *)locationAction;
/// 经纬度对应的地址
- (nullable NSString *)addressAction;

@end


@interface MagicRecognitionSession : NSObject

@property (nonatomic, weak) id<MagicRecognitionSessionDelegate> delegate;

/// websocket是否连接
@property (nonatomic, assign, readonly) BOOL isConnected;

/// 是否需要vad, 默认YES
@property (nonatomic, assign) BOOL needVAD;

/// 连续静音达到多少毫秒判定结束，默认1500ms
@property (nonatomic, assign) NSInteger silenceTriggerDurationMs;

/// 静默时长，默认10s, needVAD = YES有效
/// 从开始传输音频到超过时长还未检测出声音，则触发vad
@property (nonatomic, assign) NSInteger silenceTimeout;

/// 获取支持的configCode
- (NSArray *)getSmartConfigModels;

/// 创建会话
- (void)createSession:(nullable NSDictionary *)ext  __attribute__((deprecated("请使用 createSessionWithConfigCode:ext 替代")));

/// 创建会话
/// configCode: 控制模型，不设置使用默认的，可通过getSmartConfigModels获取
/// online_search_bailian： 带意图版本
/// online_search_bailian_no_intent：不带意图
/// ext: "{\"extKey\":\"extValue\"}" // Session级别扩展字段
- (void)createSessionWithConfigCode:(nullable NSString *)configCode ext:(nullable NSDictionary *)ext  __attribute__((deprecated("请使用 createSessionWithConfigCode:model:ext 替代")));

/// 创建会话
- (void)createSessionWithConfigCode:(nullable NSString *)configCode model:(nullable MagicSmartOptionModel *)model ext:(nullable NSDictionary *)ext;


/// 开始语音对话
- (void)startSpeech:(MagicAudioType)type __attribute__((deprecated("请使用 startSpeechWithMode:mode 替代")));

/// 开始语音对话
- (void)startSpeechWithMode:(MGAudioInputMode)mode;

/// 发送音频数据
- (void)sendSpeechAudioData:(NSData *)data;

/// 发送结束帧
- (void)endSpeech;

/// 中断对话
- (void)closeSpeech;

/// 关闭整个会话（WebSocket）
- (void)stopSession;

/// 主动发起图片识图/翻译等文本任务
/// type: 拍照识图、翻译(visual_qa)
/// params : {
///"prompt": "这是什么植物？",
///"images": [
///           {"type":"base64","value":"${image base64}"}
///           ]
///}
///注意： 图片要小于5M
- (void)requestToRespondWithType:(NSString *)intentType
                          params:(NSDictionary *)params;


/// 开始多模态图文输入流程（图文传输起始点）
/// 调用顺序：startMultimodalQAIput -> requestToRespondWithType -> startSpeech -> endSpeech -> commitMultimodalQAIput
- (void)startMultimodalQAIput;

/// 提交多模态图文输入（结束图文传输流程）
- (void)commitMultimodalQAIput;

/// 获取configcode列表
- (NSArray *)queryConfigCodeList;

/// 输入文本开启对话
- (void)commitText:(NSString *)text;

#pragma mark - 记忆 (Memory)

/// 记忆类型：fact-事实, card-卡证, order-订单
typedef NSString * MagicMemoryType NS_STRING_ENUM;
///事实类记忆，如⽤户偏好、设备状态等
FOUNDATION_EXPORT MagicMemoryType const MagicMemoryTypeFact;
///卡证类记忆，如身份证、银⾏卡信息
FOUNDATION_EXPORT MagicMemoryType const MagicMemoryTypeCard;
///订单类记忆，如购物记录、服务订单
FOUNDATION_EXPORT MagicMemoryType const MagicMemoryTypeOrder;

/// 记忆来源：dialogue-对话, image-图像, page-页面
typedef NSString * MagicMemorySource NS_STRING_ENUM;
///来自ai对话
FOUNDATION_EXPORT MagicMemorySource const MagicMemorySourceDialogue;
///来自图片识别
FOUNDATION_EXPORT MagicMemorySource const MagicMemorySourceImage;
///来自用户创建
FOUNDATION_EXPORT MagicMemorySource const MagicMemorySourcePage;

/// 添加记忆
- (void)addMemoryWithTopic:(NSString *)topic
                   content:(NSString *)content
                      type:(MagicMemoryType)type
                    source:(MagicMemorySource)source
                 onSuccess:(void (^)(NSString *memoryId))onSuccess
                   onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 编辑记忆
- (void)editeMemoryWithMemoryId:(NSString *)memoryId
                         topic:(NSString *)topic
                       content:(NSString *)content
                     onSuccess:(void (^)(void))onSuccess
                       onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 删除记忆
- (void)deleteMemoryWithMemoryId:(NSString *)memoryId
                       onSuccess:(void (^)(void))onSuccess
                         onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 拉取记忆列表，list 元素为 MagicMemoryData
- (void)fetchMemoryWithSource:(nullable MagicMemorySource)source
                         type:(nullable MagicMemoryType)type
                     pageNum:(NSInteger)pageNum
                    pageSize:(NSInteger)pageSize
                   onSuccess:(void (^)(NSArray<MagicMemoryData *> *list))onSuccess
                     onError:(void (^)(NSString *msg, NSInteger code))onError;

@end

NS_ASSUME_NONNULL_END

