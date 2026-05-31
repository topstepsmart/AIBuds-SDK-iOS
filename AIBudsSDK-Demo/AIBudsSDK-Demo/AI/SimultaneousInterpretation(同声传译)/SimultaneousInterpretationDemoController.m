//
//  SimultaneousInterpretationDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "SimultaneousInterpretationDemoController.h"
#import "SimultaneousInterpretationContext.h"

@interface SimultaneousInterpretationDemoController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *sourceLanguagePicker;
@property (nonatomic, strong) UIPickerView *targetLanguagePicker;
@property (nonatomic, strong) UIButton *swapLanguagesButton;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UITextView *sourceTextView;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *sourceLanguageLabel;
@property (nonatomic, strong) UILabel *targetLanguageLabel;
@property (nonatomic, strong) UILabel *sourceTextLabel;
@property (nonatomic, strong) UILabel *resultTextLabel;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) NSString *selectedSourceLanguage;
@property (nonatomic, strong) NSString *selectedTargetLanguage;
@property (nonatomic, assign) BOOL isInterpreting;

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSString*> *sourceSentences;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSString*> *targetSentences;

@property (nonatomic, strong) UISwitch *internalRecordingSwitch;
@property (nonatomic, strong) UILabel *internalRecordingLabel;
@property (nonatomic, strong) UISwitch *speakerOutputSwitch;
@property (nonatomic, strong) UILabel *speakerOutputLabel;

@end

@implementation SimultaneousInterpretationDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSentences];
    [self setupUI];
    [self setupLanguages];
}

