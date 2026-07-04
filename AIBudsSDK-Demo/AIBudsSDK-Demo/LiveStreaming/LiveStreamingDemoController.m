//
//  LiveStreamingDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-06-25.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "LiveStreamingDemoController.h"

typedef NS_ENUM(NSInteger, LiveStreamingMode) {
    LiveStreamingModeRTSP = 0,
    LiveStreamingModeJPEG = 1
};

@interface LiveStreamingDemoController () <AIBudsLiveStreamingPlayerDelegate, AIBudsLiveStreamerDelegate, UITextFieldDelegate>

// Live Streaming Mode
@property (nonatomic, assign) LiveStreamingMode liveStreamingMode;

// Mode Selector
@property (nonatomic, strong) UISegmentedControl *modeSelector;

// Video Display
@property (nonatomic, strong) UIView *videoContainerView;
@property (nonatomic, strong) UILabel *videoPlaceholderLabel;
@property (nonatomic, strong) UIImageView *jpegImageView;
@property (nonatomic, strong) AIBudsLiveStreamingPlayer *mediaPlayer;

// Controls Container
@property (nonatomic, strong) UIView *controlsContainerView;

// Test RTSP URL Input
@property (nonatomic, strong) UILabel *testRtspUrlLabel;
@property (nonatomic, strong) UITextField *testRtspUrlTextField;
@property (nonatomic, strong) UIButton *saveTestRtspUrlButton;
@property (nonatomic, strong) UIButton *connectTestRtspButton;

// RTMP URL Input
@property (nonatomic, strong) UILabel *rtmpUrlLabel;
@property (nonatomic, strong) UITextField *rtmpUrlTextField;
@property (nonatomic, strong) UIButton *saveRtmpUrlButton;

// Status Labels
@property (nonatomic, strong) UILabel *deviceStatusLabel;
@property (nonatomic, strong) UILabel *rtspAddressLabel;
@property (nonatomic, strong) UILabel *connectionStatusLabel;
@property (nonatomic, strong) UILabel *frameRateLabel;

// Buttons
@property (nonatomic, strong) UIButton *closeStreamingButton;
@property (nonatomic, strong) UIButton *pushStreamButton;

// State
@property (nonatomic, assign) BOOL isStreaming;
@property (nonatomic, assign) BOOL isPushingStream;
@property (nonatomic, assign) BOOL isUsingTestRtsp;
@property (nonatomic, strong) NSString *currentRtspAddress;
@property (nonatomic, copy) NSString *savedTestRtspUrl;
@property (nonatomic, copy) NSString *savedRtmpUrl;
@property (nonatomic, strong) AIBudsLiveStreamer *liveStreamer;
@property (nonatomic, assign) NSUInteger jpegFrameCount;
@property (nonatomic, strong) NSDate *startTime;

@end

@implementation LiveStreamingDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.liveStreamingMode = LiveStreamingModeRTSP;
    [self setupUI];
    [self loadSavedTestRtspUrl];
    [self loadSavedRtmpUrl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateStreamingButton];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopDeviceLiveStreaming];
    [self cleanupPlayer];
}

- (void)dealloc {
    // 所有清理已在 viewWillDisappear 中完成，dealloc 不做任何操作
}

#pragma mark - Streaming Toggle

- (void)toggleStreaming {
    if (self.isStreaming) {
        [self stopDeviceLiveStreaming];
    } else {
        [self startDeviceLiveStreaming];
    }
}

- (void)updateStreamingButton {
    if (self.isStreaming) {
        [self.closeStreamingButton setTitle:NSLocalizedString(@"LocKey.StopLiveStreaming", @"Stop Live Streaming") forState:UIControlStateNormal];
        self.closeStreamingButton.backgroundColor = [UIColor systemRedColor];
    } else {
        [self.closeStreamingButton setTitle:NSLocalizedString(@"LocKey.StartLiveStreaming", @"Start Live Streaming") forState:UIControlStateNormal];
        self.closeStreamingButton.backgroundColor = [UIColor systemGreenColor];
    }
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = NSLocalizedString(@"LocKey.LiveStreamingDemoTitle", @"Live Streaming");

    [self setupVideoContainer];
    [self setupControlsContainer];
    [self setupConstraints];
}

- (void)setupVideoContainer {
    // Video Container
    self.videoContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.videoContainerView.backgroundColor = [UIColor blackColor];
    self.videoContainerView.layer.cornerRadius = 12;
    self.videoContainerView.clipsToBounds = YES;
    self.videoContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.videoContainerView];

    // Placeholder Label
    self.videoPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.videoPlaceholderLabel.text = @"";
    self.videoPlaceholderLabel.textColor = [UIColor lightGrayColor];
    self.videoPlaceholderLabel.font = [UIFont systemFontOfSize:16];
    self.videoPlaceholderLabel.textAlignment = NSTextAlignmentCenter;
    self.videoPlaceholderLabel.numberOfLines = 0;
    self.videoPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.videoContainerView addSubview:self.videoPlaceholderLabel];

    // JPEG Image View
    self.jpegImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.jpegImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.jpegImageView.backgroundColor = [UIColor blackColor];
    self.jpegImageView.hidden = YES;
    self.jpegImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.videoContainerView addSubview:self.jpegImageView];

    // Initialize AIBudsLiveStreamingPlayer
    self.mediaPlayer = [[AIBudsLiveStreamingPlayer alloc] init];
    self.mediaPlayer.delegate = self;
}

