//
//  VideoRecordingDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-09.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "VideoRecordingDemoController.h"

@interface VideoRecordingDemoController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) UILabel *statusLabel;

// 相机信息
@property (nonatomic, strong) UIView *cameraInfoCardView;
@property (nonatomic, strong) UILabel *firmwareVersionLabel;

// 最大录制时长设置
@property (nonatomic, strong) UIView *maxDurationCardView;
@property (nonatomic, strong) UISlider *maxDurationSlider;
@property (nonatomic, strong) UILabel *maxDurationValueLabel;

// 拍照控制
@property (nonatomic, strong) UIView *photoCardView;
@property (nonatomic, strong) UISegmentedControl *captureModeSegmentedControl;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *stopPhotoButton;
@property (nonatomic, strong) UILabel *photoStatusLabel;

// 视频录制控制
@property (nonatomic, strong) UIView *videoCardView;
@property (nonatomic, strong) UIButton *startRecordingButton;
@property (nonatomic, strong) UIButton *stopRecordingButton;
@property (nonatomic, strong) UILabel *videoStatusLabel;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, assign) NSTimeInterval recordingDuration;

@end

@implementation VideoRecordingDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.VideoRecordingDemoTitle", comment:@"Video Recording Demo");
    [self setupUI];
    [self loadVideoRecordingSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadVideoRecordingSettings];
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
    
    // 创建相机信息卡片
    [self setupCameraInfoCard];
    
    // 创建最大录制时长设置卡片
    [self setupMaxDurationCard];
    
    // 创建拍照控制卡片
    [self setupPhotoCard];
    
    // 创建视频录制控制卡片
    [self setupVideoCard];
}

- (void)setupCameraInfoCard {
    self.cameraInfoCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.CameraInfoTitle", comment:@"Camera Info");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cameraInfoCardView addSubview:titleLabel];
    
    // 固件版本标签
    UILabel *firmwareLabel = [[UILabel alloc] init];
    firmwareLabel.text = NSLocalizedString(@"LocKey.FirmwareVersion", comment:@"Firmware Version:");
    firmwareLabel.font = [UIFont systemFontOfSize:16];
    firmwareLabel.textColor = [UIColor systemGrayColor];
    firmwareLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cameraInfoCardView addSubview:firmwareLabel];
    
    // 固件版本值
    self.firmwareVersionLabel = [[UILabel alloc] init];
    self.firmwareVersionLabel.text = NSLocalizedString(@"LocKey.Unknown", comment:@"Unknown");
    self.firmwareVersionLabel.font = [UIFont systemFontOfSize:16];
    self.firmwareVersionLabel.textColor = [UIColor labelColor];
    self.firmwareVersionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cameraInfoCardView addSubview:self.firmwareVersionLabel];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.cameraInfoCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.cameraInfoCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.cameraInfoCardView.trailingAnchor constant:-20],
        
        [firmwareLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [firmwareLabel.leadingAnchor constraintEqualToAnchor:self.cameraInfoCardView.leadingAnchor constant:20],
        
        [self.firmwareVersionLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.firmwareVersionLabel.leadingAnchor constraintEqualToAnchor:firmwareLabel.trailingAnchor constant:10],
        [self.firmwareVersionLabel.trailingAnchor constraintEqualToAnchor:self.cameraInfoCardView.trailingAnchor constant:-20],
        [self.firmwareVersionLabel.bottomAnchor constraintEqualToAnchor:self.cameraInfoCardView.bottomAnchor constant:-20]
    ]];
    
    [self.mainStackView addArrangedSubview:self.cameraInfoCardView];
}