- (void)initSentences {
    self.sourceSentences = [NSMutableDictionary dictionary];
    self.targetSentences = [NSMutableDictionary dictionary];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.SimultaneousInterpretationDemoTitle", comment:@"Simultaneous Interpretation");
    
    // Source Language Label
    self.sourceLanguageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.sourceLanguageLabel.text = NSLocalizedString(@"LocKey.SourceLanguage", comment:@"Source language label");
    self.sourceLanguageLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.sourceLanguageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.sourceLanguageLabel];
    
    // Target Language Label
    self.targetLanguageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.targetLanguageLabel.text = NSLocalizedString(@"LocKey.TargetLanguage", comment:@"Target language label");
    self.targetLanguageLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.targetLanguageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.targetLanguageLabel];
    
    // Source Language Picker
    self.sourceLanguagePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.sourceLanguagePicker.delegate = self;
    self.sourceLanguagePicker.dataSource = self;
    self.sourceLanguagePicker.tag = 1;
    self.sourceLanguagePicker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.sourceLanguagePicker];
    
    // Target Language Picker
    self.targetLanguagePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.targetLanguagePicker.delegate = self;
    self.targetLanguagePicker.dataSource = self;
    self.targetLanguagePicker.tag = 2;
    self.targetLanguagePicker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.targetLanguagePicker];
    
    // Swap Languages Button
    self.swapLanguagesButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.swapLanguagesButton setImage:[UIImage systemImageNamed:@"arrow.left.arrow.right"] forState:UIControlStateNormal];
    [self.swapLanguagesButton setBackgroundColor:[UIColor systemBlueColor]];
    self.swapLanguagesButton.tintColor = [UIColor whiteColor];
    self.swapLanguagesButton.layer.cornerRadius = 20.0;
    self.swapLanguagesButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.swapLanguagesButton addTarget:self action:@selector(swapLanguages) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.swapLanguagesButton];
    
    // Start Button
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startButton setTitle:NSLocalizedString(@"LocKey.StartInterpretationButtonTitle", comment:@"Start interpretation button") forState:UIControlStateNormal];
    [self.startButton setTitle:NSLocalizedString(@"LocKey.StopInterpretationButtonTitle", comment:@"Stop interpretation button") forState:UIControlStateSelected];
    self.startButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.startButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.startButton.layer.cornerRadius = 25.0;
    self.startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.startButton addTarget:self action:@selector(toggleInterpretation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    // Internal Recording Label
    self.internalRecordingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.internalRecordingLabel.text = NSLocalizedString(@"LocKey.UseSDKInternalRecording", comment:@"Use SDK internal recording");
    self.internalRecordingLabel.font = [UIFont systemFontOfSize:16];
    self.internalRecordingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.internalRecordingLabel];
    
    // Internal Recording Switch
    self.internalRecordingSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.internalRecordingSwitch.on = YES;
    self.internalRecordingSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.internalRecordingSwitch];
    
    // Speaker Output Label
    self.speakerOutputLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.speakerOutputLabel.text = NSLocalizedString(@"LocKey.PreferSpeakerOutput", comment:@"Prefer speaker output");
    self.speakerOutputLabel.font = [UIFont systemFontOfSize:16];
    self.speakerOutputLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.speakerOutputLabel];
    
    // Speaker Output Switch
    self.speakerOutputSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.speakerOutputSwitch.on = NO;
    self.speakerOutputSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.speakerOutputSwitch];
    
    // Error Label
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.errorLabel.text = @"";
    self.errorLabel.textColor = [UIColor systemRedColor];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.errorLabel];
    
    // Source Text Label
    self.sourceTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.sourceTextLabel.text = NSLocalizedString(@"LocKey.SourceContent", comment:@"Source content label");
    self.sourceTextLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.sourceTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.sourceTextLabel];
    
    // Source TextView
    self.sourceTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.sourceTextView.text = NSLocalizedString(@"LocKey.SourceContentWillAppearHereTips", comment:@"Source content placeholder");
    self.sourceTextView.font = [UIFont systemFontOfSize:16];
    self.sourceTextView.editable = NO;
    self.sourceTextView.layer.borderWidth = 1.0;
    self.sourceTextView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.sourceTextView.layer.cornerRadius = 8.0;
    self.sourceTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.sourceTextView];
    
    // Result Text Label
    self.resultTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.resultTextLabel.text = NSLocalizedString(@"LocKey.TranslationResult", comment:@"Translation result label");
    self.resultTextLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.resultTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.resultTextLabel];
    
    // Result TextView
    self.resultTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.resultTextView.text = NSLocalizedString(@"LocKey.TranslationResultWillAppearHereTips", comment:@"Result placeholder");
    self.resultTextView.font = [UIFont systemFontOfSize:16];
    self.resultTextView.editable = NO;
    self.resultTextView.layer.borderWidth = 1.0;
    self.resultTextView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.resultTextView.layer.cornerRadius = 8.0;
    self.resultTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.resultTextView];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        // Source Language Label
        [self.sourceLanguageLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.sourceLanguageLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // Target Language Label
        [self.targetLanguageLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.targetLanguageLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Source Language Picker
        [self.sourceLanguagePicker.topAnchor constraintEqualToAnchor:self.sourceLanguageLabel.bottomAnchor constant:10],
        [self.sourceLanguagePicker.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.sourceLanguagePicker.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.4],
        [self.sourceLanguagePicker.heightAnchor constraintEqualToConstant:150],
        
        // Target Language Picker
        [self.targetLanguagePicker.topAnchor constraintEqualToAnchor:self.targetLanguageLabel.bottomAnchor constant:10],
        [self.targetLanguagePicker.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.targetLanguagePicker.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.4],
        [self.targetLanguagePicker.heightAnchor constraintEqualToConstant:150],
        
        // Swap Languages Button
        [self.swapLanguagesButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.swapLanguagesButton.centerYAnchor constraintEqualToAnchor:self.sourceLanguagePicker.centerYAnchor],
        [self.swapLanguagesButton.widthAnchor constraintEqualToConstant:40],
        [self.swapLanguagesButton.heightAnchor constraintEqualToConstant:40],
        
        // Start Button
        [self.startButton.topAnchor constraintEqualToAnchor:self.sourceLanguagePicker.bottomAnchor constant:30],
        [self.startButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.startButton.widthAnchor constraintEqualToConstant:200],
        [self.startButton.heightAnchor constraintEqualToConstant:50],
        
        // Internal Recording Label
        [self.internalRecordingLabel.topAnchor constraintEqualToAnchor:self.startButton.bottomAnchor constant:20],
        [self.internalRecordingLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // Internal Recording Switch
        [self.internalRecordingSwitch.topAnchor constraintEqualToAnchor:self.startButton.bottomAnchor constant:20],
        [self.internalRecordingSwitch.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Speaker Output Label
        [self.speakerOutputLabel.topAnchor constraintEqualToAnchor:self.internalRecordingLabel.bottomAnchor constant:15],
        [self.speakerOutputLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // Speaker Output Switch
        [self.speakerOutputSwitch.topAnchor constraintEqualToAnchor:self.internalRecordingLabel.bottomAnchor constant:15],
        [self.speakerOutputSwitch.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Error Label
        [self.errorLabel.topAnchor constraintEqualToAnchor:self.speakerOutputLabel.bottomAnchor constant:20],
        [self.errorLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.errorLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Source Text Label
        [self.sourceTextLabel.topAnchor constraintEqualToAnchor:self.errorLabel.bottomAnchor constant:20],
        [self.sourceTextLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // Source TextView
        [self.sourceTextView.topAnchor constraintEqualToAnchor:self.sourceTextLabel.bottomAnchor constant:10],
        [self.sourceTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.sourceTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.sourceTextView.heightAnchor constraintEqualToConstant:100],
        
        // Result Text Label
        [self.resultTextLabel.topAnchor constraintEqualToAnchor:self.sourceTextView.bottomAnchor constant:20],
        [self.resultTextLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // Result TextView
        [self.resultTextView.topAnchor constraintEqualToAnchor:self.resultTextLabel.bottomAnchor constant:10],
        [self.resultTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.resultTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.resultTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
    ]];
    
    // Set default languages
    // 根据系统语言设置默认值
    NSString *systemLanguage = [[NSLocale preferredLanguages] firstObject];
    if ([systemLanguage hasPrefix:@"zh"]) {
        self.selectedSourceLanguage = @"zh-CN";
        self.selectedTargetLanguage = @"en-US";
    } else {
        self.selectedSourceLanguage = @"en-US";
        self.selectedTargetLanguage = @"zh-CN";
    }
    
    // Set picker selections
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sourceLanguagePicker selectRow:[self indexForLanguageCode:self.selectedSourceLanguage] inComponent:0 animated:NO];
        [self.targetLanguagePicker selectRow:[self indexForLanguageCode:self.selectedTargetLanguage] inComponent:0 animated:NO];
    });
    
    // Set initial state
    self.isInterpreting = NO;
}

- (void)setupLanguages {
    self.languages = @[
        @{@"code": @"zh-CN", @"name": NSLocalizedString(@"LocKey.Chinese", comment:@"Chinese language")},
        @{@"code": @"en-US", @"name": NSLocalizedString(@"LocKey.English", comment:@"English language")},
        @{@"code": @"ja-JP", @"name": NSLocalizedString(@"LocKey.Japanese", comment:@"Japanese language")},
        @{@"code": @"ko-KR", @"name": NSLocalizedString(@"LocKey.Korean", comment:@"Korean language")},
        @{@"code": @"fr-FR", @"name": NSLocalizedString(@"LocKey.French", comment:@"French language")},
        @{@"code": @"de-DE", @"name": NSLocalizedString(@"LocKey.German", comment:@"German language")},
    ];
}

- (void)swapLanguages {
    if (self.isInterpreting) {
        self.errorLabel.text = NSLocalizedString(@"LocKey.CannotSwapLanguagesDuringInterpretationTips", comment:@"Error message");
        return;
    }
    
    // Swap selected languages
    NSString *temp = self.selectedSourceLanguage;
    self.selectedSourceLanguage = self.selectedTargetLanguage;
    self.selectedTargetLanguage = temp;
    
    // Update pickers
    [self.sourceLanguagePicker selectRow:[self indexForLanguageCode:self.selectedSourceLanguage] inComponent:0 animated:YES];
    [self.targetLanguagePicker selectRow:[self indexForLanguageCode:self.selectedTargetLanguage] inComponent:0 animated:YES];
}

- (void)toggleInterpretation {
    if (self.isInterpreting) {
        // Stop interpretation
        [self stopInterpretation];
    } else {
        // Start interpretation
        [self startInterpretation];
    }
}

- (void)startInterpretation {
    [self initSentences];
    
    if ([self.selectedSourceLanguage isEqualToString:self.selectedTargetLanguage]) {
        self.errorLabel.text = NSLocalizedString(@"LocKey.SourceAndTargetLanguagesCannotBeTheSame", comment:@"Error message");
        return;
    }
    
    self.errorLabel.text = @"";
    self.sourceTextView.text = NSLocalizedString(@"LocKey.ListeningTips", comment:@"Listening message");
    self.resultTextView.text = NSLocalizedString(@"LocKey.TranslationResultWillAppearHereTips", comment:@"Translation placeholder");
    
    // Create interpretation config
    AIBudsSimultaneousInterpretationConfig *config = [AIBudsSimultaneousInterpretationConfig defaultConfig];
    config.sourceLanguage = self.selectedSourceLanguage;
    config.targetLanguage = self.selectedTargetLanguage;
    config.usesInternalAudioRecording = self.internalRecordingSwitch.on;
    config.preferSpeakerOutput = self.speakerOutputSwitch.on;
    
    __weak typeof(self) weakSelf = self;
    // Start interpretation
    [AIBudsAISDK startSimultaneousInterpretationWithConfig:config onStartSuccess:^(id<AIBudsSimultaneousInterpretationSessionConvertible> _Nonnull session) {
        [SimultaneousInterpretationContext sharedInstance].currentSession = session;
        if (!session.isRecordingInternally) {
            id<AIBudsDeviceAudioRecordingAPI> audioRecordingAPI = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
            [audioRecordingAPI startAIAudioRecordingWithScene:AIBudsRecordingSceneOnSite completion:^(BOOL success, NSError * _Nullable error) {
                 if(!success)
                 {
                     XLOG_ERROR(@"启动设备端 AI 录音发生错误：%@", error);
                     XLOG_INFO(@"停止同声传译服务...");
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         __strong typeof(self) strongSelf = weakSelf;
                         if(!strongSelf)  return;
                         [strongSelf toggleInterpretation];
                     });
                 }
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(!strongSelf)  return;
            strongSelf.startButton.selected = YES;
            strongSelf.isInterpreting = YES;
        });
    } onStartFailure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(!strongSelf)  return;
            strongSelf.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
            strongSelf.sourceTextView.text = NSLocalizedString(@"LocKey.SourceContentWillAppearHereTips", comment:@"Source content placeholder");
            strongSelf.resultTextView.text = NSLocalizedString(@"LocKey.TranslationResultWillAppearHereTips", comment:@"Result placeholder");
        });
    } onStopByInterruption:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(!strongSelf)  return;
            if (error) {
                strongSelf.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
            }
            [strongSelf stopInterpretation];
        });
    } onException:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(!strongSelf)  return;
            strongSelf.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
       });
    } streamResultHandler:^(BOOL isFinal, AIBudsSimultaneousInterpretationDataModel * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if(!strongSelf)  return;
            if (error) {
                strongSelf.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
            } else if (response) {
                if (response.sourceTextSequence && response.isSourceTextDefinite) {
                    [strongSelf.sourceSentences setObject:response.sourceText forKey:response.sourceTextSequence];
                }
                if (response.targetTextSequence && response.isTargetTextDefinite) {
                    [strongSelf.targetSentences setObject:response.targetText forKey:response.targetTextSequence];
                }
                // 将 sourceSentences 按 key 排序后拼接
                NSArray *sortedSourceKeys = [[self.sourceSentences allKeys] sortedArrayUsingSelector:@selector(compare:)];
                NSMutableString *sourceText = [NSMutableString string];
                for (NSNumber *key in sortedSourceKeys) {
                    if (sourceText.length > 0) {
                        [sourceText appendString:@"\n"];
                    }
                    [sourceText appendString:self.sourceSentences[key]];
                }
                
                // 将 targetSentences 按 key 排序后拼接
                NSArray *sortedTargetKeys = [[strongSelf.targetSentences allKeys] sortedArrayUsingSelector:@selector(compare:)];
                NSMutableString *targetText = [NSMutableString string];
                for (NSNumber *key in sortedTargetKeys) {
                    if (targetText.length > 0) {
                        [targetText appendString:@"\n"];
                    }
                    [targetText appendString:self.targetSentences[key]];
                }
        
                strongSelf.sourceTextView.text = sourceText ?: NSLocalizedString(@"LocKey.SourceContentWillAppearHereTips", comment:@"Source content placeholder");
                strongSelf.resultTextView.text = targetText ?: NSLocalizedString(@"LocKey.TranslationResultWillAppearHereTips", comment:@"Result placeholder");
                
                if(strongSelf.resultTextView.text.length > 0 ) {
                    NSRange bottom = NSMakeRange(strongSelf.resultTextView.text.length -1, 1);
                    [strongSelf.resultTextView scrollRangeToVisible:bottom];
                }
                
                if(self.sourceTextView.text.length > 0 ) {
                    NSRange bottom = NSMakeRange(strongSelf.sourceTextView.text.length -1, 1);
                    [strongSelf.sourceTextView scrollRangeToVisible:bottom];
                }
            }
        });
    } onEvent:^(AIBudsSimultaneousInterpretationEventModel * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        if(!strongSelf)  return;
        [strongSelf handleEvent:event];
    } onFinish:^(AIBudsSimultaneousInterpretationReportModel * _Nullable report) {
        dispatch_async(dispatch_get_main_queue(), ^{
              __strong typeof(self) strongSelf = weakSelf;
              if(!strongSelf)  return;
              [strongSelf stopInterpretation];
          });
    }];
}