- (void)setupControlsContainer {
    // Controls Container
    self.controlsContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.controlsContainerView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.controlsContainerView.layer.cornerRadius = 12;
    self.controlsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.controlsContainerView];

    // Live Streaming Mode Selector
    self.modeSelector = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"LocKey.LiveStreamingModeRTSP", @"RTSP"),
        NSLocalizedString(@"LocKey.LiveStreamingModeJPEG", @"JPEG")
    ]];
    self.modeSelector.selectedSegmentIndex = self.liveStreamingMode;
    self.modeSelector.selectedSegmentTintColor = [UIColor systemBlueColor];
    [self.modeSelector setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];
    [self.modeSelector addTarget:self action:@selector(liveStreamingModeChanged:) forControlEvents:UIControlEventValueChanged];
    self.modeSelector.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlsContainerView addSubview:self.modeSelector];

    // Device Status Label
    self.deviceStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.LiveStreamingNotStarted", @"Live streaming not started");
    self.deviceStatusLabel.textColor = [UIColor secondaryLabelColor];
    self.deviceStatusLabel.font = [UIFont systemFontOfSize:14];
    self.deviceStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlsContainerView addSubview:self.deviceStatusLabel];

    // RTSP Address Label
    self.rtspAddressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.rtspAddressLabel.text = @"";
    self.rtspAddressLabel.textColor = [UIColor labelColor];
    self.rtspAddressLabel.font = [UIFont systemFontOfSize:14];
    self.rtspAddressLabel.numberOfLines = 2;
    self.rtspAddressLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.rtspAddressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlsContainerView addSubview:self.rtspAddressLabel];

    // Connection Status Label
    self.connectionStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.connectionStatusLabel.text = @"";
    self.connectionStatusLabel.textColor = [UIColor systemRedColor];
    self.connectionStatusLabel.font = [UIFont systemFontOfSize:14];
    self.connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlsContainerView addSubview:self.connectionStatusLabel];

    // Test RTSP URL Label
    self.testRtspUrlLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.testRtspUrlLabel.text = NSLocalizedString(@"LocKey.TestRtspUrlLabel", @"Test RTSP URL");
    self.testRtspUrlLabel.textColor = [UIColor labelColor];
    self.testRtspUrlLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.testRtspUrlLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlsContainerView addSubview:self.testRtspUrlLabel];

    // Test RTSP URL TextField
    self.testRtspUrlTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.testRtspUrlTextField.placeholder = NSLocalizedString(@"LocKey.TestRtspUrlPlaceholder", @"Enter test RTSP URL here...");
    self.testRtspUrlTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.testRtspUrlTextField.font = [UIFont systemFontOfSize:14];
    self.testRtspUrlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.testRtspUrlTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.testRtspUrlTextField.keyboardType = UIKeyboardTypeURL;
    self.testRtspUrlTextField.returnKeyType = UIReturnKeyDone;
    self.testRtspUrlTextField.delegate = self;
    self.testRtspUrlTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlsContainerView addSubview:self.testRtspUrlTextField];

    // Save Test RTSP URL Button
    self.saveTestRtspUrlButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.saveTestRtspUrlButton setTitle:NSLocalizedString(@"LocKey.Save", @"Save") forState:UIControlStateNormal];
    self.saveTestRtspUrlButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.saveTestRtspUrlButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.saveTestRtspUrlButton addTarget:self action:@selector(saveTestRtspUrl) forControlEvents:UIControlEventTouchUpInside];
    [self.controlsContainerView addSubview:self.saveTestRtspUrlButton];

    // Test RTSP Button
    self.connectTestRtspButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.connectTestRtspButton setTitle:NSLocalizedString(@"LocKey.ConnectTestRtsp", @"Connect Test RTSP") forState:UIControlStateNormal];
    [self.connectTestRtspButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.connectTestRtspButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.connectTestRtspButton.backgroundColor = [UIColor systemIndigoColor];
    self.connectTestRtspButton.layer.cornerRadius = 20;
    self.connectTestRtspButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.connectTestRtspButton addTarget:self action:@selector(connectTestRtspStream) forControlEvents:UIControlEventTouchUpInside];
    [self.controlsContainerView addSubview:self.connectTestRtspButton];

    // RTMP URL Label
    self.rtmpUrlLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.rtmpUrlLabel.text = NSLocalizedString(@"LocKey.RtmpUrlLabel", @"RTMP Push URL");
    self.rtmpUrlLabel.textColor = [UIColor labelColor];
    self.rtmpUrlLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.rtmpUrlLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlsContainerView addSubview:self.rtmpUrlLabel];

    // RTMP URL TextField
    self.rtmpUrlTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.rtmpUrlTextField.placeholder = NSLocalizedString(@"LocKey.RtmpUrlPlaceholder", @"Enter RTMP URL here...");
    self.rtmpUrlTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.rtmpUrlTextField.font = [UIFont systemFontOfSize:14];
    self.rtmpUrlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.rtmpUrlTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.rtmpUrlTextField.keyboardType = UIKeyboardTypeURL;
    self.rtmpUrlTextField.returnKeyType = UIReturnKeyDone;
    self.rtmpUrlTextField.delegate = self;
    self.rtmpUrlTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlsContainerView addSubview:self.rtmpUrlTextField];

    // Save RTMP URL Button
    self.saveRtmpUrlButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.saveRtmpUrlButton setTitle:NSLocalizedString(@"LocKey.Save", @"Save") forState:UIControlStateNormal];
    self.saveRtmpUrlButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.saveRtmpUrlButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.saveRtmpUrlButton addTarget:self action:@selector(saveRtmpUrl) forControlEvents:UIControlEventTouchUpInside];
    [self.controlsContainerView addSubview:self.saveRtmpUrlButton];

    // Close Streaming Button
    self.closeStreamingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeStreamingButton setTitle:NSLocalizedString(@"LocKey.StopLiveStreaming", @"Stop Live Streaming") forState:UIControlStateNormal];
    [self.closeStreamingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.closeStreamingButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.closeStreamingButton.backgroundColor = [UIColor systemRedColor];
    self.closeStreamingButton.layer.cornerRadius = 22;
    self.closeStreamingButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeStreamingButton addTarget:self action:@selector(toggleStreaming) forControlEvents:UIControlEventTouchUpInside];
    [self.controlsContainerView addSubview:self.closeStreamingButton];

    // Push Stream Button
    self.pushStreamButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.pushStreamButton setTitle:NSLocalizedString(@"LocKey.StartPushStream", @"Start Push Stream") forState:UIControlStateNormal];
    [self.pushStreamButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.pushStreamButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.pushStreamButton.backgroundColor = [UIColor systemBlueColor];
    self.pushStreamButton.layer.cornerRadius = 22;
    self.pushStreamButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pushStreamButton addTarget:self action:@selector(togglePushStream) forControlEvents:UIControlEventTouchUpInside];
    [self.controlsContainerView addSubview:self.pushStreamButton];
}

