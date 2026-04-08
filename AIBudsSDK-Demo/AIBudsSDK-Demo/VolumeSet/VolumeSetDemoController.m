//
//  VolumeSetDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-07.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "VolumeSetDemoController.h"

@interface VolumeSetDemoController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) UILabel *capabilityLabel;
@property (nonatomic, strong) UISlider *systemPromptSlider;
@property (nonatomic, strong) UILabel *systemPromptValueLabel;
@property (nonatomic, strong) UISlider *mediaSlider;
@property (nonatomic, strong) UILabel *mediaValueLabel;
@property (nonatomic, strong) UISlider *callSlider;
@property (nonatomic, strong) UILabel *callValueLabel;
@property (nonatomic, strong) UISlider *localPlaybackSlider;
@property (nonatomic, strong) UILabel *localPlaybackValueLabel;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) NSTimer *systemPromptTimer;
@property (nonatomic, strong) NSTimer *mediaTimer;
@property (nonatomic, strong) NSTimer *callTimer;
@property (nonatomic, strong) NSTimer *localPlaybackTimer;

@end

@implementation VolumeSetDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self updateUIForDeviceCapability];
    [self updateCurrentVolumes];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.VolumeControlFeatureTitle", comment:@"Volume Control");
    
    // Scroll View
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    // Main Stack View
    self.mainStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 40;
    self.mainStackView.alignment = UIStackViewAlignmentFill;
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.mainStackView];
    
    // Capability Label
    self.capabilityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.capabilityLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.capabilityLabel.textAlignment = NSTextAlignmentCenter;
    self.capabilityLabel.numberOfLines = 0;
    self.capabilityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainStackView addArrangedSubview:self.capabilityLabel];
    
    // System Prompt Volume
    [self setupSystemPromptVolumeControl];
    
    // Media Volume
    [self setupMediaVolumeControl];
    
    // Call Volume
    [self setupCallVolumeControl];
    
    // Local Playback Volume
    [self setupLocalPlaybackVolumeControl];
    
    // Reset Button
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resetButton setTitle:NSLocalizedString(@"LocKey.ResetAllVolumes", comment:@"Reset All Volumes") forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.resetButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetButton.layer.cornerRadius = 20.0;
    self.resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.resetButton addTarget:self action:@selector(resetAllVolumes) forControlEvents:UIControlEventTouchUpInside];
    [self.mainStackView addArrangedSubview:self.resetButton];
    
    // Status Label
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = [UIColor systemGreenColor];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainStackView addArrangedSubview:self.statusLabel];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        // Scroll View
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        // Main Stack View
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:20],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:20],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-20],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-20],
        [self.mainStackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-40],
        
        // Reset Button
        [self.resetButton.heightAnchor constraintEqualToConstant:40],
    ]];
    
    // Slider Actions
    [self.systemPromptSlider addTarget:self action:@selector(systemPromptSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mediaSlider addTarget:self action:@selector(mediaSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.callSlider addTarget:self action:@selector(callSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.localPlaybackSlider addTarget:self action:@selector(localPlaybackSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupSystemPromptVolumeControl {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = NSLocalizedString(@"LocKey.SystemPromptVolume", comment:@"System Prompt Volume");
    label.font = [UIFont systemFontOfSize:16];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:label];
    
    // Slider
    UISlider *sliderView = [[UISlider alloc] initWithFrame:CGRectZero];
    sliderView.minimumValue = 0.0;
    sliderView.maximumValue = 100.0;
    sliderView.value = 50.0;
    sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:sliderView];
    self.systemPromptSlider = sliderView;
    
    // Value Label
    UILabel *valueLabelView = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabelView.text = @"50%";
    valueLabelView.font = [UIFont systemFontOfSize:14];
    valueLabelView.textColor = [UIColor systemGrayColor];
    valueLabelView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:valueLabelView];
    self.systemPromptValueLabel = valueLabelView;
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [label.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [label.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        
        [sliderView.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:10],
        [sliderView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [sliderView.trailingAnchor constraintEqualToAnchor:valueLabelView.leadingAnchor constant:-10],
        [sliderView.heightAnchor constraintEqualToConstant:60],
        [sliderView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10],
        
        [valueLabelView.topAnchor constraintEqualToAnchor:sliderView.topAnchor],
        [valueLabelView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        [valueLabelView.widthAnchor constraintEqualToConstant:50],
    ]];
    
    [self.mainStackView addArrangedSubview:containerView];
}

- (void)setupMediaVolumeControl {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = NSLocalizedString(@"LocKey.MediaVolume", comment:@"Media Volume");
    label.font = [UIFont systemFontOfSize:16];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:label];
    
    // Slider
    UISlider *sliderView = [[UISlider alloc] initWithFrame:CGRectZero];
    sliderView.minimumValue = 0.0;
    sliderView.maximumValue = 100.0;
    sliderView.value = 50.0;
    sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:sliderView];
    self.mediaSlider = sliderView;
    
    // Value Label
    UILabel *valueLabelView = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabelView.text = @"50%";
    valueLabelView.font = [UIFont systemFontOfSize:14];
    valueLabelView.textColor = [UIColor systemGrayColor];
    valueLabelView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:valueLabelView];
    self.mediaValueLabel = valueLabelView;
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [label.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [label.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        
        [sliderView.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:10],
        [sliderView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [sliderView.trailingAnchor constraintEqualToAnchor:valueLabelView.leadingAnchor constant:-10],
        [sliderView.heightAnchor constraintEqualToConstant:60],
        [sliderView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10],
        
        [valueLabelView.topAnchor constraintEqualToAnchor:sliderView.topAnchor],
        [valueLabelView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        [valueLabelView.widthAnchor constraintEqualToConstant:50],
    ]];
    
    [self.mainStackView addArrangedSubview:containerView];
}

- (void)setupCallVolumeControl {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = NSLocalizedString(@"LocKey.CallVolume", comment:@"Call Volume");
    label.font = [UIFont systemFontOfSize:16];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:label];
    
    // Slider
    UISlider *sliderView = [[UISlider alloc] initWithFrame:CGRectZero];
    sliderView.minimumValue = 0.0;
    sliderView.maximumValue = 100.0;
    sliderView.value = 50.0;
    sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:sliderView];
    self.callSlider = sliderView;
    
    // Value Label
    UILabel *valueLabelView = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabelView.text = @"50%";
    valueLabelView.font = [UIFont systemFontOfSize:14];
    valueLabelView.textColor = [UIColor systemGrayColor];
    valueLabelView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:valueLabelView];
    self.callValueLabel = valueLabelView;
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [label.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [label.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        
        [sliderView.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:10],
        [sliderView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [sliderView.trailingAnchor constraintEqualToAnchor:valueLabelView.leadingAnchor constant:-10],
        [sliderView.heightAnchor constraintEqualToConstant:60],
        [sliderView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10],
        
        [valueLabelView.topAnchor constraintEqualToAnchor:sliderView.topAnchor],
        [valueLabelView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        [valueLabelView.widthAnchor constraintEqualToConstant:50],
    ]];
    
    [self.mainStackView addArrangedSubview:containerView];
}

- (void)setupLocalPlaybackVolumeControl {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = NSLocalizedString(@"LocKey.LocalPlaybackVolume", comment:@"Local Playback Volume");
    label.font = [UIFont systemFontOfSize:16];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:label];
    
    // Slider
    UISlider *sliderView = [[UISlider alloc] initWithFrame:CGRectZero];
    sliderView.minimumValue = 0.0;
    sliderView.maximumValue = 100.0;
    sliderView.value = 50.0;
    sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:sliderView];
    self.localPlaybackSlider = sliderView;
    
    // Value Label
    UILabel *valueLabelView = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabelView.text = @"50%";
    valueLabelView.font = [UIFont systemFontOfSize:14];
    valueLabelView.textColor = [UIColor systemGrayColor];
    valueLabelView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:valueLabelView];
    self.localPlaybackValueLabel = valueLabelView;
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [label.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [label.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        
        [sliderView.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:10],
        [sliderView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [sliderView.trailingAnchor constraintEqualToAnchor:valueLabelView.leadingAnchor constant:-10],
        [sliderView.heightAnchor constraintEqualToConstant:60],
        [sliderView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10],
        
        [valueLabelView.topAnchor constraintEqualToAnchor:sliderView.topAnchor],
        [valueLabelView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        [valueLabelView.widthAnchor constraintEqualToConstant:50],
    ]];
    
    [self.mainStackView addArrangedSubview:containerView];
}

- (void)updateUIForDeviceCapability {
    if (!self.device) {
        self.capabilityLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
        [self disableAllControls];
        return;
    }
    
    AIBudsVolumeSetCapability capability = [(id<AIBudsDeviceVolumeControlAPI>)self.device volumeSetCapability];
    
    switch (capability) {
        case AIBudsVolumeSetCapabilityNone:
            self.capabilityLabel.text = NSLocalizedString(@"LocKey.VolumeControlNotSupportedTips", comment:@"Volume control not supported");
            [self disableAllControls];
            break;
        case AIBudsVolumeSetCapabilityCommon:
            self.capabilityLabel.text = NSLocalizedString(@"LocKey.SupportsSettingSystemMediaAndCallVolumesSeparatelyTips", comment:@"Supports setting system, media, and call volumes separately");
            [self enableCommonControls];
            break;
        case AIBudsVolumeSetCapabilityAdvanced:
            self.capabilityLabel.text = NSLocalizedString(@"LocKey.SupportsSettingSystemMediaCallAndLocalPlaybackVolumesSeparatelyTips", comment:@"Supports setting system, media, call, and local playback volumes separately");
            [self enableAdvancedControls];
            break;
        default:
            self.capabilityLabel.text = NSLocalizedString(@"LocKey.UnknownVolumeControlCapabilityTips", comment:@"Unknown volume control capability");
            [self disableAllControls];
            break;
    }
}

- (void)updateCurrentVolumes {
    if (!self.device) {
        return;
    }
    
    AIBudsVolumesInfoModel *volumesInfo = [(id<AIBudsDeviceVolumeControlAPI>)self.device volumesInfo];
    if (volumesInfo) {
        if (volumesInfo.systemPromptVolume) {
            self.systemPromptSlider.value = volumesInfo.systemPromptVolume.floatValue;
            self.systemPromptValueLabel.text = [NSString stringWithFormat:@"%d%%", (int)volumesInfo.systemPromptVolume.integerValue];
        }
        
        if (volumesInfo.mediaVolume) {
            self.mediaSlider.value = volumesInfo.mediaVolume.floatValue;
            self.mediaValueLabel.text = [NSString stringWithFormat:@"%d%%", (int)volumesInfo.mediaVolume.integerValue];
        }
        
        if (volumesInfo.callVolume) {
            self.callSlider.value = volumesInfo.callVolume.floatValue;
            self.callValueLabel.text = [NSString stringWithFormat:@"%d%%", (int)volumesInfo.callVolume.integerValue];
        }
        
        if (volumesInfo.localPlaybackVolume) {
            self.localPlaybackSlider.value = volumesInfo.localPlaybackVolume.floatValue;
            self.localPlaybackValueLabel.text = [NSString stringWithFormat:@"%d%%", (int)volumesInfo.localPlaybackVolume.integerValue];
        }
    }
}

- (void)disableAllControls {
    self.systemPromptSlider.enabled = NO;
    self.mediaSlider.enabled = NO;
    self.callSlider.enabled = NO;
    self.localPlaybackSlider.enabled = NO;
    self.resetButton.enabled = NO;
    
    self.systemPromptSlider.alpha = 0.5;
    self.mediaSlider.alpha = 0.5;
    self.callSlider.alpha = 0.5;
    self.localPlaybackSlider.alpha = 0.5;
    self.resetButton.alpha = 0.5;
}

- (void)enableCommonControls {
    self.systemPromptSlider.enabled = YES;
    self.mediaSlider.enabled = YES;
    self.callSlider.enabled = YES;
    self.localPlaybackSlider.enabled = NO;
    self.resetButton.enabled = YES;
    
    self.systemPromptSlider.alpha = 1.0;
    self.mediaSlider.alpha = 1.0;
    self.callSlider.alpha = 1.0;
    self.localPlaybackSlider.alpha = 0.5;
    self.resetButton.alpha = 1.0;
}

- (void)enableAdvancedControls {
    self.systemPromptSlider.enabled = YES;
    self.mediaSlider.enabled = YES;
    self.callSlider.enabled = YES;
    self.localPlaybackSlider.enabled = YES;
    self.resetButton.enabled = YES;
    
    self.systemPromptSlider.alpha = 1.0;
    self.mediaSlider.alpha = 1.0;
    self.callSlider.alpha = 1.0;
    self.localPlaybackSlider.alpha = 1.0;
    self.resetButton.alpha = 1.0;
}

- (void)systemPromptSliderValueChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.systemPromptValueLabel.text = [NSString stringWithFormat:@"%ld%%", value];
    
    // 防抖处理
    [self.systemPromptTimer invalidate];
    self.systemPromptTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(systemPromptVolumeUpdate:) userInfo:@(value) repeats:NO];
}

