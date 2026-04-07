//
//  TTSDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "TTSDemoController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TTSDemoController ()

@property (nonatomic, strong) UITextView *textInputView;
@property (nonatomic, strong) UIButton *synthesizeButton;
@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AIBudsTTSResultModel *currentResult;

@end

@implementation TTSDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.TTSDemoTitle", comment:@"Text to Speech");
    
    // Text Input View
    self.textInputView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textInputView.text = NSLocalizedString(@"LocKey.TTSDemoText", comment:@"Default TTS text");
    self.textInputView.font = [UIFont systemFontOfSize:16];
    self.textInputView.layer.borderWidth = 1.0;
    self.textInputView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.textInputView.layer.cornerRadius = 8.0;
    self.textInputView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.textInputView];
    
    // Synthesize Button
    self.synthesizeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.synthesizeButton setTitle:NSLocalizedString(@"LocKey.StartToSynthesize", comment:@"Synthesize button") forState:UIControlStateNormal];
    self.synthesizeButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.synthesizeButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.synthesizeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.synthesizeButton.layer.cornerRadius = 25.0;
    self.synthesizeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.synthesizeButton addTarget:self action:@selector(synthesizeText) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.synthesizeButton];
    
    // Replay Button
    self.replayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.replayButton setTitle:NSLocalizedString(@"LocKey.Replay", comment:@"Replay button") forState:UIControlStateNormal];
    self.replayButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.replayButton setBackgroundColor:[UIColor systemGreenColor]];
    [self.replayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.replayButton.layer.cornerRadius = 8.0;
    self.replayButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.replayButton addTarget:self action:@selector(replayAudio) forControlEvents:UIControlEventTouchUpInside];
    self.replayButton.enabled = NO;
    [self.view addSubview:self.replayButton];
    
    // Result Label
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.resultLabel.text = NSLocalizedString(@"LocKey.SynthesisResultWillAppearHereTips", comment:@"Result placeholder");
    self.resultLabel.font = [UIFont systemFontOfSize:14];
    self.resultLabel.textColor = [UIColor systemGrayColor];
    self.resultLabel.textAlignment = NSTextAlignmentLeft;
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.resultLabel];
    
    // Error Label
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.errorLabel.text = @"";
    self.errorLabel.textColor = [UIColor systemRedColor];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.errorLabel];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        // Text Input View
        [self.textInputView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.textInputView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.textInputView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.textInputView.heightAnchor constraintEqualToConstant:200],
        
        // Synthesize Button
        [self.synthesizeButton.topAnchor constraintEqualToAnchor:self.textInputView.bottomAnchor constant:30],
        [self.synthesizeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.synthesizeButton.widthAnchor constraintEqualToConstant:200],
        [self.synthesizeButton.heightAnchor constraintEqualToConstant:50],
        
        // Replay Button
        [self.replayButton.topAnchor constraintEqualToAnchor:self.synthesizeButton.bottomAnchor constant:20],
        [self.replayButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.replayButton.widthAnchor constraintEqualToConstant:150],
        [self.replayButton.heightAnchor constraintEqualToConstant:44],
        
        // Error Label
        [self.errorLabel.topAnchor constraintEqualToAnchor:self.replayButton.bottomAnchor constant:20],
        [self.errorLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.errorLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Result Label
        [self.resultLabel.topAnchor constraintEqualToAnchor:self.errorLabel.bottomAnchor constant:20],
        [self.resultLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.resultLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.resultLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
    ]];
}

- (void)synthesizeText {
    NSString *text = self.textInputView.text;
    if (!text || text.length == 0) {
        self.errorLabel.text = NSLocalizedString(@"LocKey.PleaseEnterTextToSynthesize", comment:@"Error message");
        return;
    }
    
    self.errorLabel.text = @"";
    self.resultLabel.text = NSLocalizedString(@"LocKey.Processing", comment:@"Processing message");
    
    // Create TTS config
    AIBudsTTSConfig *config = [AIBudsTTSConfig defaultConfig];
    
    // Synthesize text
    [AIBudsAISDK synthesizeText:text config:config completion:^(NSString * _Nullable taskId, BOOL success, AIBudsTTSResultModel * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && response) {
                self.currentResult = response;
                self.resultLabel.text = [NSString stringWithFormat:@"%@: %@\n%@: %@", 
                                        NSLocalizedString(@"LocKey.AudioFile", comment:@"Audio file label"), 
                                        response.audioFilePath, 
                                        NSLocalizedString(@"LocKey.AudioFormat", comment:@"Audio format label"), 
                                        [self getAudioFormatString:response.audioFormat]];
                self.replayButton.enabled = YES;
                [self playAudio:response.audioFilePath];
            } else {
                self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                self.resultLabel.text = NSLocalizedString(@"LocKey.SynthesisFailed", comment:@"Failed message");
                self.replayButton.enabled = NO;
            }
        });
    }];
}

- (void)replayAudio {
    if (self.currentResult) {
        [self playAudio:self.currentResult.audioFilePath];
    }
}

- (void)playAudio:(NSString *)filePath {
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
    if (error) {
        self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
        return;
    }
    
    [self.audioPlayer play];
}

- (NSString *)getAudioFormatString:(AIBudsAIAudioFormat)format {
    switch (format) {
        case AIBudsAIAudioFormatPcm:
            return @"PCM";
        case AIBudsAIAudioFormatMp3:
            return @"MP3";
        case AIBudsAIAudioFormatWav:
            return @"WAV";
        default:
            return @"Unknown";
    }
}

@end