- (void)setupConstraints {
    CGFloat padding = 20;
    CGFloat containerPadding = 16;

    [NSLayoutConstraint activateConstraints:@[
        // Video Container
        [self.videoContainerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:padding],
        [self.videoContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.videoContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        [self.videoContainerView.heightAnchor constraintEqualToAnchor:self.videoContainerView.widthAnchor multiplier:9.0/16.0],

        // Placeholder Label
        [self.videoPlaceholderLabel.centerXAnchor constraintEqualToAnchor:self.videoContainerView.centerXAnchor],
        [self.videoPlaceholderLabel.centerYAnchor constraintEqualToAnchor:self.videoContainerView.centerYAnchor],
        [self.videoPlaceholderLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.videoContainerView.leadingAnchor constant:16],
        [self.videoPlaceholderLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.videoContainerView.trailingAnchor constant:-16],

        // JPEG Image View
        [self.jpegImageView.topAnchor constraintEqualToAnchor:self.videoContainerView.topAnchor],
        [self.jpegImageView.leadingAnchor constraintEqualToAnchor:self.videoContainerView.leadingAnchor],
        [self.jpegImageView.trailingAnchor constraintEqualToAnchor:self.videoContainerView.trailingAnchor],
        [self.jpegImageView.bottomAnchor constraintEqualToAnchor:self.videoContainerView.bottomAnchor],

        // Controls Container
        [self.controlsContainerView.topAnchor constraintEqualToAnchor:self.videoContainerView.bottomAnchor constant:padding],
        [self.controlsContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.controlsContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        [self.controlsContainerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-padding],

        // Mode Selector
        [self.modeSelector.topAnchor constraintEqualToAnchor:self.controlsContainerView.topAnchor constant:containerPadding],
        [self.modeSelector.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.modeSelector.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],

        // Device Status Label
        [self.deviceStatusLabel.topAnchor constraintEqualToAnchor:self.modeSelector.bottomAnchor constant:12],
        [self.deviceStatusLabel.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.deviceStatusLabel.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],

        // RTSP Address Label
        [self.rtspAddressLabel.topAnchor constraintEqualToAnchor:self.deviceStatusLabel.bottomAnchor constant:8],
        [self.rtspAddressLabel.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.rtspAddressLabel.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],

        // Connection Status Label
        [self.connectionStatusLabel.topAnchor constraintEqualToAnchor:self.rtspAddressLabel.bottomAnchor constant:8],
        [self.connectionStatusLabel.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.connectionStatusLabel.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],

        // Test RTSP URL Label
        [self.testRtspUrlLabel.topAnchor constraintEqualToAnchor:self.connectionStatusLabel.bottomAnchor constant:12],
        [self.testRtspUrlLabel.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.testRtspUrlLabel.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],

        // Test RTSP URL TextField
        [self.testRtspUrlTextField.topAnchor constraintEqualToAnchor:self.testRtspUrlLabel.bottomAnchor constant:8],
        [self.testRtspUrlTextField.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.testRtspUrlTextField.trailingAnchor constraintEqualToAnchor:self.saveTestRtspUrlButton.leadingAnchor constant:-8],
        [self.testRtspUrlTextField.heightAnchor constraintEqualToConstant:40],

        // Save Test RTSP URL Button
        [self.saveTestRtspUrlButton.centerYAnchor constraintEqualToAnchor:self.testRtspUrlTextField.centerYAnchor],
        [self.saveTestRtspUrlButton.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],
        [self.saveTestRtspUrlButton.widthAnchor constraintEqualToConstant:60],
        [self.saveTestRtspUrlButton.heightAnchor constraintEqualToConstant:40],

        // Test RTSP Button
        [self.connectTestRtspButton.topAnchor constraintEqualToAnchor:self.testRtspUrlTextField.bottomAnchor constant:12],
        [self.connectTestRtspButton.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.connectTestRtspButton.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],
        [self.connectTestRtspButton.heightAnchor constraintEqualToConstant:40],

        // RTMP URL Label
        [self.rtmpUrlLabel.topAnchor constraintEqualToAnchor:self.connectTestRtspButton.bottomAnchor constant:16],
        [self.rtmpUrlLabel.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.rtmpUrlLabel.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],

        // RTMP URL TextField
        [self.rtmpUrlTextField.topAnchor constraintEqualToAnchor:self.rtmpUrlLabel.bottomAnchor constant:8],
        [self.rtmpUrlTextField.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.rtmpUrlTextField.trailingAnchor constraintEqualToAnchor:self.saveRtmpUrlButton.leadingAnchor constant:-8],
        [self.rtmpUrlTextField.heightAnchor constraintEqualToConstant:40],

        // Save RTMP URL Button
        [self.saveRtmpUrlButton.centerYAnchor constraintEqualToAnchor:self.rtmpUrlTextField.centerYAnchor],
        [self.saveRtmpUrlButton.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],
        [self.saveRtmpUrlButton.widthAnchor constraintEqualToConstant:60],
        [self.saveRtmpUrlButton.heightAnchor constraintEqualToConstant:40],

        // Close Streaming Button
        [self.closeStreamingButton.topAnchor constraintEqualToAnchor:self.rtmpUrlTextField.bottomAnchor constant:24],
        [self.closeStreamingButton.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.closeStreamingButton.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],
        [self.closeStreamingButton.heightAnchor constraintEqualToConstant:44],

        // Push Stream Button
        [self.pushStreamButton.topAnchor constraintEqualToAnchor:self.closeStreamingButton.bottomAnchor constant:12],
        [self.pushStreamButton.leadingAnchor constraintEqualToAnchor:self.controlsContainerView.leadingAnchor constant:containerPadding],
        [self.pushStreamButton.trailingAnchor constraintEqualToAnchor:self.controlsContainerView.trailingAnchor constant:-containerPadding],
        [self.pushStreamButton.heightAnchor constraintEqualToConstant:44],
    ]];
}

#pragma mark - Device Live Streaming

- (void)startDeviceLiveStreaming {
    self.isUsingTestRtsp = NO;
    id<AIBudsLiveStreamingAPI> device = (id<AIBudsLiveStreamingAPI>)self.device;
    if (![device conformsToProtocol:@protocol(AIBudsLiveStreamingAPI)]) {
        XLOG_ERROR(@"%@", APP_LOG_STRING(@"Device does not support LiveStreamingAPI"));
        self.rtspAddressLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportLiveStreaming", @"Device does not support live streaming");
        return;
    }

    // 根据选择的模式启动不同的流
    if (self.liveStreamingMode == LiveStreamingModeRTSP) {
        [self startRTSPLiveStreaming];
    } else {
        [self startJPEGLiveStreaming];
    }
}

- (void)connectTestRtspStream {
    NSString *testRtspAddress = [self.testRtspUrlTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (testRtspAddress.length == 0 || ![testRtspAddress hasPrefix:@"rtsp://"]) {
        [self showInvalidTestRtspUrlAlert];
        return;
    }

    self.savedTestRtspUrl = testRtspAddress;
    [[NSUserDefaults standardUserDefaults] setObject:testRtspAddress forKey:@"LiveStreamingSavedTestRtspUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.testRtspUrlTextField.layer.borderWidth = 0;
    [self.testRtspUrlTextField resignFirstResponder];

    if (self.isPushingStream) {
        [self stopPushStream];
    }

    if (self.isStreaming) {
        [self.mediaPlayer stop];
    }

    self.liveStreamingMode = LiveStreamingModeRTSP;
    self.modeSelector.selectedSegmentIndex = self.liveStreamingMode;
    self.isUsingTestRtsp = YES;
    self.isStreaming = YES;
    self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.UsingTestRtspAddress", @"Using test RTSP address");
    self.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectingToStream", @"Connecting to stream...");
    self.connectionStatusLabel.textColor = [UIColor systemOrangeColor];
    self.videoPlaceholderLabel.hidden = NO;
    self.jpegImageView.hidden = YES;
    [self updateStreamingButton];

    [self handleRtspAddress:testRtspAddress];
}

- (void)startRTSPLiveStreaming {
    id<AIBudsLiveStreamingAPI> device = (id<AIBudsLiveStreamingAPI>)self.device;
    
    if(!self.device.isConnectedAndReady) {
        XLOG_ERROR(@"%@", APP_LOG_STRING(@"Device is not connected and ready"));
        self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.DeviceNotConnected", @"Device is not connected");
        return;
    }
    
    if (!device.supportsRTSPLiveStreaming) {
        XLOG_ERROR(@"%@", APP_LOG_STRING(@"Device does not support RTSP live streaming"));
        self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportRTSP", @"Device does not support RTSP");
        return;
    }

    self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.DeviceStatusStarting", @"Starting live streaming...");
    self.rtspAddressLabel.text = NSLocalizedString(@"LocKey.RtspAddressWaiting", @"Waiting for RTSP address...");
    self.connectionStatusLabel.text = @"";
    self.connectionStatusLabel.textColor = [UIColor systemOrangeColor];
    self.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.StartingLiveStreaming", @"Starting live streaming...");
    self.videoPlaceholderLabel.hidden = NO;
    self.jpegImageView.hidden = YES;

    __weak typeof(self) weakSelf = self;
    [device startRTSPLiveStreamingWithParams:[AIBudsRTSPStreamParams defaultParams] configureHotspotStartingHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.ConfiguringHotspot", @"Configuring hotspot...");
        });
    } hotspotConfigureCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.HotspotConfigured", @"Hotspot configured");
            } else {
                weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.HotspotConfigureFailed", @"Hotspot configuration failed");
            }
        });
    } enterLiveStreamingModeStartingHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.EnteringLiveStreamingMode", @"Entering live streaming mode...");
        });
    } enterLiveStreamingModeCompletedHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.LiveStreamingModeEntered", @"Live streaming mode entered");
            } else {
                weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.EnterLiveStreamingModeFailed", @"Failed to enter live streaming mode");
            }
        });
    } waitingForHotspotOpenHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.WaitingHotspotOpen", @"Waiting for hotspot to open...");
        });
    } connectDeviceHotspotStartingHandler:^(NSString * _Nonnull ssid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.deviceStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.ConnectingToHotspotFormat", @"Connecting to %@..."), ssid];
        });
    } deviceHotspotConnectCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.HotspotConnected", @"Hotspot connected");
            } else {
                weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.HotspotConnectionFailed", @"Hotspot connection failed");
            }
        });
    } rtspAddressReceivedHandler:^(NSString * _Nonnull rtspAddress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleRtspAddress:rtspAddress];
        });
    } sessionStartCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                weakSelf.isStreaming = YES;
                [weakSelf updateStreamingButton];
                weakSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusConnected", @"Connected");
                weakSelf.connectionStatusLabel.textColor = [UIColor systemGreenColor];
            } else {
                weakSelf.isStreaming = NO;
                [weakSelf updateStreamingButton];
                weakSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusFailed", @"Connection failed");
                weakSelf.connectionStatusLabel.textColor = [UIColor systemRedColor];
                weakSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.LiveStreamingFailed", @"Live streaming failed");
            }
        });
    } sessionFinishHandler:^(BOOL isUserInitiatedStop, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isStreaming = NO;
            weakSelf.isPushingStream = NO;
            [weakSelf updatePushStreamButton];
            [weakSelf updateStreamingButton];
            
            if (isUserInitiatedStop) {
                weakSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusStopped", @"Stopped");
                weakSelf.connectionStatusLabel.textColor = [UIColor systemGrayColor];
                weakSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.LiveStreamingStopped", @"Live streaming stopped");
            } else {
                weakSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.HotspotDisconnected", @"Hotspot disconnected");
                weakSelf.connectionStatusLabel.textColor = [UIColor systemOrangeColor];
                weakSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.LiveStreamingDisconnected", @"Live streaming disconnected, tap to reconnect");
            }
        });
    }];
}