- (void)setupMaxDurationCard {
    self.maxDurationCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.MaxVideoRecordingDurationTitle", comment:@"Max Video Recording Duration");
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

- (void)setupPhotoCard {
    self.photoCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.PhotoTakingTitle", comment:@"Photo Taking");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.photoCardView addSubview:titleLabel];
    
    // 拍摄模式选择
    self.captureModeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"LocKey.CaptureModeCamera", comment:@"Camera"),
        NSLocalizedString(@"LocKey.CaptureModeAI", comment:@"AI")
    ]];
    self.captureModeSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.photoCardView addSubview:self.captureModeSegmentedControl];
    
    // 状态标签
    self.photoStatusLabel = [[UILabel alloc] init];
    self.photoStatusLabel.text = NSLocalizedString(@"LocKey.ReadyToCapture", comment:@"Ready to capture");
    self.photoStatusLabel.font = [UIFont systemFontOfSize:16];
    self.photoStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.photoStatusLabel.textColor = [UIColor systemBlueColor];
    self.photoStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.photoCardView addSubview:self.photoStatusLabel];
    
    // 按钮栈视图
    UIStackView *buttonStackView = [[UIStackView alloc] init];
    buttonStackView.axis = UILayoutConstraintAxisHorizontal;
    buttonStackView.spacing = 20;
    buttonStackView.alignment = UIStackViewAlignmentFill;
    buttonStackView.distribution = UIStackViewDistributionFillEqually;
    buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.photoCardView addSubview:buttonStackView];
    
    // 拍照按钮
    self.takePhotoButton = [self createPrimaryButtonWithTitle:NSLocalizedString(@"LocKey.TakePhoto", comment:@"Take Photo")];
    [self.takePhotoButton addTarget:self action:@selector(takePhotoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttonStackView addArrangedSubview:self.takePhotoButton];
    
    // 停止拍照按钮
    self.stopPhotoButton = [self createSecondaryButtonWithTitle:NSLocalizedString(@"LocKey.StopPhoto", comment:@"Stop Photo")];
    [self.stopPhotoButton addTarget:self action:@selector(stopPhotoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.stopPhotoButton setEnabled:NO];
    [buttonStackView addArrangedSubview:self.stopPhotoButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.photoCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.photoCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.photoCardView.trailingAnchor constant:-20],
        
        [self.captureModeSegmentedControl.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.captureModeSegmentedControl.leadingAnchor constraintEqualToAnchor:self.photoCardView.leadingAnchor constant:20],
        [self.captureModeSegmentedControl.trailingAnchor constraintEqualToAnchor:self.photoCardView.trailingAnchor constant:-20],
        
        [self.photoStatusLabel.topAnchor constraintEqualToAnchor:self.captureModeSegmentedControl.bottomAnchor constant:20],
        [self.photoStatusLabel.centerXAnchor constraintEqualToAnchor:self.photoCardView.centerXAnchor],
        
        [buttonStackView.topAnchor constraintEqualToAnchor:self.photoStatusLabel.bottomAnchor constant:20],
        [buttonStackView.leadingAnchor constraintEqualToAnchor:self.photoCardView.leadingAnchor constant:20],
        [buttonStackView.trailingAnchor constraintEqualToAnchor:self.photoCardView.trailingAnchor constant:-20],
        [buttonStackView.bottomAnchor constraintEqualToAnchor:self.photoCardView.bottomAnchor constant:-20],
        [buttonStackView.heightAnchor constraintEqualToConstant:50]
    ]];
    
    [self.mainStackView addArrangedSubview:self.photoCardView];
}

