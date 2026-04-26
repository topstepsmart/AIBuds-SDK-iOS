//
//  AIAudioRecordingDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIAudioRecordingDemoController.h"
#import "AIAudioRecordingContext.h"
#import <UIKit/UIKit.h>

@interface AIAudioRecordingDemoController ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIView *waveContainerView;
@property (nonatomic, strong) UIPickerView *languagePicker;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *transcriptLabel;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) NSString *selectedLanguage;

@end

@implementation AIAudioRecordingDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupLanguages];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.AiAudioRecordingDemoTitle", comment:@"AI Recording");
    
    // Duration Label
    self.durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.durationLabel.text = @"00:00.00";
    self.durationLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightBold];
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.durationLabel];
    
    // Wave Container View
    self.waveContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.waveContainerView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.waveContainerView.layer.cornerRadius = 10.0;
    self.waveContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.waveContainerView];
    
    // Language Picker
    self.languagePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.languagePicker.delegate = self;
    self.languagePicker.dataSource = self;
    self.languagePicker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.languagePicker];
    
    // Record Button
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setTitle:NSLocalizedString(@"LocKey.StartRecording", comment:@"Start Recording") forState:UIControlStateNormal];
    [self.recordButton setTitle:NSLocalizedString(@"LocKey.StopRecording", comment:@"Stop Recording") forState:UIControlStateSelected];
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.recordButton setBackgroundColor:[UIColor systemRedColor]];
    [self.recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.recordButton.layer.cornerRadius = 25.0;
    self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.recordButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];
    
    // Error Label
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.errorLabel.text = @"";
    self.errorLabel.textColor = [UIColor systemRedColor];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.errorLabel];
    
    // Transcript Label
    self.transcriptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.transcriptLabel.text = NSLocalizedString(@"LocKey.TranscriptWillAppearHereTips", comment:@"Transcript placeholder");
    self.transcriptLabel.font = [UIFont systemFontOfSize:16];
    self.transcriptLabel.textAlignment = NSTextAlignmentCenter;
    self.transcriptLabel.numberOfLines = 0;
    self.transcriptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.transcriptLabel];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        // Duration Label
        [self.durationLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.durationLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        
        // Wave Container View
        [self.waveContainerView.topAnchor constraintEqualToAnchor:self.durationLabel.bottomAnchor constant:30],
        [self.waveContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.waveContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.waveContainerView.heightAnchor constraintEqualToConstant:120],
        
        // Language Picker
        [self.languagePicker.topAnchor constraintEqualToAnchor:self.waveContainerView.bottomAnchor constant:30],
        [self.languagePicker.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.languagePicker.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.languagePicker.heightAnchor constraintEqualToConstant:150],
        
        // Transcript Label
        [self.transcriptLabel.topAnchor constraintEqualToAnchor:self.languagePicker.bottomAnchor constant:20],
        [self.transcriptLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.transcriptLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.transcriptLabel.heightAnchor constraintEqualToConstant:160],
        
        // Record Button
        [self.recordButton.topAnchor constraintEqualToAnchor:self.transcriptLabel.bottomAnchor constant:30],
        [self.recordButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.recordButton.widthAnchor constraintEqualToConstant:200],
        [self.recordButton.heightAnchor constraintEqualToConstant:50],
        
        // Error Label
        [self.errorLabel.topAnchor constraintEqualToAnchor:self.recordButton.bottomAnchor constant:20],
        [self.errorLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.errorLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
    ]];
    
    // Start with default language
    self.selectedLanguage = self.languages[0];
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

- (void)toggleRecording {
    if (self.recordButton.isSelected) {
        // Stop recording
        [self stopRecording];
    } else {
        // Start recording
        [self startRecording];
    }
}