- (void)stopDeviceLiveStreaming {
    id<AIBudsLiveStreamingAPI> device = (id<AIBudsLiveStreamingAPI>)self.device;
    if ([device conformsToProtocol:@protocol(AIBudsLiveStreamingAPI)] && !self.isUsingTestRtsp) {
        [device stopLiveStreaming];
    }

    // Stop push stream first
    if (self.isPushingStream) {
        [self stopPushStream];
    }

    // Stop playback
    [self.mediaPlayer stop];

    self.isStreaming = NO;
    self.isUsingTestRtsp = NO;
    self.currentRtspAddress = nil;
    self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.LiveStreamingStopped", @"Live streaming stopped");
    self.rtspAddressLabel.text = @"";
    self.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusStopped", @"Stopped");
    self.connectionStatusLabel.textColor = [UIColor systemGrayColor];
    [self updateStreamingButton];
    [self updatePushStreamButton];
}

- (void)handleRtspAddress:(NSString *)rtspAddress {
    self.currentRtspAddress = rtspAddress;
    self.rtspAddressLabel.text = [NSString stringWithFormat:@"RTSP: %@", rtspAddress];

    // Start playing the stream
    [self startPlaybackWithRtspAddress:rtspAddress];
}

- (void)startJPEGLiveStreaming {
    id<AIBudsLiveStreamingAPI> device = (id<AIBudsLiveStreamingAPI>)self.device;
    
    if(!self.device.isConnectedAndReady) {
        XLOG_ERROR(@"%@", APP_LOG_STRING(@"Device is not connected and ready"));
        self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.DeviceNotConnected", @"Device is not connected");
        return;
    }
    
    if (!device.supportsJPEGImageLiveStreaming) {
        XLOG_ERROR(@"%@", APP_LOG_STRING(@"Device does not support JPEG live streaming"));
        self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportJPEG", @"Device does not support JPEG");
        return;
    }

    self.deviceStatusLabel.text = NSLocalizedString(@"LocKey.DeviceStatusStarting", @"Starting live streaming...");
    self.connectionStatusLabel.text = @"";
    self.connectionStatusLabel.textColor = [UIColor systemOrangeColor];
    self.videoPlaceholderLabel.hidden = YES;
    self.jpegImageView.hidden = NO;
    self.jpegFrameCount = 0;
    self.startTime = [NSDate date];
    self.frameRateLabel.text = @"";

    __weak typeof(self) weakSelf = self;
    [device startJPEGImageLiveStreamingWithSessionStartCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                weakSelf.isStreaming = YES;
                [weakSelf updateStreamingButton];
                weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.LiveStreamingStarted", @"Live streaming started");
                weakSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusConnected", @"Connected");
                weakSelf.connectionStatusLabel.textColor = [UIColor systemGreenColor];
            } else {
                weakSelf.isStreaming = NO;
                [weakSelf updateStreamingButton];
                weakSelf.deviceStatusLabel.text = NSLocalizedString(@"LocKey.LiveStreamingFailed", @"Live streaming failed");
                weakSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusFailed", @"Connection failed");
                weakSelf.connectionStatusLabel.textColor = [UIColor systemRedColor];
            }
        });
    } jpegDataReceivedHandler:^(NSData * _Nonnull jpegData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleJpegData:jpegData];
        });
    } sessionFinishHandler:^(BOOL isUserInitiatedStop, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isStreaming = NO;
            weakSelf.isPushingStream = NO;
            [weakSelf updatePushStreamButton];
            [weakSelf updateStreamingButton];
            
            if (isUserInitiatedStop) {
                weakSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusStopped", @"Stopped");
                weakSelf.connectionStatusLabel.textColor = [UIColor systemGrayColor];
            } else {
                weakSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusDisconnected", @"Disconnected");
                weakSelf.connectionStatusLabel.textColor = [UIColor systemOrangeColor];
            }
        });
    }];
}