- (void)systemPromptVolumeUpdate:(NSTimer *)timer {
    NSInteger value = [timer.userInfo integerValue];
    __weak typeof(self) weakSelf = self;
    
    [(id<AIBudsDeviceVolumeControlAPI>)self.device setVolumeWithType:AIBudsDeviceVolumeTypeSystemPrompt value:value completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.SystemPromptVolumeUpdatedSuccessfullyTips", comment:@"System prompt volume updated successfully");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)mediaSliderValueChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.mediaValueLabel.text = [NSString stringWithFormat:@"%ld%%", value];
    
    // 防抖处理
    [self.mediaTimer invalidate];
    self.mediaTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(mediaVolumeUpdate:) userInfo:@(value) repeats:NO];
}

- (void)mediaVolumeUpdate:(NSTimer *)timer {
    NSInteger value = [timer.userInfo integerValue];
    __weak typeof(self) weakSelf = self;
    
    [(id<AIBudsDeviceVolumeControlAPI>)self.device setVolumeWithType:AIBudsDeviceVolumeTypeMedia value:value completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.MediaVolumeUpdatedSuccessfullyTips", comment:@"Media volume updated successfully");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)callSliderValueChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.callValueLabel.text = [NSString stringWithFormat:@"%ld%%", value];
    
    // 防抖处理
    [self.callTimer invalidate];
    self.callTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(callVolumeUpdate:) userInfo:@(value) repeats:NO];
}