- (void)handleEvent:(AIBudsSimultaneousInterpretationEventModel *)event {
    switch (event.eventType) {
        case AIBudsSimultaneousInterpretationEventTypeAppWillTerminate:
        {
            
            XLOG_INFO(@"App 即将终止....");
            [self stopDeviceSideAIAudioRecordingIfNeeded];
        }
            break;
        default:
            break;
    }
}

-(void) stopDeviceSideAIAudioRecordingIfNeeded {
    
    id<AIBudsSimultaneousInterpretationSessionConvertible> currentSession = [SimultaneousInterpretationContext sharedInstance].currentSession;
    if(currentSession && !currentSession.isRecordingInternally) {
        id<AIBudsDeviceAudioRecordingAPI> audioRecordingAPI = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
        [audioRecordingAPI stopAIAudioRecordingWithScene:AIBudsRecordingSceneOnSite completion:^(BOOL success, NSError * _Nullable error) {
        }];
        return;
    }
}

- (void)stopInterpretation {
    __weak typeof(self) weakSelf = self;
    id<AIBudsSimultaneousInterpretationSessionConvertible> currentSession = [SimultaneousInterpretationContext sharedInstance].currentSession;
    if(currentSession && !currentSession.isRecordingInternally) {
        id<AIBudsDeviceAudioRecordingAPI> audioRecordingAPI = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
        [audioRecordingAPI stopAIAudioRecordingWithScene:AIBudsRecordingSceneOnSite completion:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf stopInterpretationService];
            });
        }];
        return;
    }
    [self stopInterpretationService];
}