- (void)startPlaybackWithRtspAddress:(NSString *)rtspAddress {
    self.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.ConnectingToStream", @"Connecting to stream...");

    AIBudsVideoSource *source = [[AIBudsVideoSource alloc] initWithUrl:[NSURL URLWithString:rtspAddress] videoType:AIBudsLiveStreamingVideoTypeNormal];
    source.isLiveStream = YES;
    
   
    [self.mediaPlayer addVideoViewToView:self.videoContainerView];
    [self.mediaPlayer playWithSource:source];

    XLOG_INFO(@"%@", APP_LOG_STRING(@"Started AIBudsLiveStreamingPlayer playback with RTSP: %@", rtspAddress));
}

#pragma mark - Push Stream

- (void)togglePushStream {
    if (self.isPushingStream) {
        [self stopPushStream];
    } else {
        [self startPushStream];
    }
}

- (void)startPushStream {
    if (!self.currentRtspAddress) {
        XLOG_WARNING(@"%@", APP_LOG_STRING(@"Cannot start push stream: RTSP address not available"));
        return;
    }

    if (!self.savedRtmpUrl || self.savedRtmpUrl.length == 0) {
        XLOG_WARNING(@"%@", APP_LOG_STRING(@"Cannot start push stream: RTMP URL not configured"));
        self.rtmpUrlTextField.layer.borderColor = [UIColor systemRedColor].CGColor;
        self.rtmpUrlTextField.layer.borderWidth = 1;
        return;
    }

    self.rtmpUrlTextField.layer.borderWidth = 0;
    self.isPushingStream = YES;
    [self updatePushStreamButton];

    XLOG_INFO(@"%@", APP_LOG_STRING(@"Starting push stream to RTMP: %@", self.savedRtmpUrl));
    XLOG_INFO(@"%@", APP_LOG_STRING(@"Source RTSP: %@", self.currentRtspAddress));

    AIBudsLiveStreamer* streamer = [AIBudsLiveStreamer new];
    streamer.delegate = self;
    AIBudsLiveStreamerConfig* configuration = [AIBudsLiveStreamerConfig defaultConfig];
    [streamer configureWithInputURL:self.currentRtspAddress outputURL:self.savedRtmpUrl config:configuration];
    self.liveStreamer = streamer;
    [streamer startStreaming];
}

