//
//  AITextTranslationDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AITextTranslationDemoController.h"

@interface AITextTranslationDemoController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *sourceLanguagePicker;
@property (nonatomic, strong) UIPickerView *targetLanguagePicker;
@property (nonatomic, strong) UIButton *swapLanguagesButton;
@property (nonatomic, strong) UITextView *sourceTextView;
@property (nonatomic, strong) UIButton *translateButton;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *sourceLanguageLabel;
@property (nonatomic, strong) UILabel *targetLanguageLabel;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) NSString *selectedSourceLanguage;
@property (nonatomic, strong) NSString *selectedTargetLanguage;

@end

@implementation AITextTranslationDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupLanguages];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.AiTextTranslationDemoTitle", comment:@"Text Translation");
    
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
    
    // Source TextView
    self.sourceTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.sourceTextView.text = NSLocalizedString(@"LocKey.AiTextTranslationDemoText", comment:@"Default translation input text");
    self.sourceTextView.font = [UIFont systemFontOfSize:16];
    self.sourceTextView.layer.borderWidth = 1.0;
    self.sourceTextView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.sourceTextView.layer.cornerRadius = 8.0;
    self.sourceTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.sourceTextView];
    
    // Translate Button
    self.translateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.translateButton setTitle:NSLocalizedString(@"LocKey.TranslateButtonTitle", comment:@"Translate button") forState:UIControlStateNormal];
    self.translateButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.translateButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.translateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.translateButton.layer.cornerRadius = 25.0;
    self.translateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.translateButton addTarget:self action:@selector(translateText) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.translateButton];
    
    // Error Label
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.errorLabel.text = @"";
    self.errorLabel.textColor = [UIColor systemRedColor];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.errorLabel];
    
    // Result TextView
    self.resultTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.resultTextView.text = NSLocalizedString(@"LocKey.TranslateResultWillAppearHereTips", comment:@"Result placeholder");
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
        
        // Source TextView
        [self.sourceTextView.topAnchor constraintEqualToAnchor:self.sourceLanguagePicker.bottomAnchor constant:20],
        [self.sourceTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.sourceTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.sourceTextView.heightAnchor constraintEqualToConstant:120],
        
        // Translate Button
        [self.translateButton.topAnchor constraintEqualToAnchor:self.sourceTextView.bottomAnchor constant:30],
        [self.translateButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.translateButton.widthAnchor constraintEqualToConstant:200],
        [self.translateButton.heightAnchor constraintEqualToConstant:50],
        
        // Error Label
        [self.errorLabel.topAnchor constraintEqualToAnchor:self.translateButton.bottomAnchor constant:20],
        [self.errorLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.errorLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Result TextView
        [self.resultTextView.topAnchor constraintEqualToAnchor:self.errorLabel.bottomAnchor constant:20],
        [self.resultTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.resultTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.resultTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
    ]];
    
    // Set default languages
    self.selectedSourceLanguage = @"en-US";
    self.selectedTargetLanguage = @"zh-CN";
    
    // Set picker selections
    [self.sourceLanguagePicker selectRow:[self indexForLanguageCode:self.selectedSourceLanguage] inComponent:0 animated:NO];
    [self.targetLanguagePicker selectRow:[self indexForLanguageCode:self.selectedTargetLanguage] inComponent:0 animated:NO];
}

- (void)setupLanguages {
    self.languages = @[
        @{@"code": @"auto", @"name": NSLocalizedString(@"LocKey.AutoDetect", comment:@"Auto detect language")},
        @{@"code": @"zh-CN", @"name": NSLocalizedString(@"LocKey.Chinese", comment:@"Chinese language")},
        @{@"code": @"en-US", @"name": NSLocalizedString(@"LocKey.English", comment:@"English language")},
        @{@"code": @"ja-JP", @"name": NSLocalizedString(@"LocKey.Japanese", comment:@"Japanese language")},
        @{@"code": @"ko-KR", @"name": NSLocalizedString(@"LocKey.Korean", comment:@"Korean language")},
        @{@"code": @"fr-FR", @"name": NSLocalizedString(@"LocKey.French", comment:@"French language")},
        @{@"code": @"de-DE", @"name": NSLocalizedString(@"LocKey.German", comment:@"German language")},
    ];
}

- (void)swapLanguages {
    // Swap selected languages
    NSString *temp = self.selectedSourceLanguage;
    self.selectedSourceLanguage = self.selectedTargetLanguage;
    self.selectedTargetLanguage = temp;
    
    // Update pickers
    [self.sourceLanguagePicker selectRow:[self indexForLanguageCode:self.selectedSourceLanguage] inComponent:0 animated:YES];
    [self.targetLanguagePicker selectRow:[self indexForLanguageCode:self.selectedTargetLanguage] inComponent:0 animated:YES];
    
    // Swap text if both text views have content
    if (self.sourceTextView.text.length > 0 && ![self.resultTextView.text isEqualToString:NSLocalizedString(@"LocKey.TranslateResultWillAppearHereTips", comment:@"Result placeholder")]) {
        NSString *tempText = self.sourceTextView.text;
        self.sourceTextView.text = self.resultTextView.text;
        self.resultTextView.text = tempText;
    }
}

- (void)translateText {
    NSString *text = self.sourceTextView.text;
    if (!text || text.length == 0) {
        self.errorLabel.text = NSLocalizedString(@"LocKey.PleaseEnterTextToTranslate", comment:@"Error message");
        return;
    }
    
    if ([self.selectedSourceLanguage isEqualToString:self.selectedTargetLanguage] && ![self.selectedSourceLanguage isEqualToString:@"auto"]) {
        self.errorLabel.text = NSLocalizedString(@"LocKey.SourceAndTargetLanguagesCannotBeTheSame", comment:@"Error message");
        return;
    }
    
    self.errorLabel.text = @"";
    self.resultTextView.text = NSLocalizedString(@"LocKey.Processing", comment:@"Processing message");
    
    // Translate text
    [AIBudsAISDK translateText:text from:self.selectedSourceLanguage to:self.selectedTargetLanguage streamResultHandler:^(BOOL isFinal, NSString * _Nullable transcript, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            if (error) {
                self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                self.resultTextView.text = NSLocalizedString(@"LocKey.TranslationFailed", comment:@"Failed message");
            } else if (transcript) {
                self.resultTextView.text = transcript;
            }
        });
    }];
}

- (NSInteger)indexForLanguageCode:(NSString *)code {
    for (NSInteger i = 0; i < self.languages.count; i++) {
        if ([self.languages[i][@"code"] isEqualToString:code]) {
            return i;
        }
    }
    return 0; // Default to auto detect
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
    if (pickerView.tag == 1) {
        self.selectedSourceLanguage = self.languages[row][@"code"];
    } else if (pickerView.tag == 2) {
        self.selectedTargetLanguage = self.languages[row][@"code"];
    }
}

@end
