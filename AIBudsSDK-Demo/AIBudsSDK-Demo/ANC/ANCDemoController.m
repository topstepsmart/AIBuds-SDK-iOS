//
//  ANCDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-09.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "ANCDemoController.h"

@interface ANCDemoController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) UILabel *statusLabel;

// ANC Mode Selection
@property (nonatomic, strong) UIView *modeCardView;
@property (nonatomic, strong) UISegmentedControl *modeSegmentedControl;

// ANC Gain Control
@property (nonatomic, strong) UIView *ancGainCardView;
@property (nonatomic, strong) UISlider *ancGainSlider;
@property (nonatomic, strong) UILabel *ancGainValueLabel;

// Transparency Gain Control
@property (nonatomic, strong) UIView *transparencyGainCardView;
@property (nonatomic, strong) UISlider *transparencyGainSlider;
@property (nonatomic, strong) UILabel *transparencyGainValueLabel;

// ANC Fade Toggle
@property (nonatomic, strong) UIView *fadeCardView;
@property (nonatomic, strong) UISwitch *fadeSwitch;

@end

@implementation ANCDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.ANCDemoTitle", comment:@"ANC Demo");
    [self setupUI];
    [self loadANCSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadANCSettings];
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
    
    // 创建 ANC 模式选择卡片
    [self setupModeCard];
    
    // 创建 ANC 增益控制卡片
    [self setupANCGainCard];
    
    // 创建通透增益控制卡片
    [self setupTransparencyGainCard];
    
    // 创建 ANC 淡入淡出卡片
    [self setupFadeCard];
}

- (void)setupModeCard {
    self.modeCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.ANCModeTitle", comment:@"ANC Mode");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.modeCardView addSubview:titleLabel];
    
    // 模式选择分段控制器
    self.modeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"LocKey.ANCModeNormal", comment:@"Normal"),
        NSLocalizedString(@"LocKey.ANCModeANC", comment:@"ANC"),
        NSLocalizedString(@"LocKey.ANCModeTransparency", comment:@"Transparency")
    ]];
    self.modeSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.modeSegmentedControl addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.modeCardView addSubview:self.modeSegmentedControl];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.modeCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.modeCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.modeCardView.trailingAnchor constant:-20],
        
        [self.modeSegmentedControl.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:20],
        [self.modeSegmentedControl.leadingAnchor constraintEqualToAnchor:self.modeCardView.leadingAnchor constant:20],
        [self.modeSegmentedControl.trailingAnchor constraintEqualToAnchor:self.modeCardView.trailingAnchor constant:-20],
        [self.modeSegmentedControl.bottomAnchor constraintEqualToAnchor:self.modeCardView.bottomAnchor constant:-20],
        [self.modeSegmentedControl.heightAnchor constraintEqualToConstant:40]
    ]];
    
    [self.mainStackView addArrangedSubview:self.modeCardView];
}

- (void)setupANCGainCard {
    self.ancGainCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.ANCGainTitle", comment:@"ANC Gain");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.ancGainCardView addSubview:titleLabel];
    
    // 数值标签
    self.ancGainValueLabel = [[UILabel alloc] init];
    self.ancGainValueLabel.text = @"0";
    self.ancGainValueLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    self.ancGainValueLabel.textColor = [UIColor systemBlueColor];
    self.ancGainValueLabel.textAlignment = NSTextAlignmentCenter;
    self.ancGainValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.ancGainCardView addSubview:self.ancGainValueLabel];
    
    // 滑块
    self.ancGainSlider = [[UISlider alloc] init];
    self.ancGainSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.ancGainSlider.minimumValue = 0;
    self.ancGainSlider.maximumValue = 100;
    [self.ancGainSlider addTarget:self action:@selector(ancGainChanged:) forControlEvents:UIControlEventValueChanged];
    [self.ancGainSlider addTarget:self action:@selector(ancGainChangeEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.ancGainCardView addSubview:self.ancGainSlider];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.ancGainCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.ancGainCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.ancGainCardView.trailingAnchor constant:-20],
        
        [self.ancGainValueLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.ancGainValueLabel.centerXAnchor constraintEqualToAnchor:self.ancGainCardView.centerXAnchor],
        
        [self.ancGainSlider.topAnchor constraintEqualToAnchor:self.ancGainValueLabel.bottomAnchor constant:15],
        [self.ancGainSlider.leadingAnchor constraintEqualToAnchor:self.ancGainCardView.leadingAnchor constant:20],
        [self.ancGainSlider.trailingAnchor constraintEqualToAnchor:self.ancGainCardView.trailingAnchor constant:-20],
        [self.ancGainSlider.bottomAnchor constraintEqualToAnchor:self.ancGainCardView.bottomAnchor constant:-20]
    ]];
    
    [self.mainStackView addArrangedSubview:self.ancGainCardView];
}