- (void)stopInterpretationService {
    [AIBudsAISDK stopSimultaneousInterpretation];
    [SimultaneousInterpretationContext sharedInstance].currentSession = nil;
    self.startButton.selected = NO;
    self.isInterpreting = NO;
    self.sourceTextView.text = NSLocalizedString(@"LocKey.SourceContentWillAppearHereTips", comment:@"Source content placeholder");
    self.resultTextView.text = NSLocalizedString(@"LocKey.TranslationResultWillAppearHereTips", comment:@"Result placeholder");
}

- (NSInteger)indexForLanguageCode:(NSString *)code {
    for (NSInteger i = 0; i < self.languages.count; i++) {
        if ([self.languages[i][@"code"] isEqualToString:code]) {
            return i;
        }
    }
    return 0; // Default to Chinese
}

#pragma mark - UIPickerView DataSource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.languages.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.languages[row][@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.isInterpreting) {
        [pickerView selectRow:[self indexForLanguageCode:pickerView.tag == 1 ? self.selectedSourceLanguage : self.selectedTargetLanguage] inComponent:0 animated:NO];
        self.errorLabel.text = NSLocalizedString(@"LocKey.CannotSwapLanguagesDuringInterpretationTips", comment:@"Error message");
        return;
    }
    
    if (pickerView.tag == 1) {
        self.selectedSourceLanguage = self.languages[row][@"code"];
    } else if (pickerView.tag == 2) {
        self.selectedTargetLanguage = self.languages[row][@"code"];
    }
    
    self.errorLabel.text = @"";
}

@end
