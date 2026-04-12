//
//  MusicControlDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-09.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "MusicControlDemoController.h"

@interface MusicControlDemoController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *volumeUpButton;
@property (nonatomic, strong) UIButton *volumeDownButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *unmuteButton;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UILabel *volumeValueLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSTimer *volumeUpdateTimer;

@property (nonatomic, assign) BOOL isVolumeChangedFromNotification;

@end

@implementation MusicControlDemoController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.MusicControlDemoTitle", comment:@"Music Control Demo");
    [self setupUI];
    [self updateUIForDeviceStatus];
    self.isVolumeChangedFromNotification = NO;
    [self registerNotifications];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"VolumesChangedNotification" object:nil];
}

- (void)volumeChanged:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        if(!strongSelf) return;
        AIBudsVolumesInfoModel *volumes = notification.object;
        if (volumes) {
            strongSelf.isVolumeChangedFromNotification = YES;
            strongSelf.volumeSlider.value = [volumes.systemPromptVolume integerValue];
            strongSelf.volumeValueLabel.text = [NSString stringWithFormat:@"%ld%%", [volumes.systemPromptVolume integerValue]];
        }
    });
   
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 创建主视图容器
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:containerView];
    
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    [containerView addSubview:self.scrollView];
    
    // 创建主栈视图
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 30;
    self.mainStackView.alignment = UIStackViewAlignmentFill;
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.mainStackView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 容器视图约束
        [containerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [containerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [containerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [containerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        // 滚动视图约束
        [self.scrollView.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],
        
        // 主栈视图约束
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.mainStackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-40] // 考虑 contentInset
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
    
    // 创建卡片视图
    UIView *playbackCardView = [self createCardView];
    
    // 添加播放控制标题
    UILabel *playbackTitleLabel = [[UILabel alloc] init];
    playbackTitleLabel.text = NSLocalizedString(@"LocKey.PlaybackControlTitle", comment:@"Playback Control");
    playbackTitleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    playbackTitleLabel.textColor = [UIColor labelColor];
    playbackTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [playbackCardView addSubview:playbackTitleLabel];
    
    // 创建播放控制按钮组
    UIStackView *playbackControlStack = [[UIStackView alloc] init];
    playbackControlStack.axis = UILayoutConstraintAxisHorizontal;
    playbackControlStack.spacing = 16;
    playbackControlStack.alignment = UIStackViewAlignmentCenter;
    playbackControlStack.distribution = UIStackViewDistributionFillEqually;
    playbackControlStack.translatesAutoresizingMaskIntoConstraints = NO;
    [playbackCardView addSubview:playbackControlStack];
    
    // 上一曲按钮
    self.previousButton = [self createModernControlButtonWithTitle:NSLocalizedString(@"LocKey.PreviousTrackButton", comment:@"Previous") color:[UIColor systemPurpleColor]];
    [self.previousButton addTarget:self action:@selector(previousButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [playbackControlStack addArrangedSubview:self.previousButton];
    
    // 暂停按钮
    self.pauseButton = [self createModernControlButtonWithTitle:NSLocalizedString(@"LocKey.PauseButton", comment:@"Pause") color:[UIColor systemOrangeColor]];
    [self.pauseButton addTarget:self action:@selector(pauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [playbackControlStack addArrangedSubview:self.pauseButton];
    
    // 播放按钮
    self.playButton = [self createModernControlButtonWithTitle:NSLocalizedString(@"LocKey.PlayButton", comment:@"Play") color:[UIColor systemGreenColor]];
    [self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [playbackControlStack addArrangedSubview:self.playButton];
    
    // 下一曲按钮
    self.nextButton = [self createModernControlButtonWithTitle:NSLocalizedString(@"LocKey.NextTrackButton", comment:@"Next") color:[UIColor systemPurpleColor]];
    [self.nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [playbackControlStack addArrangedSubview:self.nextButton];
    
    // 设置播放控制卡片内约束
    [NSLayoutConstraint activateConstraints:@[
        [playbackTitleLabel.topAnchor constraintEqualToAnchor:playbackCardView.topAnchor constant:20],
        [playbackTitleLabel.leadingAnchor constraintEqualToAnchor:playbackCardView.leadingAnchor constant:20],
        [playbackTitleLabel.trailingAnchor constraintEqualToAnchor:playbackCardView.trailingAnchor constant:-20],
        
        [playbackControlStack.topAnchor constraintEqualToAnchor:playbackTitleLabel.bottomAnchor constant:20],
        [playbackControlStack.leadingAnchor constraintEqualToAnchor:playbackCardView.leadingAnchor constant:20],
        [playbackControlStack.trailingAnchor constraintEqualToAnchor:playbackCardView.trailingAnchor constant:-20],
        [playbackControlStack.bottomAnchor constraintEqualToAnchor:playbackCardView.bottomAnchor constant:-20]
    ]];
    
    [self.mainStackView addArrangedSubview:playbackCardView];
    
    // 创建音量控制卡片
    UIView *volumeCardView = [self createCardView];
    
    // 添加音量控制标题
    UILabel *volumeTitleLabel = [[UILabel alloc] init];
    volumeTitleLabel.text = NSLocalizedString(@"LocKey.VolumeControlTitle", comment:@"Volume Control");
    volumeTitleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    volumeTitleLabel.textColor = [UIColor labelColor];
    volumeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [volumeCardView addSubview:volumeTitleLabel];
    
    // 音量滑块
    UIStackView *sliderStack = [[UIStackView alloc] init];
    sliderStack.axis = UILayoutConstraintAxisHorizontal;
    sliderStack.spacing = 16;
    sliderStack.alignment = UIStackViewAlignmentCenter;
    sliderStack.translatesAutoresizingMaskIntoConstraints = NO;
    [volumeCardView addSubview:sliderStack];
    
    self.volumeSlider = [[UISlider alloc] init];
    self.volumeSlider.minimumValue = 0;
    self.volumeSlider.maximumValue = 100;
    self.volumeSlider.value = 50;
    self.volumeSlider.minimumTrackTintColor = [UIColor systemBlueColor];
    self.volumeSlider.maximumTrackTintColor = [UIColor systemGray3Color];
    self.volumeSlider.thumbTintColor = [UIColor systemBlueColor];
    [self.volumeSlider addTarget:self action:@selector(volumeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderStack addArrangedSubview:self.volumeSlider];
    
    self.volumeValueLabel = [[UILabel alloc] init];
    
    self.volumeValueLabel.text = @"50%";
    
    id<AIBudsDeviceVolumeControlAPI> aiDevice = (id<AIBudsDeviceVolumeControlAPI>)self.device;
    if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceVolumeControlAPI)]) {
        AIBudsVolumesInfoModel* volumesInfo = aiDevice.volumesInfo;
        if ([volumesInfo isKindOfClass:[AIBudsVolumesInfoModel class]])
        {
            self.volumeValueLabel.text = [NSString stringWithFormat:@"%@%%", volumesInfo.systemPromptVolume];
        }
    }
    self.volumeValueLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.volumeValueLabel.textColor = [UIColor labelColor];
    [self.volumeValueLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.volumeValueLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [sliderStack addArrangedSubview:self.volumeValueLabel];
    
    // 音量按钮组
    UIStackView *volumeButtonsStack = [[UIStackView alloc] init];
    volumeButtonsStack.axis = UILayoutConstraintAxisHorizontal;
    volumeButtonsStack.spacing = 12;
    volumeButtonsStack.alignment = UIStackViewAlignmentCenter;
    volumeButtonsStack.distribution = UIStackViewDistributionFillEqually;
    volumeButtonsStack.translatesAutoresizingMaskIntoConstraints = NO;
    [volumeCardView addSubview:volumeButtonsStack];
    
    self.volumeDownButton = [self createModernControlButtonWithTitle:NSLocalizedString(@"LocKey.VolumeDownButton", comment:@"Volume Down") color:[UIColor systemBlueColor]];
    [self.volumeDownButton addTarget:self action:@selector(volumeDownButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [volumeButtonsStack addArrangedSubview:self.volumeDownButton];
    
    self.muteButton = [self createModernControlButtonWithTitle:NSLocalizedString(@"LocKey.MuteButton", comment:@"Mute") color:[UIColor systemRedColor]];
    [self.muteButton addTarget:self action:@selector(muteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [volumeButtonsStack addArrangedSubview:self.muteButton];
    
    self.unmuteButton = [self createModernControlButtonWithTitle:NSLocalizedString(@"LocKey.UnmuteButton", comment:@"Unmute") color:[UIColor systemGreenColor]];
    [self.unmuteButton addTarget:self action:@selector(unmuteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [volumeButtonsStack addArrangedSubview:self.unmuteButton];
    
    self.volumeUpButton = [self createModernControlButtonWithTitle:NSLocalizedString(@"LocKey.VolumeUpButton", comment:@"Volume Up") color:[UIColor systemBlueColor]];
    [self.volumeUpButton addTarget:self action:@selector(volumeUpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [volumeButtonsStack addArrangedSubview:self.volumeUpButton];
    
    // 设置音量控制卡片内约束
    [NSLayoutConstraint activateConstraints:@[
        [volumeTitleLabel.topAnchor constraintEqualToAnchor:volumeCardView.topAnchor constant:20],
        [volumeTitleLabel.leadingAnchor constraintEqualToAnchor:volumeCardView.leadingAnchor constant:20],
        [volumeTitleLabel.trailingAnchor constraintEqualToAnchor:volumeCardView.trailingAnchor constant:-20],
        
        [sliderStack.topAnchor constraintEqualToAnchor:volumeTitleLabel.bottomAnchor constant:20],
        [sliderStack.leadingAnchor constraintEqualToAnchor:volumeCardView.leadingAnchor constant:20],
        [sliderStack.trailingAnchor constraintEqualToAnchor:volumeCardView.trailingAnchor constant:-20],
        
        [volumeButtonsStack.topAnchor constraintEqualToAnchor:sliderStack.bottomAnchor constant:20],
        [volumeButtonsStack.leadingAnchor constraintEqualToAnchor:volumeCardView.leadingAnchor constant:20],
        [volumeButtonsStack.trailingAnchor constraintEqualToAnchor:volumeCardView.trailingAnchor constant:-20],
        [volumeButtonsStack.bottomAnchor constraintEqualToAnchor:volumeCardView.bottomAnchor constant:-20]
    ]];
    
    [self.mainStackView addArrangedSubview:volumeCardView];
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

- (UIButton *)createModernControlButtonWithTitle:(NSString *)title color:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = color;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 12;
    button.layer.shadowColor = color.CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 2);
    button.layer.shadowOpacity = 0.3;
    button.layer.shadowRadius = 4;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [button.heightAnchor constraintEqualToConstant:48]
    ]];
    
    // 添加按钮点击效果
    [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    
    return button;
}

- (void)buttonTouchDown:(UIButton *)button {
    [UIView animateWithDuration:0.1 animations:^{ 
        button.transform = CGAffineTransformMakeScale(0.95, 0.95);
        button.alpha = 0.8;
    }];
}

- (void)buttonTouchUp:(UIButton *)button {
    [UIView animateWithDuration:0.1 animations:^{ 
        button.transform = CGAffineTransformIdentity;
        button.alpha = 1.0;
    }];
}

- (void)updateUIForDeviceStatus {
    if (!self.device) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
        [self disableAllControls];
        return;
    }
    
    self.statusLabel.text = NSLocalizedString(@"LocKey.DeviceConnected", comment:@"Device connected");
    [self enableAllControls];
}

- (void)disableAllControls {
    self.playButton.enabled = NO;
    self.pauseButton.enabled = NO;
    self.nextButton.enabled = NO;
    self.previousButton.enabled = NO;
    self.volumeUpButton.enabled = NO;
    self.volumeDownButton.enabled = NO;
    self.muteButton.enabled = NO;
    self.unmuteButton.enabled = NO;
    self.volumeSlider.enabled = NO;
    
    self.playButton.alpha = 0.5;
    self.pauseButton.alpha = 0.5;
    self.nextButton.alpha = 0.5;
    self.previousButton.alpha = 0.5;
    self.volumeUpButton.alpha = 0.5;
    self.volumeDownButton.alpha = 0.5;
    self.muteButton.alpha = 0.5;
    self.unmuteButton.alpha = 0.5;
    self.volumeSlider.alpha = 0.5;
}

- (void)enableAllControls {
    self.playButton.enabled = YES;
    self.pauseButton.enabled = YES;
    self.nextButton.enabled = YES;
    self.previousButton.enabled = YES;
    self.volumeUpButton.enabled = YES;
    self.volumeDownButton.enabled = YES;
    self.muteButton.enabled = YES;
    self.unmuteButton.enabled = YES;
    self.volumeSlider.enabled = YES;
    
    self.playButton.alpha = 1.0;
    self.pauseButton.alpha = 1.0;
    self.nextButton.alpha = 1.0;
    self.previousButton.alpha = 1.0;
    self.volumeUpButton.alpha = 1.0;
    self.volumeDownButton.alpha = 1.0;
    self.muteButton.alpha = 1.0;
    self.unmuteButton.alpha = 1.0;
    self.volumeSlider.alpha = 1.0;
}

- (void)playButtonTapped:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device playMusicWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.MusicPlaybackStarted", comment:@"Music playback started");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)pauseButtonTapped:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device pauseMusicWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.MusicPlaybackPaused", comment:@"Music playback paused");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)nextButtonTapped:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device playNextMusicWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.SkippedToNextTrack", comment:@"Skipped to next track");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)previousButtonTapped:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device playPreviousMusicWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.SkippedToPreviousTrack", comment:@"Skipped to previous track");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)volumeUpButtonTapped:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device musicVolumeUpWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.VolumeIncreased", comment:@"Volume increased");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)volumeDownButtonTapped:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device musicVolumeDownWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.VolumeDecreased", comment:@"Volume decreased");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)muteButtonTapped:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device muteWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.VolumeMuted", comment:@"Volume muted");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)unmuteButtonTapped:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device unmuteWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.VolumeUnmuted", comment:@"Volume unmuted");
                [strongSelf hideStatusLabelAfterDelay];
            } else {
                strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                [strongSelf hideStatusLabelAfterDelay];
            }
        });
    }];
}

- (void)volumeSliderValueChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.volumeValueLabel.text = [NSString stringWithFormat:@"%ld%%", value];
    if(self.isVolumeChangedFromNotification)
    {
        self.isVolumeChangedFromNotification = NO;
        return;
    }
    // 防抖处理
    [self.volumeUpdateTimer invalidate];
    self.volumeUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 
                                                              target:self 
                                                            selector:@selector(volumeUpdate:) 
                                                            userInfo:@(value) 
                                                             repeats:NO];
}

- (void)volumeUpdate:(NSTimer *)timer {
    NSInteger value = [timer.userInfo integerValue];
    
    __weak typeof(self) weakSelf = self;
    [(id<AIBudsDeviceMusicControlAPI>)self.device setMusicVolume:value completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (success) {
                strongSelf.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.VolumeSetTo", comment:@"Volume set to %d%%"), value];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ 
        self.statusLabel.text = @"";
        self.statusLabel.textColor = [UIColor systemGrayColor];
    });
}

@end
