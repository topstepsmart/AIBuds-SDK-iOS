//
//  AudioRecordingDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-09.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AudioRecordingDemoController.h"

@interface AudioRecordingDemoController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) UILabel *statusLabel;

// 普通录音控制
@property (nonatomic, strong) UIView *normalRecordingCardView;
@property (nonatomic, strong) UIButton *startRecordingButton;
@property (nonatomic, strong) UIButton *stopRecordingButton;
@property (nonatomic, strong) UILabel *recordingStatusLabel;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, assign) NSTimeInterval recordingDuration;

// AI 录音控制
@property (nonatomic, strong) UIView *aiRecordingCardView;
@property (nonatomic, strong) UISegmentedControl *aiSceneSegmentedControl;
@property (nonatomic, strong) UIButton *startAIRecordingButton;
@property (nonatomic, strong) UIButton *stopAIRecordingButton;
@property (nonatomic, strong) UILabel *aiRecordingStatusLabel;

// 最大录音时长设置
@property (nonatomic, strong) UIView *maxDurationCardView;
@property (nonatomic, strong) UISlider *maxDurationSlider;
@property (nonatomic, strong) UILabel *maxDurationValueLabel;

@end

@implementation AudioRecordingDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.AudioRecordingDemoTitle", comment:@"Audio Recording Demo");
    [self setupUI];
    [self loadAudioRecordingSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAudioRecordingSettings];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRecordingTimer];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    [self.view addSubview:self.scrollView];
    
    // 创建主栈视图
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 20;
    self.mainStackView.alignment = UIStackViewAlignmentFill;
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.mainStackView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.mainStackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-40]
    ]];
    
    // 添加状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = [UIColor systemGrayColor];
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.heightAnchor constraintEqualToConstant:44]
    ]];
    [self.mainStackView addArrangedSubview:self.statusLabel];
    
    // 创建普通录音控制卡片
    [self setupNormalRecordingCard];
    
    // 创建 AI 录音控制卡片
    [self setupAIRecordingCard];
    
    // 创建最大录音时长设置卡片
    [self setupMaxDurationCard];
}

- (void)setupNormalRecordingCard {
    self.normalRecordingCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.NormalRecordingTitle", comment:@"Normal Recording");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.normalRecordingCardView addSubview:titleLabel];
    
    // 状态标签
    self.recordingStatusLabel = [[UILabel alloc] init];
    self.recordingStatusLabel.text = NSLocalizedString(@"LocKey.RecordingStatusReady", comment:@"Ready to record");
    self.recordingStatusLabel.font = [UIFont systemFontOfSize:16];
    self.recordingStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.recordingStatusLabel.textColor = [UIColor systemBlueColor];
    self.recordingStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.normalRecordingCardView addSubview:self.recordingStatusLabel];
    
    // 按钮栈视图
    UIStackView *buttonStackView = [[UIStackView alloc] init];
    buttonStackView.axis = UILayoutConstraintAxisHorizontal;
    buttonStackView.spacing = 20;
    buttonStackView.alignment = UIStackViewAlignmentFill;
    buttonStackView.distribution = UIStackViewDistributionFillEqually;
    buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.normalRecordingCardView addSubview:buttonStackView];
    
    // 开始录音按钮
    self.startRecordingButton = [self createPrimaryButtonWithTitle:NSLocalizedString(@"LocKey.StartRecording", comment:@"Start Recording")];
    [self.startRecordingButton addTarget:self action:@selector(startRecordingButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttonStackView addArrangedSubview:self.startRecordingButton];
    
    // 停止录音按钮
    self.stopRecordingButton = [self createSecondaryButtonWithTitle:NSLocalizedString(@"LocKey.StopRecording", comment:@"Stop Recording")];
    [self.stopRecordingButton addTarget:self action:@selector(stopRecordingButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.stopRecordingButton setEnabled:NO];
    [buttonStackView addArrangedSubview:self.stopRecordingButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.normalRecordingCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.normalRecordingCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.normalRecordingCardView.trailingAnchor constant:-20],
        
        [self.recordingStatusLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:20],
        [self.recordingStatusLabel.centerXAnchor constraintEqualToAnchor:self.normalRecordingCardView.centerXAnchor],
        
        [buttonStackView.topAnchor constraintEqualToAnchor:self.recordingStatusLabel.bottomAnchor constant:20],
        [buttonStackView.leadingAnchor constraintEqualToAnchor:self.normalRecordingCardView.leadingAnchor constant:20],
        [buttonStackView.trailingAnchor constraintEqualToAnchor:self.normalRecordingCardView.trailingAnchor constant:-20],
        [buttonStackView.bottomAnchor constraintEqualToAnchor:self.normalRecordingCardView.bottomAnchor constant:-20],
        [buttonStackView.heightAnchor constraintEqualToConstant:50]
    ]];
    
    [self.mainStackView addArrangedSubview:self.normalRecordingCardView];
}