- (void)setupTransparencyGainCard {
    self.transparencyGainCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.TransparencyGainTitle", comment:@"Transparency Gain");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.transparencyGainCardView addSubview:titleLabel];
    
    // 数值标签
    self.transparencyGainValueLabel = [[UILabel alloc] init];
    self.transparencyGainValueLabel.text = @"0";
    self.transparencyGainValueLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    self.transparencyGainValueLabel.textColor = [UIColor systemGreenColor];
    self.transparencyGainValueLabel.textAlignment = NSTextAlignmentCenter;
    self.transparencyGainValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.transparencyGainCardView addSubview:self.transparencyGainValueLabel];
    
    // 滑块
    self.transparencyGainSlider = [[UISlider alloc] init];
    self.transparencyGainSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.transparencyGainSlider.minimumValue = 0;
    self.transparencyGainSlider.maximumValue = 100;
    [self.transparencyGainSlider addTarget:self action:@selector(transparencyGainChanged:) forControlEvents:UIControlEventValueChanged];
    [self.transparencyGainSlider addTarget:self action:@selector(transparencyGainChangeEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.transparencyGainCardView addSubview:self.transparencyGainSlider];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.transparencyGainCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.transparencyGainCardView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.transparencyGainCardView.trailingAnchor constant:-20],
        
        [self.transparencyGainValueLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.transparencyGainValueLabel.centerXAnchor constraintEqualToAnchor:self.transparencyGainCardView.centerXAnchor],
        
        [self.transparencyGainSlider.topAnchor constraintEqualToAnchor:self.transparencyGainValueLabel.bottomAnchor constant:15],
        [self.transparencyGainSlider.leadingAnchor constraintEqualToAnchor:self.transparencyGainCardView.leadingAnchor constant:20],
        [self.transparencyGainSlider.trailingAnchor constraintEqualToAnchor:self.transparencyGainCardView.trailingAnchor constant:-20],
        [self.transparencyGainSlider.bottomAnchor constraintEqualToAnchor:self.transparencyGainCardView.bottomAnchor constant:-20]
    ]];
    
    [self.mainStackView addArrangedSubview:self.transparencyGainCardView];
}

- (void)setupFadeCard {
    self.fadeCardView = [self createCardView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.ANCFadeTitle", comment:@"ANC Fade");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.fadeCardView addSubview:titleLabel];
    
    // 描述标签
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = NSLocalizedString(@"LocKey.ANCFadeDescription", comment:@"Enable smooth transition between ANC modes");
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor systemGrayColor];
    descLabel.numberOfLines = 0;
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.fadeCardView addSubview:descLabel];
    
    // 开关
    self.fadeSwitch = [[UISwitch alloc] init];
    self.fadeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.fadeSwitch addTarget:self action:@selector(fadeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.fadeCardView addSubview:self.fadeSwitch];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.fadeCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.fadeCardView.leadingAnchor constant:20],
        
        [descLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
        [descLabel.leadingAnchor constraintEqualToAnchor:self.fadeCardView.leadingAnchor constant:20],
        [descLabel.trailingAnchor constraintEqualToAnchor:self.fadeSwitch.leadingAnchor constant:-20],
        [descLabel.bottomAnchor constraintEqualToAnchor:self.fadeCardView.bottomAnchor constant:-20],
        
        [self.fadeSwitch.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
        [self.fadeSwitch.trailingAnchor constraintEqualToAnchor:self.fadeCardView.trailingAnchor constant:-20]
    ]];
    
    [self.mainStackView addArrangedSubview:self.fadeCardView];
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

#pragma mark - Load Settings

