//
//  AIChatSettingsController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIChatSettingsController.h"
#import "AIChatContext.h"
#import "AIFeatureContext.h"
#import "AILanguageUtils.h"
#import "AIChatSpeechLanguageSelectController.h"

@interface AIChatSettingsController () <UITableViewDelegate, UITableViewDataSource>

/// Settings model
@property (nonatomic, strong) AIChatSettings *settings;

/// Table view
@property (nonatomic, strong) UITableView *tableView;

/// 服务商选择控件
@property (nonatomic, strong) UISegmentedControl *vendorSegmentedControl;

/// 语音通道选择控件
@property (nonatomic, strong) UISegmentedControl *audioChannelSegmentedControl;

/// 打断 AI 应答开关
@property (nonatomic, strong) UISwitch *interruptSwitch;

/// 语音播放开关
@property (nonatomic, strong) UISwitch *voicePlaybackSwitch;

/// 保存语音调试开关
@property (nonatomic, strong) UISwitch *saveVoiceSwitch;

/// 星芒 AI 使用计划选择控件
@property (nonatomic, strong) UISegmentedControl *starBurstPlanSegmentedControl;

@end

@implementation AIChatSettingsController

+ (NSArray<NSNumber *> *) availableAIVendorKeys {
    return @[@(AIBudsAIServiceVendorStarBurst), @(AIBudsAIServiceVendorMltcloud)];
}

+ (NSDictionary<NSNumber *, NSString *> *) availableAIVendorDictionary {
    return @{
        @(AIBudsAIServiceVendorStarBurst) : NSLocalizedString(@"LocKey.StarBurstAI", nil),
        @(AIBudsAIServiceVendorMltcloud) : NSLocalizedString(@"LocKey.MLTCloudAI", nil),
    };
}

+ (NSArray<NSString *> *) availableAIVendorNames {
    NSMutableArray<NSString *> *vendorNames = [NSMutableArray array];
    for (NSNumber *vendorKey in [AIChatSettingsController availableAIVendorKeys]) {
        [vendorNames addObject:[AIChatSettingsController availableAIVendorDictionary][vendorKey]];
    }
    return vendorNames;
}

+ (NSArray<NSNumber *> *) availableAIAudioChannelKeys {
    return @[@(AIBudsAIChatAudioChannelSco),
             @(AIBudsAIChatAudioChannelOpusInA2dpOut),
             //@(AIBudsAIChatAudioChannelOpusInOpusOut)
           ];
}

+ (NSDictionary<NSNumber *, NSString *> *) availableAIAudioChannelDictionary {
    return @{
        @(AIBudsAIChatAudioChannelSco) : NSLocalizedString(@"LocKey.AiAudioChannelSco", nil),
        @(AIBudsAIChatAudioChannelOpusInA2dpOut) : NSLocalizedString(@"LocKey.AiAudioChannelOpusInA2dpOut", nil),
        @(AIBudsAIChatAudioChannelOpusInOpusOut) : NSLocalizedString(@"LocKey.AiAudioChannelOpusInOpusOut", nil),
    };
}

+ (NSArray<NSString *> *) availableAIAudioChannelNames {
    NSMutableArray<NSString *> *audioChannelNames = [NSMutableArray array];
    for (NSNumber *audioChannelKey in [AIChatSettingsController availableAIAudioChannelKeys]) {
        [audioChannelNames addObject:[AIChatSettingsController availableAIAudioChannelDictionary][audioChannelKey]];
    }
    return audioChannelNames;
}

+ (NSArray<NSString*>*) availableStarBurstUsagePlans {
    return @[@"lite", @"pro"];
}

+ (NSDictionary<NSString*, NSString*>*) availableStarBurstUsagePlanDictionary {
    return @{
        @"lite" : NSLocalizedString(@"LocKey.StarBurstLitePlan", nil),
        @"pro" : NSLocalizedString(@"LocKey.StarBurstProPlan", nil),
    };
}

+ (NSArray<NSString*>*) availableStarBurstUsagePlanNames {
    NSMutableArray<NSString*> *planNames = [NSMutableArray array];
    for (NSString *plan in [AIChatSettingsController availableStarBurstUsagePlans]) {
        [planNames addObject:[AIChatSettingsController availableStarBurstUsagePlanDictionary][plan]];
    }
    return planNames;
}

