//
//  StreamingASRDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "StreamingASRDemoController.h"
#import <UIKit/UIKit.h>

@interface StreamingASRDemoController () <UIDocumentPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIButton *fileSelectButton;
@property (nonatomic, strong) UIPickerView *formatPicker;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UILabel *filePathLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) NSArray *audioFormats;
@property (nonatomic, strong) NSString *selectedFormat;
@property (nonatomic, strong) NSString *selectedFilePath;

@end

@implementation StreamingASRDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupAudioFormats];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.StreamingASRDemoTitle", comment:@"Streaming ASR Demonstration");
    
    // File Select Button
    self.fileSelectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.fileSelectButton setTitle:NSLocalizedString(@"LocKey.SelectAudioFile", comment:@"Select Audio File") forState:UIControlStateNormal];
    self.fileSelectButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.fileSelectButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.fileSelectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.fileSelectButton.layer.cornerRadius = 8.0;
    self.fileSelectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.fileSelectButton addTarget:self action:@selector(selectAudioFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fileSelectButton];
    
    // File Path Label
    self.filePathLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.filePathLabel.text = NSLocalizedString(@"LocKey.NoFileSelected", comment:@"No file selected");
    self.filePathLabel.font = [UIFont systemFontOfSize:14];
    self.filePathLabel.textColor = [UIColor systemGrayColor];
    self.filePathLabel.textAlignment = NSTextAlignmentCenter;
    self.filePathLabel.numberOfLines = 2;
    self.filePathLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.filePathLabel];
    
    // Format Picker
    self.formatPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.formatPicker.delegate = self;
    self.formatPicker.dataSource = self;
    self.formatPicker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.formatPicker];
    
    // Start Button
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startButton setTitle:NSLocalizedString(@"LocKey.StartRecognition", comment:@"Start Recognition") forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.startButton setBackgroundColor:[UIColor systemGreenColor]];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButton.layer.cornerRadius = 25.0;
    self.startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.startButton addTarget:self action:@selector(startRecognition) forControlEvents:UIControlEventTouchUpInside];
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
    
    // Result TextView
    self.resultTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.resultTextView.text = NSLocalizedString(@"LocKey.RecognitionResultWillAppearHereTips", comment:@"Result placeholder");
    self.resultTextView.font = [UIFont systemFontOfSize:16];
    self.resultTextView.textAlignment = NSTextAlignmentLeft;
    self.resultTextView.editable = NO;
    self.resultTextView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.resultTextView.layer.cornerRadius = 8.0;
    self.resultTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.resultTextView];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        // File Select Button
        [self.fileSelectButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.fileSelectButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.fileSelectButton.widthAnchor constraintEqualToConstant:200],
        [self.fileSelectButton.heightAnchor constraintEqualToConstant:44],
        
        // File Path Label
        [self.filePathLabel.topAnchor constraintEqualToAnchor:self.fileSelectButton.bottomAnchor constant:10],
        [self.filePathLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.filePathLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Format Picker
        [self.formatPicker.topAnchor constraintEqualToAnchor:self.filePathLabel.bottomAnchor constant:20],
        [self.formatPicker.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.formatPicker.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.formatPicker.heightAnchor constraintEqualToConstant:150],
        
        // Start Button
        [self.startButton.topAnchor constraintEqualToAnchor:self.formatPicker.bottomAnchor constant:30],
        [self.startButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.startButton.widthAnchor constraintEqualToConstant:200],
        [self.startButton.heightAnchor constraintEqualToConstant:50],
        
        // Error Label
        [self.errorLabel.topAnchor constraintEqualToAnchor:self.startButton.bottomAnchor constant:20],
        [self.errorLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.errorLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Result TextView
        [self.resultTextView.topAnchor constraintEqualToAnchor:self.errorLabel.bottomAnchor constant:20],
        [self.resultTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.resultTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.resultTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
    ]];
    
    // Start with default format
    self.selectedFormat = self.audioFormats[0];
}

- (void)setupAudioFormats {
    self.audioFormats = @[
        @{@"code": @"pcm", @"name": NSLocalizedString(@"PCM", comment:@"PCM format")},
        @{@"code": @"mp3", @"name": NSLocalizedString(@"MP3", comment:@"MP3 format")},
        @{@"code": @"wav", @"name": NSLocalizedString(@"WAV", comment:@"WAV format")},
    ];
}

- (void)selectAudioFile {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.audio"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.allowsMultipleSelection = NO;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)startRecognition {
    if (!self.selectedFilePath) {
        self.errorLabel.text = NSLocalizedString(@"LocKey.PleaseSelectAnAudioFile", comment:@"Error message");
        return;
    }
    
    self.errorLabel.text = @"";
    self.resultTextView.text = NSLocalizedString(@"LocKey.Processing", comment:@"Processing message");
    
    // Create config
    AIBudsStreamingASRConfig *config = [[AIBudsStreamingASRConfig alloc] initWithLanguageForSpeechInput:nil audioFormat:[self getAudioFormatFromString:self.selectedFormat]];
    
    // Start recognition
    [AIBudsAISDK recognizeVoiceFile:self.selectedFilePath 
                              withConfig:config
                             onTranscript:^(AIBudsStreamSpeechASRModel *transcriptData) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (transcriptData.sequence == 0) {
                                         self.resultTextView.text = @"";
                                     }
                                     NSString* message = [NSString stringWithFormat:@"- seq:%@ sentence:%@ transcript:%@", @(transcriptData.sequence), transcriptData.transcriptSequence, transcriptData.transcript];
                                     NSString* text = self.resultTextView.text;
                                     if([text length] > 0)
                                     {
                                         text = [text stringByAppendingString:@"\n"];
                                     }
                                     text = [text stringByAppendingString:message];
                                     self.resultTextView.text = text;
                                 });
                             }
                               onFailed:^(NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{ 
                                       self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                                   });
                               }
                               onFinish:^{ 
                                   dispatch_async(dispatch_get_main_queue(), ^{ 
                                       // Recognition finished
                                   });
                               }];
}

- (AIBudsAIAudioFormat)getAudioFormatFromString:(NSString *)formatString {
    if ([formatString isEqualToString:@"pcm"]) {
        return AIBudsAIAudioFormatPcm;
    } else if ([formatString isEqualToString:@"mp3"]) {
        return AIBudsAIAudioFormatMp3;
    } else if ([formatString isEqualToString:@"wav"]) {
        return AIBudsAIAudioFormatWav;
    } else {
        return AIBudsAIAudioFormatPcm;
    }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *url = urls[0];
        self.selectedFilePath = [url path];
        self.filePathLabel.text = [self.selectedFilePath lastPathComponent];
        self.errorLabel.text = @"";
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // User cancelled file selection
}

#pragma mark - UIPickerView DataSource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.audioFormats.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.audioFormats[row][@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedFormat = self.audioFormats[row][@"code"];
}

@end