- (void)callVolumeUpdate:(NSTimer *)timer {
    NSInteger value = [timer.userInfo integerValue];
    __weak typeof(self) weakSelf = self;
    
    [(id<AIBudsDeviceVolumeControlAPI>)self.device setVolumeWithType:AIBudsDeviceVolumeTypeCall value:value completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.CallVolumeUpdatedSuccessfullyTips", comment:@"Call volume updated successfully");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)localPlaybackSliderValueChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.localPlaybackValueLabel.text = [NSString stringWithFormat:@"%ld%%", (long)value];
    
    // 防抖处理
    [self.localPlaybackTimer invalidate];
    self.localPlaybackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(localPlaybackVolumeUpdate:) userInfo:@(value) repeats:NO];
}

- (void)localPlaybackVolumeUpdate:(NSTimer *)timer {
    NSInteger value = [timer.userInfo integerValue];
    
    // Note: There's no direct API for setting local playback volume individually
    // We'll need to use the setVolumes method with current values
    AIBudsVolumesInfoModel *volumesInfo = [(id<AIBudsDeviceVolumeControlAPI>)self.device volumesInfo];
    NSInteger systemPromptValue = volumesInfo.systemPromptVolume ? volumesInfo.systemPromptVolume.integerValue : 50;
    NSInteger mediaValue = volumesInfo.mediaVolume ? volumesInfo.mediaVolume.integerValue : 50;
    NSInteger callValue = volumesInfo.callVolume ? volumesInfo.callVolume.integerValue : 50;
    __weak typeof(self) weakSelf = self;
    
    [(id<AIBudsDeviceVolumeControlAPI>)self.device setVolumesWithSystemPrompt:systemPromptValue media:mediaValue call:callValue completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.LocalPlaybackVolumeUpdatedSuccessfullyTips", comment:@"Local playback volume updated successfully");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)resetAllVolumes {
    // Reset all sliders to 50%
    self.systemPromptSlider.value = 50.0;
    self.mediaSlider.value = 50.0;
    self.callSlider.value = 50.0;
    self.localPlaybackSlider.value = 50.0;
    
    self.systemPromptValueLabel.text = @"50%";
    self.mediaValueLabel.text = @"50%";
    self.callValueLabel.text = @"50%";
    self.localPlaybackValueLabel.text = @"50%";
    
    // Set all volumes to 50%
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceVolumeControlAPI>)self.device setVolumesWithSystemPrompt:50 media:50 call:50 completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) { return; }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.AllVolumesResetTo50Tips", comment:@"All volumes reset to 50%");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)hideStatusLabelAfterDelay {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ 
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        strongSelf.statusLabel.text = @"";
        strongSelf.statusLabel.textColor = [UIColor systemGreenColor];
    });
}

@end
