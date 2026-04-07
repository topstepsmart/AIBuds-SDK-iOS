//
//  SimultaneousInterpretationDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "SimultaneousInterpretationDemoController.h"

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
@property (nonatomic, strong) id<AIBudsSimultaneousInterpretationSessionConvertible> interpretationSession;

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSString*> *sourceSentences;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSString*> *targetSentences;

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
        
        // Error Label
        [self.errorLabel.topAnchor constraintEqualToAnchor:self.startButton.bottomAnchor constant:20],
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
    
    // Start interpretation
    [AIBudsAISDK startSimultaneousInterpretationWithConfig:config onStartSuccess:^(id<AIBudsSimultaneousInterpretationSessionConvertible> _Nonnull session) {
        self.interpretationSession = session;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startButton.selected = YES;
            self.isInterpreting = YES;
        });
    } onStartFailure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
            self.sourceTextView.text = NSLocalizedString(@"LocKey.SourceContentWillAppearHereTips", comment:@"Source content placeholder");
            self.resultTextView.text = NSLocalizedString(@"LocKey.TranslationResultWillAppearHereTips", comment:@"Result placeholder");
        });
    } onStopByInterruption:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
            }
            [self stopInterpretation];
        });
    } onException:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
           self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
       });
    } streamResultHandler:^(BOOL isFinal, AIBudsSimultaneousInterpretationDataModel * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
            } else if (response) {
                if (response.sourceTextSequence && response.isSourceTextDefinite) {
                    [self.sourceSentences setObject:response.sourceText forKey:response.sourceTextSequence];
                }
                if (response.targetTextSequence && response.isTargetTextDefinite) {
                    [self.targetSentences setObject:response.targetText forKey:response.targetTextSequence];
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
                NSArray *sortedTargetKeys = [[self.targetSentences allKeys] sortedArrayUsingSelector:@selector(compare:)];
                NSMutableString *targetText = [NSMutableString string];
                for (NSNumber *key in sortedTargetKeys) {
                    if (targetText.length > 0) {
                        [targetText appendString:@"\n"];
                    }
                    [targetText appendString:self.targetSentences[key]];
                }
        
                self.sourceTextView.text = sourceText ?: NSLocalizedString(@"LocKey.SourceContentWillAppearHereTips", comment:@"Source content placeholder");
                self.resultTextView.text = targetText ?: NSLocalizedString(@"LocKey.TranslationResultWillAppearHereTips", comment:@"Result placeholder");
                
                if(self.resultTextView.text.length > 0 ) {
                    NSRange bottom = NSMakeRange(self.resultTextView.text.length -1, 1);
                    [self.resultTextView scrollRangeToVisible:bottom];
                }
                
                if(self.sourceTextView.text.length > 0 ) {
                    NSRange bottom = NSMakeRange(self.sourceTextView.text.length -1, 1);
                    [self.sourceTextView scrollRangeToVisible:bottom];
                }
            }
        });
    } onFinish:^(AIBudsSimultaneousInterpretationReportModel * _Nullable report) {
        dispatch_async(dispatch_get_main_queue(), ^{
              [self stopInterpretation];
          });
    }];
}

- (void)stopInterpretation {
    [AIBudsAISDK stopSimultaneousInterpretation];
    self.interpretationSession = nil;
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