- (void)setupVideoCard {
    self.videoCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.VideoRecordingTitle", comment:@"Video Recording");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.videoCardView addSubview:titleLabel];
    
    // 状态标签
    self.videoStatusLabel = [[UILabel alloc] init];
    self.videoStatusLabel.text = NSLocalizedString(@"LocKey.ReadyToRecord", comment:@"Ready to record");
    self.videoStatusLabel.font = [UIFont systemFontOfSize:16];
    self.videoStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.videoStatusLabel.textColor = [UIColor systemRedColor];
    self.videoStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.videoCardView addSubview:self.videoStatusLabel];
    
    // 按钮栈视图
    UIStackView *buttonStackView = [[UIStackView alloc] init];
    buttonStackView.axis = UILayoutConstraintAxisHorizontal;
    buttonStackView.spacing = 20;
    buttonStackView.alignment = UIStackViewAlignmentFill;
    buttonStackView.distribution = UIStackViewDistributionFillEqually;
    buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.videoCardView addSubview:buttonStackView];
    
    // 开始录制按钮
    self.startRecordingButton = [self createPrimaryButtonWithTitle:NSLocalizedString(@"LocKey.StartVideoRecording", comment:@"Start Video Recording")];
    [self.startRecordingButton addTarget:self action:@selector(startRecordingButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttonStackView addArrangedSubview:self.startRecordingButton];
    
    // 停止录制按钮
    self.stopRecordingButton = [self createSecondaryButtonWithTitle:NSLocalizedString(@"LocKey.StopVideoRecording", comment:@"Stop Video Recording")];
    [self.stopRecordingButton addTarget:self action:@selector(stopRecordingButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.stopRecordingButton setEnabled:NO];
    [buttonStackView addArrangedSubview:self.stopRecordingButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.videoCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.videoCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.videoCardView.trailingAnchor constant:-20],
        
        [self.videoStatusLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:20],
        [self.videoStatusLabel.centerXAnchor constraintEqualToAnchor:self.videoCardView.centerXAnchor],
        
        [buttonStackView.topAnchor constraintEqualToAnchor:self.videoStatusLabel.bottomAnchor constant:20],
        [buttonStackView.leadingAnchor constraintEqualToAnchor:self.videoCardView.leadingAnchor constant:20],
        [buttonStackView.trailingAnchor constraintEqualToAnchor:self.videoCardView.trailingAnchor constant:-20],
        [buttonStackView.bottomAnchor constraintEqualToAnchor:self.videoCardView.bottomAnchor constant:-20],
        [buttonStackView.heightAnchor constraintEqualToConstant:50]
    ]];
    
    [self.mainStackView addArrangedSubview:self.videoCardView];
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

- (void)loadVideoRecordingSettings {
    if (!self.device) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
        [self setControlsEnabled:NO];
        return;
    }
    
    id<AIBudsDeviceCameraAPI> videoDevice = (id<AIBudsDeviceCameraAPI>)self.device;
    if ([videoDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) {
        [self setControlsEnabled:YES];
        
        // 加载相机固件版本
        self.firmwareVersionLabel.text = videoDevice.cameraFirmwareVersion ?: NSLocalizedString(@"LocKey.Unknown", comment:@"Unknown");
        
        // 加载最大录制时长
        NSNumber *maxDuration = videoDevice.maxVideoRecordDuration;
        if (maxDuration) {
            self.maxDurationSlider.value = maxDuration.intValue;
            self.maxDurationValueLabel.text = [NSString stringWithFormat:@"%d", maxDuration.intValue];
        }
        
        self.statusLabel.text = NSLocalizedString(@"LocKey.VideoRecordingSettingsLoaded", comment:@"Video recording settings loaded");
    } else {
        self.statusLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportVideoRecording", comment:@"Device does not support video recording");
        [self setControlsEnabled:NO];
    }
}

- (void)setControlsEnabled:(BOOL)enabled {
    self.maxDurationSlider.enabled = enabled;
    self.captureModeSegmentedControl.enabled = enabled;
    self.takePhotoButton.enabled = enabled;
    self.stopPhotoButton.enabled = enabled && self.stopPhotoButton.isEnabled;
    self.startRecordingButton.enabled = enabled;
    self.stopRecordingButton.enabled = enabled && self.stopRecordingButton.isEnabled;
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
        self.videoStatusLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        self.videoStatusLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
}

#pragma mark - Actions