- (void)stopPushStream {
    [self.liveStreamer stopStreaming];
    self.liveStreamer = nil;

    self.isPushingStream = NO;
    [self updatePushStreamButton];

    XLOG_INFO(@"%@", APP_LOG_STRING(@"Stopped push stream"));
}

- (void)streamer:(AIBudsLiveStreamer *)streamer didChangeState:(AIBudsLiveStreamerState)oldState newState:(AIBudsLiveStreamerState)newState {
    XLOG_INFO(@"%@", APP_LOG_STRING(@"Live streamer state changed: %ld -> %ld", (long)oldState, (long)newState));

    if (newState == AIBudsLiveStreamerStateFailed || newState == AIBudsLiveStreamerStateEnded || newState == AIBudsLiveStreamerStateIdle) {
        self.isPushingStream = NO;
        [self updatePushStreamButton];
    } else if (newState == AIBudsLiveStreamerStateStreaming) {
        self.isPushingStream = YES;
        [self updatePushStreamButton];
    }
}

- (void)streamer:(AIBudsLiveStreamer *)streamer didEncounterError:(NSError *)error {
    XLOG_ERROR(@"%@", APP_LOG_STRING(@"Live streamer error: %@", error.localizedDescription));
    self.isPushingStream = NO;
    [self updatePushStreamButton];
}