+(NSArray<NSString*>*) starBurstSupportedSpeechLanguages {
    return @[
        @"zh-CN",
        @"en-US",
        @"ja-JP",
        @"ko-KR",
        @"fr-FR",
        @"es-MX",
        @"pt-BR",
        @"id-ID",
        @"ms-MY",
        @"de-DE",
        @"fil-PH",
        @"th-TH",
        @"ar-SA",
        @"vi",
        @"ru-RU",
        @"ru",
        @"da",
        @"el",
        @"fi",
        @"he",
        @"hi",
        @"it",
        @"nl",
        @"no",
        @"pl",
        @"sv",
        @"sw",
        @"tr"
    ];
}

+(NSArray<NSString*>*) supportedSpeechLanguagesForVendor:(AIBudsAIServiceVendor)vendor {
    switch (vendor) {
        case AIBudsAIServiceVendorStarBurst:
            return [AIChatSettingsController starBurstSupportedSpeechLanguages];
        case AIBudsAIServiceVendorMltcloud:
            return @[];
        default:
            return @[];
    }
}



/// Initialize settings controller
- (instancetype)initWithSettings:(AIChatSettings *)settings {
    self = [super init];
    if (self) {
        self.settings = [settings copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.ChatSettingsTitle", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupNavigationBar];
    [self setupTableView];
}

- (void)setupNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LocKey.Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveSettings)];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3; // 服务商选择、通用设置、AI 特有设置
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: // 服务商选择
            return 1;
        case 1: // 通用设置
            return 7;
        case 2: // AI 特有设置
            {
                AIBudsAIServiceVendor vendor = self.settings.serviceVendor;
                switch (vendor) {
                    case AIBudsAIServiceVendorStarBurst:
                        return 3;
                    case AIBudsAIServiceVendorMltcloud:
                        return 0;
                    default:
                        return 0;
                }
            }
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"LocKey.ServiceVendor", nil);
        case 1:
            return NSLocalizedString(@"LocKey.GeneralSettings", nil);
        case 2:
            {
                AIBudsAIServiceVendor vendor = self.settings.serviceVendor;
                switch (vendor) {
                    case AIBudsAIServiceVendorStarBurst:
                        return NSLocalizedString(@"LocKey.StarBurstSettings", nil);
                    case AIBudsAIServiceVendorMltcloud:
                        return nil;//NSLocalizedString(@"LocKey.MLTCloudSettings", nil);
                    default:
                        return nil;
                }
            }
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryView = nil;
    
    switch (indexPath.section) {
        case 0: {
            // 服务商选择
            cell.textLabel.text = NSLocalizedString(@"LocKey.SelectServiceVendor", nil);
            NSArray<NSNumber*>* vendorKeys = [AIChatSettingsController availableAIVendorKeys];
            NSInteger selectedIndex = [vendorKeys indexOfObject:@(self.settings.serviceVendor)];
            self.vendorSegmentedControl = [[UISegmentedControl alloc] initWithItems:[AIChatSettingsController availableAIVendorNames]];
            self.vendorSegmentedControl.selectedSegmentIndex = selectedIndex;
            [self.vendorSegmentedControl addTarget:self action:@selector(vendorChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.vendorSegmentedControl;
            break;
        }
        case 1: {
            // 通用设置
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.LanguageForSpeechInput", nil);
                    NSString* languageName = NSLocalizedString(@"LocKey.NotSet", nil);
                    NSString* languageCode = self.settings.sessionCfg.languageForSpeechInput;
                    if (languageCode.length > 0) {
                        NSArray *components = [languageCode componentsSeparatedByString:@"-"];
                        NSString *iso6391 = components.firstObject;
                        NSString *iso3166 = components.count > 1 ? components[1] : nil;
                        languageName = [NSString stringWithFormat:@"%@(%@)", [AILanguageUtils localizedDisplayNameForLanguageCode:languageCode iso6391:iso6391 iso3166:iso3166], languageCode];
                    }
                    cell.detailTextLabel.text = languageName;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.AiAudioChannel", nil);

                    NSArray<NSNumber*>* audioChannelKeys = [AIChatSettingsController availableAIAudioChannelKeys];
                    NSInteger selectedIndex = [audioChannelKeys indexOfObject:@(self.settings.sessionCfg.audioChannel)];
                    self.audioChannelSegmentedControl = [[UISegmentedControl alloc] initWithItems:[AIChatSettingsController availableAIAudioChannelNames]];
                    self.audioChannelSegmentedControl.selectedSegmentIndex = selectedIndex;
                    [self.audioChannelSegmentedControl addTarget:self action:@selector(audioChannelChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = self.audioChannelSegmentedControl;
                    break;
                }
                case 2: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.AllowInterruptAiAnswer", nil);
                    self.interruptSwitch = [[UISwitch alloc] init];
                    self.interruptSwitch.on = self.settings.sessionCfg.allowUserToInterruptAIResponse;
                    [self.interruptSwitch addTarget:self action:@selector(interruptChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = self.interruptSwitch;
                    break;
                }
                case 3: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.MaxPauseDuration", nil);
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1fs", self.settings.sessionCfg.maxPauseDurationBeforeAIResponds];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    break;
                }
                case 4: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.AutoEndSessionDuration", nil);
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0fs", self.settings.sessionCfg.autoEndSessionAfterNoInputDuration];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    break;
                }
                case 5: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.VoiceBroadcast", nil);
                    self.voicePlaybackSwitch = [[UISwitch alloc] init];
                    self.voicePlaybackSwitch.on = self.settings.sessionCfg.enableVoicePlayback;
                    [self.voicePlaybackSwitch addTarget:self action:@selector(voicePlaybackChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = self.voicePlaybackSwitch;
                    break;
                }
                case 6: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.SaveInputVoiceForDebugging", nil);
                    self.saveVoiceSwitch = [[UISwitch alloc] init];
                    self.saveVoiceSwitch.on = self.settings.sessionCfg.shouldSaveInputVoiceForDebugging;
                    [self.saveVoiceSwitch addTarget:self action:@selector(saveVoiceChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = self.saveVoiceSwitch;
                    break;
                }
            }
            break;
        }
        case 2: {
            // 星芒 AI 特有设置
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.StarBurstUsagePlan", nil);
                    NSString *plan = self.settings.sessionCfg.additionalOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstUsagePlan];
                    if (!plan) {
                        plan = @"pro";
                    }
                    NSArray<NSString*>* availablePlans = [AIChatSettingsController availableStarBurstUsagePlans];
                    NSUInteger selectedIndex = [availablePlans indexOfObject:plan];
                    self.starBurstPlanSegmentedControl = [[UISegmentedControl alloc] initWithItems:[AIChatSettingsController availableStarBurstUsagePlanNames]];
                    self.starBurstPlanSegmentedControl.selectedSegmentIndex = selectedIndex;
                    [self.starBurstPlanSegmentedControl addTarget:self action:@selector(starBurstPlanChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = self.starBurstPlanSegmentedControl;
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.StarBurstAgentId", nil);
                    NSString *agentId = self.settings.sessionCfg.additionalOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstAgentId];
                    if (!agentId) {
                        agentId = NSLocalizedString(@"LocKey.NotSet", nil);
                    }
                    cell.detailTextLabel.text = agentId;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    break;
                }
                case 2: {
                    cell.textLabel.text = NSLocalizedString(@"LocKey.StarBurstSpeakerId", nil);
                    NSString *speakerId = self.settings.sessionCfg.additionalOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstSpeakerId];
                    if (!speakerId) {
                        speakerId = NSLocalizedString(@"LocKey.NotSet", nil);
                    }
                    cell.detailTextLabel.text = speakerId;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    break;
                }
            }
            break;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString* languageCode = self.settings.sessionCfg.languageForSpeechInput;
            NSArray<NSString*>* supportedLanguages = [AIChatSettingsController supportedSpeechLanguagesForVendor:self.settings.serviceVendor];
            __weak typeof(self) weakSelf = self;
            AIChatSpeechLanguageSelectController* selectVC = [[AIChatSpeechLanguageSelectController alloc] initWithSupportedLanguages:supportedLanguages defaultLanguage:languageCode completion:^(NSString * _Nonnull languageCode) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf.settings.sessionCfg.languageForSpeechInput = languageCode;
                [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
            [self.navigationController pushViewController:selectVC animated:YES];
        }
        else if (indexPath.row == 3) {
            // 最大停顿时长调整
            [self showDurationPickerWithTitle:NSLocalizedString(@"LocKey.MaxPauseDuration", nil) 
                                     currentValue:self.settings.sessionCfg.maxPauseDurationBeforeAIResponds 
                                          step:0.1 
                                    completion:^(CGFloat value) {
                self.settings.sessionCfg.maxPauseDurationBeforeAIResponds = value;
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        } else if (indexPath.row == 4) {
            // 自动结束对话时长调整
            [self showDurationPickerWithTitle:NSLocalizedString(@"LocKey.AutoEndSessionDuration", nil) 
                                     currentValue:self.settings.sessionCfg.autoEndSessionAfterNoInputDuration 
                                          step:1.0 
                                    completion:^(CGFloat value) {
                self.settings.sessionCfg.autoEndSessionAfterNoInputDuration = value;
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    }
    else if (indexPath.section == 2) {
        // 星芒 AI 特有设置
        if (indexPath.row == 1) {
            // 角色 ID 调整
            [self showTextFieldWithTitle:NSLocalizedString(@"LocKey.StarBurstAgentId", nil)
                                currentValue:self.settings.sessionCfg.additionalOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstAgentId]
                                    completion:^(NSString *agentId) {
                                        if ([agentId isKindOfClass:[NSString class]]
                                            && [agentId length] > 0) {
                                            NSMutableDictionary *mutableOptions = [self.settings.sessionCfg.additionalOptions mutableCopy] ?: [NSMutableDictionary dictionary];
                                            mutableOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstAgentId] = agentId;
                                            self.settings.sessionCfg.additionalOptions = [mutableOptions copy];
                                        }
                                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                    }];
        }
        else if (indexPath.row == 2) {
            // 音色 ID 调整
            [self showTextFieldWithTitle:NSLocalizedString(@"LocKey.StarBurstSpeakerId", nil) 
                                currentValue:self.settings.sessionCfg.additionalOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstSpeakerId] 
                                    completion:^(NSString *speakerId) {
                                        if ([speakerId isKindOfClass:[NSString class]]
                                            && [speakerId length] > 0) {
                                            NSMutableDictionary *mutableOptions = [self.settings.sessionCfg.additionalOptions mutableCopy] ?: [NSMutableDictionary dictionary];
                                            mutableOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstSpeakerId] = speakerId;
                                            self.settings.sessionCfg.additionalOptions = [mutableOptions copy];
                                        }
                                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                    }];
        }   
    }
}

#pragma mark - Actions

- (void)vendorChanged:(UISegmentedControl *)sender {
    NSArray<NSNumber*>* vendorKeys = [[self class] availableAIVendorKeys];
    NSUInteger selectedIndex = sender.selectedSegmentIndex;
    if ([vendorKeys count] > selectedIndex) {
        self.settings.serviceVendor = (AIBudsAIServiceVendor)[[vendorKeys objectAtIndex:selectedIndex] integerValue];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)audioChannelChanged:(UISegmentedControl *)sender {
    NSArray<NSNumber*>* audioChannelKeys = [AIChatSettingsController availableAIAudioChannelKeys];
    NSUInteger selectedIndex = sender.selectedSegmentIndex;
    if ([audioChannelKeys count] > selectedIndex) {
        self.settings.sessionCfg.audioChannel = (AIBudsAIChatAudioChannel)[[audioChannelKeys objectAtIndex:selectedIndex] integerValue];
    }
}

- (void)interruptChanged:(UISwitch *)sender {
    self.settings.sessionCfg.allowUserToInterruptAIResponse = sender.on;
}

- (void)voicePlaybackChanged:(UISwitch *)sender {
    self.settings.sessionCfg.enableVoicePlayback = sender.on;
}

- (void)saveVoiceChanged:(UISwitch *)sender {
    self.settings.sessionCfg.shouldSaveInputVoiceForDebugging = sender.on;
}

- (void)starBurstPlanChanged:(UISegmentedControl *)sender {
    NSArray<NSString*>* availablePlans = [AIChatSettingsController availableStarBurstUsagePlans];
    NSUInteger selectedIndex = sender.selectedSegmentIndex;
    if ([availablePlans count] > selectedIndex) {
        NSString *plan = [availablePlans objectAtIndex:selectedIndex];
        NSMutableDictionary *mutableOptions = [self.settings.sessionCfg.additionalOptions mutableCopy];
        if (!mutableOptions) {
            mutableOptions = [NSMutableDictionary dictionary];
        }
        mutableOptions[AIBudsAIChatSessionConfig.AdditionalOptionKeyStarburstUsagePlan] = plan;
        self.settings.sessionCfg.additionalOptions = [mutableOptions copy];
    }
}

- (void)saveSettings {
    
    AIChatContext *context = [AIChatContext sharedInstance];
    if (context.settings.serviceVendor != self.settings.serviceVendor) {
        context.settings.serviceVendor = self.settings.serviceVendor;
        [AIFeatureContext sharedInstance].serviceVendor = context.settings.serviceVendor;
        [AIBudsAISDK setAIServiceVendor:context.settings.serviceVendor];
        
        AIBudsAIDeviceInfoModel* deviceInfo = [AIBudsAISDK deviceInfo];
        if([deviceInfo isKindOfClass:[AIBudsAIDeviceInfoModel class]])
        {
            AIBudsAIServiceVendor aiServiceVendor = [AIFeatureContext sharedInstance].serviceVendor;
            if([AIBudsAISDK authenticationModeForVendor:aiServiceVendor] == AIBudsAIAuthenticationModeAppInitiated
               && ![AIBudsAISDK isAuthenticatedForVendor:aiServiceVendor]) {
                [AIBudsAISDK authenticateDevice:deviceInfo completion:^(BOOL isSuccess, NSError * _Nullable error) {
                    if([error isKindOfClass:[NSError class]])
                    {
                        XLOG_ERROR(@"%@", APP_LOG_STRING(@"AI 鉴权失败(vendor = %@)：%@", @(aiServiceVendor), error));
                        return;
                    }
                    XLOG_INFO(@"%@", APP_LOG_STRING(@"AI 鉴权成功(vendor = %@)。", @(aiServiceVendor)));
                }];
            }
        }
        else
        {
            XLOG_ERROR(@"%@", APP_LOG_STRING(@"设备信息为空，可能设备尚未连接成功。"));
        }
    }
    context.settings.sessionCfg.languageForSpeechInput = self.settings.sessionCfg.languageForSpeechInput;
    context.settings.sessionCfg.audioChannel = self.settings.sessionCfg.audioChannel;
    context.settings.sessionCfg.allowUserToInterruptAIResponse = self.settings.sessionCfg.allowUserToInterruptAIResponse;
    context.settings.sessionCfg.enableVoicePlayback = self.settings.sessionCfg.enableVoicePlayback;
    context.settings.sessionCfg.shouldSaveInputVoiceForDebugging = self.settings.sessionCfg.shouldSaveInputVoiceForDebugging;
    context.settings.sessionCfg.additionalOptions = self.settings.sessionCfg.additionalOptions;
    context.settings.sessionCfg.maxPauseDurationBeforeAIResponds = self.settings.sessionCfg.maxPauseDurationBeforeAIResponds;
    context.settings.sessionCfg.autoEndSessionAfterNoInputDuration = self.settings.sessionCfg.autoEndSessionAfterNoInputDuration;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Methods

- (void)showDurationPickerWithTitle:(NSString *)title 
                       currentValue:(CGFloat)currentValue 
                               step:(CGFloat)step 
                         completion:(void (^)(CGFloat value))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title 
                                                                   message:nil 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.text = [NSString stringWithFormat:@"%.1f", currentValue];
        textField.placeholder = NSLocalizedString(@"LocKey.EnterValue", nil);
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ConfirmLocKey", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        CGFloat value = [textField.text floatValue];
        if (value > 0) {
            if (completion) {
                completion(value);
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showTextFieldWithTitle:(NSString *)title 
                          currentValue:(NSString *)currentValue 
                         completion:(void (^)(NSString *value))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title 
                                                                   message:nil 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = currentValue;
        textField.placeholder = NSLocalizedString(@"LocKey.EnterTextValue", nil);
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ConfirmLocKey", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        if (textField.text.length > 0) {
            if (completion) {
                completion(textField.text);
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