- (void)setupAIRecordingCard {
    self.aiRecordingCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.AIRecordingTitle", comment:@"AI Recording");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.aiRecordingCardView addSubview:titleLabel];
    
    // 场景选择
    self.aiSceneSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"LocKey.SceneOnSite", comment:@"On-site Recording"),
        NSLocalizedString(@"LocKey.SceneCall", comment:@"Call Recording")
    ]];
    self.aiSceneSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.aiRecordingCardView addSubview:self.aiSceneSegmentedControl];
    
    // 状态标签
    self.aiRecordingStatusLabel = [[UILabel alloc] init];
    self.aiRecordingStatusLabel.text = NSLocalizedString(@"LocKey.RecordingStatusReady", comment:@"Ready to record");
    self.aiRecordingStatusLabel.font = [UIFont systemFontOfSize:16];
    self.aiRecordingStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.aiRecordingStatusLabel.textColor = [UIColor systemPurpleColor];
    self.aiRecordingStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.aiRecordingCardView addSubview:self.aiRecordingStatusLabel];
    
    // 按钮栈视图
    UIStackView *buttonStackView = [[UIStackView alloc] init];
    buttonStackView.axis = UILayoutConstraintAxisHorizontal;
    buttonStackView.spacing = 20;
    buttonStackView.alignment = UIStackViewAlignmentFill;
    buttonStackView.distribution = UIStackViewDistributionFillEqually;
    buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.aiRecordingCardView addSubview:buttonStackView];
    
    // 开始 AI 录音按钮
    self.startAIRecordingButton = [self createPrimaryButtonWithTitle:NSLocalizedString(@"LocKey.StartAIRecording", comment:@"Start AI Recording")];
    [self.startAIRecordingButton addTarget:self action:@selector(startAIRecordingButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttonStackView addArrangedSubview:self.startAIRecordingButton];
    
    // 停止 AI 录音按钮
    self.stopAIRecordingButton = [self createSecondaryButtonWithTitle:NSLocalizedString(@"LocKey.StopAIRecording", comment:@"Stop AI Recording")];
    [self.stopAIRecordingButton addTarget:self action:@selector(stopAIRecordingButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.stopAIRecordingButton setEnabled:NO];
    [buttonStackView addArrangedSubview:self.stopAIRecordingButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.aiRecordingCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.aiRecordingCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.aiRecordingCardView.trailingAnchor constant:-20],
        
        [self.aiSceneSegmentedControl.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.aiSceneSegmentedControl.leadingAnchor constraintEqualToAnchor:self.aiRecordingCardView.leadingAnchor constant:20],
        [self.aiSceneSegmentedControl.trailingAnchor constraintEqualToAnchor:self.aiRecordingCardView.trailingAnchor constant:-20],
        
        [self.aiRecordingStatusLabel.topAnchor constraintEqualToAnchor:self.aiSceneSegmentedControl.bottomAnchor constant:20],
        [self.aiRecordingStatusLabel.centerXAnchor constraintEqualToAnchor:self.aiRecordingCardView.centerXAnchor],
        
        [buttonStackView.topAnchor constraintEqualToAnchor:self.aiRecordingStatusLabel.bottomAnchor constant:20],
        [buttonStackView.leadingAnchor constraintEqualToAnchor:self.aiRecordingCardView.leadingAnchor constant:20],
        [buttonStackView.trailingAnchor constraintEqualToAnchor:self.aiRecordingCardView.trailingAnchor constant:-20],
        [buttonStackView.bottomAnchor constraintEqualToAnchor:self.aiRecordingCardView.bottomAnchor constant:-20],
        [buttonStackView.heightAnchor constraintEqualToConstant:50]
    ]];
    
    [self.mainStackView addArrangedSubview:self.aiRecordingCardView];
}