- (void)updatePushStreamButton {
    if (self.isPushingStream) {
        [self.pushStreamButton setTitle:NSLocalizedString(@"LocKey.StopPushStream", @"Stop Push Stream") forState:UIControlStateNormal];
        self.pushStreamButton.backgroundColor = [UIColor systemGrayColor];
    } else {
        [self.pushStreamButton setTitle:NSLocalizedString(@"LocKey.StartPushStream", @"Start Push Stream") forState:UIControlStateNormal];
        self.pushStreamButton.backgroundColor = [UIColor systemBlueColor];
    }

    // Disable if not streaming
    self.pushStreamButton.enabled = self.isStreaming;
    self.pushStreamButton.alpha = self.isStreaming ? 1.0 : 0.5;
}

#pragma mark - URL Management

- (void)showInvalidTestRtspUrlAlert {
    self.testRtspUrlTextField.layer.borderColor = [UIColor systemRedColor].CGColor;
    self.testRtspUrlTextField.layer.borderWidth = 1;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.InvalidUrl", @"Invalid URL")
                                                                   message:NSLocalizedString(@"LocKey.InvalidTestRtspUrlMessage", @"Please enter a valid RTSP URL (starting with rtsp://)")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.OK", @"OK") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveTestRtspUrl {
    NSString *url = [self.testRtspUrlTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (url.length == 0 || ![url hasPrefix:@"rtsp://"]) {
        [self showInvalidTestRtspUrlAlert];
        return;
    }

    self.savedTestRtspUrl = url;
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"LiveStreamingSavedTestRtspUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.testRtspUrlTextField.layer.borderWidth = 0;
    [self.testRtspUrlTextField resignFirstResponder];

    XLOG_INFO(@"%@", APP_LOG_STRING(@"Saved test RTSP URL: %@", url));
}

- (void)loadSavedTestRtspUrl {
    NSString *savedUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"LiveStreamingSavedTestRtspUrl"];

    self.savedTestRtspUrl = savedUrl;
    self.testRtspUrlTextField.text = savedUrl;
}