- (void)maxDurationChanged:(UISlider *)sender {
    self.maxDurationValueLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (void)maxDurationChangeEnded:(UISlider *)sender {
    if (!self.device) return;
    
    id<AIBudsDeviceCameraAPI> videoDevice = (id<AIBudsDeviceCameraAPI>)self.device;
    if (![videoDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) return;
    
    int duration = (int)sender.value;
    
    __weak typeof(self) weakSelf = self;
    [videoDevice setMaxVideoRecordDuration:duration completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.MaxVideoRecordingDurationSetSuccess", comment:@"Max video recording duration set successfully");
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.MaxVideoRecordingDurationSetFailed", comment:@"Failed to set max video recording duration");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                // 恢复之前的值
                [strongSelf loadVideoRecordingSettings];
            }
        });
    }];
}

- (void)takePhotoButtonTapped {
    if (!self.device) return;
    
    id<AIBudsDeviceCameraAPI> videoDevice = (id<AIBudsDeviceCameraAPI>)self.device;
    if (![videoDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) return;
    
    AIBudsCaptureMode mode = (self.captureModeSegmentedControl.selectedSegmentIndex == 0) ? AIBudsCaptureModeCamera : AIBudsCaptureModeAi;
    
    __weak typeof(self) weakSelf = self;
    [videoDevice requestPhotoTakingWithCaptureMode:mode completion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.PhotoTakingStarted", comment:@"Photo taking started");
                strongSelf.photoStatusLabel.text = NSLocalizedString(@"LocKey.PhotoTakingInProgress", comment:@"Photo taking in progress");
                [strongSelf.takePhotoButton setEnabled:NO];
                [strongSelf.stopPhotoButton setEnabled:YES];
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.PhotoTakingStartFailed", comment:@"Failed to start photo taking");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)stopPhotoButtonTapped {
    if (!self.device) return;
    
    id<AIBudsDeviceCameraAPI> videoDevice = (id<AIBudsDeviceCameraAPI>)self.device;
    if (![videoDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) return;
    
    __weak typeof(self) weakSelf = self;
    [videoDevice requestStopPhotoTakingWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.PhotoTakingStopped", comment:@"Photo taking stopped");
                strongSelf.photoStatusLabel.text = NSLocalizedString(@"LocKey.ReadyToCapture", comment:@"Ready to capture");
                [strongSelf.takePhotoButton setEnabled:YES];
                [strongSelf.stopPhotoButton setEnabled:NO];
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.PhotoTakingStopFailed", comment:@"Failed to stop photo taking");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)startRecordingButtonTapped {
    if (!self.device) return;
    
    id<AIBudsDeviceCameraAPI> videoDevice = (id<AIBudsDeviceCameraAPI>)self.device;
    if (![videoDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) return;
    
    __weak typeof(self) weakSelf = self;
    [videoDevice requestVideoRecordingWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.VideoRecordingStarted", comment:@"Video recording started");
                strongSelf.videoStatusLabel.text = NSLocalizedString(@"LocKey.VideoRecordingInProgress", comment:@"Video recording in progress");
                [strongSelf.startRecordingButton setEnabled:NO];
                [strongSelf.stopRecordingButton setEnabled:YES];
                [strongSelf startRecordingTimer];
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.VideoRecordingStartFailed", comment:@"Failed to start video recording");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)stopRecordingButtonTapped {
    if (!self.device) return;
    
    id<AIBudsDeviceCameraAPI> videoDevice = (id<AIBudsDeviceCameraAPI>)self.device;
    if (![videoDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) return;
    
    __weak typeof(self) weakSelf = self;
    [videoDevice requestStopVideoRecordingWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.VideoRecordingStopped", comment:@"Video recording stopped");
                strongSelf.videoStatusLabel.text = NSLocalizedString(@"LocKey.ReadyToRecord", comment:@"Ready to record");
                [strongSelf.startRecordingButton setEnabled:YES];
                [strongSelf.stopRecordingButton setEnabled:NO];
                [strongSelf stopRecordingTimer];
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.VideoRecordingStopFailed", comment:@"Failed to stop video recording");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

@end