- (void)setupMaxDurationCard {
    self.maxDurationCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.MaxRecordingDurationTitle", comment:@"Max Recording Duration");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.maxDurationCardView addSubview:titleLabel];
    
    // 数值标签
    self.maxDurationValueLabel = [[UILabel alloc] init];
    self.maxDurationValueLabel.text = @"0";
    self.maxDurationValueLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    self.maxDurationValueLabel.textColor = [UIColor systemGreenColor];
    self.maxDurationValueLabel.textAlignment = NSTextAlignmentCenter;
    self.maxDurationValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.maxDurationCardView addSubview:self.maxDurationValueLabel];
    
    // 滑块
    self.maxDurationSlider = [[UISlider alloc] init];
    self.maxDurationSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.maxDurationSlider.minimumValue = 1;
    self.maxDurationSlider.maximumValue = 120; // 2 小时
    self.maxDurationSlider.value = 30; // 默认 30 分钟
    [self.maxDurationSlider addTarget:self action:@selector(maxDurationChanged:) forControlEvents:UIControlEventValueChanged];
    [self.maxDurationSlider addTarget:self action:@selector(maxDurationChangeEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.maxDurationCardView addSubview:self.maxDurationSlider];
    
    // 单位标签
    UILabel *unitLabel = [[UILabel alloc] init];
    unitLabel.text = NSLocalizedString(@"LocKey.Minutes", comment:@"Minutes");
    unitLabel.font = [UIFont systemFontOfSize:14];
    unitLabel.textColor = [UIColor systemGrayColor];
    unitLabel.textAlignment = NSTextAlignmentCenter;
    unitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.maxDurationCardView addSubview:unitLabel];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.maxDurationCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.maxDurationCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.maxDurationCardView.trailingAnchor constant:-20],
        
        [self.maxDurationValueLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.maxDurationValueLabel.centerXAnchor constraintEqualToAnchor:self.maxDurationCardView.centerXAnchor],
        
        [self.maxDurationSlider.topAnchor constraintEqualToAnchor:self.maxDurationValueLabel.bottomAnchor constant:15],
        [self.maxDurationSlider.leadingAnchor constraintEqualToAnchor:self.maxDurationCardView.leadingAnchor constant:20],
        [self.maxDurationSlider.trailingAnchor constraintEqualToAnchor:self.maxDurationCardView.trailingAnchor constant:-20],
        
        [unitLabel.topAnchor constraintEqualToAnchor:self.maxDurationSlider.bottomAnchor constant:10],
        [unitLabel.centerXAnchor constraintEqualToAnchor:self.maxDurationCardView.centerXAnchor],
        [unitLabel.bottomAnchor constraintEqualToAnchor:self.maxDurationCardView.bottomAnchor constant:-20]
    ]];
    
    [self.mainStackView addArrangedSubview:self.maxDurationCardView];
}

- (UIView *)createCardView {
    UIView *cardView = [[UIView alloc] init];
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    cardView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    cardView.layer.cornerRadius = 16;
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOffset = CGSizeMake(0, 2);
    cardView.layer.shadowOpacity = 0.1;
    cardView.layer.shadowRadius = 4;
    return cardView;
}

- (UIButton *)createPrimaryButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    button.backgroundColor = [UIColor systemBlueColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 12;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (UIButton *)createSecondaryButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    button.backgroundColor = [UIColor systemGray2Color];
    [button setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 12;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

#pragma mark - Load Settings

- (void)loadAudioRecordingSettings {
    if (!self.device) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
        [self setControlsEnabled:NO];
        return;
    }
    
    id<AIBudsDeviceAudioRecordingAPI> audioDevice = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    if ([audioDevice conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) {
        [self setControlsEnabled:YES];
        
        // 加载最大录音时长
        NSNumber *maxDuration = audioDevice.maxAudioRecordDuration;
        if (maxDuration) {
            self.maxDurationSlider.value = maxDuration.intValue;
            self.maxDurationValueLabel.text = [NSString stringWithFormat:@"%d", maxDuration.intValue];
        }
        
        self.statusLabel.text = NSLocalizedString(@"LocKey.AudioRecordingSettingsLoaded", comment:@"Audio recording settings loaded");
    } else {
        self.statusLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportAudioRecording", comment:@"Device does not support audio recording");
        [self setControlsEnabled:NO];
    }
}

- (void)setControlsEnabled:(BOOL)enabled {
    self.startRecordingButton.enabled = enabled;
    self.stopRecordingButton.enabled = enabled && self.recordingTimer != nil;
    self.startAIRecordingButton.enabled = enabled;
    self.stopAIRecordingButton.enabled = enabled && self.stopAIRecordingButton.isEnabled;
    self.maxDurationSlider.enabled = enabled;
    self.aiSceneSegmentedControl.enabled = enabled;
}

#pragma mark - Recording Timer

- (void)startRecordingTimer {
    [self stopRecordingTimer];
    self.recordingDuration = 0;
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecordingTimer) userInfo:nil repeats:YES];
}

- (void)stopRecordingTimer {
    [self.recordingTimer invalidate];
    self.recordingTimer = nil;
}