- (void)saveRtmpUrl {
    NSString *url = [self.rtmpUrlTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (url.length > 0 && ![url hasPrefix:@"rtmp://"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.InvalidUrl", @"Invalid URL")
                                                                       message:NSLocalizedString(@"LocKey.InvalidRtmpUrlMessage", @"Please enter a valid RTMP URL (starting with rtmp://)")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.OK", @"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    self.savedRtmpUrl = url;
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"LiveStreamingSavedRtmpUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Visual feedback
    self.rtmpUrlTextField.layer.borderWidth = 0;
    [self.rtmpUrlTextField resignFirstResponder];

    XLOG_INFO(@"%@", APP_LOG_STRING(@"Saved RTMP URL: %@", url.length > 0 ? url : @"(empty)"));
}

- (void)loadSavedRtmpUrl {
    NSString *savedUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"LiveStreamingSavedRtmpUrl"];
    
    if (savedUrl) {
        self.savedRtmpUrl = savedUrl;
        self.rtmpUrlTextField.text = savedUrl;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - AIBudsLiveStreamingPlayerDelegate

- (void)player:(AIBudsLiveStreamingPlayer *)player didChangeState:(AIBudsLiveStreamingPlayerState)oldState newState:(AIBudsLiveStreamingPlayerState)newState {

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        switch (newState) {
            case AIBudsLiveStreamingPlayerStateBuffering:
                strongSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.Buffering", @"Buffering...");
                break;
            case AIBudsLiveStreamingPlayerStateReadyToPlay:
                strongSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.ReadyToPlay", @"Ready to play");
                break;
            case AIBudsLiveStreamingPlayerStatePlaying:
                strongSelf.videoPlaceholderLabel.hidden = YES;
                strongSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusPlaying", @"Playing");
                strongSelf.connectionStatusLabel.textColor = [UIColor systemGreenColor];
                break;
            case AIBudsLiveStreamingPlayerStatePaused:
                strongSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.Paused", @"Paused");
                break;
            case AIBudsLiveStreamingPlayerStateFinished:
                strongSelf.videoPlaceholderLabel.hidden = NO;
                strongSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.StreamEnded", @"Stream ended");
                break;
            case AIBudsLiveStreamingPlayerStateError:
                strongSelf.videoPlaceholderLabel.hidden = NO;
                strongSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.StreamError", @"Stream error");
                strongSelf.connectionStatusLabel.text = NSLocalizedString(@"LocKey.ConnectionStatusError", @"Error");
                strongSelf.connectionStatusLabel.textColor = [UIColor systemRedColor];
                break;
            case AIBudsLiveStreamingPlayerStateIdle:
                strongSelf.videoPlaceholderLabel.hidden = NO;
                strongSelf.videoPlaceholderLabel.text = NSLocalizedString(@"LocKey.StreamStopped", @"Stream stopped");
                break;
            default:
                break;
        }
    });
}


- (void)player:(AIBudsLiveStreamingPlayer *)player didEncounterError:(NSError *)error {
    XLOG_ERROR(@"%@", APP_LOG_STRING(@"Player error: %@", error.localizedDescription));
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf.videoPlaceholderLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.StreamErrorFormat", @"Stream error"), error.localizedDescription];
        strongSelf.connectionStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.ConnectionStatusErrorFormat", @"Error"), error.localizedDescription];
        strongSelf.connectionStatusLabel.textColor = [UIColor systemRedColor];
    });
}

#pragma mark - Mode Selection

- (void)liveStreamingModeChanged:(UISegmentedControl *)sender {
    LiveStreamingMode newMode = (LiveStreamingMode)sender.selectedSegmentIndex;
    
    if (self.isStreaming) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.SwitchModeTitle", @"Switch Mode")
                                                                       message:NSLocalizedString(@"LocKey.SwitchModeMessage", @"Please stop current streaming before switching mode")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            sender.selectedSegmentIndex = self.liveStreamingMode;
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.liveStreamingMode = newMode;
    
    // 更新 UI 显示（未开始直播时显示提示）
    if (self.liveStreamingMode == LiveStreamingModeRTSP) {
        self.rtspAddressLabel.hidden = NO;
        self.frameRateLabel.hidden = YES;
    } else {
        self.rtspAddressLabel.hidden = YES;
        self.frameRateLabel.hidden = NO;
    }
    
}

- (void)handleJpegData:(NSData *)jpegData {
    if (!self.isStreaming || self.liveStreamingMode != LiveStreamingModeJPEG) {
        return;
    }
    
    self.jpegFrameCount++;
    UIImage *image = [UIImage imageWithData:jpegData];
    if (image) {
        self.jpegImageView.image = image;
    }
    
    // 更新帧率显示
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.startTime];
    if (elapsed > 0) {
        double fps = self.jpegFrameCount / elapsed;
        self.frameRateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FrameRateFormat", @"FPS: %.1f (%@ frames)"), fps, @(self.jpegFrameCount)];
    }
}

#pragma mark - Cleanup

- (void)cleanupPlayer {
    if (!self.mediaPlayer) {
        return;
    }
    
    [self.mediaPlayer stop];
    [self.mediaPlayer removeVideoView];
    self.mediaPlayer.delegate = nil;
    self.mediaPlayer = nil;
    
    XLOG_INFO(@"%@", APP_LOG_STRING(@"AIBudsLiveStreamingPlayer cleaned up successfully"));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