- (void)startRecording {
    self.recordButton.selected = YES;
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    self.errorLabel.text = @"";
    
    // Start duration timer
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES];
    
    // Start audio wave animation
    [self startWaveAnimation];
    
    // Create recording config
    AIBudsAIAudioRecordingSessionConfig *config = [[AIBudsAIAudioRecordingSessionConfig alloc] initWithRecordingScene:AIBudsRecordingSceneOnSite allowRecordingWhileOffline:YES languageForSpeechInput:nil];
    config.languageForSpeechInput = self.selectedLanguage;
    
    // Start recording
    __weak typeof(self) weakSelf = self;
    [AIBudsAISDK startAIAudioRecordingWithConfig:config 
                        onStartSuccess:^(id<AIBudsAIAudioRecordingSessionConvertible> session) {
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                            if(!strongSelf)  return;  
                            [AIAudioRecordingContext sharedInstance].currentSession = session;
                            [strongSelf startDeviceSideAIAudioRecording];
                          }
                          onStartFailure:^(NSError *error) {
                              [self handleError:error];
                              [self stopRecording];
                          }
                          onTranscript:^(AIBudsStreamSpeechASRModel *transcriptData) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  self.transcriptLabel.text = transcriptData.transcript ?: NSLocalizedString(@"Transcript will appear here", comment:@"Transcript placeholder");
                              });
                          }
                          onError:^(NSError *error) {
                              [self handleError:error];
                          }
                          onFinish:^(AIBudsAIAudioRecordingReportModel *report) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self stopRecording];
                              });
                          }];
}


- (void)startDeviceSideAIAudioRecording {
    id<AIBudsDeviceAudioRecordingAPI> device = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) {
        __weak typeof(self) weakSelf = self;
        [device startAIAudioRecordingWithScene:AIBudsRecordingSceneOnSite completion:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if(!strongSelf)  return;  
                if(!success) {
                    [strongSelf handleError:error];
                    [strongSelf stopRecording];
                }
            });
        }];
    }
}

-(void)stopDeviceSideAIAudioRecording {
    id<AIBudsDeviceAudioRecordingAPI> device = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) {
        [device stopAIAudioRecordingWithScene:AIBudsRecordingSceneOnSite completion:^(BOOL success, NSError * _Nullable error) {
            
        }];
    }
}


- (void)stopRecording {
    [AIAudioRecordingContext sharedInstance].currentSession = nil;
    [self stopDeviceSideAIAudioRecording];
    self.recordButton.selected = NO;
    
    // Stop duration timer
    if (self.durationTimer) {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
    
    // Stop audio wave animation
    [self stopWaveAnimation];
    
    // Stop recording
    [AIBudsAISDK stopAIAudioRecording];
}

- (void)updateDuration {
    NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
    
    int hours = (int)elapsed / 3600;
    int minutes = (int)(elapsed - hours * 3600) / 60;
    int seconds = (int)(elapsed - hours * 3600 - minutes * 60);
    int milliseconds = (int)((elapsed - floor(elapsed)) * 100);
    
    if (hours > 0) {
        self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds];
    } else {
        self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d.%02d", minutes, seconds, milliseconds];
    }
}

- (void)startWaveAnimation {
    // Clear existing subviews
    for (UIView *subview in self.waveContainerView.subviews) {
        [subview removeFromSuperview];
    }
    
    // Create wave animation
    CGFloat width = self.waveContainerView.bounds.size.width;
    CGFloat height = self.waveContainerView.bounds.size.height;
    int barCount = 30;
    CGFloat barWidth = (width - (barCount + 1) * 4) / barCount;
    
    for (int i = 0; i < barCount; i++) {
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(4 + i * (barWidth + 4), height, barWidth, 0)];
        bar.backgroundColor = [UIColor systemBlueColor];
        bar.layer.cornerRadius = barWidth / 2;
        [self.waveContainerView addSubview:bar];
        
        // Animate bar height
        [UIView animateWithDuration:0.5 
                              delay:i * 0.05 
                            options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseInOut
                         animations:^{ 
                             CGFloat randomHeight = arc4random_uniform((int)(height * 0.8)) + height * 0.1;
                             bar.frame = CGRectMake(bar.frame.origin.x, height - randomHeight, barWidth, randomHeight);
                         } 
                         completion:nil];
    }
}

- (void)stopWaveAnimation {
    for (UIView *subview in self.waveContainerView.subviews) {
        [subview.layer removeAllAnimations];
    }
}

- (void)handleError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{ 
        self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
    });
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
    self.selectedLanguage = self.languages[row][@"code"];
}

@end