- (void)updateRecordingTimer {
    self.recordingDuration += 1.0;
    NSInteger hours = (NSInteger)self.recordingDuration / 3600;
    NSInteger minutes = ((NSInteger)self.recordingDuration % 3600) / 60;
    NSInteger seconds = (NSInteger)self.recordingDuration % 60;
    
    if (hours > 0) {
        self.recordingStatusLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        self.recordingStatusLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
}

#pragma mark - Actions

- (void)startRecordingButtonTapped {
    if (!self.device) return;
    
    id<AIBudsDeviceAudioRecordingAPI> audioDevice = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    if (![audioDevice conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) return;
    
    __weak typeof(self) weakSelf = self;
    [audioDevice requestStartAudioRecordingWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.RecordingStarted", comment:@"Recording started");
                strongSelf.recordingStatusLabel.text = NSLocalizedString(@"LocKey.RecordingInProgress", comment:@"Recording in progress");
                [strongSelf.startRecordingButton setEnabled:NO];
                [strongSelf.stopRecordingButton setEnabled:YES];
                [strongSelf startRecordingTimer];
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.RecordingStartFailed", comment:@"Failed to start recording");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)stopRecordingButtonTapped {
    if (!self.device) return;
    
    id<AIBudsDeviceAudioRecordingAPI> audioDevice = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    if (![audioDevice conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) return;
    
    __weak typeof(self) weakSelf = self;
    [audioDevice requestStopAudioRecordingWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.RecordingStopped", comment:@"Recording stopped");
                strongSelf.recordingStatusLabel.text = NSLocalizedString(@"LocKey.RecordingStatusReady", comment:@"Ready to record");
                [strongSelf.startRecordingButton setEnabled:YES];
                [strongSelf.stopRecordingButton setEnabled:NO];
                [strongSelf stopRecordingTimer];
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.RecordingStopFailed", comment:@"Failed to stop recording");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)startAIRecordingButtonTapped {
    if (!self.device) return;
    
    id<AIBudsDeviceAudioRecordingAPI> audioDevice = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    if (![audioDevice conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) return;
    
    AIBudsRecordingScene scene;
    switch (self.aiSceneSegmentedControl.selectedSegmentIndex) {
        case 0:
            scene = AIBudsRecordingSceneOnSite;
            break;
        case 1:
            scene = AIBudsRecordingSceneCall;
            break;
        default:
            scene = AIBudsRecordingSceneOnSite;
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    [audioDevice startAIAudioRecordingWithScene:scene completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.AIRecordingStarted", comment:@"AI recording started");
                strongSelf.aiRecordingStatusLabel.text = NSLocalizedString(@"LocKey.RecordingInProgress", comment:@"Recording in progress");
                [strongSelf.startAIRecordingButton setEnabled:NO];
                [strongSelf.stopAIRecordingButton setEnabled:YES];
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.AIRecordingStartFailed", comment:@"Failed to start AI recording");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)stopAIRecordingButtonTapped {
    if (!self.device) return;
    
    id<AIBudsDeviceAudioRecordingAPI> audioDevice = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    if (![audioDevice conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) return;
    
    AIBudsRecordingScene scene;
    switch (self.aiSceneSegmentedControl.selectedSegmentIndex) {
        case 0:
            scene = AIBudsRecordingSceneOnSite;
            break;
        case 1:
            scene = AIBudsRecordingSceneCall;
            break;
        default:
            scene = AIBudsRecordingSceneOnSite;
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    [audioDevice stopAIAudioRecordingWithScene:scene completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.AIRecordingStopped", comment:@"AI recording stopped");
                strongSelf.aiRecordingStatusLabel.text = NSLocalizedString(@"LocKey.RecordingStatusReady", comment:@"Ready to record");
                [strongSelf.startAIRecordingButton setEnabled:YES];
                [strongSelf.stopAIRecordingButton setEnabled:NO];
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.AIRecordingStopFailed", comment:@"Failed to stop AI recording");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)maxDurationChanged:(UISlider *)sender {
    self.maxDurationValueLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (void)maxDurationChangeEnded:(UISlider *)sender {
    if (!self.device) return;
    
    id<AIBudsDeviceAudioRecordingAPI> audioDevice = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    if (![audioDevice conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) return;
    
    int duration = (int)sender.value;
    
    __weak typeof(self) weakSelf = self;
    [audioDevice setMaxAudioRecordDuration:duration completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.MaxDurationSetSuccess", comment:@"Max recording duration set successfully");
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.MaxDurationSetFailed", comment:@"Failed to set max recording duration");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                // 恢复之前的值
                [strongSelf loadAudioRecordingSettings];
            }
        });
    }];
}

@end