- (void)loadANCSettings {
    if (!self.device) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
        [self setControlsEnabled:NO];
        return;
    }
    
    id<AIBudsDeviceANCAPI> ancDevice = (id<AIBudsDeviceANCAPI>)self.device;
    if ([ancDevice conformsToProtocol:@protocol(AIBudsDeviceANCAPI)]) {
        [self setControlsEnabled:YES];
        
        // 加载 ANC 模式
        AIBudsANCMode currentMode = ancDevice.ancMode;
        
        if(currentMode != AIBudsANCModeUnknown) {
            switch (currentMode) {
                case AIBudsANCModeNormal:
                    self.modeSegmentedControl.selectedSegmentIndex = 0;
                    break;
                case AIBudsANCModeAnc:
                    self.modeSegmentedControl.selectedSegmentIndex = 1;
                    break;
                case AIBudsANCModeTransparency:
                    self.modeSegmentedControl.selectedSegmentIndex = 2;
                    break;
                default:
                    self.modeSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
                    break;
            }
            
            // 加载 ANC 增益
            NSNumber *ancGain = ancDevice.ancGain;
            if (ancGain) {
                self.ancGainSlider.value = ancGain.intValue;
                self.ancGainValueLabel.text = [NSString stringWithFormat:@"%d", ancGain.intValue];
            }
            
            // 加载通透增益
            NSNumber *transparencyGain = ancDevice.transparencyGain;
            if (transparencyGain) {
                self.transparencyGainSlider.value = transparencyGain.intValue;
                self.transparencyGainValueLabel.text = [NSString stringWithFormat:@"%d", transparencyGain.intValue];
            }
            
            // 加载 ANC 淡入淡出状态
            self.fadeSwitch.on = ancDevice.isAncFadeOn;
            
            self.statusLabel.text = NSLocalizedString(@"LocKey.ANCSettingsLoaded", comment:@"ANC settings loaded");
        }
        else {
            self.statusLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportANC", comment:@"Device does not support ANC");
            [self setControlsEnabled:NO];
        }
    } else {
        self.statusLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportANC", comment:@"Device does not support ANC");
        [self setControlsEnabled:NO];
    }
}

- (void)setControlsEnabled:(BOOL)enabled {
    self.modeSegmentedControl.enabled = enabled;
    self.ancGainSlider.enabled = enabled;
    self.transparencyGainSlider.enabled = enabled;
    self.fadeSwitch.enabled = enabled;
}

#pragma mark - Actions

- (void)modeChanged:(UISegmentedControl *)sender {
    if (!self.device) return;
    
    id<AIBudsDeviceANCAPI> ancDevice = (id<AIBudsDeviceANCAPI>)self.device;
    if (![ancDevice conformsToProtocol:@protocol(AIBudsDeviceANCAPI)]) return;
    
    AIBudsANCMode mode;
    switch (sender.selectedSegmentIndex) {
        case 0:
            mode = AIBudsANCModeNormal;
            break;
        case 1:
            mode = AIBudsANCModeAnc;
            break;
        case 2:
            mode = AIBudsANCModeTransparency;
            break;
        default:
            return;
    }
    
    __weak typeof(self) weakSelf = self;
    [ancDevice setAncMode:mode completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.ANCModeSetSuccess", comment:@"ANC mode set successfully");
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.ANCModeSetFailed", comment:@"Failed to set ANC mode");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                // 恢复之前的选中状态
                [strongSelf loadANCSettings];
            }
        });
    }];
}

- (void)ancGainChanged:(UISlider *)sender {
    self.ancGainValueLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (void)ancGainChangeEnded:(UISlider *)sender {
    if (!self.device) return;
    
    id<AIBudsDeviceANCAPI> ancDevice = (id<AIBudsDeviceANCAPI>)self.device;
    if (![ancDevice conformsToProtocol:@protocol(AIBudsDeviceANCAPI)]) return;
    
    int gain = (int)sender.value;
    
    __weak typeof(self) weakSelf = self;
    [ancDevice setAncGain:gain completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.ANCGainSetSuccess", comment:@"ANC gain set successfully");
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.ANCGainSetFailed", comment:@"Failed to set ANC gain");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)transparencyGainChanged:(UISlider *)sender {
    self.transparencyGainValueLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (void)transparencyGainChangeEnded:(UISlider *)sender {
    if (!self.device) return;
    
    id<AIBudsDeviceANCAPI> ancDevice = (id<AIBudsDeviceANCAPI>)self.device;
    if (![ancDevice conformsToProtocol:@protocol(AIBudsDeviceANCAPI)]) return;
    
    int gain = (int)sender.value;
    
    __weak typeof(self) weakSelf = self;
    [ancDevice setTransparencyGain:gain completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.TransparencyGainSetSuccess", comment:@"Transparency gain set successfully");
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.TransparencyGainSetFailed", comment:@"Failed to set transparency gain");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            }
        });
    }];
}

- (void)fadeSwitchChanged:(UISwitch *)sender {
    if (!self.device) return;
    
    id<AIBudsDeviceANCAPI> ancDevice = (id<AIBudsDeviceANCAPI>)self.device;
    if (![ancDevice conformsToProtocol:@protocol(AIBudsDeviceANCAPI)]) return;
    
    __weak typeof(self) weakSelf = self;
    [ancDevice setAncFadeOn:sender.on completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (success) {
                strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.ANCFadeSetSuccess", comment:@"ANC fade setting updated");
            } else {
                strongSelf.statusLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.ANCFadeSetFailed", comment:@"Failed to update ANC fade setting");
                strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                strongSelf.fadeSwitch.on = !sender.on;
            }
        });
    }];
}

@end
